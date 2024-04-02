
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
        and (   (Formclass = 'TFORMLIEFFIRM') 
                OR (Formclass = 'TFORMDIFFERENZBUCHUNGERFASSEN')
                OR ((Formclass = 'TFORMARTIKEL') AND (ACTIONNAME = 'ACTMISPOOLPRODFORM'))
                OR ((Formclass = 'TFORMARTIKEL') AND (ACTIONNAME = 'ACTEDITEKPREISSEIT'))
                OR ((Formclass = 'TTABBESTAND') AND (Actionname = 'ACTEINKAUFSLAGER'))
                OR ((Formclass = 'TTABBESTAND') AND (Actionname = 'ACTUNCHECKEINKAUFSLAGER'))
                OR ((Formclass = 'TTABAUFTRAEGE') AND (Actionname = 'ACTINFOWEBAUFTRAG'))
  --              OR (Formclass = 'TFORMLIEFLSKOANK')
  --              OR (Formclass = 'TTABLIEFABKO')
                
                )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @EinkaufID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @EinkaufID);
--------------------------------------------------------------------------
-- Zentrallager:

DECLARE @ZentrallagerID as Integer 
SET @ZentrallagerID = (SELECT Top 1 ID from rights where RightsBez = '#_Lageradmin')

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ((Formclass = 'TFORMBKO') 
                OR (Formclass = 'TFORMLIEFFIRM')
                OR (Formclass = 'TFORMDIFFERENZBUCHUNGERFASSEN')
                OR ((Formclass = 'TFORMARTIKEL') AND (ACTIONNAME = 'ACTMISPOOLPRODFORM'))
                OR (Formclass = 'TFORMCREATESTMOVKO')
                OR (Formclass = 'TFORMINSLAGERMANUELLLAGERORTE')
                OR (Formclass = 'TFORMEMBLEMARTI')
                OR (Formclass = 'TTABEINVBESTAND')
                OR (Formclass = 'TTABBESTELLTOBWOHLVORHANDEN')
                OR ((Formclass = 'TFORMARTIKEL') AND (ACTIONNAME = 'ACTEDITEKPREISSEIT'))
                OR ((Formclass = 'TFORMLIEFLSKO') AND (ACTIONNAME = 'ACTPREISETIKETT'))
                OR ((Formclass = 'TTABBESTAND') AND (Actionname = 'ACTEINKAUFSLAGER'))
                OR ((Formclass = 'TTABBESTAND') AND (Actionname = 'ACTUNCHECKEINKAUFSLAGER'))
                OR ((Formclass = 'TTABAUFTRAEGE') AND (Actionname = 'ACTINFOWEBAUFTRAG'))
                
              --  OR (Formclass = 'TFORMARTIKELSONSTIGE') 
              
        )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @ZentrallagerID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @ZentrallagerID);


-- damit Lagerleitung mind. gleiche Rechte wie Lageradmin hat zusammenführen der beiden

DECLARE @RightToMergeInto as NVARCHAR(250) = '#_Lagerleitung'
DECLARE @RightToMergeFrom as NVARCHAR(250) = '#_Lageradmin'

DECLARE @RightIntoID as Integer = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = @RightToMergeInto)
DECLARE @RightFromID as Integer = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = @RightToMergeFrom)

MERGE INTO MODACT
    USING (
        SELECT FormactID, RightsID
        FROM MODACT 
        WHERE MODACT.RightsID = @RightFromID
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @RightIntoID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @RightIntoID);
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
        and ((Formclass = 'TFORMCONTAINERVERWALTUNG')
                OR (Formclass = 'TFORMSCANOUTSORTIERREGALVPS') 
                OR (Formclass = 'TFORMUEBERNAHMETEILPATCHEN') 
                OR (Formclass = 'TADVANTEXMAINFORM' AND ACTIONNAME = 'ACTMISPOOLPRODFORM') 
                OR (Formclass = 'TTABANFKO')
--                OR (Formclass = 'UHFPOOLTEILEPZ' AND actionname = 'DRUCKCONTAINERSCHEIN')


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
        and ((Formclass = 'TFORMOPQUALITYCTRLZIELWAHL')
            OR (Formclass = 'TFORMOPEINWEGKOMMISSIONIEREN')
            OR  (Formclass = 'TFORMSCANCLEANROOMSTERICHARGE')
            

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
        SELECT FormactID,RightsID
        From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        --AND rights.id = @ksrightID
        and ((Formclass = 'TADVANTEXMAINFORM' AND ActionName = 'ACTHISTPRIO')
                 OR (Formclass = 'TFORMSCANOUTSORTIERREGALVPS') 
                 OR (Formclass = 'TFORMDIFFERENZBUCHUNGERFASSEN')
                 OR (Formclass = 'TFORMINFOMEMO') 
                 OR (Formclass = 'TFORMVSA')
                 OR (Formclass = 'TFORMVSAANF')
                 OR (Formclass = 'TFORMVSALEAS')
                 OR (Formclass = 'TFORMWEBUSER')
                 OR (Formclass = 'TFROMBDETAETIGKEITENKONTROLLE')
                 OR (Formclass = 'TTABKDARTI')
                 OR (Formclass = 'TFORMKUNDEN')
                 OR (Formclass = 'TTABTRAEGER')
                 OR (Formclass = 'TTABVSA')
                 OR (Formclass = 'TTABVSAANFOFFEN')
                 OR (Formclass = 'TTABFAHRTLSKO')
                 OR (Formclass = 'TTABANFKO')
                 OR ((Formclass = 'TTABBESTAND') AND (Actionname = 'ACTEINKAUFSLAGER'))
                 OR ((Formclass = 'TTABBESTAND') AND (Actionname = 'ACTUNCHECKEINKAUFSLAGER'))
                 OR ((Formclass = 'TTABAUFTRAEGE') AND (Actionname = 'ACTINFOWEBAUFTRAG'))
                 OR ((Formclass = 'TMAINFORMMENU') AND (ActionName = 'ACTWEBAUFTRAEGE'))

                )
        -- and actionname, formclass,....
        
        -- SELECT ID FROM MODACT JOIN FORMACT ON MODACT.FormActID = FormAct.ID Where Formclass like .... 
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @KSRightID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @KSRightID);

--damit KundenserviceLeitung mind gleiche Rechte wie Kundenservice hat zusammenführen der beiden

DECLARE @RightToMergeInto1 as NVARCHAR(250) = '#_Kundenserviceleitung'
DECLARE @RightToMergeFrom1 as NVARCHAR(250) = '#_Kundenservice'

DECLARE @RightIntoID1 as Integer = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = @RightToMergeInto1)
DECLARE @RightFromID1 as Integer = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = @RightToMergeFrom1)

MERGE INTO MODACT
    USING (
        SELECT FormactID, RightsID
        FROM MODACT 
        WHERE MODACT.RightsID = @RightFromID1
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @RightIntoID1
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @RightIntoID1);

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
        and ((Formclass = 'TFORMPREISERHOEHUNG') 
                OR (Formclass =  'TFORMRKO')
                OR (Formclass = 'TFORMRKOANLAG')
                OR ((Formclass = 'TTABEINZHIST') AND (Actionname = 'ACTTEILSOFARESTWERT'))
                OR (Formclass = 'TTABFAHRTLSKO')

               
                

                )
        -- and actionname, formclass,....
        
        -- SELECT ID FROM MODACT JOIN FORMACT ON MODACT.FormActID = FormAct.ID Where Formclass like .... 
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @FakturaID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @FakturaID);

--damit Fakturaleitung mind gleiche Rechte wie Faktura hat zusammenführen der beiden

DECLARE @RightToMergeInto2 as NVARCHAR(250) = '#_Faktura_Leitung'
DECLARE @RightToMergeFrom2 as NVARCHAR(250) = '#_Faktura'

DECLARE @RightIntoID2 as Integer = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = @RightToMergeInto2)
DECLARE @RightFromID2 as Integer = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = @RightToMergeFrom2)

MERGE INTO MODACT
    USING (
        SELECT FormactID, RightsID
        FROM MODACT 
        WHERE MODACT.RightsID = @RightFromID2
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @RightIntoID2
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @RightIntoID2);



-----------------------------------------------------------------------
-- Vertrieb:
DECLARE @SalesID as Integer 
SET @SalesID = (SELECT Top 1 ID from rights where RightsBez = '#_Sales')

