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

  -- Wstaw dane zamówienia do tabeli Zamowienia
  INSERT INTO Zamowienia (id_zamowienia, id_klienta, data_zamowienia, status_zamowienia, id_sposobu_zaplaty)
  VALUES (v_id_zamowienia, p_id_klienta, p_data_zamowienia, 'W trakcie', p_id_sposobu_zaplaty);

  -- Wstaw produkty do tabeli Pozycje_Zamowienia
  FOR i IN 1..p_produkty_tab.COUNT LOOP
    INSERT INTO Pozycje_Zamowienia (id_pozycji_zamowienia, id_zamowienia, id_zabawki, ilosc_sztuk)
    VALUES (v_id_pozycji_zamowienia, v_id_zamowienia, p_produkty_tab(i), p_ilosci_tab(i));
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
  produkty ZabawkiCollection := ZabawkiCollection(1, 2, 3);
  ilosci IlosciZabawekCollection := IlosciZabawekCollection(2, 3, 1);
BEGIN
  RealizujZamowienie(1, SYSDATE, 1, produkty, ilosci);
END;
/
    
select * from zamowienia;
select * from pozycje_zamowienia;


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

SELECT
  K.id_klienta,
  K.nazwa_firmy,
  K.imie,
  K.nazwisko,
  K.staly_klient,
  SUM(PZ.ilosc_sztuk) AS ilosc_zakupionych_zabawek
FROM
  Klienci K
JOIN
  Zamowienia Z ON K.id_klienta = Z.id_klienta
JOIN
  Pozycje_Zamowienia PZ ON Z.id_zamowienia = PZ.id_zamowienia
GROUP BY
  K.id_klienta, K.nazwa_firmy, K.imie, K.nazwisko, K.staly_klient;

