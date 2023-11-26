CREATE TABLE Materialy (
    id_materialu INTEGER PRIMARY KEY,
    nazwa_materialu VARCHAR2(30 CHAR) NOT NULL
);

CREATE TABLE Kategorie (
    id_kategorii INTEGER PRIMARY KEY,
    nazwa_kategorii VARCHAR2(30 CHAR)
);

CREATE TABLE Sposoby_Zaplaty (
    id_sposobu_zaplaty INTEGER PRIMARY KEY,
    sposob_zaplaty VARCHAR2(20 CHAR)
);

CREATE TABLE Zabawki (
    id_zabawki     INTEGER PRIMARY KEY,
    nazwa          VARCHAR2(60 CHAR) NOT NULL,
    cena           FLOAT,
    dostepna_ilosc INTEGER,
    id_kategorii   INTEGER NOT NULL,
    id_materialu   INTEGER NOT NULL,
    FOREIGN KEY (id_kategorii) REFERENCES Kategorie (id_kategorii),
    FOREIGN KEY (id_materialu) REFERENCES Materialy (id_materialu)
);

CREATE TABLE Adresy (
    id_adresu INTEGER PRIMARY KEY,
    kod_pocztowy VARCHAR2(30 CHAR) NOT NULL,
    wojewodztwo VARCHAR2(30 CHAR),
    powiat VARCHAR2(30 CHAR),
    miejscowosc VARCHAR2(30 CHAR),
    ulica VARCHAR2(30 CHAR)
);

CREATE TABLE Klienci (
    id_klienta INTEGER PRIMARY KEY,
    nazwa_firmy VARCHAR2(30 CHAR),
    imie VARCHAR2(20 CHAR),
    nazwisko VARCHAR2(30 CHAR),
    pesel INTEGER,
    id_adresu INTEGER NOT NULL,
    nr_ulicy VARCHAR2(30 CHAR),
    FOREIGN KEY (id_adresu) REFERENCES Adresy (id_adresu)
);

CREATE TABLE Zamowienia (
    id_zamowienia       INTEGER PRIMARY KEY,
    data_zamowienia     DATE NOT NULL,
    status_zamowienia   VARCHAR2(20 CHAR),
    id_klienta          INTEGER NOT NULL,
    id_sposobu_zaplaty  INTEGER NOT NULL,
    FOREIGN KEY (id_klienta) REFERENCES Klienci (id_klienta),
    FOREIGN KEY (id_sposobu_zaplaty) REFERENCES Sposoby_Zaplaty (id_sposobu_zaplaty)
);


CREATE TABLE Pozycje_Zamowienia (
    id_pozycji_zamowienia INTEGER PRIMARY KEY,
    id_zamowienia INTEGER NOT NULL,
    id_zabawki INTEGER NOT NULL,
    ilosc_sztuk INTEGER,
    FOREIGN KEY (id_zamowienia) REFERENCES Zamowienia (id_zamowienia),
    FOREIGN KEY (id_zabawki) REFERENCES Zabawki (id_zabawki)
);

CREATE TABLE Faktury_sprzedazy (
    nr_faktury INTEGER PRIMARY KEY,
    id_zamowienia INTEGER NOT NULL,
    data_wystawienia DATE,
    FOREIGN KEY (id_zamowienia) REFERENCES Zamowienia (id_zamowienia)
);

CREATE TABLE Pracownicy (
    id_pracownika INTEGER PRIMARY KEY,
    imie VARCHAR2(20 CHAR),
    nazwisko VARCHAR2(30 CHAR),
    nr_telefonu INTEGER,
    wynagrodzenie_podstawowe INTEGER,
    stanowisko VARCHAR2(30 CHAR),
    id_adresu INTEGER NOT NULL,
    nr_ulicy VARCHAR2(30 CHAR),
    FOREIGN KEY (id_adresu) REFERENCES Adresy (id_adresu)
);


CREATE TABLE Wpisy_Magazynowe (
    id_wpisu INTEGER PRIMARY KEY,
    data_wpisu DATE,
    ilosc_sztuk INTEGER,
    id_zabawki INTEGER NOT NULL,
    id_pracownika INTEGER NOT NULL,
    FOREIGN KEY (id_zabawki) REFERENCES Zabawki (id_zabawki),
    FOREIGN KEY (id_pracownika) REFERENCES Pracownicy (id_pracownika)
);



INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (1, 'Plastik');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (2, 'Drewno');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (3, 'Metal');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (4, 'Guma');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (5, 'Tkanina');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (6, 'Papier');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (7, 'Szkło');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (8, 'Gips');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (9, 'Metaloplastyka');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (10, 'Stal nierdzewna');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (11, 'Skóra');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (12, 'Bawełna');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (13, 'Silikon');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (14, 'Aluminium');
INSERT INTO Materialy (id_materialu, nazwa_materialu) VALUES (15, 'Karton');


INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (1, 'Edukacyjne');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (2, 'Dla niemowląt');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (3, 'Zręcznościowe');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (4, 'Kreatywne');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (5, 'Interaktywne');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (6, 'Sportowe');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (7, 'Planszowe');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (8, 'Maskotki');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (9, 'Klocki');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (10, 'Puzzle');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (11, 'Rękodzielnicze');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (12, 'Technologiczne');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (13, 'Artystyczne');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (14, 'Eksperymentalne');
INSERT INTO Kategorie (id_kategorii, nazwa_kategorii) VALUES (15, 'Ekonomiczne');


INSERT INTO Sposoby_Zaplaty (id_sposobu_zaplaty, sposob_zaplaty) VALUES (1, 'Karta kredytowa');
INSERT INTO Sposoby_Zaplaty (id_sposobu_zaplaty, sposob_zaplaty) VALUES (2, 'Gotowka');
INSERT INTO Sposoby_Zaplaty (id_sposobu_zaplaty, sposob_zaplaty) VALUES (3, 'Przelew');
INSERT INTO Sposoby_Zaplaty (id_sposobu_zaplaty, sposob_zaplaty) VALUES (4, 'Platnosc online');
INSERT INTO Sposoby_Zaplaty (id_sposobu_zaplaty, sposob_zaplaty) VALUES (5, 'Paypal');
INSERT INTO Sposoby_Zaplaty (id_sposobu_zaplaty, sposob_zaplaty) VALUES (6, 'Blik');


INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (1, 'Puzzle Edukacyjne', 19.99, 50, 1, 5);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (2, 'Lalka Malwina', 39.99, 30, 8, 12);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (3, 'Samochod zdalnie sterowany', 79.99, 20, 6, 4);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (4, 'Klocki drewniane', 29.99, 40, 9, 2);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (5, 'Gra planszowa "Zlap Muche"', 49.99, 25, 7, 3);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (6, 'Laptop edukacyjny', 89.99, 15, 1, 11);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (7, 'Ksiazka do kolorowania', 9.99, 100, 4, 6);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (8, 'Kosmiczna rakietka do gry', 14.99, 50, 5, 1);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (9, 'Układanka magnetyczna', 24.99, 35, 10, 14);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (10, 'Kreatywny zestaw artystyczny', 34.99, 25, 13, 7);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (11, 'Instrument Muzyczny dla Dzieci', 49.99, 20, 4, 11);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (12, 'Maskotka Pingwin', 29.99, 30, 8, 12);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (13, 'Samolot Zdalnie Sterowany', 69.99, 15, 6, 4);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (14, 'Klocki Magnetyczne', 39.99, 25, 9, 2);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (15, 'Gra Planszowa "Magiczny Labirynt"', 54.99, 20, 7, 3);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (16, 'Tablet Edukacyjny dla Dzieci', 99.99, 10, 1, 11);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (17, 'Ksiazka do Malowania Woda', 14.99, 80, 4, 6);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (18, 'Pilka do Skakania', 19.99, 40, 6, 4);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (19, 'Układanka Alfabetyczna', 29.99, 30, 10, 14);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (20, 'Kreatywny Zestaw Rekodzielniczy', 44.99, 20, 13, 7);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (21, 'Zestaw do Eksperymentów Chemicznych', 39.99, 15, 13, 14);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (22, 'Konsola Gry Edukacyjnej', 89.99, 10, 1, 11);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (23, 'Ksiazka Zabawkowa dla Malucha', 9.99, 120, 2, 6);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (24, 'Stacja Kreatywna dla Artysty', 59.99, 18, 4, 7);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (25, 'Samochod Wyscigowy na Pilot', 79.99, 12, 6, 4);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (26, 'Puzzle Krajobrazowe', 29.99, 22, 10, 5);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (27, 'Gra Planszowa "Zlodziej Skarbow"', 49.99, 18, 7, 3);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (28, 'Interaktywny Kubek z Melodia', 24.99, 35, 5, 1);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (29, 'Ksiazeczka Zabawkowa dla Niemowlaka', 14.99, 50, 2, 6);
INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu) VALUES (30, 'Zestaw Naukowy dla Mlodego Odkrywcy', 34.99, 25, 13, 14);


INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (1, '35-001', 'Podkarpackie', 'Rzeszow', 'Rzeszow', 'ul. 3 Maja');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (2, '35-234', 'Podkarpackie', 'rzeszowski', 'Boguchwala', 'ul. Jagiellońska');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (3, '35-567', 'Podkarpackie', 'Rzeszow', 'Rzeszow', 'ul. Podwislocze');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (4, '35-789', 'Podkarpackie', 'Rzeszow', 'Rzeszow', 'ul. Mickiewicza');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (5, '35-123', 'Podkarpackie', 'Rzeszow', 'Rzeszow', 'ul. Piłsudskiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (6, '35-456', 'Podkarpackie', 'Rzeszowski', 'Niechobrz', 'ul. Waska');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (7, '35-789', 'Podkarpackie', 'Strzyzowski', 'Strzyzow', 'ul. Piekna');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (8, '35-001', 'Podkarpackie', 'Rzeszow', 'Rzeszow', 'ul. Kosciuszki');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (9, '35-234', 'Podkarpackie', 'Rzeszow', 'Rzeszow', 'ul. Zamojska');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (10, '35-567', 'Podkarpackie', 'Strzyzowski', 'Nowa Wies', 'ul. Lubelska');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (11, '40-123', 'Małopolskie', 'Krakow', 'Krakow', 'ul. Florianska');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (12, '50-234', 'Dolnośląskie', 'Wroclaw', 'Wroclaw', 'ul. Swidnicka');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (13, '02-567', 'Podkarpackie', 'Rzeszow', 'Rzeszow', 'ul. Marszalkowska');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (14, '60-789', 'Podkarpackie', 'Lancucki', 'Lancut', 'ul. Stary Rynek');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (15, '80-001', 'Podkarpackie', 'Rzeszowski', 'Jasionka', 'ul. Dluga');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (16, '51-456', 'Podkarpackie', 'Rzeszowski', 'Wysoka Glogowska', 'ul. Rynek');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (17, '03-789', 'Mazowieckie', 'Warszawa', 'Warszawa', 'ul. Chmielna');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (18, '40-999', 'Podkarpackie', 'Jasielski', 'Jaslo', 'ul. Stawowa');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (19, '90-876', 'Podkarpackie', 'Krosnienski', 'Piotrowka', 'ul. Piotrkowska');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (20, '31-555', 'Podkarpackie', 'Leski', 'Lesko', 'ul. Leska');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (21, '38-200', 'Podkarpackie', 'Jasielski', 'Jaslo', 'ul. Mickiewicza');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (22, '38-210', 'Podkarpackie', 'Jasielski', 'Jaslo', 'ul. Slowackiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (23, '38-220', 'Podkarpackie', 'Jasielski', 'Jaslo', 'ul. Pilsudskiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (24, '38-230', 'Podkarpackie', 'Jasielski', 'Jaslo', 'ul. Dworcowa');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (25, '38-240', 'Podkarpackie', 'Jasielski', 'Jaslo', 'ul. Sobieskiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (26, '38-400', 'Podkarpackie', 'Krosnienski', 'Krosno', 'ul. Rynek');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (27, '38-410', 'Podkarpackie', 'Krosnienski', 'Krosno', 'ul. Pilksudskiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (28, '38-420', 'Podkarpackie', 'Krosnienski', 'Krosno', 'ul. Mickiewicza');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (29, '38-430', 'Podkarpackie', 'Krosnienski', 'Krosno', 'ul. Dworcowa');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (30, '38-440', 'Podkarpackie', 'Krosnienski', 'Krosno', 'ul. Slowackiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (31, '37-300', 'Podkarpackie', 'Lezajski', 'Lezajsk', 'ul. Rynek');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (32, '37-310', 'Podkarpackie', 'Lezajski', 'Lezajsk', 'ul. Pilsudskiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (33, '37-320', 'Podkarpackie', 'Lezajski', 'Lezajsk', 'ul. Mickiewicza');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (34, '37-330', 'Podkarpackie', 'Lezajski', 'Lezajsk', 'ul. Sobieskiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (35, '37-340', 'Podkarpackie', 'Lezajski', 'Lezajsk', 'ul. Dworcowa');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (36, '38-100', 'Podkarpackie', 'Strzyzowski', 'Strzyzów', 'ul. Rynek');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (37, '38-110', 'Podkarpackie', 'Strzyzowski', 'Strzyzów', 'ul. Pilsudskiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (38, '38-120', 'Podkarpackie', 'Strzyzowski', 'Strzyzów', 'ul. Mickiewicza');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (39, '38-130', 'Podkarpackie', 'Strzyzowski', 'Strzyzów', 'ul. Dworcowa');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (40, '38-140', 'Podkarpackie', 'Strzyzowski', 'Strzyzów', 'ul. Slowackiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (41, '35-100', 'Podkarpackie', 'Rzeszowski', 'Rzeszow', 'ul. Rynek');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (42, '35-110', 'Podkarpackie', 'Rzeszowski', 'Rzeszow', 'ul. Pilsudskiego');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (43, '35-120', 'Podkarpackie', 'Rzeszowski', 'Rzeszow', 'ul. Mickiewicza');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (44, '35-130', 'Podkarpackie', 'Rzeszowski', 'Rzeszow', 'ul. Dworcowa');
INSERT INTO Adresy (id_adresu, kod_pocztowy, wojewodztwo, powiat, miejscowosc, ulica) VALUES (45, '35-140', 'Podkarpackie', 'Rzeszowski', 'Rzeszow', 'ul. Slowackiego');


INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (1, 'Magiczne Zabawki', 'Anna', 'Nowak', 12345678901, 1, '2A');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (2, 'Kraina Zabaw', 'Piotr', 'Kowalski', 23456789012, 2, '5B');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (3, 'Skarby Dziecinstwa', 'Magdalena', 'Wisniewska', 34567890123, 3, '8C');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (4, 'Zabawkowy Raj', 'Marek', 'Lis', 45678901234, 4, '11D');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (5, 'Marzenia Dzieci', 'Katarzyna', 'Kwiatkowska', 56789012345, 5, '14E');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (6, 'Zabawkowe Cudo', 'Grzegorz', 'Nowicki', 67890123456, 6, '17F');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (7, 'Bajkowe Zabawki', 'Agnieszka', 'Pawlak', 78901234567, 7, '20G');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (8, 'Zabawkowy Swiat', 'Robert', 'Czarnecki', 89012345678, 8, '23H');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (9, 'Kolorowe Zabawki', 'Karolina', 'Jaworska', 90123456789, 9, '26I');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (10, 'Zabawkowy Skarbiec', 'Daniel', 'Szymanski', 10234567890, 10, '29J');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (11, 'Festiwal Zabawek', 'Dominika', 'Kaczmarek', 11234567891, 11, '32K');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (12, 'Zabawkowy Uśmiech', 'Mariusz', 'Piotrowski', 12234567892, 12, '35L');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (13, 'Krolestwo Zabawek', 'Oliwia', 'Zajac', 13234567893, 13, '38M');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (14, 'Zabawkowy Magazyn', 'Patryk', 'Kaminski', 14234567894, 14, '41N');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (15, 'Kraina Marzen', 'Anna', 'Lewandowska', 15234567895, 15, '44O');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (16, 'Zabawkowa Fantazja', 'Tomasz', 'Sawicki', 16234567896, 16, '47P');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (17, 'Kolorowy Swiat Zabawek', 'Natalia', 'Dabrowska', 17234567897, 17, '50Q');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (18, 'Zabawkowy Zaulek', 'Marcin', 'Zielinski', 18234567898, 18, '53R');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (19, 'Magiczny Sklepik', 'Monika', 'Wojcik', 19234567899, 19, '56S');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (20, 'Bajkowa Kraina', 'Kamil', 'Kubiak', 20234567001, 20, '59T');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (21, 'Zabawkowy Sen', 'Anna', 'Sokolowska', 21234567002, 21, '62U');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (22, 'Zabawkowe Przygody', 'Pawel', 'Kowalczyk', 22234567003, 22, '65V');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (23, 'Zabawkowe Spotkanie', 'Karolina', 'Michalak', 23234567004, 23, '68W');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (24, 'Zabawkowy Swiat Marzen', 'Rafal', 'Jankowski', 24234567005, 24, '71X');
INSERT INTO Klienci (id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy) VALUES (25, 'Zabawkowy Usmiech Dziecka', 'Dominika', 'Szczepańska', 25234567006, 25, '74Y');



INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (1, TO_DATE('2023-09-21', 'YYYY-MM-DD'), 'W trakcie', 1, 1);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (2, TO_DATE('2023-02-01', 'YYYY-MM-DD'), 'Zrealizowane', 2, 2);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (3, TO_DATE('2023-11-01', 'YYYY-MM-DD'), 'W trakcie', 3, 3);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (4, TO_DATE('2023-04-01', 'YYYY-MM-DD'), 'Anulowane', 4, 4);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (5, TO_DATE('2023-08-10', 'YYYY-MM-DD'), 'W trakcie', 5, 5);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (6, TO_DATE('2023-06-01', 'YYYY-MM-DD'), 'Zrealizowane', 6, 1);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (7, TO_DATE('2023-07-01', 'YYYY-MM-DD'), 'Anulowane', 7, 2);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (8, TO_DATE('2023-08-05', 'YYYY-MM-DD'), 'Zrealizowane', 8, 1);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (9, TO_DATE('2023-11-20', 'YYYY-MM-DD'), 'W trakcie', 9, 2);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (10, TO_DATE('2023-10-01', 'YYYY-MM-DD'), 'W trakcie', 10, 4);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (11, TO_DATE('2023-11-01', 'YYYY-MM-DD'), 'Anulowane', 11, 4);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (12, TO_DATE('2023-11-05', 'YYYY-MM-DD'), 'Zrealizowane', 12, 3);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (13, TO_DATE('2024-01-02', 'YYYY-MM-DD'), 'W trakcie', 13, 1);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (14, TO_DATE('2023-12-01', 'YYYY-MM-DD'), 'Zrealizowane', 14, 1);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (15, TO_DATE('2024-01-05', 'YYYY-MM-DD'), 'W trakcie', 15, 1);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (16, TO_DATE('2023-12-07', 'YYYY-MM-DD'), 'Zrealizowane', 16, 2);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (17, TO_DATE('2023-11-01', 'YYYY-MM-DD'), 'W trakcie', 17, 5);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (18, TO_DATE('2024-01-02', 'YYYY-MM-DD'), 'W trakcie', 18, 6);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (19, TO_DATE('2023-12-05', 'YYYY-MM-DD'), 'Zrealizowane', 19, 3);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (20, TO_DATE('2023-12-12', 'YYYY-MM-DD'), 'W trakcie', 20, 1);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (21, TO_DATE('2023-09-01', 'YYYY-MM-DD'), 'Anulowane', 21, 2);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (22, TO_DATE('2024-10-01', 'YYYY-MM-DD'), 'Zrealizowane', 22, 2);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (23, TO_DATE('2024-11-01', 'YYYY-MM-DD'), 'W trakcie', 23, 5);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (24, TO_DATE('2023-12-01', 'YYYY-MM-DD'), 'Anulowane', 24, 6);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (25, TO_DATE('2023-09-15', 'YYYY-MM-DD'), 'Zrealizowane', 25, 6);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (26, TO_DATE('2024-01-04', 'YYYY-MM-DD'), 'W trakcie', 1, 1);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (27, TO_DATE('2023-03-01', 'YYYY-MM-DD'), 'Zrealizowane', 2, 2);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (28, TO_DATE('2023-11-24', 'YYYY-MM-DD'), 'W trakcie', 3, 3);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (29, TO_DATE('2023-12-01', 'YYYY-MM-DD'), 'Zrealizowane', 4, 4);
INSERT INTO Zamowienia (id_zamowienia, data_zamowienia, status_zamowienia, id_klienta, id_sposobu_zaplaty) VALUES (30, TO_DATE('2023-12-06', 'YYYY-MM-DD'), 'W trakcie', 5, 5);


INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (1, 1, 1, 3);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (2, 1, 3, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (3, 1, 2, 1);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (4, 2, 5, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (5, 3, 4, 4);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (6, 3, 7, 1);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (7, 3, 6, 3);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (8, 4, 9, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (9, 5, 13, 1);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (10, 5, 16, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (11, 6, 20, 1);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (12, 6, 22, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (13, 7, 25, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (14, 7, 28, 1);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (15, 7, 3, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (16, 8, 6, 1);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (17, 8, 9, 3);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (18, 9, 12, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (19, 10, 15, 1);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (20, 10, 18, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (21, 11, 21, 3);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (22, 11, 24, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (23, 11, 27, 1);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (24, 12, 30, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (25, 13, 2, 3);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (26, 13, 5, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (27, 13, 8, 1);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (28, 14, 11, 2);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (29, 15, 14, 3);
INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk) VALUES (30, 15, 17, 2);


INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (1, 1, TO_DATE('2023-09-21', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (2, 2, TO_DATE('2023-02-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (3, 3, TO_DATE('2023-11-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (4, 4, TO_DATE('2023-04-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (5, 5, TO_DATE('2023-08-10', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (6, 6, TO_DATE('2023-06-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (7, 7, TO_DATE('2023-07-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (8, 8, TO_DATE('2023-08-05', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (9, 9, TO_DATE('2023-11-20', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (10, 10, TO_DATE('2023-10-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (11, 11, TO_DATE('2023-11-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (12, 12, TO_DATE('2023-11-05', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (13, 13, TO_DATE('2024-01-02', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (14, 14, TO_DATE('2023-12-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (15, 15, TO_DATE('2024-01-05', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (16, 16, TO_DATE('2023-12-07', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (17, 17, TO_DATE('2023-11-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (18, 18, TO_DATE('2024-01-02', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (19, 19, TO_DATE('2023-12-05', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (20, 20, TO_DATE('2023-12-12', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (21, 21, TO_DATE('2023-09-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (22, 22, TO_DATE('2024-10-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (23, 23, TO_DATE('2024-11-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (24, 24, TO_DATE('2023-12-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (25, 25, TO_DATE('2023-09-15', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (26, 26, TO_DATE('2024-01-04', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (27, 27, TO_DATE('2023-03-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (28, 28, TO_DATE('2023-11-24', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (29, 29, TO_DATE('2023-12-01', 'YYYY-MM-DD'));
INSERT INTO Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia) VALUES (30, 30, TO_DATE('2023-12-06', 'YYYY-MM-DD'));


INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (1, 'Anna', 'Kowalska', 123456789, 9000, 'Prezes', 26, '12A');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (2, 'Piotr', 'Nowak', 987654321, 5500, 'Kierownik działu marketingu', 27, '13B');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (3, 'Magdalena', 'Jankowska', 555666777, 4800, 'Magazynier', 28, '14C');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (4, 'Krzysztof', 'Wojcik', 333222111, 6000, 'Magazynier', 29, '15D');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (5, 'Monika', 'Lewandowska', 444555666, 5200, 'Specjalista ds. HR', 30, '16E');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (6, 'Michał', 'Wronski', 666555444, 5100, 'Analityk finansowy', 31, '17F');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (7, 'Karolina', 'Szymanska', 111222333, 5900, 'Kierownik działu logistyki', 32, '18G');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (8, 'Adam', 'Kaczmarek', 999888777, 4700, 'Kierowca', 33, '19H');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (9, 'Natalia', 'Dabrowska', 777888999, 5400, 'Specjalista ds. IT', 34, '20I');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (10, 'Kamil', 'Zielinski', 123789456, 6300, 'Asystent ds. sprzedazy', 35, '21J');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (11, 'Alicja', 'Pawlak', 987654321, 5200, 'Specjalista ds. marketingu', 36, '22K');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (12, 'Marcin', 'Olszewski', 333222111, 4800, 'Asystent ds. sprzedazy', 37, '23L');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (13, 'Oliwia', 'Kowalczyk', 444555666, 5900, 'Kierownik projektu', 38, '24M');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (14, 'Lukasz', 'Sikorski', 666555444, 5500, 'Specjalista ds. finansow', 39, '25N');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (15, 'Klaudia', 'Piotrowska', 111222333, 5100, 'Magazynier', 40, '26O');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (16, 'Tomasz', 'Wisniewski', 999888777, 6000, 'Magazynier', 41, '27P');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (17, 'Weronika', 'Jabłonska', 777888999, 7400, 'Wiceprezes', 42, '28R');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (18, 'Bartosz', 'Czarnecki', 123789456, 6300, 'Analityk biznesowy', 43, '29S');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (19, 'Aleksandra', 'Gorka', 987654321, 4700, 'Magazynier', 44, '30T');
INSERT INTO Pracownicy (id_pracownika, imie, nazwisko, nr_telefonu, wynagrodzenie_podstawowe, stanowisko, id_adresu, nr_ulicy) VALUES (20, 'Patryk', 'Nowicki', 333222111, 5200, 'Magazynier', 45, '31U');


INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (1, TO_DATE('2023-11-06', 'YYYY-MM-DD'), 10, 1, 3);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (2, TO_DATE('2023-10-06', 'YYYY-MM-DD'), 5, 2, 3);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (3, TO_DATE('2023-09-07', 'YYYY-MM-DD'), 8, 3, 15);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (4, TO_DATE('2023-10-07', 'YYYY-MM-DD'), 12, 4, 16);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (5, TO_DATE('2023-11-08', 'YYYY-MM-DD'), 6, 5, 15);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (6, TO_DATE('2023-08-08', 'YYYY-MM-DD'), 15, 6, 4);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (7, TO_DATE('2023-04-09', 'YYYY-MM-DD'), 20, 7, 4);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (8, TO_DATE('2023-07-09', 'YYYY-MM-DD'), 7, 8, 19);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (9, TO_DATE('2023-09-10', 'YYYY-MM-DD'), 10, 9, 20);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (10, TO_DATE('2023-07-10', 'YYYY-MM-DD'), 15, 10, 19);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (11, TO_DATE('2023-06-11', 'YYYY-MM-DD'), 8, 11, 15);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (12, TO_DATE('2023-08-11', 'YYYY-MM-DD'), 12, 12, 4);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (13, TO_DATE('2023-11-12', 'YYYY-MM-DD'), 18, 13, 3);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (14, TO_DATE('2023-10-12', 'YYYY-MM-DD'), 10, 14, 3);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (15, TO_DATE('2023-09-13', 'YYYY-MM-DD'), 6, 15, 19);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (16, TO_DATE('2023-10-13', 'YYYY-MM-DD'), 10, 16, 19);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (17, TO_DATE('2023-07-14', 'YYYY-MM-DD'), 15, 17, 16);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (18, TO_DATE('2023-05-14', 'YYYY-MM-DD'), 20, 18, 15);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (19, TO_DATE('2023-05-15', 'YYYY-MM-DD'), 12, 19, 16);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (20, TO_DATE('2023-06-15', 'YYYY-MM-DD'), 8, 20, 20);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (21, TO_DATE('2023-04-16', 'YYYY-MM-DD'), 14, 21, 3);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (22, TO_DATE('2023-05-16', 'YYYY-MM-DD'), 16, 22, 4);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (23, TO_DATE('2023-08-17', 'YYYY-MM-DD'), 20, 23, 15);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (24, TO_DATE('2023-10-17', 'YYYY-MM-DD'), 10, 24, 15);
INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika) VALUES (25, TO_DATE('2023-09-18', 'YYYY-MM-DD'), 8, 25, 16);





