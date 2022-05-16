WITH Mitarbeistatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'MITARBEI'
)
SELECT Mitarbei.MaNr, Mitarbei.Anrede, Mitarbei.Titel, Mitarbei.Vorname, Mitarbei.Nachname, Mitarbei.Initialen, 
  Geschlecht = CASE Mitarbei.Geschlecht
    WHEN N'M' THEN N'Männlich'
    WHEN N'W' THEN N'Weiblich'
    WHEN N'S' THEN N'Pseudo(Sächlich)'
    ELSE N'Unbekannt'
  END,
  Mitarbeistatus.StatusBez AS [Status], MitarTyp.MitarTypBez AS [Typ], Mitarbei.Geburtstag, Mitarbei.Strasse, Mitarbei.Land, Mitarbei.PLZ, Mitarbei.Ort, Mitarbei.Telefon, Mitarbei.Mobil, Mitarbei.Telefax, Mitarbei.eMail, Mitarbei.Kostenstelle, Standort.Bez AS Standort, Firma.Bez AS Firma, MitarAbt.MitarAbtBez AS Abteilung, ChefMitarbei.Name AS Vorgesetzter, KdGf.KurzBez AS Geschäftsfeld, Sichtbar.Bez AS [Sichtbar für], Mitarbei.EintrittAm AS Eintrittsdatum, Mitarbei.AustrittAm AS Austrittsdatum, Mitarbei.Frei1 AS [Montag frei?], Mitarbei.Frei2 AS [Dienstag frei?], Mitarbei.Frei3 AS [Mittwoch frei?], Mitarbei.Frei4 AS [Donnerstag frei?], Mitarbei.Frei5 AS [Freitag frei?], Mitarbei.Frei6 AS [Samstag frei?], Mitarbei.Frei7 AS [Sonntag frei?], Mitarbei.Fahrer AS [Mitarbeiter ist als Fahrer tätig?], Mitarbei.FahrerPKW AS [Mitarbeiter fährt mit PKW?], Fahrzeug.Kennzeichen AS Hauptfahrzeug, Mitarbei.FahrerC AS [LKW-Klasse C], Mitarbei.FahrerCbis AS [LKW-Klasse C bis], Mitarbei.FahrerCE AS [LKW-Klasse CE], Mitarbei.FahrerCEbis AS [LKW-Klasse CE bis], Mitarbei.FahrerC1 AS [LKW-Klasse C1], Mitarbei.FahrerC1bis AS [LKW-Klasse C1 bis], Mitarbei.FahrerC1E AS [LKW-Klasse C1E], Mitarbei.FahrerC1Ebis AS [LKW-Klasse C1E bis], Mitarbei.FahrerB AS [PKW-Klasse B], Mitarbei.FahrerBE AS [PKW-Klasse BE], Mitarbei.FahrerS AS [PKW-Klasse S], Mitarbei.FahrerQuali AS [Berufsqualifikation Kennzahl], Mitarbei.FahrerQualiBis AS [Berufsqualifikation gültig bis], Mitarbei.Modul1 AS [Modul 1], Mitarbei.Modul2 AS [Modul 2], Mitarbei.Modul3 AS [Modul 3], Mitarbei.Modul4 AS [Modul 4], Mitarbei.Modul5 AS [Modul 5], Mitarbei.FahrerkartenNr AS [Fahrerkarten-Nummer], Mitarbei.Fuehrerscheinnummer AS [Führerscheinnummer], Mitarbei.FahrerkarteGueltigVon AS [Fahrerkarte gültig von], Mitarbei.FahrerkarteGueltigBis AS [Fahrerkarte gültig bis]
FROM Mitarbei
JOIN Mitarbeistatus ON Mitarbei.Status = Mitarbeistatus.Status
JOIN MitarTyp ON Mitarbei.MitarTypID = MitarTyp.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Firma ON Standort.FirmaID = Firma.ID
JOIN MitarAbt ON Mitarbei.MitarAbtID = MitarAbt.ID
JOIN Mitarbei AS ChefMitarbei ON Mitarbei.ChefMitarbeiID = ChefMitarbei.ID
JOIN KdGf ON Mitarbei.KdGfID = KdGf.ID
JOIN Sichtbar ON Mitarbei.SichtbarID = Sichtbar.ID
JOIN Fahrzeug ON Mitarbei.FahrzeugID = Fahrzeug.ID
WHERE Mitarbei.Fahrer = 1;

GO

WITH Fahrzeugstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'FAHRZEUG'
)
SELECT Fahrzeug.FzNr AS Nummer, Fahrzeug.Kennzeichen, Fahrzeugstatus.StatusBez AS [Status], Fahrzeug.FahrgestellNr, Fahrzeug.Typ, Fahrtype.FahrTypeBez AS Fahrzeugtyp, Fahrzeug.Fabrikat, Fahrzeug.KmStand AS Kilometerstand, Fahrzeug.kmDatum AS [Datum Kilometerstand], Mitarbei.Name AS [Stamm-Fahrer], Fahrzeug.Hersteller, Sichtbar.Bez AS [Sichtbar für], Standort.Bez AS Standort, Fahrzeug.SuchCode, AltFahrzeug.Kennzeichen AS [Ersatz für], Fahrzeug.Telefon, Fahrzeug.Beschriftung, Fahrzeug.EZDatum AS Erstzulassung, Fahrzeug.Baujahr, Fahrzeug.MaxMenge AS [Maximale Beladung Stück], Fahrzeug.MaxGewicht AS [Maximale Beladung kg], Fahrzeug.MaxVolumen AS [Maximale Beladung Liter], Fahrzeug.MaxContain AS [Maximale Beladung Container], Fahrzeug.Leistung AS [Leistung kW], Fahrzeug.HoechstGewicht AS [zulässiges Gesamtgewicht kg], Fahrzeug.Eigengewicht AS [Eigengewicht kg], Fahrzeug.Hubraum, Fahrzeug.VerbrauchSoll, Fahrzeug.CO2Ausstoss, Fahrzeug.Schadstoffklasse, Fahrzeug.TuevBis AS [TÜV bis], Fahrzeug.TachoTuev AS [Tacho-TÜV], Fahrzeug.UVVPruefung AS [UVV-Prüfung], Fahrzeug.SPPruefung AS [SP-Prüfung], Fahrzeug.FuehrerscheinKlasse AS [benötigte Führerscheinklasse], Fahrzeug.LieferantName AS Lieferant, Fahrzeug.BestellNr, Fahrzeug.BestelltAm AS [bestellt am], Fahrzeug.UebernahmeDatum AS [Übernahmedatum], Fahrzeug.RueckgabeDatum AS [Rückgabedatum], Fahrzeug.AbmeldDatum AS [Abmeldedatum], Fahrzeug.LeasingFirma AS Leasingfirma, Fahrzeug.LeasingNr AS Vertragsnummer, Fahrzeug.LeasingStart AS [Leasing von], Fahrzeug.LeasingEnde AS [Leasing bis], Fahrzeug.LeasingKM AS [Leasing-KM pro Jahr], Fahrzeug.Versicherer, Fahrzeug.VersichNr AS Versicherungsnummer, Fahrzeug.VersichArt AS Versicherungsart, Fahrzeug.VersichProMonat AS [Versicherung pro Monat], Fahrzeug.BruttoListenPr AS [Brutto-Listenpreis], Fahrzeug.Kostenstelle, Fahrzeug.LeasingProMonat AS [Leasingpreis pro Monat], Fahrzeug.SteuerProMonat AS [Steuern pro Monat], Fahrzeug.Ladebordwand, Fahrzeug.NaviGPS AS [Navigationsgerät / GPS-Erfassung], Fahrzeug.Mautgeraet AS [Maut-Gerät], Fahrzeug.AnhaengerKupplung AS Anhängerkupplung, Fahrzeug.Seitentuer AS Seitentür, Fahrzeug.KlimaAnlage AS Klimaanlage, Fahrzeug.Luftfederung, Fahrzeug.AutoGetr AS Automatikgetriebe, Fahrzeug.StandHeizung AS Standheizung, Fahrzeug.DigiTacho AS [Digitaler Tachograph], Fahrzeug.Radio, Fahrzeug.KofferAufbau AS Kofferaufbau, Fahrzeug.KofferAufbauLaenge AS [Kofferaufbaulänge m]
FROM Fahrzeug
JOIN Fahrzeugstatus ON Fahrzeug.Status = Fahrzeugstatus.Status
JOIN FahrType ON Fahrzeug.FahrtypeID = FahrType.ID
JOIN Mitarbei ON Fahrzeug.MitarbeiID = Mitarbei.ID
JOIN Sichtbar ON Fahrzeug.SichtbarID = Sichtbar.ID
JOIN Standort ON Fahrzeug.StandortID = Standort.ID
JOIN Fahrzeug AS AltFahrzeug ON Fahrzeug.AltFahrzeugID = AltFahrzeug.ID
WHERE Fahrzeug.ID > 0;

GO