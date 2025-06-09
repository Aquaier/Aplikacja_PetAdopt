# PetAdopt 🐱🐶

## O Projekcie
PetAdopt to aplikacja mobilna ułatwiająca adopcję zwierząt. Łączy osoby chcące adoptować zwierzę ze schroniskami i prywatnymi właścicielami. Aplikacja umożliwia przeglądanie ogłoszeń, dodawanie zwierząt do ulubionych oraz bezpośredni kontakt z właścicielami.

### Główne Funkcje
- 🔍 Przeglądanie ogłoszeń o zwierzętach do adopcji
- ❤️ Zapisywanie ogłoszeń do ulubionych
- 💬 System wiadomości między użytkownikami
- 📝 Dodawanie i edycja ogłoszeń
- 🌙 Tryb ciemny/jasny
- 👤 Zarządzanie kontem użytkownika

## Technologie
- **Frontend**: Flutter/Dart
- **Backend**: Python (Flask)
- **Baza danych**: MySQL
- **API**: REST API

## Wymagania
### Backend (Python)
- Python 3.8+
- Flask
- MySQL
- Dodatkowe pakiety wymienione w `database/requirements.txt`

### Frontend (Flutter)
- Flutter SDK 3.0+
- Dart SDK 2.17+
- Android Studio / VS Code z pluginem Flutter
- Dodatkowe zależności wymienione w `petadoptapp/pubspec.yaml`

## Instalacja i Uruchomienie

### Backend
1. Utwórz bazę danych MySQL:
```sql
CREATE DATABASE petadopt;
```

2. Zaimportuj schemat i przykładowe dane:
```sql
mysql -u root -p petadopt < database/petadopt_baza_danych.sql
mysql -u root -p petadopt < database/testowe_dane.sql
```

3. Zainstaluj wymagane pakiety Python:
```powershell
cd database
pip install flask flask-cors mysql-connector-python bcrypt
```

4. Uruchom serwer:
```powershell
python petadopt_api.py
```

### Frontend
1. Przejdź do katalogu aplikacji:
```powershell
cd petadoptapp
```

2. Zainstaluj zależności:
```powershell
flutter pub get
```

3. Uruchom aplikację:
```powershell
flutter run
```

## Struktura Projektu
```
petadoptapp/         # Aplikacja Flutter
├── lib/            # Kod źródłowy Dart
│   ├── main.dart   # Punkt wejścia aplikacji
│   └── ...        # Pozostałe pliki komponentów
└── pubspec.yaml    # Konfiguracja projektu Flutter

database/           # Backend Python
├── petadopt_api.py          # Serwer Flask
├── petadopt_baza_danych.sql # Schema bazy danych
└── testowe_dane.sql         # Przykładowe dane
```

## Konfiguracja
- Backend: Skonfiguruj połączenie z bazą danych w `database/petadopt_api.py`
- Frontend: Ustaw adres API w `petadoptapp/lib/main.dart`

## Współtwórcy
- [Eryk Majcherczak, Michał Kuźnicki]
