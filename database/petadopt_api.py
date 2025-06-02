from flask import Flask, request, jsonify, send_from_directory
import mysql.connector
from flask_cors import CORS
import bcrypt
from flask import session
import re
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import random
import string
import os

app = Flask(__name__)
CORS(app)
app.secret_key = 'super_secret_key'  

conn = mysql.connector.connect(
    host='localhost',  
    user='root',
    password='16213303',
    database='petadopt'
)

@app.route('/')
def home():
    return jsonify({'message': 'Welcome to the PetAdopt API!'})

# Funkcja pomocnicza do haszowania hasła
def hash_password(password):
    return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

# Funkcja pomocnicza do sprawdzania hasła
def check_password(password, hashed):
    return bcrypt.checkpw(password.encode('utf-8'), hashed.encode('utf-8'))

# Funkcja do walidacji emaila
EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

def is_valid_email(email):
    return EMAIL_REGEX.match(email) is not None

# Funkcja do walidacji siły hasła (min. 6 znaków, litera i cyfra)
def is_strong_password(password):
    if len(password) < 6:
        return False
    if not re.search(r"[A-Za-z]", password):
        return False
    if not re.search(r"[0-9]", password):
        return False
    return True

def generate_random_password(length=10):
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(length))


def send_reset_email(recipient_email, new_password):
    smtp_servers = [
        {
            'host': 'smtp.gmail.com',
            'port': 587,
            'user': 'apppetadopt@gmail.com',
            'password': 'PetAdopt2025!',
        },
    ]
    subject = 'Reset hasła - PetAdopt'
    body = f'Twoje nowe hasło do konta PetAdopt: {new_password}\nZaloguj się i zmień hasło w ustawieniach.'
    for smtp in smtp_servers:
        try:
            msg = MIMEMultipart()
            msg['From'] = smtp['user']
            msg['To'] = recipient_email
            msg['Subject'] = subject
            msg.attach(MIMEText(body, 'plain'))
            server = smtplib.SMTP(smtp['host'], smtp['port'])
            server.starttls()
            server.login(smtp['user'], smtp['password'])
            server.sendmail(smtp['user'], recipient_email, msg.as_string())
            server.quit()
            return True
        except Exception as e:
            continue
    return False

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'success': False, 'message': 'Wprowadź e-mail i hasło'}), 400

    cursor = conn.cursor(dictionary=True)
    cursor.execute('SELECT * FROM uzytkownicy WHERE email=%s', (email,))
    user = cursor.fetchone()
    cursor.close()

    if not user or not user.get('haslo_hash'):
        return jsonify({'success': False, 'message': 'Nieprawidłowy email lub hasło'}), 401

    if not check_password(password, user['haslo_hash']):
        return jsonify({'success': False, 'message': 'Nieprawidłowy email lub hasło'}), 401

    session['user_id'] = user['id']
    session['email'] = user['email']
    return jsonify({'success': True, 'user': {'id': user['id'], 'email': user['email'], 'czy_schronisko': user['czy_schronisko']}})


@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    if not is_valid_email(email):
        return jsonify({'success': False, 'message': 'Niepoprawny adres e-mail. E-mail musi zawierać znak "@" i być poprawny.'}), 400
    if not is_strong_password(password):
        return jsonify({'success': False, 'message': 'Hasło musi mieć min. 6 znaków, zawierać literę i cyfrę.'}), 400
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM uzytkownicy WHERE email=%s', (email,))
    if cursor.fetchone():
        cursor.close()
        return jsonify({'success': False, 'message': 'Email już istnieje'}), 409
    hashed = hash_password(password)
    cursor.execute('INSERT INTO uzytkownicy (email, haslo_hash, czy_schronisko) VALUES (%s, %s, %s)', (email, hashed, False))
    conn.commit()
    cursor.close()
    return jsonify({'success': True})

@app.route('/logout', methods=['POST'])
def logout():
    session.clear()
    return jsonify({'success': True, 'message': 'Wylogowano'})

@app.route('/test-db', methods=['GET'])
def test_db():
    try:
        cursor = conn.cursor()
        cursor.execute('SELECT 1')
        cursor.fetchall()
        cursor.close()
        return jsonify({'success': True, 'message': 'Połączenie z bazą danych działa.'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/forgot-password', methods=['POST'])
def forgot_password():
    data = request.get_json()
    email = data.get('email')
    if not is_valid_email(email):
        return jsonify({'success': False, 'message': 'Niepoprawny adres e-mail.'}), 400
    cursor = conn.cursor(dictionary=True)
    cursor.execute('SELECT * FROM uzytkownicy WHERE email=%s', (email,))
    user = cursor.fetchone()
    if not user:
        cursor.close()
        return jsonify({'success': False, 'message': 'Nie znaleziono użytkownika o podanym adresie e-mail.'}), 404
    new_password = generate_random_password()
    hashed = hash_password(new_password)
    cursor.execute('UPDATE uzytkownicy SET haslo_hash=%s WHERE email=%s', (hashed, email))
    conn.commit()
    cursor.close()
    if send_reset_email(email, new_password):
        return jsonify({'success': True, 'message': 'Nowe hasło zostało wysłane na Twój e-mail.'})
    else:
        return jsonify({'success': False, 'message': 'Nie udało się wysłać e-maila. Skontaktuj się z administratorem.'}), 500

@app.route('/animals', methods=['GET'])
def get_animals():
    cursor = conn.cursor(dictionary=True)
    cursor.execute('SELECT id, gatunek, rasa, tytul, imie, wiek, waga, opis, zdjecie_url FROM zwierzeta')
    animals = cursor.fetchall()
    print(animals)
    cursor.close()
    import random
    random.shuffle(animals)
    for animal in animals:
        if animal['zdjecie_url']:
            filename = os.path.basename(animal['zdjecie_url'])
            animal['zdjecie_url'] = f'http://192.168.0.103:5000/images/{filename}'
    return jsonify({'success': True, 'animals': animals})

@app.route('/images/<filename>')
def serve_image(filename):
    images_dir = os.path.join(os.path.dirname(__file__), 'images')
    response = send_from_directory(images_dir, filename)
    # Dodaj nagłówek CORS dla obrazów
    response.headers['Access-Control-Allow-Origin'] = '*'
    return response
    
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)

