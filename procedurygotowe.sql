--ZAMOWIENIA
CREATE
OR REPLACE PROCEDURE ZmienStatusZamowienia(
    p_id_zamowienia INTEGER,
    p_nowy_status VARCHAR2
) AS v_obecny_status VARCHAR2(20);

-- Definicja kursora 
CURSOR c_zabawki IS
SELECT
    PZ.id_zabawki,
    PZ.ilosc_sztuk,
    Z.id_klienta
FROM
    Pozycje_Zamowienia PZ
    JOIN Zamowienia Z ON PZ.id_zamowienia = Z.id_zamowienia
WHERE
    PZ.id_zamowienia = p_id_zamowienia;

-- Zmienne do przechowywania danych z kursora 
v_zabawka_id INTEGER;

v_ilosc_sztuk INTEGER;

v_id_klienta INTEGER;

v_dostepna_ilosc INTEGER;

v_ilosc_zamowiona_przez_klienta INTEGER;

BEGIN -- Sprawdzenie, czy zamówienie istnieje 
SELECT
    status_zamowienia INTO v_obecny_status
FROM
    Zamowienia
WHERE
    id_zamowienia = p_id_zamowienia;

-- Sprawdzenie, czy podany status jest poprawny 
IF p_nowy_status NOT IN ('W trakcie', 'Zrealizowane', 'Anulowane') THEN DBMS_OUTPUT.PUT_LINE('Błąd: Niepoprawny status zamówienia.');

RETURN;

END IF;

-- Sprawdzenie, czy nowy status różni się od obecnego 
IF p_nowy_status = v_obecny_status THEN DBMS_OUTPUT.PUT_LINE('Błąd: Nowy status jest taki sam jak obecny.');

RETURN;

END IF;

-- Zmiana statusu zamówienia 
UPDATE
    Zamowienia
SET
    status_zamowienia = p_nowy_status
WHERE
    id_zamowienia = p_id_zamowienia;

-- Otwarcie kursora 
OPEN c_zabawki;

-- Pętla FETCH dla kursora 
LOOP FETCH c_zabawki INTO v_zabawka_id,
v_ilosc_sztuk,
v_id_klienta;

EXIT
WHEN c_zabawki % NOTFOUND;

SELECT
    dostepna_ilosc INTO v_dostepna_ilosc
FROM
    Zabawki
WHERE
    id_zabawki = v_zabawka_id;

SELECT
    SUM(PZ.ilosc_sztuk) INTO v_ilosc_zamowiona_przez_klienta
FROM
    Pozycje_Zamowienia PZ
    JOIN Zamowienia Z ON PZ.id_zamowienia = Z.id_zamowienia
WHERE
    Z.id_klienta = v_id_klienta;

-- Usuniecie zabawek przypadku zmiany z na "Zrealizowane" lub "W trakcie" 
IF v_obecny_status = 'Anulowane'
AND (
    p_nowy_status = 'W trakcie'
    OR p_nowy_status = 'Zrealizowane'
) THEN IF(v_dostepna_ilosc - v_ilosc_sztuk < 0) THEN DBMS_OUTPUT.PUT_LINE(
    'Niewystarczajaca ilosc zabawek na przeprowadzenie takiej 
operacji.'
);

RETURN;

END IF;

UPDATE
    Zabawki
SET
    dostepna_ilosc = dostepna_ilosc - v_ilosc_sztuk
WHERE
    id_zabawki = v_zabawka_id;

-- Sprawdzenie czy ilość kupionych zabawek przez klienta przekroczyła 100 
IF (
    (v_ilosc_zamowiona_przez_klienta + v_ilosc_sztuk) > 100
) THEN -- Zmiana klienta na stałego 
UPDATE
    Klienci
SET
    staly_klient = 1
WHERE
    id_klienta = v_id_klienta;

DBMS_OUTPUT.PUT_LINE(
    'Zmieniono klienta o ID ' || v_id_klienta || ' na 
klienta stalego.'
);

END IF;

DBMS_OUTPUT.PUT_LINE(
    'Zamówienie o ID ' || p_id_zamowienia || ' zostało 
zrealizowane, zabawki usuniete z magazynu.'
);

END IF;

