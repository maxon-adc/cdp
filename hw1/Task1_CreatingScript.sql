USE master;

IF DB_ID('Shipment_ML') IS NOT NULL
BEGIN
	ALTER DATABASE [Shipment_ML] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Shipment_ML];
END

CREATE DATABASE [Shipment_ML];

GO

USE Shipment_ML;

CREATE TABLE dbo.ContactInformation (
	Id INT IDENTITY(1, 1) NOT NULL,
	FirstName NVARCHAR(100) NOT NULL,
	LastName NVARCHAR(100) NOT NULL,
	CellPhone NVARCHAR(20) NOT NULL
);

ALTER TABLE dbo.ContactInformation   
	ADD CONSTRAINT pk_ContactInformation PRIMARY KEY CLUSTERED(Id ASC);

CREATE TABLE dbo.Warehouse (
	Id INT IDENTITY(1, 1) NOT NULL,
	City NVARCHAR(50) NOT NULL,
	[State] NVARCHAR(50) NOT NULL
);

ALTER TABLE dbo.Warehouse   
	ADD CONSTRAINT pk_Warehouse PRIMARY KEY CLUSTERED(Id ASC);

CREATE TABLE dbo.Truck (
	Id INT IDENTITY(1, 1) NOT NULL,
	BrandName NVARCHAR(100) NOT NULL,
	RegistrationNumber NVARCHAR(100) NOT NULL,
	[Year] NVARCHAR(50) NULL,
	Payload INT NOT NULL,
	FuelConsumption INT NOT NULL,
	Volume INT NOT NULL,
);

ALTER TABLE dbo.Truck   
	ADD CONSTRAINT pk_Truck PRIMARY KEY CLUSTERED(Id ASC);

CREATE TABLE dbo.Driver (
	Id INT IDENTITY(1, 1) NOT NULL,
	FirstName NVARCHAR(100) NOT NULL,
	LastName NVARCHAR(100) NOT NULL,
	Birthdate NVARCHAR(100) NOT NULL
);

ALTER TABLE dbo.Driver   
	ADD CONSTRAINT pk_Driver PRIMARY KEY CLUSTERED(Id ASC);

CREATE TABLE dbo.DriverTruck
(
	TruckId INT NOT NULL,
	DriverId INT NOT NULL
);

ALTER TABLE dbo.DriverTruck
	ADD CONSTRAINT pk_DriverTruck PRIMARY KEY (DriverId, TruckId),
		CONSTRAINT fk_DriverTruck_Driver FOREIGN KEY (DriverId) REFERENCES dbo.Driver (Id),
		CONSTRAINT fk_DriverTruck_Truck FOREIGN KEY (TruckId) REFERENCES dbo.Truck (Id)

CREATE TABLE dbo.[Route] (
	Id INT IDENTITY(1, 1) NOT NULL,
	OriginId INT NULL,
	DestinationId INT NULL,
	Distance INT NOT NULL
);

ALTER TABLE dbo.[Route]   
	ADD CONSTRAINT pk_Route PRIMARY KEY CLUSTERED(Id ASC),
		CONSTRAINT fk_Route_Origin FOREIGN KEY (OriginId) REFERENCES dbo.Warehouse (Id),
		CONSTRAINT fk_Route_Destination FOREIGN KEY (DestinationId) REFERENCES dbo.Warehouse (Id);

CREATE TABLE dbo.Shipment (
	Id INT IDENTITY(1, 1) NOT NULL,
	RouteId INT NOT NULL,
	DriverId INT NOT NULL,
	TruckId INT NOT NULL,
	DepartureDate DATETIME NOT NULL,
	DeliveryDate DATETIME NOT NULL
);

ALTER TABLE dbo.Shipment   
	ADD CONSTRAINT pk_Shipment PRIMARY KEY CLUSTERED(Id ASC),
		CONSTRAINT fk_Shipment_Route FOREIGN KEY (RouteId) REFERENCES dbo.[Route] (Id),
		CONSTRAINT fk_Shipment_Driver FOREIGN KEY (DriverId) REFERENCES dbo.Driver (Id),
		CONSTRAINT fk_Shipment_Truck FOREIGN KEY (TruckId) REFERENCES dbo.Truck (Id);

CREATE TABLE dbo.Cargo (
	Id INT IDENTITY(1, 1) NOT NULL,
	[Weight] INT NOT NULL,
	Volume INT NOT NULL,
	SenderId INT NOT NULL,
	RecipientId INT NOT NULL,
	ShipmentId INT NULL
);

ALTER TABLE dbo.Cargo   
	ADD CONSTRAINT pk_Cargo PRIMARY KEY CLUSTERED(Id ASC),
		CONSTRAINT fk_Cargo_Sender FOREIGN KEY (SenderId) REFERENCES dbo.ContactInformation (Id),
		CONSTRAINT fk_Cargo_Recipient FOREIGN KEY (RecipientId) REFERENCES dbo.ContactInformation (Id),
		CONSTRAINT fk_Cargo_Shipment FOREIGN KEY (ShipmentId) REFERENCES dbo.Shipment (Id) ON DELETE SET NULL;

GO

CREATE VIEW dbo.vNewId
AS
SELECT NEWID() AS Id

GO

CREATE FUNCTION dbo.GenerateRandomDate (@dateFrom DATETIME, @dateTo DATETIME)
RETURNS DATETIME
AS BEGIN
    DECLARE @days_diff AS INT = cast(@dateTo - @dateFrom AS INT);
	DECLARE @departureDate DATETIME;

	SELECT @departureDate = @dateFrom +
		DATEADD(second, ABS(CHECKSUM((SELECT Id FROM dbo.vNewId)) % 60), 0) +
		DATEADD(minute, ABS(CHECKSUM((SELECT Id FROM dbo.vNewId)) % 60), 0) +
		DATEADD(hour, ABS(CHECKSUM((SELECT Id FROM dbo.vNewId)) % 24), 0) +
		DATEADD(day, ABS(CHECKSUM((SELECT Id FROM dbo.vNewId)) % @days_diff), 0);

    RETURN @departureDate
END

GO

CREATE PROCEDURE dbo.ImportCSV (@tableName NVARCHAR(100), @path NVARCHAR(100))
AS BEGIN
	DECLARE @sqlCommand NVARCHAR(500);

	SET @sqlCommand = 
		'BULK INSERT ' + @tableName +
		' FROM ''' + @path  + 
		''' WITH (
		FIELDTERMINATOR = '','',
		ROWTERMINATOR = ''\n'',
		FIRSTROW = 2
		);'

	EXEC(@sqlCommand);
END