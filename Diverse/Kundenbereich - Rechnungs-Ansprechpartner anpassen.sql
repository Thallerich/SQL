DECLARE @RechKoService int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'SVOBKU');
DECLARE @CustomerService int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'NILSEL')

UPDATE KdBer SET RechKoServiceID = @RechKoService
WHERE KdBer.ServiceID = @CustomerService
  AND KdBer.RechKoServiceID <> @RechKoService;