-- Przywrocenie zabawek do magazynu w przypadku zmiany na "Anulowane" 
IF (
    v_obecny_status = 'Zrealizowane'
    OR v_obecny_status = 'W trakcie'
)
AND p_nowy_status = 'Anulowane' THEN
UPDATE
    Zabawki
SET
    dostepna_ilosc = dostepna_ilosc + v_ilosc_sztuk
WHERE
    id_zabawki = v_zabawka_id;

-- Sprawdzenie czy ilość kupionych zabawek przez klienta nie spadła poniżej 100 
IF (
    (v_ilosc_zamowiona_przez_klienta - v_ilosc_sztuk) < 100
) THEN -- Zmiana klienta na niestałego 
UPDATE
    Klienci
SET
    staly_klient = 0
WHERE
    id_klienta = v_id_klienta;

DBMS_OUTPUT.PUT_LINE(
    'Zmieniono klienta o ID ' || v_id_klienta || ' na 
klienta niestalego.'
);

END IF;

DBMS_OUTPUT.PUT_LINE(
    'Zamówienie o ID ' || p_id_zamowienia || ' zostało 
anulowane, zabawki przywrocone do magazynu.'
);

END IF;

END LOOP;

CLOSE c_zabawki;

DBMS_OUTPUT.PUT_LINE(
    'Status zamówienia o ID ' || p_id_zamowienia || ' został 
zmieniony na: ' || p_nowy_status
);

COMMIT;

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(
    'Błąd: Zamówienie o ID ' || p_id_zamowienia || ' nie 
istnieje.'
);

WHEN OTHERS THEN ROLLBACK;

DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);

END ZmienStatusZamowienia;

---------------------------------------------------------------------------------------------
CREATE TYPE ZabawkiCollection AS TABLE OF INTEGER;

CREATE TYPE IlosciZabawekCollection AS TABLE OF INTEGER;

CREATE
OR REPLACE PROCEDURE RealizujZamowienie(
    p_id_klienta INTEGER,
    p_data_zamowienia DATE,
    p_id_sposobu_zaplaty INTEGER,
    p_produkty_tab IN ZabawkiCollection,
    p_ilosci_tab IN IlosciZabawekCollection
) AS v_id_zamowienia INTEGER;

v_id_pozycji_zamowienia INTEGER;

v_liczba_zamowionych_zabawek INTEGER := 0;

BEGIN -- Sprawdź, czy ilości i produkty mają taką samą długość
IF p_produkty_tab.COUNT <> p_ilosci_tab.COUNT THEN DBMS_OUTPUT.PUT_LINE(
    'Błąd: Kolekcje p_produkty_tab i p_ilosci_tab muszą mieć tę samą 
długość.'
);

RETURN;

END IF;

-- Znajdź pierwszy dostępny identyfikator zamówienia
SELECT
    COALESCE(MAX(id_zamowienia) + 1, 1) INTO v_id_zamowienia
FROM
    Zamowienia;

-- Znajdź pierwszy dostępny identyfikator pozycji zamówienia
SELECT
    COALESCE(MAX(id_pozycji_zamowienia) + 1, 1) INTO v_id_pozycji_zamowienia
FROM
    Pozycje_Zamowienia;

-- Rozpocznij transakcję
BEGIN -- Wstaw dane zamówienia do tabeli Zamowienia
INSERT INTO
    Zamowienia (
        id_zamowienia,
        id_klienta,
        data_zamowienia,
        status_zamowienia,
        id_sposobu_zaplaty
    )
VALUES
    (
        v_id_zamowienia,
        p_id_klienta,
        p_data_zamowienia,
        'W trakcie',
        p_id_sposobu_zaplaty
    );

-- Wstaw produkty do tabeli Pozycje_Zamowienia
FOR i IN 1..p_produkty_tab.COUNT LOOP -- Sprawdź dostępność zabawek
DECLARE v_dostepna_ilosc INTEGER;

BEGIN
SELECT
    dostepna_ilosc INTO v_dostepna_ilosc
FROM
    Zabawki
WHERE
    id_zabawki = p_produkty_tab(i);

IF v_dostepna_ilosc < p_ilosci_tab(i) THEN RAISE_APPLICATION_ERROR(
    -20001,
    'Błąd: Brak wystarczającej ilości zabawek o ID ' || p_produkty_tab(i)
);

