WITH MdeDevices AS (
  SELECT MdeDev.Art, COUNT(MdeDev.ID) AS [Anzahl Geräte]
  FROM MdeDev
  WHERE MdeDev.ID > 0
    AND MdeDev.Status = N'A'
  GROUP BY MdeDev.Art
)
SELECT App = 
  CASE MdeDevices.Art
    WHEN N'A' THEN N'AdvanTex Mobile (Inventur) v1'
    WHEN N'B' THEN N'Besys (FTP)'
    WHEN N'C' THEN N'AdvanTex Mobile (Inventur) v2'
    WHEN N'D' THEN N'AdvanTex Bag Packing'
    WHEN N'E' THEN N'Easy (FTP)'
    WHEN N'F' THEN N'AdvanTex Mobile (Fuhrpark)'
    WHEN N'G' THEN N'Advantex Self-Service'
    WHEN N'H' THEN N'AdvanTex Service Driver'
    WHEN N'I' THEN N'AdvanTex Order'
    WHEN N'J' THEN N'AdvanTex Sales'
    WHEN N'K' THEN N'AdvanTex Container Expedition'
    WHEN N'L' THEN N'AdvanTex Wearer Companion'
    WHEN N'M' THEN N'AdvanTex Locker Control'
    WHEN N'N' THEN N'AdvanTex Pool Delivery Scan (UHF Service Driver)'
    WHEN N'O' THEN N'AdvanTex Pool Inventory'
    WHEN N'P' THEN N'AdvanTex Dispatch'
    WHEN N'U' THEN N'Bulk Reading (FTP)'
    WHEN N'X' THEN N'Exite (FTP)'
    ELSE N'(unknown)'
  END,
  MdeDevices.[Anzahl Geräte]
FROM MdeDevices
ORDER BY MdeDevices.Art;