--DECLARE @AftersalesID as Integer 
--SET @AftersalesID = (SELECT Top 1 ID from rights where RightsBez = '#_AfterSales')

MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ( (Formclass = 'TTABABSATZCH')
                OR(Formclass = 'TTABMITARWOPA') 
                OR (Formclass = 'TFORMKUNDEN')
               

                )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @SalesID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @SalesID);


--Sync neuer Berechtigungen zw Sales und Aftersales

DECLARE @RightToMergeInto3 as NVARCHAR(250) = '#_Sales'
DECLARE @RightToMergeFrom3 as NVARCHAR(250) = '#AfterSales'

DECLARE @RightIntoID3 as Integer = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = @RightToMergeInto3)
DECLARE @RightFromID3 as Integer = (SELECT TOP 1 ID FROM RIGHTS WHERE RightsBez = @RightToMergeFrom3)

MERGE INTO MODACT
    USING (
        SELECT FormactID, RightsID
        FROM MODACT 
        WHERE MODACT.RightsID = @RightFromID3
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @RightIntoID3
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @RightIntoID3);




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
        and ((Formclass = 'TFORMCONTAINERVERWALTUNG') 
        OR (Formclass = 'TTABFAHRTLSKO')
                                
                )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @FuhrparkID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @FuhrparkID);




--------------------------------------------------------------------------------------------
--ohne Einschränkung

DECLARE @oEID as Integer 
SET @oEID = (SELECT Top 1 ID from rights where RightsBez = '(ohne Beschränkung)')


MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and ((Formclass = 'TFORMARTIKEL' AND ACTIONNAME = 'ACTOPENBESTAND') 
                OR (Formclass = 'TFORMJPG')
                OR (Formclass = 'TFORMPRINTPREVIEW')
                OR (Formclass = 'TFORMPROJVIEW')
                OR (Formclass = 'TFORMREPARATUR')
                OR (Formclass = 'TTABHISTORY')
                OR ((Formclass = 'TFORMKDAUSGRPID') AND (ActionName = 'ACTMASSENUEBERSETZUNG'))
                OR (formclass = 'TFORMMENUTREE')
                OR (formclass = 'TFORMMSG')
                OR (Formclass = 'TTABSHOWWITHMENU')
                OR (Formclass = 'TTABSCHRANKFACHDRUCKLEITSTAND')
                OR (Formclass = 'TTABSERVICEVIEW')
                OR (Formclass = 'TTABMSGBOX')
                OR (Formclass = 'TFORMPRINTALLTEILEFORLAGERORT')
                OR ((Formclass = 'TADVANTEXMAINFORM') AND (ActionName = 'ACTADDSTARTMSG'))
                OR ((Formclass = 'TADVANTEXMAINFORM') AND (ActionName = 'ACTASSISTPROKUNDENVSA'))
                OR ((Formclass = 'TADVANTEXMAINFORM') AND (ActionName = 'ACTUMLAGERNBARCODESCMSCM'))
                OR ((Formclass = 'TADVANTEXMAINFORM') AND (ActionName = 'ACTSCANLSCONTLSKOPERMA'))
                             



                                
                )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @oEID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @oEID);


--------------------------------------------------------------------------------------------
--reporting

DECLARE @ReportingID as Integer 
SET @ReportingID = (SELECT Top 1 ID from rights where RightsBez = '#_Reporting')


MERGE INTO MODACT
    USING (
        SELECT FormactID,RightsID From RIGHTS
        JOIN MODACT ON MODACT.RightsID = Rights.ID
        JOIN FORMACT ON MODACT.FormActID = FormAct.ID
        where rights.id = 901149
        and (((Formclass = '_CHARTKO_') AND (ACTIONNAME = 'ID01100636')) 
            OR ((Formclass = '_CHARTKO_') AND (ACTIONNAME = 'ID01100660'))
            OR ((Formclass = '_CHARTKO_') AND (ACTIONNAME = 'ID01100661'))
        
                                
                )
    ) as source (FormactID,RightsID) ON source.formactid = modact.formactID AND modact.rightsID = @ReportingID
    WHEN NOT MATCHED THEN
        INSERT (FormactID, RightsID) VALUES (Source.FormactID, @ReportingID);


-- TODO Later: Neue Funktionen truncaten