END IF;

-- Odejmij zamówione ilości od dostępnych zabawek
UPDATE
    Zabawki
SET
    dostepna_ilosc = dostepna_ilosc - p_ilosci_tab(i)
WHERE
    id_zabawki = p_produkty_tab(i);

-- Zlicz zamówione ilości
v_liczba_zamowionych_zabawek := v_liczba_zamowionych_zabawek + p_ilosci_tab(i);

EXCEPTION
WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(
    -20002,
    'Błąd: Zabawka o ID ' || p_produkty_tab(i) || ' nie 
istnieje.'
);

END;

-- Wstaw pozycję zamówienia
INSERT INTO
    Pozycje_Zamowienia (
        id_pozycji_zamowienia,
        id_zamowienia,
        id_zabawki,
        ilosc_sztuk
    )
VALUES
    (
        v_id_pozycji_zamowienia,
        v_id_zamowienia,
        p_produkty_tab(i),
        p_ilosci_tab(i)
    );

v_id_pozycji_zamowienia := v_id_pozycji_zamowienia + 1;

END LOOP;

-- Zakończ transakcję
COMMIT;

-- Sprawdzenie, czy liczba zamówionych zabawek przekracza 100
IF v_liczba_zamowionych_zabawek > 100 THEN -- Zmiana klienta na stałego
UPDATE
    Klienci
SET
    staly_klient = 1
WHERE
    id_klienta = p_id_klienta;

DBMS_OUTPUT.PUT_LINE(
    'Klient o ID ' || p_id_klienta || ' został zmieniony na stałego 
klienta.'
);

END IF;

-----------------------------------------------------------------------------------------------
CREATE
OR REPLACE PROCEDURE ZmienDaneKlienta(
    p_id_klienta INTEGER,
    p_nowa_nazwa_firmy VARCHAR2,
    p_nowe_imie VARCHAR2,
    p_nowe_nazwisko VARCHAR2,
    p_nowy_pesel VARCHAR2,
    p_nowe_id_adresu INTEGER,
    p_nowy_nr_ulicy VARCHAR2
) AS CURSOR klient_cursor IS
SELECT
    id_klienta,
    nazwa_firmy,
    imie,
    nazwisko,
    pesel,
    id_adresu,
    nr_ulicy
FROM
    Klienci
WHERE
    id_klienta = p_id_klienta;

v_id_klienta INTEGER;

v_stara_nazwa_firmy VARCHAR2(100);

v_stare_imie VARCHAR2(50);

v_stare_nazwisko VARCHAR2(50);

v_stary_pesel VARCHAR2(11);

v_stare_id_adresu INTEGER;

v_stary_nr_ulicy VARCHAR2(20);

BEGIN OPEN klient_cursor;

FETCH klient_cursor INTO v_id_klienta,
v_stara_nazwa_firmy,
v_stare_imie,
v_stare_nazwisko,
v_stary_pesel,
v_stare_id_adresu,
v_stary_nr_ulicy;

CLOSE klient_cursor;

IF v_id_klienta IS NOT NULL THEN BEGIN
SELECT
    id_klienta INTO v_id_klienta
FROM
    Klienci
WHERE
    id_klienta = p_id_klienta;

EXCEPTION
WHEN NO_DATA_FOUND THEN NULL;

END;

UPDATE
    Klienci
SET
    nazwa_firmy = p_nowa_nazwa_firmy,
    imie = p_nowe_imie,
    nazwisko = p_nowe_nazwisko,
    pesel = p_nowy_pesel,
    id_adresu = p_nowe_id_adresu,
    nr_ulicy = p_nowy_nr_ulicy
WHERE
    id_klienta = p_id_klienta;

COMMIT;

DBMS_OUTPUT.PUT_LINE('Zmieniono dane klienta o ID ' || p_id_klienta);

ELSE DBMS_OUTPUT.PUT_LINE('Nie znaleziono klienta o ID ' || p_id_klienta);

END IF;

EXCEPTION
WHEN OTHERS THEN ROLLBACK;

DBMS_OUTPUT.PUT_LINE(
    'Wystąpił błąd podczas zmiany danych klienta: ' || SQLERRM
);

