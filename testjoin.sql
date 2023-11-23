SELECT Zamowienia.id_zamowienia, Zamowienia.data_zamowienia, Zamowienia.status_zamowienia, Pozycje_Zamowienia.id_pozycji_zamowienia
FROM Zamowienia
JOIN Pozycje_Zamowienia ON Zamowienia.id_zamowienia = Pozycje_Zamowienia.id_zamowienia;

SELECT Pracownicy.id_pracownika, Pracownicy.imie, Pracownicy.nazwisko, Adresy.id_adresu
FROM Pracownicy
JOIN Adresy ON Pracownicy.id_adresu = Adresy.id_adresu;

SELECT Faktury_sprzedazy.nr_faktury, Zamowienia.id_zamowienia
FROM Faktury_sprzedazy
JOIN Zamowienia ON Faktury_sprzedazy.id_zamowienia = Zamowienia.id_zamowienia;

SELECT Wpisy_Magazynowe.id_wpisu, Wpisy_Magazynowe.ilosc_sztuk, Pracownicy.id_pracownika
FROM Wpisy_Magazynowe
JOIN Pracownicy ON Wpisy_Magazynowe.id_pracownika = Pracownicy.id_pracownika;