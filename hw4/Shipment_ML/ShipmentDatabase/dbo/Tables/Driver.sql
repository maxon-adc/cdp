﻿CREATE TABLE [dbo].[Driver] (
    [Id]        INT            IDENTITY (1, 1) NOT NULL,
    [FirstName] NVARCHAR (100) NOT NULL,
    [LastName]  NVARCHAR (100) NOT NULL,
    [Birthdate] NVARCHAR (100) NOT NULL,
    [IsDeleted] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [pk_Driver] PRIMARY KEY CLUSTERED ([Id] ASC)
);

