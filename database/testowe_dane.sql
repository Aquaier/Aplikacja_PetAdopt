INSERT INTO uzytkownicy (email, haslo_hash, imie, czy_schronisko) VALUES
('schroniskokrakow@gmail.com', '1234', 'Schronisko Kraków', TRUE),
('schroniskopoznan@gmail.com', '1234', 'Schronisko Poznań', TRUE),
('schroniskogdansk@gmail.com', '1234', 'Schronisko Gdańsk', TRUE),
('schroniskowroclaw@gmail.com', '1234', 'Schronisko Wrocław', TRUE),
('schroniskolodz@gmail.com', '1234', 'Schronisko Łódź', TRUE),
('ania.kowalska@gmail.com', '1234', 'Ania', FALSE),
('jan.nowak@gmail.com', '1234', 'Jan', FALSE),
('ewa.zielinska@gmail.com', '1234', 'Ewa', FALSE),
('marek.maj@gmail.com', '1234', 'Marek', FALSE),
('katarzyna.wojak@gmail.com', '1234', 'Katarzyna', FALSE);

INSERT INTO profile_schronisk (uzytkownik_id, nazwa_schroniska, adres, wojewodztwo, telefon) VALUES
(1, 'Schronisko Kraków', 'ul. Psia 12, Kraków', 'Małopolskie', '123456789'),
(2, 'Schronisko Poznań', 'ul. Kocia 7, Poznań', 'Wielkopolskie', '987654321'),
(3, 'Schronisko Gdańsk', 'ul. Zwierzęca 5, Gdańsk', 'Pomorskie', '111222333'),
(4, 'Schronisko Wrocław', 'ul. Adopcyjna 4, Wrocław', 'Dolnośląskie', '444555666'),
(5, 'Schronisko Łódź', 'ul. Przytulna 9, Łódź', 'Łódzkie', '777888999');

INSERT INTO profile_prywatne (uzytkownik_id, miasto, wojewodztwo, telefon) VALUES
(6, 'Kraków', 'Małopolskie', '500600700'),
(7, 'Poznań', 'Wielkopolskie', '501601701'),
(8, 'Gdańsk', 'Pomorskie', '502602702'),
(9, 'Wrocław', 'Dolnośląskie', '503603703'),
(10, 'Łódź', 'Łódzkie', '504604704');

INSERT INTO zwierzeta (uzytkownik_id, gatunek, rasa, tytul, imie, wiek, waga, opis, zdjecie_url) VALUES
(1, 'pies', 'Labrador', 'Wesoły Labrador do adopcji', 'Max', 3, 25.5, 'Przyjazny i energiczny pies.', 'https://example.com/zdjecia/max.jpg'),
(2, 'kot', 'Europejski', 'Cichy kotek do adopcji', 'Mia', 2, 4.2, 'Lubi się przytulać i spać.', 'https://example.com/zdjecia/mia.jpg'),
(6, 'pies', 'Owczarek niemiecki', 'Pies rodzinny szuka domu', 'Reks', 5, 30.0, 'Zna komendy, idealny do domu z ogrodem.', 'https://example.com/zdjecia/reks.jpg'),
(7, 'kot', 'Maine Coon', 'Duży kot szuka właściciela', 'Luna', 4, 6.5, 'Spokojna, ale nie lubi hałasu.', 'https://example.com/zdjecia/luna.jpg'),
(3, 'pies', 'Beagle', 'Beagle szuka kochającej rodziny', 'Fado', 2, 12.3, 'Wesoły i energiczny.', 'https://example.com/zdjecia/fado.jpg'),
(4, 'kot', 'Syjamski', 'Piękna kotka szuka domu', 'Sisi', 1, 3.8, 'Bardzo kontaktowa i towarzyska.', 'https://example.com/zdjecia/sisi.jpg'),
(5, 'pies', 'Buldog', 'Zabawny buldog gotowy na adopcję', 'Brutus', 6, 20.0, 'Uwielbia dzieci.', 'https://example.com/zdjecia/brutus.jpg'),
(8, 'kot', 'Perski', 'Puszysty pers czeka na dom', 'Mruczek', 3, 5.5, 'Bardzo spokojny kot.', 'https://example.com/zdjecia/mruczek.jpg'),
(9, 'pies', 'Golden Retriever', 'Złoty przyjaciel do adopcji', 'Sunny', 4, 28.0, 'Lubi spacery i zabawy.', 'https://example.com/zdjecia/sunny.jpg'),
(10, 'kot', 'Brytyjski', 'Kotek z charakterem', 'Oscar', 2, 4.7, 'Lubi samotność i ciszę.', 'https://example.com/zdjecia/oscar.jpg'),
(1, 'pies', 'Husky', 'Energiczny husky potrzebuje przestrzeni', 'Thor', 3, 23.0, 'Idealny dla aktywnych.', 'https://example.com/zdjecia/thor.jpg'),
(2, 'kot', 'Ragdoll', 'Miły kotek do adopcji', 'Bella', 2, 4.9, 'Cichy, ale uwielbia zabawę.', 'https://example.com/zdjecia/bella.jpg'),
(3, 'pies', 'Mieszaniec', 'Adoptuj przyjaciela', 'Burek', 7, 18.5, 'Lojalny i czuły.', 'https://example.com/zdjecia/burek.jpg'),
(4, 'kot', 'Sfinks', 'Kot bez sierści', 'Neo', 1, 3.0, 'Nie lubi zimna, ale lubi ludzi.', 'https://example.com/zdjecia/neo.jpg'),
(5, 'pies', 'Pudel', 'Inteligentny piesek szuka opiekuna', 'Karo', 5, 10.5, 'Szybko się uczy.', 'https://example.com/zdjecia/karo.jpg');

INSERT INTO rozmowy (zwierze_id, uzytkownik1_id, uzytkownik2_id) VALUES
(1, 6, 1);

INSERT INTO wiadomosci (rozmowa_id, nadawca_id, tresc) VALUES
(1, 6, 'Dzień dobry, czy Max nadal jest dostępny do adopcji?'),
(1, 1, 'Tak, Max wciąż czeka na dom. Chętnie odpowiemy na pytania.');
