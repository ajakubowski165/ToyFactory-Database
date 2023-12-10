--PAKIET 1 - ZARZADZANIE ZAMOWIENIAMI

-------------------------------------------FUNKCJE------------------------------------------------------

--OBLICZ KWOTE ZAMOWIENIA

CREATE OR REPLACE FUNCTION ObliczKwoteZamowienia(
  id_zamowienia_param IN INTEGER
) RETURN NUMBER IS
  v_suma_kwoty NUMBER := 0;

  CURSOR c_pozycje_zamowienia IS
    SELECT pz.ilosc_sztuk, z.cena
    FROM pozycje_zamowienia pz
    JOIN zabawki z ON pz.id_zabawki = z.id_zabawki
    WHERE pz.id_zamowienia = id_zamowienia_param;

BEGIN
  FOR rekord IN c_pozycje_zamowienia LOOP
    v_suma_kwoty := v_suma_kwoty + (rekord.ilosc_sztuk * rekord.cena);
  END LOOP;

  RETURN v_suma_kwoty;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Brak danych dla zamówienia o ID: ' || id_zamowienia_param);
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
END;
/


DECLARE
  v_id_zamowienia INTEGER := 1;
  v_suma_kwoty NUMBER;
BEGIN
  v_suma_kwoty := ObliczKwoteZamowienia(id_zamowienia_param => v_id_zamowienia);
  DBMS_OUTPUT.PUT_LINE('Łączna kwota zamówienia o ID ' || v_id_zamowienia || ': ' || v_suma_kwoty);
END;
/


--ILOSC ZAMOWIEN KLIENTA

CREATE OR REPLACE FUNCTION Pobierz_Ilosc_Zamowien_Klienta(p_id_klienta INTEGER) RETURN INTEGER IS
  ilosc_zamowien INTEGER;
  v_nazwa VARCHAR2(20);

  CURSOR klient_cursor IS
    SELECT nazwa_firmy
    FROM Klienci
    WHERE id_klienta = p_id_klienta;

  CURSOR zamowienia_cursor IS
    SELECT COUNT(*)
    FROM Zamowienia
    WHERE id_klienta = p_id_klienta;

BEGIN
  OPEN klient_cursor;
  FETCH klient_cursor INTO v_nazwa;
  CLOSE klient_cursor;

  DBMS_OUTPUT.PUT_LINE('Klient o ID ' || p_id_klienta || ': ' || v_nazwa );

  OPEN zamowienia_cursor;
  FETCH zamowienia_cursor INTO ilosc_zamowien;
  CLOSE zamowienia_cursor;

  DBMS_OUTPUT.PUT_LINE('Ilość zamówień: ' || ilosc_zamowien);

  RETURN ilosc_zamowien;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Brak danych do wyświetlenia.');
    RETURN 0; 
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Wystąpił nieoczekiwany błąd: ' || SQLERRM);
    RETURN 0; 
END Pobierz_Ilosc_Zamowien_Klienta;
/

DECLARE
  v_ilosc_zamowien INTEGER;
BEGIN
  v_ilosc_zamowien := Pobierz_Ilosc_Zamowien_Klienta(2);
END;
/


--RAPORTY ZAMOWIEN Z BIEZACEGO ROKU

CREATE OR REPLACE FUNCTION Raport_Zamowien_Biezacy_Rok RETURN INTEGER IS
  v_ilosc INTEGER := 0;

  CURSOR zamowienia_cursor IS
    SELECT K.nazwa_firmy, Z.data_zamowienia,
           D.nazwa AS nazwa_zabawki, D.cena
    FROM Zamowienia Z
    JOIN Klienci K ON Z.id_klienta = K.id_klienta
    JOIN Pozycje_Zamowienia PZ ON Z.id_zamowienia = PZ.id_zamowienia
    JOIN Zabawki D ON PZ.id_zabawki = D.id_zabawki
    WHERE EXTRACT(YEAR FROM Z.data_zamowienia) = EXTRACT(YEAR FROM SYSDATE);

