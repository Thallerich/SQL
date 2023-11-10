DECLARE @KSRightID as Integer 
SET @KSRightID = (SELECT TOP 1 ID FROM Rights where RightsBez = '#_Kundenservice')

DECLARE @KSLeitungID as Integer 
SET @KSRightID = (SELECT TOP 1 ID FROM Rights where RightsBez = '#_Kundenserviceleitung')

DECLARE @FakturaRightID as Integer 
SET @FakturaRightID = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = '#_Faktura')

DECLARE @SalesRightID as Integer 
SET @SalesRightID = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = '#_Sales')

DECLARE @ITRightID as Integer
SET @ITRightID = (SELECT Top 1 ID from rights where RightsBez = '__SAL_IT')

DECLARE @GesperrtID as Integer 
SET @GesperrtID = (SELECT Top 1 ID from rights where RightsBez = '__SAL_Funktion gesperrt')






------------------------------------------------------------------------
--IT: alles

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @ITRightID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @ITRightID);

-------------------------------------------------------------------------
--Einkauf 
DECLARE @EinkaufID as Integer 
SET @EinkaufID = (SELECT TOP 1 ID FROM Rights where RightsBez = '#_Einkauf')

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ((Formclass = 'TFORMLIEF') 
                OR (Formclass = 'TFORMLIEFLSKOANK')
                OR (Formclass = 'TTABLIEFABKO')
                
                )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @EinkaufID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @EinkaufID);
--------------------------------------------------------------------------
-- Zentrallager:

DECLARE @ZentrallagerID as Integer 
SET @ZentrallagerID = (SELECT Top 1 ID from rights where RightsBez = 'Lagerleitung')

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ((Formclass = 'TFORMARTIKEL' AND ActionName = 'ACTOPENBESTAND') 
                OR (Formclass = 'TFORMARTIKELSONSTIGE') 
                OR (Formclass = 'TFORMBKO') 
                OR (Formclass = 'TFORMBKOART') 
                OR (Formclass = 'TFORMLIEF') 
                OR (Formclass = 'TFORMLIEFLSKO') 
                OR (Formclass = 'TFORMLIEFLSKOANK') 
                OR (Formclass = 'TFORMLIEFRKOCHECKASK')
                OR (Formclass = 'TFORMARTISTAN')
                OR (Formclass = 'TFORMEMBLEMARTI' AND Actionname = 'ACTCOPY')
                OR (Formclass = 'TFORMFIRMA' AND Actionname = 'ACTLIEF')
                OR (Formclass = 'TFORMLIEF')
                OR (Formclass = 'TFORMLIEFLSKOANK')
                OR (Formclass = 'TTABLIEFABKO')
                OR (Formclass = 'TTABMINMAX')
                OR (Formclass = 'TTABBESTAND')
                OR (Formclass = 'TTABARGRLIEF')
        )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @ZentrallagerID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @ZentrallagerID);

----------------------------------------------------------------------------------
--Produktion:
DECLARE @ProduktionID as Integer 
SET @ProduktionID = (SELECT Top 1 ID from rights where RightsBez = 'Produktion')

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ((Formclass = 'TADVANTEXMAINFORM' AND ActionName = 'ACTCONTAINERVORBEREITEN') 
                OR (Formclass = 'UHFPOOLTEILEPZ' AND actionname = 'DRUCKCONTAINERSCHEIN')
                OR (Formclass = 'TFORMOPTEILEPZ')
                OR (Formclass = 'TFORMREPARATUR')
                OR (Formclass = 'TFORMSCANOUTLOTS')
                OR (Formclass = 'TFORMSCANOUTLOTSAHMODUS')
                OR (Formclass = 'TFORMSCANOUTSORTIERREGALVPS')

                )
        -- and actionname, formclass,....
        
        -- SELECT ID FROM MODACT JOIN FORMACT ON MODACT.FormActID = FormAct.ID Where Formclass like .... 
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @ProduktionID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @ProduktionID);
---------------------------------------------------------------------------------------------------------
--OP:
DECLARE @OPID as Integer 
SET @OPID = (SELECT Top 1 ID from rights where RightsBez = '__SAL_OPMaster')

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ((Formclass = 'TFORMSCANCLEANROOMSTERICHARGE')
            

                )
        -- and actionname, formclass,....
        
        -- SELECT ID FROM MODACT JOIN FORMACT ON MODACT.FormActID = FormAct.ID Where Formclass like .... 
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @OPID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @OPID);

-------------------------------------------------------------------------
--Kundenservice:

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ((Formclass = 'TADVANTEXMAINFORM' AND ActionName = 'ACTCONTAINERVORBEREITEN') 
                OR (Formclass = 'TFORMARTIKEL' AND ActionName = 'ACTOPENBESTAND') 
                OR (Formclass = 'TFORMARTISTAN') 
                OR (Formclass = 'TFORMBEREICH') 
                OR (Formclass = 'TFORMBKO') 
                OR (Formclass = 'TFORMINFOMEMO') 
                OR (Formclass = 'TFORMKDARTI') 
                OR (Formclass = 'TFORMKUNDEN')
                OR (Formclass = 'TFORMINFOMEMO')
                OR (Formclass = 'TFORMKDARTI')
                OR (Formclass = 'TTABVERARTI')
                OR (Formclass = 'TTABVSA')
                OR (Formclass = 'TTABVSAANF')
                OR (Formclass = 'TTABVSAANFOFFEN')
                OR (Formclass = 'TTABVSALIEFA')
                OR (Formclass = 'TFORMOPTEILEPZ')
                OR (Formclass = 'TFORMREPARATUR')
                OR (Formclass = 'TFORMVSA')
                OR (Formclass = 'TFORMVSALEAS')
                )
        -- and actionname, formclass,....
        
        -- SELECT ID FROM MODACT JOIN FORMACT ON MODACT.FormActID = FormAct.ID Where Formclass like .... 
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @KSRightID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @KSRightID);


-----------------------------------------------------------------------------
--Kundenserviceleitung


-----------------------------------------------------------------------------
--Faktura:
DECLARE @FakturaID as Integer 
SET @FakturaID = (SELECT Top 1 ID from rights where RightsBez = '#_Faktura')

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and (
                (Formclass = 'TFORMARTIKEL' AND ActionName = 'ACTOPENBESTAND') 
                OR (Formclass = 'TFORMARTISTAN') 
                OR (Formclass = 'TFORMASKPREISERHOEHUNGDURCHFUEHREN') 
                OR (Formclass = 'TFORMBEREICH') 
                OR (Formclass = 'TFORMKONTEN') 
                OR ((Formclass = 'TFORMLSKO') AND actionname = 'ACTCHANGEKST' ) 
                OR (Formclass = 'TFORMMAHNUNGEN') 
                OR (Formclass = 'TFORMPEKOIMPORT') 
                OR (Formclass = 'TFORMPREISERHOEHUNG') 
                OR (Formclass = 'TFORMRKOTYPE') 
                OR (Formclass = 'TFORMRKO')
                OR (Formclass = 'TMAINFORMMENU' AND Actionname = 'ACTPEKOIMPORT')
                OR (Formclass = 'TMAINFORMMENU' AND Actionname = 'ACTRWTEMPLA') 
                OR (Formclass = 'TMAINFORMMENU' AND Actionname = 'ACTRWART') 
                OR (Formclass = 'TFORMRWTEMPLA')
                OR (Formclass = 'TFORMRWCONFIG')
                OR (Formclass = 'TFORMPREISERHOEHUNG')
                OR (Formclass = 'TFORMASKPREISERHOEHUNGDURCHFUEHREN')
                OR (Formclass = 'TTABMAHNKO')
                

                )
        -- and actionname, formclass,....
        
        -- SELECT ID FROM MODACT JOIN FORMACT ON MODACT.FormActID = FormAct.ID Where Formclass like .... 
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @FakturaID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @FakturaID);






-----------------------------------------------------------------------
-- Vertrieb:
DECLARE @SalesID as Integer 
SET @SalesID = (SELECT Top 1 ID from rights where RightsBez = '#_Sales')

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ((Formclass = 'TFORMINTKUNDEN') 
                OR (Formclass = 'TTABABSATZCH') 
                OR (Formclass = 'TTABMITARWOPA')
                OR (Formclass = 'TFORMMITARBEI' AND ActionName = 'ACTEDTMITARWOP')
                OR (Formclass = 'TTABABSATZLAUFZEIT')
                
                )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @SalesID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @SalesID);






----------------------------------------------------------------------
--Fuhrpark 
DECLARE @FuhrparkID as Integer 
SET @FuhrparkID = (SELECT Top 1 ID from rights where RightsBez = '#_Fuhrpark')


MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ((Formclass = 'TFORMTOUREN') 
                                
                )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @FuhrparkID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @FuhrparkID);