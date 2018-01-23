WITH CTE AS (
  SELECT t.name AS TableName,
    t.create_date AS TableCreation,
    SUM(s.row_count) AS [Rows],
    SUM(s.used_page_count) AS used_page_count,
    SUM(CASE WHEN i.index_id < 2
        THEN s.in_row_data_page_count + s.lob_used_page_count + s.row_overflow_used_page_count
        ELSE s.lob_used_page_count + s.row_overflow_used_page_count
        END
      ) AS pages
  FROM sys.dm_db_partition_stats AS s
  INNER JOIN sys.tables AS t ON s.object_id = t.object_id
  INNER JOIN sys.indexes AS i ON t.object_id = i.object_id AND s.index_id = i.index_id
  GROUP BY t.name, t.create_date
)
SELECT TableName,
  FORMAT(TableCreation, 'd', 'de-AT') AS TableCreation,
  FORMAT([Rows], 'N0', 'de-AT') AS [Rows],
  FORMAT(CAST((CTE.used_page_count * 8.) / 1024 AS decimal(10,2)), 'N2', 'de-AT') AS [FullSize MB],
  FORMAT(CAST((CTE.pages * 8.) / 1024 AS decimal(10,2)), 'N2', 'de-AT') AS [TableSize MB],
  FORMAT(CAST(((
    CASE WHEN CTE.used_page_count > CTE.pages
      THEN CTE.used_page_count - CTE.pages
      ELSE 0
    END
    ) * 8. / 1024) AS decimal(10,2)), 'N2', 'de-AT') AS [IndexSize MB]
FROM CTE
ORDER BY CTE.[Rows] DESC