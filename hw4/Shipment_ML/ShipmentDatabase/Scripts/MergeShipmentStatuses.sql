﻿MERGE INTO dbo.ShipmentStatus AS t
USING (VALUES(N'Scheduled'),(N'Departured'),(N'Arrived'),(N'Cancelled')) AS s (DisplayName)
ON (t.DisplayName = s.DisplayName)
WHEN MATCHED AND (t.DisplayName <> s.DisplayName) THEN
    UPDATE SET
    DisplayName = s.DisplayName
WHEN NOT MATCHED BY TARGET THEN
    INSERT(DisplayName)
    VALUES(s.DisplayName)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE;