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
    nazwa          VARCHAR2(30 CHAR) NOT NULL,
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
    ulica VARCHAR2(30 CHAR),
    nr_ulicy VARCHAR2(30 CHAR)
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
    cena_jednostkowa FLOAT,
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