END ZmienDaneKlienta;

/ -------------------------------------------------------------------------------------------
CREATE
OR REPLACE PROCEDURE Dodaj_Fakture_Sprzedazy (p_id_zamowienia INTEGER) AS v_nr_faktury INTEGER;

v_data_wystawienia DATE := SYSDATE;

BEGIN
SELECT
    COALESCE(MAX(nr_faktury) + 1, 1) INTO v_nr_faktury
FROM
    Faktury_sprzedazy;

INSERT INTO
    Faktury_sprzedazy (nr_faktury, id_zamowienia, data_wystawienia)
VALUES
    (
        v_nr_faktury,
        p_id_zamowienia,
        v_data_wystawienia
    );

COMMIT;

DBMS_OUTPUT.PUT_LINE(
    'Faktura sprzedaży o numerze ' || v_nr_faktury || ' została 
dodana.'
);

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE(
    'Brak danych dla zamówienia o ID ' || p_id_zamowienia
);

ROLLBACK;

WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);

ROLLBACK;

END Dodaj_Fakture_Sprzedazy;

/ --------------------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION GenerujFaktureSprzedazy(nr_faktury_p IN INTEGER) RETURN VARCHAR2 IS v_numer_faktury INTEGER;

v_nazwy_zabawek VARCHAR2(4000);

v_kwota NUMBER := 0;

CURSOR c_pozycje_zamowienia IS
SELECT
    Z.nazwa,
    P.ilosc_sztuk,
    Z.cena
FROM
    Pozycje_Zamowienia P
    JOIN Zabawki Z ON P.id_zabawki = Z.id_zabawki
WHERE
    P.id_zamowienia = v_numer_faktury;

BEGIN
SELECT
    id_zamowienia INTO v_numer_faktury
FROM
    Faktury_sprzedazy
WHERE
    nr_faktury = nr_faktury_p;

v_nazwy_zabawek := '';

FOR rec IN c_pozycje_zamowienia LOOP v_nazwy_zabawek := v_nazwy_zabawek || rec.nazwa || ', ';

v_kwota := v_kwota + (rec.cena * rec.ilosc_sztuk);

END LOOP;

RETURN 'Numer faktury: ' || nr_faktury_p || CHR(10) || 'Zabawki: ' || v_nazwy_zabawek || CHR(10) || 'Kwota zamówienia: ' || TO_CHAR(v_kwota, '99999.99');

END;

/ --------------------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION Raport_Zamowien_Biezacy_Rok RETURN INTEGER IS v_ilosc INTEGER := 0;

CURSOR zamowienia_cursor IS
SELECT
    K.nazwa_firmy,
    Z.data_zamowienia,
    D.nazwa AS nazwa_zabawki,
    D.cena
FROM
    Zamowienia Z
    JOIN Klienci K ON Z.id_klienta = K.id_klienta
    JOIN Pozycje_Zamowienia PZ ON Z.id_zamowienia = PZ.id_zamowienia
    JOIN Zabawki D ON PZ.id_zabawki = D.id_zabawki
WHERE
    EXTRACT(
        YEAR
        FROM
            Z.data_zamowienia
    ) = EXTRACT(
        YEAR
        FROM
            SYSDATE
    );

BEGIN BEGIN FOR rekord IN zamowienia_cursor LOOP v_ilosc := v_ilosc + 1;

DBMS_OUTPUT.PUT_LINE('Nazwa Firmy: ' || rekord.nazwa_firmy);

DBMS_OUTPUT.PUT_LINE('Data Zamówienia: ' || rekord.data_zamowienia);

DBMS_OUTPUT.PUT_LINE('Zamówiona zabawka: ' || rekord.nazwa_zabawki);

DBMS_OUTPUT.PUT_LINE('Cena: ' || rekord.cena);

DBMS_OUTPUT.PUT_LINE('---------------------------------------');

END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak danych dla bieżącego roku.');

WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);

END;

DBMS_OUTPUT.PUT_LINE('Ilość zamówień z bieżącego roku: ' || v_ilosc);

RETURN v_ilosc;

END Raport_Zamowien_Biezacy_Rok;

/ -------------------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION Raport_Najlepiej_Sprzedawane_Zabawki RETURN INTEGER IS v_ilosc INTEGER := 0;

