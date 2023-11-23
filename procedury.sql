--PAKIET 1 - ZARZADZANIE ZAMOWIENIAMI

-------------------------------------------FUNKCJE------------------------------------------------------

--OBLICZ KWOTE ZAMOWIENIA

CREATE OR REPLACE FUNCTION ObliczKwoteZamowieniaFFFFF(
  id_zamowienia_param IN INTEGER
) RETURN NUMBER IS
  v_suma_kwoty NUMBER := 0;
BEGIN
  -- Kursor sparametryzowany
  FOR rekord IN (SELECT pz.ilosc_sztuk, z.cena
                 FROM pozycje_zamowienia pz
                 JOIN zabawki z ON pz.id_zabawki = z.id_zabawki
                 WHERE pz.id_zamowienia = id_zamowienia_param) LOOP
    -- Dodaj kwotę pozycji zamówienia do sumy
    v_suma_kwoty := v_suma_kwoty + (rekord.ilosc_sztuk * rekord.cena);
  END LOOP;

  -- Zwróć łączną kwotę
  RETURN v_suma_kwoty;
END;
/


DECLARE
  v_id_zamowienia INTEGER := 1; -
  v_suma_kwoty NUMBER;
BEGIN
  v_suma_kwoty := ObliczKwoteZamowieniaFFFFF(id_zamowienia_param => v_id_zamowienia);
  DBMS_OUTPUT.PUT_LINE('Łączna kwota zamówienia o ID ' || v_id_zamowienia || ': ' || v_suma_kwoty);
END;
/

--ILOSC ZAMOWIEN KLIENTA

CREATE OR REPLACE FUNCTION Pobierz_Ilosc_Zamowien_Klienta(p_id_klienta INTEGER) RETURN INTEGER IS
  ilosc_zamowien INTEGER;
  v_nazwa VARCHAR2(20);
BEGIN

  SELECT nazwa_firmy INTO v_nazwa
  FROM Klienci
  WHERE id_klienta = p_id_klienta;

  DBMS_OUTPUT.PUT_LINE('Klient o ID ' || p_id_klienta || ': ' || v_nazwa );

  SELECT COUNT(*) INTO ilosc_zamowien
  FROM Zamowienia
  WHERE id_klienta = p_id_klienta;

  DBMS_OUTPUT.PUT_LINE('Ilość zamówień: ' || ilosc_zamowien);

  RETURN ilosc_zamowien;
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
  FOR rekord IN zamowienia_cursor LOOP
    v_ilosc := v_ilosc + 1;

    DBMS_OUTPUT.PUT_LINE('Nazwa Firmy: ' || rekord.nazwa_firmy);
    DBMS_OUTPUT.PUT_LINE('Data Zamówienia: ' || rekord.data_zamowienia);
    DBMS_OUTPUT.PUT_LINE('Zamówiona zabawka: ' || rekord.nazwa_zabawki);
    DBMS_OUTPUT.PUT_LINE('Cena: ' || rekord.cena);
    DBMS_OUTPUT.PUT_LINE('---------------------------------------');

  END LOOP;

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
  FOR rekord IN najlepiej_sprzedawane_cursor LOOP
    v_ilosc := v_ilosc + 1;

    DBMS_OUTPUT.PUT_LINE('Miejsce ' || v_ilosc || ':');
    DBMS_OUTPUT.PUT_LINE('ID Zabawki: ' || rekord.id_zabawki);
    DBMS_OUTPUT.PUT_LINE('Nazwa Zabawki: ' || rekord.nazwa);
    DBMS_OUTPUT.PUT_LINE('Ilość Sprzedanych: ' || rekord.ilosc_sprzedanych);
    DBMS_OUTPUT.PUT_LINE('---------------------------------------');
    
    -- Dodatkowe informacje o sprzedawanej zabawce, jeśli są potrzebne

    IF v_ilosc = 5 THEN
      EXIT; -- Zakończ pętlę po pięciu najlepiej sprzedawanych zabawkach
    END IF;
  END LOOP;

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

CREATE OR REPLACE PROCEDURE RealizujZamowienie(
  p_id_klienta INTEGER,
  p_data_zamowienia DATE,
  p_produkty_tab SYS.ODCINUMBERLIST,
  p_id_sposobu_zaplaty INTEGER
) AS
  v_id_zamowienia INTEGER;
  v_id_pozycji_zamowienia INTEGER;
BEGIN
  -- Znajdź pierwszy dostępny identyfikator zamówienia
  SELECT COALESCE(MAX(id_zamowienia) + 1, 1)
  INTO v_id_zamowienia
  FROM Zamowienia;

  -- Znajdź pierwszy dostępny identyfikator pozycji zamówienia
  SELECT COALESCE(MAX(id_pozycji_zamowienia) + 1, 1)
  INTO v_id_pozycji_zamowienia
  FROM Pozycje_Zamowienia;

  -- Wstaw dane zamówienia do tabeli Zamowienia
  INSERT INTO Zamowienia (id_zamowienia, id_klienta, data_zamowienia, status_zamowienia, id_sposobu_zaplaty)
  VALUES (v_id_zamowienia, p_id_klienta, p_data_zamowienia, 'W trakcie', p_id_sposobu_zaplaty);

  -- Wstaw produkty do tabeli Pozycje_Zamowienia
  FOR i IN 1..p_produkty_tab.COUNT LOOP
    INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk)
    VALUES (v_id_pozycji_zamowienia, v_id_zamowienia, p_produkty_tab(i), 1);
    -- Zwiększ identyfikator dla kolejnej pozycji zamówienia
    v_id_pozycji_zamowienia := v_id_pozycji_zamowienia + 1;
  END LOOP;

  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Zamówienie o ID ' || v_id_zamowienia || ' zostało zrealizowane.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd podczas realizacji zamówienia: ' || SQLERRM);
END RealizujZamowienie;
/


DECLARE
  v_produkty SYS.ODCINUMBERLIST := SYS.ODCINUMBERLIST(1, 2, 3, 4); 
BEGIN
  RealizujZamowienie(
    p_id_klienta => 1,
    p_data_zamowienia => SYSDATE,
    p_produkty_tab => v_produkty,
    p_id_sposobu_zaplaty => 3
  );
END;
/



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
  v_id_zamowienia INTEGER := 4; -- Zastąp wartością odpowiedniego ID zamówienia
  v_nowy_status VARCHAR2(50) := 'Anulowane'; -- Zastąp wartością nowego statusu
BEGIN
  ZmienStatusZamowienia(v_id_zamowienia, v_nowy_status);
END;



--USUWANIE ZAMOWIENIA

CREATE OR REPLACE PROCEDURE UsunZamowienie(
  p_id_zamowienia INTEGER
) AS
BEGIN
  -- Usuń pozycje zamówienia
  DELETE FROM Pozycje_Zamowienia WHERE id_zamowienia = p_id_zamowienia;

  -- Usuń zamówienie
  DELETE FROM Zamowienia WHERE id_zamowienia = p_id_zamowienia;

  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Zamówienie o ID ' || p_id_zamowienia || ' zostało usunięte.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Wystąpił błąd podczas usuwania zamówienia: ' || SQLERRM);
END UsunZamowienie;
/


DECLARE
  v_id_zamowienia_do_usuniecia INTEGER := 101; -- Zastąp wartością odpowiedniego ID zamówienia
BEGIN
  UsunZamowienie(v_id_zamowienia_do_usuniecia);
END;
/


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
    -- Sprawdź, czy nowe id_pracownika nie istnieje już w tabeli
    BEGIN
      SELECT id_klienta
      INTO v_id_klienta
      FROM Klienci
      WHERE id_klienta = p_id_klienta AND id_klienta != p_id_klienta;

      -- Jeśli istnieje, zgłoś wyjątek
      RAISE_APPLICATION_ERROR(-20001, 'Klient o podanym ID już istnieje');
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        -- Jeśli nie istnieje, kontynuuj normalnie
        NULL;
    END;

    -- Aktualizuj dane klienta
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
  v_id_klienta INTEGER := 1; -- Zastąp wartością odpowiedniego ID klienta
  v_nowa_nazwa_firmy VARCHAR2(100) := 'Nowa Firma';
  v_nowe_imie VARCHAR2(50) := 'Nowe Imie';
  v_nowe_nazwisko VARCHAR2(50) := 'Nowe Nazwisko';
  v_nowy_pesel VARCHAR2(11) := '12345678901';
  v_nowe_id_adresu INTEGER := 2; -- Zastąp wartością nowego ID adresu
  v_nowy_nr_ulicy VARCHAR2(20) := 'Nowy Numer Ulicy';
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






