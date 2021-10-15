IF (SELECT COUNT(*) AS Anz FROM dbSystem.dbo.SettDefs WHERE dbSystem.dbo.SettDefs.Parameter = N'ANF_AUTO_NACHLIEF_IMMER') = 0
BEGIN
  DECLARE @ID INT;

  SET @ID = (SELECT MAX(ID) FROM dbSystem.dbo.SettDefs) + 1;

  INSERT INTO dbSystem.dbo.SettDefs (ID, Parameter, DefaultWert, Kategorie, Bez, InfoText, SettParaID, OnTheFly, AllowAusnahme, Update_, User_)
  VALUES (@ID, 'ANF_AUTO_NACHLIEF_IMMER', '0', 'Anforderungen Packzettel', 'Nachlieferungen: automatische Nachlieferungen immer?', 'Im Kundenbereich gibt es die Möglichkeit einzustellen, dass Minderlieferungen automatisch ohne Rückfrage zu Nachlieferungen führen sollen. Bei dieser Einstellung wird jedoch berücksichtigt, wenn es bereits eine zukünftige Anforderung gibt, dass nicht automatisch nachgeliefert wird, wenn die bereits angeforderte Menge größer als die noch offene nachzuliefernde Menge wäre.
Mit diesem Setting kann die Prüfung auf eine ggf. vorhandene zukünftige Anforderung deaktiviert werden, so dass die nachzuliefernde Menge in jedem Fall automatisch angefordert wird.', 10, 0, 0, CAST('2021-10-15 09:43:01' AS DATETIME2(3)), 'TERBRACK'
    );
END;