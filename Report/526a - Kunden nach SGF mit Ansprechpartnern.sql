/* Pipeline: Reportdaten +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
),
Ansprechpartner AS (
  SELECT KundenID, Anrede, Titel, Vorname, [Name], SerienAnrede, eMail, Telefon, Abteilung, [Position], STRING_AGG(Rolle, N', ') AS Rollen
  FROM (
    SELECT Sachbear.TableID AS KundenID, Sachbear.Anrede, Sachbear.Titel, Sachbear.Vorname, Sachbear.Name, Sachbear.SerienAnrede, Sachbear.eMail, Sachbear.Telefon, Sachbear.Abteilung, Sachbear.Position, Rollen.RollenBez$LAN$ AS Rolle
    FROM Sachbear
    LEFT JOIN SachRoll ON SachRoll.SachBearID = SachBear.ID
    LEFT JOIN Rollen ON SachRoll.RollenID = Rollen.ID
    WHERE Sachbear.Status = N'A'
      AND Sachbear.TableName = N'KUNDEN'

    UNION

    SELECT Vsa.KundenID AS KundenID, Sachbear.Anrede, Sachbear.Titel, Sachbear.Vorname, Sachbear.Name, Sachbear.SerienAnrede, Sachbear.eMail, Sachbear.Telefon, Sachbear.Abteilung, Sachbear.Position, Rollen.RollenBez$LAN$ AS Rolle
    FROM Sachbear
    JOIN Vsa ON Sachbear.TableID = Vsa.ID
    LEFT JOIN SachRoll ON SachRoll.SachBearID = SachBear.ID
    LEFT JOIN Rollen ON SachRoll.RollenID = Rollen.ID
    WHERE Sachbear.Status = N'A'
      AND Sachbear.TableName = N'VSA'
  ) AS SachbearList
  GROUP BY KundenID, Anrede, Titel, Vorname, [Name], SerienAnrede, eMail, Telefon, Abteilung, [Position]
)
SELECT DISTINCT KdGf.KurzBez AS Geschäftsbereich, Firma.Bez AS Firma, Standort.Bez AS Hauptstandort, Kundenstatus.StatusBez AS Kundenstatus, ABC.ABCBez AS Kundenklasse, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1 AS Adresszeile1, Kunden.Name2 AS Adresszeile2, Kunden.Name3 AS Adresszeile3, Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, Kunden.KundeSeit AS [Kunde seit], ZahlZiel.ZahlZielBez$LAN$ AS Zahlungsziel, Ansprechpartner.Anrede, Ansprechpartner.Titel, Ansprechpartner.Vorname, Ansprechpartner.Name, Ansprechpartner.SerienAnrede, Ansprechpartner.eMail, Ansprechpartner.Telefon, Ansprechpartner.Abteilung, Ansprechpartner.Position, Ansprechpartner.Rollen,
  Kundenservice = (
    SELECT TOP 1 IIF($4$ = 0, KdBerMitarbei.Name, VsaBerMitarbei.Name) AS [Name]
    FROM VsaBer
    JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
    JOIN Mitarbei AS VsaBerMitarbei ON VsaBer.ServiceID = VsaBerMitarbei.ID
    JOIN Mitarbei AS KdBerMitarbei ON KdBer.ServiceID = KdBerMitarbei.ID
    WHERE KdBer.KundenID = Kunden.ID
    GROUP BY IIF($4$ = 0, KdBerMitarbei.Name, VsaBerMitarbei.Name)
    ORDER BY COUNT(VsaBer.ID) DESC
  ),
  Kundenbetreuer = (
    SELECT TOP 1 IIF($4$ = 0, KdBerMitarbei.Name, VsaBerMitarbei.Name) AS [Name]
    FROM VsaBer
    JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
    JOIN Mitarbei AS VsaBerMitarbei ON VsaBer.BetreuerID = VsaBerMitarbei.ID
    JOIN Mitarbei AS KdBerMitarbei ON KdBer.BetreuerID = KdBerMitarbei.ID
    WHERE KdBer.KundenID = Kunden.ID
    GROUP BY IIF($4$ = 0, KdBerMitarbei.Name, VsaBerMitarbei.Name)
    ORDER BY COUNT(VsaBer.ID) DESC
  )
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN ZahlZiel ON Kunden.ZahlZielID = ZahlZiel.ID
LEFT JOIN Ansprechpartner ON Ansprechpartner.KundenID = Kunden.ID
WHERE Kunden.AdrArtID = 1
  AND Kundenstatus.ID IN ($3$)
  AND KdGf.ID IN ($1$)
  AND Kunden.StandortID IN ($2$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr, Ansprechpartner.Name;

/* Pipeline: Auf VSA Basierend +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
),
Ansprechpartner AS (
  /*SELECT Sachbear.TableID AS KundenID, Sachbear.Anrede, Sachbear.Titel, Sachbear.Vorname, Sachbear.Name, Sachbear.SerienAnrede, Sachbear.eMail, Sachbear.Telefon, Sachbear.Abteilung, Sachbear.Position, Rollen.RollenBez$LAN$ AS Rolle
  FROM Sachbear
  LEFT JOIN SachRoll ON SachRoll.SachBearID = SachBear.ID
  LEFT JOIN Rollen ON SachRoll.RollenID = Rollen.ID
  WHERE Sachbear.Status = N'A'
    AND Sachbear.TableName = N'KUNDEN'

  UNION ALL*/

  SELECT vsa.kundenid as kundenid,Vsa.id AS VSAID, vsa.vsanr,Sachbear.Anrede, Sachbear.Titel, Sachbear.Vorname, Sachbear.Name, Sachbear.SerienAnrede, Sachbear.eMail, Sachbear.Telefon, Sachbear.Abteilung, Sachbear.Position, Rollen.RollenBez$LAN$ AS Rolle
  FROM Sachbear
  JOIN Vsa ON Sachbear.TableID = Vsa.ID
  LEFT JOIN SachRoll ON SachRoll.SachBearID = SachBear.ID
  LEFT JOIN Rollen ON SachRoll.RollenID = Rollen.ID
  WHERE Sachbear.Status = N'A'
    AND Sachbear.TableName = N'VSA'
)
SELECT DISTINCT KdGf.KurzBez AS Geschäftsbereich, Firma.Bez AS Firma, Standort.Bez AS Hauptstandort, Kundenstatus.StatusBez AS Kundenstatus, ABC.ABCBez AS Kundenklasse, Kunden.KdNr, Kunden.SuchCode AS Kunde,VSA.VsaNr, VSA.Bez, Kunden.Name1 AS Adresszeile1, Kunden.Name2 AS Adresszeile2, Kunden.Name3 AS Adresszeile3, vsa.Strasse, vsa.Land, vsa.PLZ, vsa.Ort, Kunden.KundeSeit AS [Kunde seit], ZahlZiel.ZahlZielBez$LAN$ AS Zahlungsziel, Ansprechpartner.Anrede, Ansprechpartner.Titel, Ansprechpartner.Vorname, Ansprechpartner.Name, Ansprechpartner.SerienAnrede, Ansprechpartner.eMail, Ansprechpartner.Telefon, Ansprechpartner.Abteilung, Ansprechpartner.Position, Ansprechpartner.Rolle
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN ZahlZiel ON Kunden.ZahlZielID = ZahlZiel.ID
LEFT JOIN Ansprechpartner ON Ansprechpartner.kundenid = kunden.ID and ansprechpartner.vsanr = vsa.vsanr
WHERE Kunden.AdrArtID = 1
  AND VSA.STATUS = 'A'
  AND Kundenstatus.ID IN ($3$)
  AND KdGf.ID IN ($1$)
  AND Kunden.StandortID IN ($2$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr,VSA.VSANR, Ansprechpartner.Name;