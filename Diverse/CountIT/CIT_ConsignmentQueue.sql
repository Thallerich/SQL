USE AdvanTexSync

SELECT Location.Description, ConsignmentTask.PackingNumber, ConsignmentTask.SyncState, ConsignmentTask.QueueTimestamp
FROM ConsignmentTask, LaundryAutomation.dbo.Location
WHERE ConsignmentTask.LocationID = Location.LocationID
  AND ConsignmentTask.SyncState < 11
ORDER BY ConsignmentTask.QueueTimestamp ASC;

GO