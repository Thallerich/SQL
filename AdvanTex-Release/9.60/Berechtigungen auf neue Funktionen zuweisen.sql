DECLARE @RechtIDMassenUebersetzung AS INTEGER

SET @RechtIDMassenUebersetzung = (
    SELECT TOP 1 id
    FROM rights
    WHERE RightsBez LIKE ('%__SAL_Übersetzung%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDMassenUebersetzung
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND ActionName LIKE ('%ACTMASSENUEBERSETZUNG%')
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDMassenUebersetzung
      AND m.SichtKatID = -1
  );

GO

DECLARE @RechtIDArtikelBearbeiten AS INTEGER

SET @RechtIDArtikelBearbeiten = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%__SAL_Artikel bearbeiten%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDArtikelBearbeiten
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND FormClass LIKE ('%TFORMARTIKEL%')
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDArtikelBearbeiten
      AND m.SichtKatID = -1
  );

GO

DECLARE @RechtIDProduktion AS INTEGER

SET @RechtIDProduktion = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('Produktion')
    )

--INSERT INTO MODACT(FormActID, RightsID)
SELECT FormActID, @RechtIDProduktion
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND formclass LIKE ('%TFORMWAAGEEINGANG%')
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDProduktion
      AND m.SichtKatID = -1
  );

GO

DECLARE @RechtIDIT AS INTEGER

SET @RechtIDIT = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%__SAL_IT%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDIT
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND (
    formclass LIKE ('%TTABSYSJOB%')
    OR formclass LIKE ('%TFORMQUERY%')
    OR formclass LIKE ('%TFORMTABLEDEF%')
    )
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDIT
      AND m.SichtKatID = -1
  );

GO

-- FREI VERFÜGBAR FÜR ALLE NUTZER
DECLARE @RechtId_oB AS INTEGER

SET @RechtId_oB = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%(ohne Beschränkung)%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtId_oB
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND (
    formclass LIKE ('%TFORMSUCHEN%')
    OR FORMCLASS LIKE ('%TFORMKUNDEN%')
    OR (
      FORMclass LIKE ('%TFormBKo%')
      AND ACTIONname LIKE ('%actChangeLiefNeuBKo%')
      )
    OR (
      formclass LIKE ('%TTABBESTAND%')
      AND actionname LIKE ('ACTNEWBESTAND')
      )
    OR formclass LIKE ('%TFORMLSKO%')
    OR actionname LIKE ('%ACTENDKONTROLLEBEWTEIL%')
    OR actionname LIKE ('%ACTKDARTIDESBEREICHS%')
    OR actionname LIKE ('%ACTSTACKMONSINGLEMODE%')
    OR actionname LIKE ('%ACTLIVEUSER%')
    OR formclass LIKE ('%TTABSCANS%')
    OR actionname LIKE ('%ACTLIEF%')
    OR actionname LIKE ('%ACTEXPFRIST%')
    OR actionname LIKE ('%ACTEDITUMLAUFMENGE%')
    )
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtId_oB
      AND m.SichtKatID = -1
  );

GO

--CONTAINERVERFOLGUNG
DECLARE @RechtIDContainerverfolgung AS INTEGER

SET @RechtIDContainerverfolgung = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%Containerverfolgung%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDContainerverfolgung
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND (
    formclass LIKE ('%TFORMCONTAINVORBEREITEN%')
    OR (
      formclass LIKE ('%TMAINFORMMENU%')
      AND actionname LIKE ('%ACTCONTAINERVORBEREITEN%')
      )
    )
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDContainerverfolgung
      AND m.SichtKatID = -1
  );

GO

-- ZENTRALLAGER - LAGERADMIN
DECLARE @RechtIDLager AS INTEGER

SET @RechtIDLager = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%Lager%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDLager
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND (
    formclass LIKE ('%TFORMBKO%')
    OR formclass LIKE ('%TFORMBKOART%')
    OR Formclass LIKE ('%TFORMLIEF%')
    OR Formclass LIKE ('%TFORMLIEFFIRM%')
    OR FORMCLASS LIKE ('%TTABARGRLIEF%')
    )
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDLager
      AND m.SichtKatID = -1
  );