BEGIN
  BEGIN
    FOR rekord IN zamowienia_cursor LOOP
      v_ilosc := v_ilosc + 1;

      DBMS_OUTPUT.PUT_LINE('Nazwa Firmy: ' || rekord.nazwa_firmy);
      DBMS_OUTPUT.PUT_LINE('Data Zamówienia: ' || rekord.data_zamowienia);
      DBMS_OUTPUT.PUT_LINE('Zamówiona zabawka: ' || rekord.nazwa_zabawki);
      DBMS_OUTPUT.PUT_LINE('Cena: ' || rekord.cena);
      DBMS_OUTPUT.PUT_LINE('---------------------------------------');
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Brak danych dla bieżącego roku.');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
      -- Dodatkowe działania obsługujące błąd, np. zapisanie informacji do logów
  END;

  DBMS_OUTPUT.PUT_LINE('Ilość zamówień z bieżącego roku: ' || v_ilosc);
  RETURN v_ilosc;
END Raport_Zamowien_Biezacy_Rok;
/

DECLARE
  ilosc_zamowien INTEGER;
BEGIN
  ilosc_zamowien := Raport_Zamowien_Biezacy_Rok;
END;
/


--RAPORT TOP5 SPRZEDAWANYCH ZABAWEK

CREATE OR REPLACE FUNCTION Raport_Najlepiej_Sprzedawane_Zabawki RETURN INTEGER IS
  v_ilosc INTEGER := 0;

  CURSOR najlepiej_sprzedawane_cursor IS
    SELECT D.id_zabawki, D.nazwa, SUM(PZ.ilosc_sztuk) AS ilosc_sprzedanych
    FROM Pozycje_Zamowienia PZ
    JOIN Zamowienia Z ON PZ.id_zamowienia = Z.id_zamowienia
    JOIN Zabawki D ON PZ.id_zabawki = D.id_zabawki
    GROUP BY D.id_zabawki, D.nazwa
    ORDER BY ilosc_sprzedanych DESC;

BEGIN
  BEGIN
    FOR rekord IN najlepiej_sprzedawane_cursor LOOP
      v_ilosc := v_ilosc + 1;

      DBMS_OUTPUT.PUT_LINE('Miejsce ' || v_ilosc || ':');
      DBMS_OUTPUT.PUT_LINE('ID Zabawki: ' || rekord.id_zabawki);
      DBMS_OUTPUT.PUT_LINE('Nazwa Zabawki: ' || rekord.nazwa);
      DBMS_OUTPUT.PUT_LINE('Ilość Sprzedanych: ' || rekord.ilosc_sprzedanych);
      DBMS_OUTPUT.PUT_LINE('---------------------------------------');
      
      IF v_ilosc = 5 THEN
        EXIT; 
      END IF;
    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Brak danych do wyświetlenia.');
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
  END;

  RETURN v_ilosc;
END Raport_Najlepiej_Sprzedawane_Zabawki;
/

DECLARE
  ilosc INTEGER;
BEGIN
  ilosc := Raport_Najlepiej_Sprzedawane_Zabawki;
  DBMS_OUTPUT.PUT_LINE('Liczba najlepiej sprzedawanych zabawek: ' || ilosc);
END;
/



-------------------------------------------PROCEDURY------------------------------------------------------


--REALIZUJE ZAMOWIENIE

CREATE TYPE ZabawkiCollection AS TABLE OF INTEGER;
CREATE TYPE IlosciZabawekCollection AS TABLE OF INTEGER;

CREATE OR REPLACE PROCEDURE RealizujZamowienie(
  p_id_klienta INTEGER,
  p_data_zamowienia DATE,
  p_id_sposobu_zaplaty INTEGER,
  p_produkty_tab IN ZabawkiCollection,
  p_ilosci_tab IN IlosciZabawekCollection
) AS
  v_id_zamowienia INTEGER;
  v_id_pozycji_zamowienia INTEGER;
  v_liczba_zamowionych_zabawek INTEGER := 0;