CURSOR najlepiej_sprzedawane_cursor IS
SELECT
    D.id_zabawki,
    D.nazwa,
    SUM(PZ.ilosc_sztuk) AS ilosc_sprzedanych
FROM
    Pozycje_Zamowienia PZ
    JOIN Zamowienia Z ON PZ.id_zamowienia = Z.id_zamowienia
    JOIN Zabawki D ON PZ.id_zabawki = D.id_zabawki
GROUP BY
    D.id_zabawki,
    D.nazwa
ORDER BY
    ilosc_sprzedanych DESC;

BEGIN BEGIN FOR rekord IN najlepiej_sprzedawane_cursor LOOP v_ilosc := v_ilosc + 1;

DBMS_OUTPUT.PUT_LINE('Miejsce ' || v_ilosc || ':');

DBMS_OUTPUT.PUT_LINE('ID Zabawki: ' || rekord.id_zabawki);

DBMS_OUTPUT.PUT_LINE('Nazwa Zabawki: ' || rekord.nazwa);

DBMS_OUTPUT.PUT_LINE(
    'Ilość Sprzedanych: ' || rekord.ilosc_sprzedanych
);

DBMS_OUTPUT.PUT_LINE('---------------------------------------');

IF v_ilosc = 5 THEN EXIT;

END IF;

END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak danych do wyświetlenia.');

WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);

END;

RETURN v_ilosc;

END Raport_Najlepiej_Sprzedawane_Zabawki;

/ -------------------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION Pobierz_Ilosc_Zamowien_Klienta(p_id_klienta INTEGER) RETURN INTEGER IS ilosc_zamowien INTEGER;

v_nazwa VARCHAR2(20);

CURSOR klient_cursor IS
SELECT
    nazwa_firmy
FROM
    Klienci
WHERE
    id_klienta = p_id_klienta;

CURSOR zamowienia_cursor IS
SELECT
    COUNT(*)
FROM
    Zamowienia
WHERE
    id_klienta = p_id_klienta;

BEGIN OPEN klient_cursor;

FETCH klient_cursor INTO v_nazwa;

CLOSE klient_cursor;

DBMS_OUTPUT.PUT_LINE(
    'Klient o ID ' || p_id_klienta || ': ' || v_nazwa
);

OPEN zamowienia_cursor;

FETCH zamowienia_cursor INTO ilosc_zamowien;

CLOSE zamowienia_cursor;

DBMS_OUTPUT.PUT_LINE('Ilość zamówień: ' || ilosc_zamowien);

RETURN ilosc_zamowien;

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak danych do wyświetlenia.');

RETURN 0;

WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Wystąpił nieoczekiwany błąd: ' || SQLERRM);

RETURN 0;

END Pobierz_Ilosc_Zamowien_Klienta;

/ -------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
CREATE
OR REPLACE PROCEDURE Zmien_Informacje_O_Pracowniku (
    p_id_pracownika INTEGER,
    p_nowe_imie VARCHAR2,
    p_nowe_nazwisko VARCHAR2,
    p_nowy_nr_telefonu INTEGER,
    p_nowe_wynagrodzenie INTEGER,
    p_nowe_stanowisko VARCHAR2,
    p_nowy_id_adresu INTEGER,
    p_nowy_nr_ulicy VARCHAR2
) IS CURSOR pracownik_cursor IS
SELECT
    *
FROM
    Pracownicy
WHERE
    id_pracownika = p_id_pracownika;

v_id_pracownika INTEGER;

v_stare_imie VARCHAR2(50);

v_stare_nazwisko VARCHAR2(50);

v_stary_nr_telefonu INTEGER;

v_stare_wynagrodzenie INTEGER;

v_stare_stanowisko VARCHAR2(50);

v_stare_id_adresu INTEGER;

v_stary_nr_ulicy VARCHAR2(20);

BEGIN OPEN pracownik_cursor;

FETCH pracownik_cursor INTO v_id_pracownika,
v_stare_imie,
v_stare_nazwisko,
v_stary_nr_telefonu,
v_stare_wynagrodzenie,
v_stare_stanowisko,
v_stare_id_adresu,
v_stary_nr_ulicy;