GO

-- Fakturierung
DECLARE @RechtIDFaktura AS INTEGER

SET @RechtIDFaktura = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_Faktura%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDFaktura
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND (
    formclass LIKE ('%TFORMRKO%')
    OR formclass LIKE ('%TTABTEILSOFARESTWERT%')
    OR ActionName LIKE ('%ACTRWTEMPLA%')
    OR (
      formclass LIKE ('%TMAINFORMMENU%')
      AND ActionName LIKE ('%ACTPEKOIMPORT%')
      )
    OR (
      formclass LIKE ('%TMAINFORMMENU%')
      AND ActionName LIKE ('%ACTRWART%')
      )
    AND formclass LIKE ('%TFORMRWCONFIG%')
    )
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDFaktura
      AND m.SichtKatID = -1
  );

GO

-- Neues Recht erstellen für neues Modul Weblinks
INSERT INTO RIGHTS (RightsBez, DarfAdvantex)
VALUES ('#_Weblinks', 1)

DECLARE @RechtIDWeblinks AS INTEGER

SET @RechtIDWeblinks = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_Weblinks%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDWeblinks
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND formclass LIKE ('%TFORMWEBLINKS%')
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDWeblinks
      AND m.SichtKatID = -1
  );

GO

-- IT 
DECLARE @RechtIdIT AS INTEGER

SET @RechtIdIT = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%__SAL_IT%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIdIT
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND (
    formclass LIKE ('%TFORMTABLEDEF%')
    OR formclass LIKE ('%TFORMQUERY%')
    OR FORMCLASS LIKE ('%TTABSYSJOB%')
    )
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIdIT
      AND m.SichtKatID = -1
  );

GO

DECLARE @RechtIdFuhrpark AS INTEGER

SET @RechtIdFuhrpark = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_Fuhrpark%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIdFuhrpark
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND (formclass LIKE ('%TFORMFAHRTLEITSTAND%'))
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIdFuhrpark
      AND m.SichtKatID = -1
  );

GO

-- Vertrieb Sales 
DECLARE @RechtIDSales AS INTEGER

SET @RechtIDSales = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_Sales%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDSales
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND ACTIONname LIKE ('%ACTABSATZCHDASHBOARD%')
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDSales
      AND m.SichtKatID = -1
  );

GO

DECLARE @RechtIDKS AS INTEGER

SET @RechtIDKS = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_Kundenservice%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDKS
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND (
    formclass LIKE ('%TTABVSAANF%')
    OR FORMCLASS LIKE ('%TFORMVSA%')
    OR FORMCLASS LIKE ('%TFORMLSKO%')
    OR formclass LIKE ('%TFORMUMBUCHPOOLLAGER%')
    OR actionname LIKE ('%ACTUMBUCHPOOLLAGER%')
    OR actionname LIKE ('%ACTLIEFPROT%')
    OR formclass LIKE ('%TFORMARTISTAN%')
    )
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDKS
      AND m.SichtKatID = -1
  );

GO

-- Steril
DECLARE @RechtIDMICRONCLEAN AS INTEGER

SET @RechtIDMICRONCLEAN = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%SAL_Micronclean%')
    )

INSERT INTO MODACT (FormActID, RightsID)
SELECT FormActID, @RechtIDMICRONCLEAN
FROM RIGHTS
JOIN MODACT ON MODACT.RightsID = Rights.ID
JOIN FORMACT ON MODACT.FormActID = FormAct.ID
WHERE rights.id = (
    SELECT TOP 1 ID
    FROM RIGHTS
    WHERE RIGHTSBEZ LIKE ('%#_NeueFunktionen%')
    )
  AND (
    formclass LIKE ('%TTABOPPSEUDOCHARGE%')
    OR formclass LIKE ('%TTABWASCHCH%')
    )
  AND NOT EXISTS (
    SELECT m.*
    FROM ModAct m
    WHERE m.FormActID = ModAct.FormActID
      AND m.RightsID = @RechtIDMICRONCLEAN
      AND m.SichtKatID = -1
  );

GO