BEGIN
  -- Sprawdź, czy ilości i produkty mają taką samą długość
  IF p_produkty_tab.COUNT <> p_ilosci_tab.COUNT THEN
    DBMS_OUTPUT.PUT_LINE('Błąd: Kolekcje p_produkty_tab i p_ilosci_tab muszą mieć tę samą długość.');
    RETURN;
  END IF;

  -- Znajdź pierwszy dostępny identyfikator zamówienia
  SELECT COALESCE(MAX(id_zamowienia) + 1, 1)
  INTO v_id_zamowienia
  FROM Zamowienia;

  -- Znajdź pierwszy dostępny identyfikator pozycji zamówienia
  SELECT COALESCE(MAX(id_pozycji_zamowienia) + 1, 1)
  INTO v_id_pozycji_zamowienia
  FROM Pozycje_Zamowienia;

  -- Rozpocznij transakcję
  BEGIN
    -- Wstaw dane zamówienia do tabeli Zamowienia
    INSERT INTO Zamowienia (id_zamowienia, id_klienta, data_zamowienia, status_zamowienia, id_sposobu_zaplaty)
    VALUES (v_id_zamowienia, p_id_klienta, p_data_zamowienia, 'W trakcie', p_id_sposobu_zaplaty);

    -- Wstaw produkty do tabeli Pozycje_Zamowienia
    FOR i IN 1..p_produkty_tab.COUNT LOOP
      -- Sprawdź dostępność zabawek
      DECLARE
        v_dostepna_ilosc INTEGER;
      BEGIN
        SELECT dostepna_ilosc
        INTO v_dostepna_ilosc
        FROM Zabawki
        WHERE id_zabawki = p_produkty_tab(i);

        IF v_dostepna_ilosc < p_ilosci_tab(i) THEN
          RAISE_APPLICATION_ERROR(-20001, 'Błąd: Brak wystarczającej ilości zabawek o ID ' || p_produkty_tab(i));
        END IF;

        -- Odejmij zamówione ilości od dostępnych zabawek
        UPDATE Zabawki
        SET dostepna_ilosc = dostepna_ilosc - p_ilosci_tab(i)
        WHERE id_zabawki = p_produkty_tab(i);

        -- Zlicz zamówione ilości
        v_liczba_zamowionych_zabawek := v_liczba_zamowionych_zabawek + p_ilosci_tab(i);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE_APPLICATION_ERROR(-20002, 'Błąd: Zabawka o ID ' || p_produkty_tab(i) || ' nie istnieje.');
      END;

      -- Wstaw pozycję zamówienia
      INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk)
      VALUES (v_id_pozycji_zamowienia, v_id_zamowienia, p_produkty_tab(i), p_ilosci_tab(i));
      
      v_id_pozycji_zamowienia := v_id_pozycji_zamowienia + 1;
    END LOOP;

    -- Zakończ transakcję
    COMMIT;

    -- Sprawdzenie, czy liczba zamówionych zabawek przekracza 100
    IF v_liczba_zamowionych_zabawek > 100 THEN
      -- Zmiana klienta na stałego
      UPDATE Klienci
      SET staly_klient = 1
      WHERE id_klienta = p_id_klienta;

      DBMS_OUTPUT.PUT_LINE('Klient o ID ' || p_id_klienta || ' został zmieniony na stałego klienta.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('Zamówienie o ID ' || v_id_zamowienia || ' zostało zrealizowane.');
  EXCEPTION
    WHEN OTHERS THEN
      -- W przypadku błędu, wykonaj rollback
      ROLLBACK;
      DBMS_OUTPUT.PUT_LINE('Wystąpił błąd podczas realizacji zamówienia: ' || SQLERRM);
  END;
END RealizujZamowienie;
/

-- Użyj procedury
DECLARE
  produkty_tab ZabawkiCollection := ZabawkiCollection(23, 2, 3); 
  ilosci_tab IlosciZabawekCollection := IlosciZabawekCollection(100, 1, 1); 
BEGIN
  RealizujZamowienie(
    p_id_klienta => 2,
    p_data_zamowienia => SYSDATE, 
    p_id_sposobu_zaplaty => 1,
    p_produkty_tab => produkty_tab,
    p_ilosci_tab => ilosci_tab
  );
END;
/


select * from zamowienia;
select * from pozycje_zamowienia;
select * from zabawki where id_zabawki = 1;



--ZMIANA STATUSU ZAMOWIENIA

CREATE OR REPLACE PROCEDURE ZmienStatusZamowienia(
  p_id_zamowienia INTEGER,
  p_nowy_status VARCHAR2
) AS
  CURSOR zamowienie_cursor IS
    SELECT id_zamowienia, status_zamowienia
    FROM Zamowienia
    WHERE id_zamowienia = p_id_zamowienia;

  v_id_zamowienia INTEGER;
  v_stary_status VARCHAR2(50);
BEGIN
  OPEN zamowienie_cursor;
  FETCH zamowienie_cursor INTO v_id_zamowienia, v_stary_status;
  CLOSE zamowienie_cursor;

  IF v_id_zamowienia IS NOT NULL THEN
    UPDATE Zamowienia
    SET status_zamowienia = p_nowy_status
    WHERE id_zamowienia = v_id_zamowienia;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Zmieniono status zamówienia o ID ' || v_id_zamowienia || ' z ' || v_stary_status || ' na ' || p_nowy_status);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono zamówienia o ID ' || p_id_zamowienia);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd podczas zmiany statusu zamówienia: ' || SQLERRM);
END ZmienStatusZamowienia;
/

DECLARE
  v_id_zamowienia INTEGER := 1; 
  v_nowy_status VARCHAR2(50) := 'Anulowane'; 
BEGIN
  ZmienStatusZamowienia(v_id_zamowienia, v_nowy_status);
END;



--AKTUALIZACJA DANYCH KLIENTA

CREATE OR REPLACE PROCEDURE ZmienDaneKlienta(
  p_id_klienta INTEGER,
  p_nowa_nazwa_firmy VARCHAR2,
  p_nowe_imie VARCHAR2,
  p_nowe_nazwisko VARCHAR2,
  p_nowy_pesel VARCHAR2,
  p_nowe_id_adresu INTEGER,
  p_nowy_nr_ulicy VARCHAR2
) AS
  CURSOR klient_cursor IS
    SELECT id_klienta, nazwa_firmy, imie, nazwisko, pesel, id_adresu, nr_ulicy
    FROM Klienci
    WHERE id_klienta = p_id_klienta;

  v_id_klienta INTEGER;
  v_stara_nazwa_firmy VARCHAR2(100);
  v_stare_imie VARCHAR2(50);
  v_stare_nazwisko VARCHAR2(50);
  v_stary_pesel VARCHAR2(11);
  v_stare_id_adresu INTEGER;
  v_stary_nr_ulicy VARCHAR2(20);
BEGIN
  OPEN klient_cursor;
  FETCH klient_cursor INTO v_id_klienta, v_stara_nazwa_firmy, v_stare_imie, v_stare_nazwisko, v_stary_pesel, v_stare_id_adresu, v_stary_nr_ulicy;
  CLOSE klient_cursor;

  IF v_id_klienta IS NOT NULL THEN
    BEGIN
      SELECT id_klienta
      INTO v_id_klienta
      FROM Klienci
      WHERE id_klienta = p_id_klienta;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    UPDATE Klienci
    SET nazwa_firmy = p_nowa_nazwa_firmy,
        imie = p_nowe_imie,
        nazwisko = p_nowe_nazwisko,
        pesel = p_nowy_pesel,
        id_adresu = p_nowe_id_adresu,
        nr_ulicy = p_nowy_nr_ulicy
    WHERE id_klienta = p_id_klienta;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Zmieniono dane klienta o ID ' || p_id_klienta);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono klienta o ID ' || p_id_klienta);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd podczas zmiany danych klienta: ' || SQLERRM);
END ZmienDaneKlienta;
/

DECLARE
  v_id_klienta INTEGER := 1; 
  v_nowa_nazwa_firmy VARCHAR2(100) := 'Kanał zabawkowy';
  v_nowe_imie VARCHAR2(50) := 'Michał';
  v_nowe_nazwisko VARCHAR2(50) := 'Pol';
  v_nowy_pesel VARCHAR2(11) := '463547372';
  v_nowe_id_adresu INTEGER := 14; 
  v_nowy_nr_ulicy VARCHAR2(20) := '5A';
BEGIN
  ZmienDaneKlienta(
    p_id_klienta => v_id_klienta,
    p_nowa_nazwa_firmy => v_nowa_nazwa_firmy,
    p_nowe_imie => v_nowe_imie,
    p_nowe_nazwisko => v_nowe_nazwisko,
    p_nowy_pesel => v_nowy_pesel,
    p_nowe_id_adresu => v_nowe_id_adresu,
    p_nowy_nr_ulicy => v_nowy_nr_ulicy
  );
END;
/









--PAKIET 2 - ZARZADZANIE ZMAGAZYNEM

-------------------------------------------PROCEDURY------------------------------------------------------


--DODAWANIE WPISU MAGAZYNOWEGO

CREATE OR REPLACE PROCEDURE Dodaj_Wpis_Magazynowy (
    p_data_wpisu DATE,
    p_ilosc_sztuk INTEGER,
    p_id_zabawki INTEGER,
    p_id_pracownika INTEGER
) AS
    v_id_wpisu INTEGER;

    CURSOR id_wpisu_cursor IS
        SELECT COALESCE(MAX(id_wpisu) + 1, 1) AS next_id
        FROM Wpisy_magazynowe;

    v_next_id INTEGER;
BEGIN
    -- Użycie kursora do uzyskania kolejnego ID wpisu magazynowego
    OPEN id_wpisu_cursor;
    FETCH id_wpisu_cursor INTO v_next_id;
    CLOSE id_wpisu_cursor;

    -- Wpisanie nowego wpisu magazynowego
    INSERT INTO Wpisy_Magazynowe (id_wpisu, data_wpisu, ilosc_sztuk, id_zabawki, id_pracownika)
    VALUES (v_next_id, p_data_wpisu, p_ilosc_sztuk, p_id_zabawki, p_id_pracownika);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Wpis magazynowy został dodany');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych do wstawienia.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        ROLLBACK;
END Dodaj_Wpis_Magazynowy;
/

DECLARE
    v_data_wpisu DATE := SYSDATE; 
    v_ilosc_sztuk INTEGER := 10;  
    v_id_zabawki INTEGER := 1;  
    v_id_pracownika INTEGER := 1; 
BEGIN
    Dodaj_Wpis_Magazynowy(v_data_wpisu, v_ilosc_sztuk, v_id_zabawki, v_id_pracownika);
END;
/


--AKTUALIZACJA ILOSCI ZABAWEK---------------


CREATE OR REPLACE PROCEDURE Aktualizuj_Ilosc_Zabawek (
    p_id_zabawki INTEGER,
    p_nowa_ilosc INTEGER
)
IS
    CURSOR zabawki_c IS
        SELECT dostepna_ilosc
        FROM Zabawki
        WHERE id_zabawki = p_id_zabawki
        FOR UPDATE OF dostepna_ilosc;

    v_stara_ilosc INTEGER;
BEGIN
    OPEN zabawki_c;
    FETCH zabawki_c INTO v_stara_ilosc;

    IF zabawki_c%FOUND THEN
        UPDATE Zabawki
        SET dostepna_ilosc = p_nowa_ilosc
        WHERE CURRENT OF zabawki_c;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Ilosc zabawek zostala zaktualizowana.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Zabawka o ID ' || p_id_zabawki || ' nie znaleziona');
    END IF;

    CLOSE zabawki_c;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Bład: ' || SQLERRM);
        ROLLBACK;
END Aktualizuj_Ilosc_Zabawek;
/

DECLARE
    v_id_zabawki INTEGER := 5;    
    v_nowa_ilosc INTEGER := 47;   
BEGIN
    Aktualizuj_Ilosc_Zabawek(v_id_zabawki, v_nowa_ilosc);
END;
/


-------------ZMIANA INFO O PRACOWNIKU---

CREATE OR REPLACE PROCEDURE Zmien_Informacje_O_Pracowniku (
    p_id_pracownika INTEGER,
    p_nowe_imie VARCHAR2,
    p_nowe_nazwisko VARCHAR2,
    p_nowy_nr_telefonu INTEGER,
    p_nowe_wynagrodzenie INTEGER,
    p_nowe_stanowisko VARCHAR2,
    p_nowy_id_adresu INTEGER,
    p_nowy_nr_ulicy VARCHAR2
)
IS
    CURSOR pracownik_cursor IS
        SELECT *
        FROM Pracownicy
        WHERE id_pracownika = p_id_pracownika;

    v_id_pracownika INTEGER;
    v_stare_imie VARCHAR2(50);
    v_stare_nazwisko VARCHAR2(50);
    v_stary_nr_telefonu INTEGER;
    v_stare_wynagrodzenie INTEGER;
    v_stare_stanowisko VARCHAR2(50);
    v_stare_id_adresu INTEGER;
    v_stary_nr_ulicy VARCHAR2(20);
BEGIN
    OPEN pracownik_cursor;
    FETCH pracownik_cursor INTO v_id_pracownika, v_stare_imie, v_stare_nazwisko, v_stary_nr_telefonu, v_stare_wynagrodzenie, v_stare_stanowisko, v_stare_id_adresu, v_stary_nr_ulicy;
    CLOSE pracownik_cursor;

    IF v_id_pracownika IS NOT NULL THEN
        BEGIN
            UPDATE Pracownicy
            SET
                imie = p_nowe_imie,
                nazwisko = p_nowe_nazwisko,
                nr_telefonu = p_nowy_nr_telefonu,
                wynagrodzenie_podstawowe = p_nowe_wynagrodzenie,
                stanowisko = p_nowe_stanowisko,
                id_adresu = p_nowy_id_adresu,
                nr_ulicy = p_nowy_nr_ulicy
            WHERE id_pracownika = p_id_pracownika;

            COMMIT;

            DBMS_OUTPUT.PUT_LINE('Informacje o pracowniku zaktualizowane pomyślnie.');
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        END;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono pracownika o ID ' || p_id_pracownika);
    END IF;
END Zmien_Informacje_O_Pracowniku;

DECLARE
  v_id_pracownika INTEGER := 13; 
  v_nowe_imie VARCHAR2(50) := 'Adrian';
  v_nowe_nazwisko VARCHAR2(50) := 'Jakubowski';
  v_nowy_nr_telefonu INTEGER := 788788788;
  v_nowe_wynagrodzenie INTEGER := 5000;
  v_nowe_stanowisko VARCHAR2(50) := 'Magazynier';
  v_nowy_id_adresu INTEGER := 10; 
  v_nowy_nr_ulicy VARCHAR2(20) := '20';
BEGIN
  Zmien_Informacje_O_Pracowniku(
    p_id_pracownika => v_id_pracownika,
    p_nowe_imie => v_nowe_imie,
    p_nowe_nazwisko => v_nowe_nazwisko,
    p_nowy_nr_telefonu => v_nowy_nr_telefonu,
    p_nowe_wynagrodzenie => v_nowe_wynagrodzenie,
    p_nowe_stanowisko => v_nowe_stanowisko,
    p_nowy_id_adresu => v_nowy_id_adresu,
    p_nowy_nr_ulicy => v_nowy_nr_ulicy
  );
END;
/



---DODAWANIE ZABAWKI------------------

CREATE OR REPLACE PROCEDURE Dodaj_Zabawke (
    p_nazwa VARCHAR2,
    p_cena NUMBER,
    p_dostepna_ilosc INTEGER,
    p_id_kategorii INTEGER,
    p_id_materialu INTEGER
)
AS
    v_id_zabawki INTEGER;

    CURSOR nowa_zabawka_cursor IS
        SELECT *
        FROM Zabawki
        WHERE id_zabawki = v_id_zabawki;

    v_rekord Zabawki%ROWTYPE;
BEGIN
    SELECT COALESCE(MAX(id_zabawki) + 1, 1)
    INTO v_id_zabawki
    FROM Zabawki;

    INSERT INTO Zabawki (id_zabawki, nazwa, cena, dostepna_ilosc, id_kategorii, id_materialu)
    VALUES (v_id_zabawki, p_nazwa, p_cena, p_dostepna_ilosc, p_id_kategorii, p_id_materialu);

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
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Brak danych do wstawienia.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        ROLLBACK;
END Dodaj_Zabawke;
/

DECLARE
    v_nazwa VARCHAR2(50) := 'Drewniane Puzzle';
    v_cena NUMBER := 19.99;
    v_dostepna_ilosc INTEGER := 50;
    v_id_kategorii INTEGER := 10;
    v_id_materialu INTEGER := 2;
BEGIN
    Dodaj_Zabawke(v_nazwa, v_cena, v_dostepna_ilosc, v_id_kategorii, v_id_materialu);
END;
/



-------------------------------FUNKCJE----------------------------------



CREATE OR REPLACE FUNCTION Oblicz_Srednia_Pensje_Pracownikow_Na_Stanowisku(
    p_stanowisko VARCHAR2
)
RETURN NUMBER
IS
    v_srednia_pensja NUMBER;

    CURSOR pensje_cursor IS
        SELECT wynagrodzenie_podstawowe
        FROM Pracownicy
        WHERE stanowisko = p_stanowisko;
BEGIN
    OPEN pensje_cursor;

    FETCH pensje_cursor INTO v_srednia_pensja;

    IF pensje_cursor%NOTFOUND THEN
        CLOSE pensje_cursor;
        DBMS_OUTPUT.PUT_LINE('Brak danych dla stanowiska: ' || p_stanowisko);
        RETURN NULL;
    END IF;

    WHILE pensje_cursor%FOUND LOOP
        FETCH pensje_cursor INTO v_srednia_pensja;
    END LOOP;

    CLOSE pensje_cursor;

    RETURN v_srednia_pensja;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
        RETURN NULL;
END Oblicz_Srednia_Pensje_Pracownikow_Na_Stanowisku;
/

DECLARE
    v_avg_salary NUMBER;
BEGIN
    v_avg_salary := Oblicz_Srednia_Pensje_Pracownikow_Na_Stanowisku('Magazynier');
    DBMS_OUTPUT.PUT_LINE('Średnia Pensja: ' || v_avg_salary);
END;
/


---------

CREATE OR REPLACE FUNCTION Raport_Wpisow_Magazynowych_Biezacy_Miesiac RETURN INTEGER IS
    v_ilosc INTEGER := 0;

    CURSOR wpisy_cursor IS
        SELECT W.data_wpisu, P.imie || ' ' || P.nazwisko AS pracownik,
               Z.nazwa AS nazwa_zabawki, W.ilosc_sztuk
        FROM Wpisy_Magazynowe W
        JOIN Pracownicy P ON W.id_pracownika = P.id_pracownika
        JOIN Zabawki Z ON W.id_zabawki = Z.id_zabawki
        WHERE EXTRACT(MONTH FROM W.data_wpisu) = EXTRACT(MONTH FROM SYSDATE)
        AND EXTRACT(YEAR FROM W.data_wpisu) = EXTRACT(YEAR FROM SYSDATE);