CLOSE pracownik_cursor;

IF v_id_pracownika IS NOT NULL THEN BEGIN DBMS_OUTPUT.PUT_LINE(
    'Zmiana danych pracownika o ID ' || p_id_pracownika || ':'
);

DBMS_OUTPUT.PUT_LINE('Stare dane:');

DBMS_OUTPUT.PUT_LINE('Imię: ' || v_stare_imie);

DBMS_OUTPUT.PUT_LINE('Nazwisko: ' || v_stare_nazwisko);

DBMS_OUTPUT.PUT_LINE('Nr telefonu: ' || v_stary_nr_telefonu);

DBMS_OUTPUT.PUT_LINE('Wynagrodzenie: ' || v_stare_wynagrodzenie);

DBMS_OUTPUT.PUT_LINE('Stanowisko: ' || v_stare_stanowisko);

DBMS_OUTPUT.PUT_LINE('ID adresu: ' || v_stare_id_adresu);

DBMS_OUTPUT.PUT_LINE('Nr ulicy: ' || v_stary_nr_ulicy);

UPDATE
    Pracownicy
SET
    imie = p_nowe_imie,
    nazwisko = p_nowe_nazwisko,
    nr_telefonu = p_nowy_nr_telefonu,
    wynagrodzenie_podstawowe = p_nowe_wynagrodzenie,
    stanowisko = p_nowe_stanowisko,
    id_adresu = p_nowy_id_adresu,
    nr_ulicy = p_nowy_nr_ulicy
WHERE
    id_pracownika = p_id_pracownika;

COMMIT;

DBMS_OUTPUT.PUT_LINE('Nowe dane:');

DBMS_OUTPUT.PUT_LINE('Imię: ' || p_nowe_imie);

DBMS_OUTPUT.PUT_LINE('Nazwisko: ' || p_nowe_nazwisko);

DBMS_OUTPUT.PUT_LINE('Nr telefonu: ' || p_nowy_nr_telefonu);

DBMS_OUTPUT.PUT_LINE('Wynagrodzenie: ' || p_nowe_wynagrodzenie);

DBMS_OUTPUT.PUT_LINE('Stanowisko: ' || p_nowe_stanowisko);

DBMS_OUTPUT.PUT_LINE('ID adresu: ' || p_nowy_id_adresu);

DBMS_OUTPUT.PUT_LINE('Nr ulicy: ' || p_nowy_nr_ulicy);

DBMS_OUTPUT.PUT_LINE(
    'Informacje o pracowniku zaktualizowane pomyślnie.'
);

EXCEPTION
WHEN OTHERS THEN ROLLBACK;

DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);

END;

ELSE DBMS_OUTPUT.PUT_LINE(
    'Nie znaleziono pracownika o ID ' || p_id_pracownika
);

END IF;

END Zmien_Informacje_O_Pracowniku;

/ ------------------------------------------------------------------------------------------
CREATE
OR REPLACE PROCEDURE Dodaj_Wpis_Magazynowy (
    p_data_wpisu DATE,
    p_ilosc_sztuk INTEGER,
    p_id_zabawki INTEGER,
    p_id_pracownika INTEGER
) AS v_id_wpisu INTEGER;

CURSOR id_wpisu_cursor IS
SELECT
    COALESCE(MAX(id_wpisu) + 1, 1) AS next_id
FROM
    Wpisy_magazynowe;

v_next_id INTEGER;

BEGIN OPEN id_wpisu_cursor;

FETCH id_wpisu_cursor INTO v_next_id;

CLOSE id_wpisu_cursor;

INSERT INTO
    Wpisy_Magazynowe (
        id_wpisu,
        data_wpisu,
        ilosc_sztuk,
        id_zabawki,
        id_pracownika
    )
VALUES
    (
        v_next_id,
        p_data_wpisu,
        p_ilosc_sztuk,
        p_id_zabawki,
        p_id_pracownika
    );

COMMIT;

DBMS_OUTPUT.PUT_LINE('Wpis magazynowy został dodany');

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak danych do wstawienia.');

WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);

ROLLBACK;

END Dodaj_Wpis_Magazynowy;

/ ------------------------------------------------------------------------------------------
CREATE
OR REPLACE PROCEDURE Aktualizuj_Ilosc_Zabawek (
    p_id_zabawki INTEGER,
    p_nowa_ilosc INTEGER
) IS CURSOR zabawki_c IS
SELECT
    dostepna_ilosc
FROM
    Zabawki
WHERE
    id_zabawki = p_id_zabawki;

v_stara_ilosc INTEGER;

BEGIN OPEN zabawki_c;

FETCH zabawki_c INTO v_stara_ilosc;

IF v_dostepna_ilosc IS NOT NULL THEN
UPDATE
    Zabawki
SET
    dostepna_ilosc = p_nowa_ilosc
WHERE
    id_zabawki = p_id_zabawki;

COMMIT;

DBMS_OUTPUT.PUT_LINE('Ilość zabawek została zaktualizowana.');

ELSE DBMS_OUTPUT.PUT_LINE(
    'Zabawka o ID ' || p_id_zabawki || ' nie znaleziona'
);

END IF;

CLOSE zabawki_c;

EXCEPTION
WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Bład: ' || SQLERRM);

ROLLBACK;

END Aktualizuj_Ilosc_Zabawek;

/ -----------------------------------------------------------------------------------------------
CREATE
OR REPLACE PROCEDURE Dodaj_Zabawke (
    p_nazwa VARCHAR2,
    p_cena NUMBER,
    p_dostepna_ilosc INTEGER,
    p_id_kategorii INTEGER,
    p_id_materialu INTEGER
) AS v_id_zabawki INTEGER;

CURSOR nowa_zabawka_cursor IS
SELECT
    *
FROM
    Zabawki
WHERE
    id_zabawki = v_id_zabawki;

v_rekord Zabawki % ROWTYPE;

BEGIN
SELECT
    COALESCE(MAX(id_zabawki) + 1, 1) INTO v_id_zabawki
FROM
    Zabawki;

INSERT INTO
    Zabawki (
        id_zabawki,
        nazwa,
        cena,
        dostepna_ilosc,
        id_kategorii,
        id_materialu
    )
VALUES
    (
        v_id_zabawki,
        p_nazwa,
        p_cena,
        p_dostepna_ilosc,
        p_id_kategorii,
        p_id_materialu
    );

COMMIT;

OPEN nowa_zabawka_cursor;

FETCH nowa_zabawka_cursor INTO v_rekord;

CLOSE nowa_zabawka_cursor;

DBMS_OUTPUT.PUT_LINE('Zabawka została dodana:');

DBMS_OUTPUT.PUT_LINE('ID: ' || v_rekord.id_zabawki);

DBMS_OUTPUT.PUT_LINE('Nazwa: ' || v_rekord.nazwa);

DBMS_OUTPUT.PUT_LINE('Cena: ' || v_rekord.cena);

DBMS_OUTPUT.PUT_LINE('Dostepna ilosc: ' || v_rekord.dostepna_ilosc);

DBMS_OUTPUT.PUT_LINE('ID kategorii: ' || v_rekord.id_kategorii);

DBMS_OUTPUT.PUT_LINE('ID materialu: ' || v_rekord.id_materialu);

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak danych do wstawienia.');

WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);

ROLLBACK;

END Dodaj_Zabawke;

/ -------------------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION Oblicz_Srednia_Pensje_Pracownikow_Na_Stanowisku(p_stanowisko VARCHAR2) RETURN NUMBER IS v_srednia_pensja NUMBER;

CURSOR pensje_cursor IS
SELECT
    wynagrodzenie_podstawowe
FROM
    Pracownicy
WHERE
    stanowisko = p_stanowisko;

BEGIN OPEN pensje_cursor;

FETCH pensje_cursor INTO v_srednia_pensja;

IF v_srednia_pensja IS NULL THEN CLOSE pensje_cursor;

DBMS_OUTPUT.PUT_LINE('Brak danych dla stanowiska: ' || p_stanowisko);

RETURN NULL;

ELSE DBMS_OUTPUT.PUT_LINE('Pobrano dane: ' || v_srednia_pensja);

END IF;

CLOSE pensje_cursor;

RETURN v_srednia_pensja;

EXCEPTION
WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);

RETURN NULL;

END Oblicz_Srednia_Pensje_Pracownikow_Na_Stanowisku;

/ -----------------------------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION Raport_Wpisow_Magazynowych_Biezacy_Miesiac RETURN INTEGER IS v_ilosc INTEGER := 0;

CURSOR wpisy_cursor IS
SELECT
    W.data_wpisu,
    P.imie || ' ' || P.nazwisko AS pracownik,
    Z.nazwa AS nazwa_zabawki,
    W.ilosc_sztuk
FROM
    Wpisy_Magazynowe W
    JOIN Pracownicy P ON W.id_pracownika = P.id_pracownika
    JOIN Zabawki Z ON W.id_zabawki = Z.id_zabawki
WHERE
    EXTRACT(
        MONTH
        FROM
            W.data_wpisu
    ) = EXTRACT(
        MONTH
        FROM
            SYSDATE
    )
    AND EXTRACT(
        YEAR
        FROM
            W.data_wpisu
    ) = EXTRACT(
        YEAR
        FROM
            SYSDATE
    );

BEGIN FOR rekord IN wpisy_cursor LOOP v_ilosc := v_ilosc + 1;

DBMS_OUTPUT.PUT_LINE('Data wpisu: ' || rekord.data_wpisu);

DBMS_OUTPUT.PUT_LINE('Pracownik: ' || rekord.pracownik);

DBMS_OUTPUT.PUT_LINE('Zabawka: ' || rekord.nazwa_zabawki);

DBMS_OUTPUT.PUT_LINE('Ilość sztuk: ' || rekord.ilosc_sztuk);

DBMS_OUTPUT.PUT_LINE('---------------------------------------');

END LOOP;

DBMS_OUTPUT.PUT_LINE(
    'Ilość wpisów magazynowych z bieżącego miesiąca: ' || v_ilosc
);

RETURN v_ilosc;

EXCEPTION
WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('Brak danych dla bieżącego miesiąca.');

RETURN 0;

WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);

RETURN NULL;

END Raport_Wpisow_Magazynowych_Biezacy_Miesiac;

/ ------------------------------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION Ilosc_Zabawek_W_Okresie(
    p_data_poczatkowa DATE,
    p_data_koncowa DATE
) RETURN INTEGER IS v_ilosc INTEGER := 0;

CURSOR zabawki_cursor IS
SELECT
    COUNT(*) AS liczba_zabawek
FROM
    Wpisy_magazynowe
WHERE
    data_wpisu BETWEEN p_data_poczatkowa
    AND p_data_koncowa;

BEGIN OPEN zabawki_cursor;

FETCH zabawki_cursor INTO v_ilosc;

CLOSE zabawki_cursor;

IF v_ilosc > 0 THEN DBMS_OUTPUT.PUT_LINE(
    'Ilość zabawek stworzonych w okresie od ' || p_data_poczatkowa || ' do ' || p_data_koncowa || ': ' || v_ilosc
);

ELSE DBMS_OUTPUT.PUT_LINE('Brak zabawek w podanym okresie.');

END IF;

RETURN v_ilosc;

EXCEPTION
WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);

END Ilosc_Zabawek_W_Okresie;

/ -------------------------------------------------------------------------------------------------------------
CREATE
OR REPLACE FUNCTION Srednia_Cena_Zabawki_W_Kategorii(p_id_kategorii INTEGER) RETURN NUMBER IS v_srednia_cena NUMBER;

CURSOR cena_cursor IS
SELECT
    AVG(cena) AS srednia_cena
FROM
    Zabawki
WHERE
    id_kategorii = p_id_kategorii;
BEGIN OPEN cena_cursor;
FETCH cena_cursor INTO v_srednia_cena;
CLOSE cena_cursor;
IF v_srednia_cena IS NOT NULL THEN DBMS_OUTPUT.PUT_LINE(
    'Średnia cena zabawki w kategorii o ID ' || p_id_kategorii || ': ' || v_srednia_cena
);
ELSE DBMS_OUTPUT.PUT_LINE(
    'Brak zabawek w kategorii o ID ' || p_id_kategorii
);
END IF;
RETURN v_srednia_cena;
EXCEPTION
WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
RETURN NULL;
END Srednia_Cena_Zabawki_W_Kategorii;
/