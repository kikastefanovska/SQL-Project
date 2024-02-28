------------------------------------------------------------  Project Intro  ---------------------------------------------------------

					--- We need to build Database solution for a bicycle company selling bicycle products -------

-----------------------------------------------------------  Project Code  -------------------------------------------------------------

--=================================================================================================================================================
-- Create Database:
--=================================================================================================================================================


USE [master] 
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'BicycleStore')
ALTER DATABASE [BicycleStore] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

USE [master]
GO

DROP DATABASE IF EXISTS [BicycleStore]
GO

CREATE DATABASE [BicycleStore]
GO

USE [BicycleStore]
GO

DROP TABLE IF EXISTS [dbo].[Customers]
GO

DROP TABLE IF EXISTS [dbo].[Employee]
GO

DROP TABLE IF EXISTS [dbo].[Products]
GO

DROP TABLE IF EXISTS [dbo].[Sales]
GO

DROP TABLE IF EXISTS [dbo].[Store]
GO


--=================================================================================================================================================
-- Create Tables:
--=================================================================================================================================================

CREATE TABLE [dbo].[Customers]
(
	[ID] INT IDENTITY (1,1) NOT NULL,
	[FirstName]	[NVARCHAR] (100) NOT NULL,
	[LastName] [NVARCHAR] (100) NOT NULL,
	[Gender] [NCHAR] (1) NOT NULL,	
	[City] [NVARCHAR] (100) NOT NULL,
	CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED
	(
	[ID] ASC
	)
)
GO

CREATE TABLE [dbo].[Employee]
(	
	[ID] INT IDENTITY (1,1) NOT NULL,
	[FirstName] [NVARCHAR] (100) NOT NULL,
	[LastName] [NVARCHAR] (100) NOT NULL,
	[Gender] [NCHAR] (1) NOT NULL,
	[JobTitle] [NVARCHAR] (100) NOT NULL,
	CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED
	(
	[ID] ASC
	)
)
GO

CREATE TABLE [dbo].[Store]
(
	[ID] INT IDENTITY (1,1) NOT NULL,
	[StoreName] [NVARCHAR] (100) NOT NULL,
	[Location] [NVARCHAR] (100) NOT NULL,
	CONSTRAINT [PK_Store] PRIMARY KEY CLUSTERED
	(
	[ID] ASC
	)
)
GO

CREATE TABLE [dbo].[Products]
(
	[ID] INT IDENTITY (1,1) NOT NULL,
	[Product] [NVARCHAR] (100) NOT NULL,
	[Price] [NVARCHAR] (20) NOT NULL,
	CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED
	(
	[ID] ASC
	)
)
GO

CREATE TABLE [dbo].[Sales]
(
	[ID] INT IDENTITY (1,1) NOT NULL,
	[EmployeeID] INT NOT NULL,
	[StoreID] INT NOT NULL,
	[ProductID] INT NOT NULL,
	[CustomerID] INT NOT NULL,
	[TransactionDate] [DATETIME] NOT NULL,
	[Amount] [DECIMAL] (20,2) NOT NULL,
	CONSTRAINT [PK_Sales] PRIMARY KEY CLUSTERED
	(
	[ID] ASC
	)
)
GO

--===============================================================================================================================================
-- Creates Table Constraints - Foreign Keys:
--===============================================================================================================================================

ALTER TABLE [dbo].[Sales] WITH CHECK
ADD CONSTRAINT [FK_Sales_Employee] FOREIGN KEY (EmployeeID)
REFERENCES [dbo].[Employee] (ID)
GO

ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [FK_Sales_Employee]
GO

ALTER TABLE [dbo].[Sales] WITH CHECK
ADD CONSTRAINT [FK_Sales_Store] FOREIGN KEY (StoreID)
REFERENCES [dbo].[Store] (ID)

ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [FK_Sales_Store]
GO

ALTER TABLE [dbo].[Sales] WITH CHECK
ADD CONSTRAINT [FK_Sales_Products] FOREIGN KEY (ProductID)
REFERENCES [dbo].[Products] (ID)

ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [FK_Sales_Products]
GO

ALTER TABLE [dbo].[Sales] WITH CHECK
ADD CONSTRAINT [FK_Sales_Customers] FOREIGN KEY (CustomerID)
REFERENCES [dbo].[Customers] (ID)

ALTER TABLE [dbo].[Sales] CHECK CONSTRAINT [FK_Sales_Customers]
GO


--======================================================================================================================================
-- Create Procedures For Initial Load:
--======================================================================================================================================

-- Fill Customers table with records from IWCBank--
-- Customers table should have 100 customers--
 
 INSERT INTO dbo.Customers (FirstName,LastName,Gender,City)
 SELECT FirstName,LastName,Gender,City
 FROM [IWCBank].[dbo].[Customer]
 WHERE Customer.Id <=100
 GO


-- Fill Employee table with records from IWCBank---
--Employee table should have 7 employees, 1 Managing Director, 1 Accountant and 5 Employees as Salesman--

	INSERT INTO dbo.Employee (FirstName,LastName,Gender,JobTitle)
	SELECT FirstName,LastName,Gender,JobTitle
	FROM [IWCBank].[dbo].[Employee]
	WHERE Employee.ID <=7
	GO
	

	UPDATE dbo.Employee
	SET JobTitle = 'Managing Director'
	WHERE ID IN (1)
	UPDATE dbo.Employee
	SET JobTitle = 'Accountant'
	WHERE ID IN (2)
	UPDATE dbo.Employee
	SET JobTitle = 'Salesman'
	WHERE ID IN (3,4,5,6,7)

-- dbo.Store Manually load :

	INSERT INTO [dbo].[Store] (StoreName,Location)
	VALUES
			('SuperBike','Main Bitola'),
			('Bike guys','BranchPrilep'),
			('RideAllDay','Branch Ohrid'),
			('FastAndFirious','M-Store'),
			('Speed World','E-Store')
GO

-- dbo Product Manually load:

	INSERT INTO [dbo].[Products] (Product,Price)
	VALUES
			('Bicycle','500'),
			('Auxiliary Equipment','300'),
			('Repair Kit','200')
GO

--- Working with transactional table: Generating randomly sales only from Salesman ---

DECLARE @StartDate DATETIME = '2023-01-01'
DECLARE @EndDate DATETIME = '2023-12-31'

;WITH RandomDates AS (
  SELECT TOP 100 DATEADD(second, ABS(CHECKSUM(NEWID())) % DATEDIFF(second, @StartDate, @EndDate), @StartDate) AS TransactionDate
  FROM sys.all_columns ac1
  CROSS JOIN sys.all_columns ac2
)
INSERT INTO dbo.Sales (EmployeeID, StoreID, ProductID, CustomerID, TransactionDate, Amount)
SELECT TOP 100
  e.ID AS EmployeeID,
  s.ID AS StoreID,
  p.ID AS ProductID,
  c.ID AS CustomerID,
  rd.TransactionDate,
  CAST(pr.Price AS DECIMAL(20,2)) AS Amount
FROM dbo.Employee e
CROSS JOIN dbo.Store s
CROSS JOIN dbo.Products p
CROSS JOIN dbo.Products pr
CROSS JOIN dbo.Customers c
CROSS JOIN RandomDates rd
WHERE e.JobTitle = 'Salesman' 
ORDER BY NEWID()

--===============================================================================================================================================
-- Check table queries:
--===============================================================================================================================================

SELECT * FROM dbo.Customers

SELECT * FROM dbo.Employee

SELECT * FROM dbo.Products

SELECT * FROM dbo.Sales

SELECT * FROM dbo.Store