BEGIN
    BEGIN
        FOR rekord IN wpisy_cursor LOOP
            v_ilosc := v_ilosc + 1;

            DBMS_OUTPUT.PUT_LINE('Data wpisu: ' || rekord.data_wpisu);
            DBMS_OUTPUT.PUT_LINE('Pracownik: ' || rekord.pracownik);
            DBMS_OUTPUT.PUT_LINE('Zabawka: ' || rekord.nazwa_zabawki);
            DBMS_OUTPUT.PUT_LINE('Ilość sztuk: ' || rekord.ilosc_sztuk);
            DBMS_OUTPUT.PUT_LINE('---------------------------------------');
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('Ilość wpisów magazynowych z bieżącego miesiąca: ' || v_ilosc);
        RETURN v_ilosc;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Brak danych dla bieżącego miesiąca.');
            RETURN 0;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
            RETURN NULL;
    END;
END Raport_Wpisow_Magazynowych_Biezacy_Miesiac;
/

DECLARE
  raport_wpisow INTEGER;
BEGIN
  raport_wpisow := Raport_Wpisow_Magazynowych_Biezacy_Miesiac;
END;
/



---------


CREATE OR REPLACE FUNCTION Ilosc_Zabawek_W_Okresie(
  p_data_poczatkowa DATE,
  p_data_koncowa DATE
) RETURN INTEGER IS
  v_ilosc INTEGER := 0;

  CURSOR zabawki_cursor IS
    SELECT COUNT(*) AS liczba_zabawek
    FROM Wpisy_magazynowe
    WHERE data_wpisu BETWEEN p_data_poczatkowa AND p_data_koncowa;

BEGIN
  OPEN zabawki_cursor;
  FETCH zabawki_cursor INTO v_ilosc;
  CLOSE zabawki_cursor;

  IF v_ilosc > 0 THEN
    DBMS_OUTPUT.PUT_LINE('Ilość zabawek stworzonych w okresie od ' || p_data_poczatkowa || ' do ' || p_data_koncowa || ': ' || v_ilosc);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Brak zabawek w podanym okresie.');
  END IF;

  RETURN v_ilosc;
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
END Ilosc_Zabawek_W_Okresie;
/


DECLARE
  ilosc_zabawek INTEGER;
BEGIN
  ilosc_zabawek := Ilosc_Zabawek_W_Okresie(DATE '2023-04-01', DATE '2023-05-31');
END;


--------------------------------------
CREATE OR REPLACE FUNCTION Srednia_Cena_Zabawki_W_Kategorii(
  p_id_kategorii INTEGER
) RETURN NUMBER IS
  v_srednia_cena NUMBER;

  CURSOR cena_cursor IS
    SELECT AVG(cena) AS srednia_cena
    FROM Zabawki
    WHERE id_kategorii = p_id_kategorii;

BEGIN
  OPEN cena_cursor;
  FETCH cena_cursor INTO v_srednia_cena;
  CLOSE cena_cursor;

  IF v_srednia_cena IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Średnia cena zabawki w kategorii o ID ' || p_id_kategorii || ': ' || v_srednia_cena);
  ELSE
    DBMS_OUTPUT.PUT_LINE('Brak zabawek w kategorii o ID ' || p_id_kategorii);
  END IF;

  RETURN v_srednia_cena;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd: ' || SQLERRM);
    IF cena_cursor%ISOPEN THEN
      CLOSE cena_cursor;
    END IF;
    RETURN NULL;
END Srednia_Cena_Zabawki_W_Kategorii;
/

DECLARE
  v_id_kategorii INTEGER := 1; 
  v_srednia_cena NUMBER;
BEGIN
  v_srednia_cena := Srednia_Cena_Zabawki_W_Kategorii(v_id_kategorii);
END;
/