USE Shipment_ML;

GO

CREATE EXTERNAL DATA SOURCE CdpBlobStorage
	WITH (
		TYPE = BLOB_STORAGE,
		LOCATION = 'https://shipment.blob.core.windows.net/importdata');

GO

BULK INSERT dbo.Truck 
FROM 'Trucks.csv'
WITH (DATA_SOURCE = 'CdpBlobStorage', FORMAT='CSV', FIRSTROW = 2);

BULK INSERT dbo.Driver 
FROM 'Drivers.csv' 
WITH (DATA_SOURCE = 'CdpBlobStorage', FORMAT='CSV', FIRSTROW = 2);

BULK INSERT dbo.DriverTruck 
FROM 'Drivers-Trucks.csv' 
WITH (DATA_SOURCE = 'CdpBlobStorage', FORMAT='CSV', FIRSTROW = 2);

BULK INSERT dbo.Warehouse 
FROM 'Warehouses.csv' 
WITH (DATA_SOURCE = 'CdpBlobStorage', FORMAT='CSV', FIRSTROW = 2);