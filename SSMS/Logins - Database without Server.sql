SELECT dp.name, dp.type
  FROM sys.database_principals dp
    LEFT OUTER JOIN sys.server_principals sp ON dp.sid = sp.sid
  WHERE dp.type IN ('S', 'U', 'G')
    AND sp.sid IS NULL
    AND dp.authentication_type_desc <> 'NONE'
ORDER BY name ASC;