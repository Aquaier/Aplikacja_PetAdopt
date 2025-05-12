CREATE TABLE uzytkownicy (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    haslo_hash VARCHAR(255) NOT NULL,
    imie VARCHAR(100),
    czy_schronisko BOOLEAN NOT NULL,
    utworzono DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE profile_schronisk (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uzytkownik_id INT NOT NULL,
    nazwa_schroniska VARCHAR(255),
    adres VARCHAR(255),
    wojewodztwo VARCHAR(100),
    telefon VARCHAR(20),
    FOREIGN KEY (uzytkownik_id) REFERENCES uzytkownicy(id) ON DELETE CASCADE
);

CREATE TABLE profile_prywatne (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uzytkownik_id INT NOT NULL,
    miasto VARCHAR(100),
    wojewodztwo VARCHAR(100),
    telefon VARCHAR(20),
    FOREIGN KEY (uzytkownik_id) REFERENCES uzytkownicy(id) ON DELETE CASCADE
);

CREATE TABLE zwierzeta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uzytkownik_id INT NOT NULL,
    gatunek ENUM('pies', 'kot') NOT NULL,
    rasa VARCHAR(100),
    tytul VARCHAR(255),
    imie VARCHAR(100),
    wiek INT,
    waga FLOAT,
    opis TEXT,
    zdjecie_url VARCHAR(255),
    status ENUM('aktywny', 'zarezerwowany', 'adoptowany') DEFAULT 'aktywny',
    liczba_wyswietlen INT DEFAULT 0,
    utworzono DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uzytkownik_id) REFERENCES uzytkownicy(id) ON DELETE CASCADE
);

CREATE TABLE rozmowy (
    id INT AUTO_INCREMENT PRIMARY KEY,
    zwierze_id INT NOT NULL,
    uzytkownik1_id INT NOT NULL,
    uzytkownik2_id INT NOT NULL,
    utworzono DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (zwierze_id) REFERENCES zwierzeta(id) ON DELETE CASCADE,
    FOREIGN KEY (uzytkownik1_id) REFERENCES uzytkownicy(id) ON DELETE CASCADE,
    FOREIGN KEY (uzytkownik2_id) REFERENCES uzytkownicy(id) ON DELETE CASCADE
);

CREATE TABLE wiadomosci (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rozmowa_id INT NOT NULL,
    nadawca_id INT NOT NULL,
    tresc TEXT NOT NULL,
    czas_wyslania DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rozmowa_id) REFERENCES rozmowy(id) ON DELETE CASCADE,
    FOREIGN KEY (nadawca_id) REFERENCES uzytkownicy(id) ON DELETE CASCADE
);
