USE [master]
GO
/****** Object:  Database [u_obarzane]    Script Date: 10.02.2022 14:42:23 ******/
CREATE DATABASE [u_obarzane]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'u_obarzane', FILENAME = N'/var/opt/mssql/data/u_obarzane.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'u_obarzane_log', FILENAME = N'/var/opt/mssql/data/u_obarzane_log.ldf' , SIZE = 66048KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [u_obarzane] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [u_obarzane].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [u_obarzane] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [u_obarzane] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [u_obarzane] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [u_obarzane] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [u_obarzane] SET ARITHABORT OFF 
GO
ALTER DATABASE [u_obarzane] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [u_obarzane] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [u_obarzane] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [u_obarzane] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [u_obarzane] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [u_obarzane] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [u_obarzane] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [u_obarzane] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [u_obarzane] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [u_obarzane] SET  ENABLE_BROKER 
GO
ALTER DATABASE [u_obarzane] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [u_obarzane] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [u_obarzane] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [u_obarzane] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [u_obarzane] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [u_obarzane] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [u_obarzane] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [u_obarzane] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [u_obarzane] SET  MULTI_USER 
GO
ALTER DATABASE [u_obarzane] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [u_obarzane] SET DB_CHAINING OFF 
GO
ALTER DATABASE [u_obarzane] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [u_obarzane] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [u_obarzane] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [u_obarzane] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [u_obarzane] SET QUERY_STORE = OFF
GO
USE [u_obarzane]
GO
/****** Object:  DatabaseRole [Owner]    Script Date: 10.02.2022 14:42:23 ******/
CREATE ROLE [Owner]
GO
/****** Object:  DatabaseRole [IndividualClient]    Script Date: 10.02.2022 14:42:24 ******/
CREATE ROLE [IndividualClient]
GO
/****** Object:  DatabaseRole [Employee]    Script Date: 10.02.2022 14:42:24 ******/
CREATE ROLE [Employee]
GO
/****** Object:  DatabaseRole [CompanyClients]    Script Date: 10.02.2022 14:42:24 ******/
CREATE ROLE [CompanyClients]
GO
/****** Object:  UserDefinedFunction [dbo].[AmountOfIndividualOrders]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[AmountOfIndividualOrders] (
	@clientid int
) returns int as
begin
	declare @count int
	set @count =(select count(*) from orders where clientid=@clientid)
	return @count
end

GO
/****** Object:  UserDefinedFunction [dbo].[FindClientCompany]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[FindClientCompany] (
	@companyname varchar(50),
	@adres varchar(50),
	@phone varchar(50)
) returns int as
begin
	declare @clientid int;
	set @clientid=(select ClientID from ClientCompany where CompanyName=@companyname)
	if (@clientid is null)
		begin
			exec AddClientCompany @companyname,@adres,@phone
			set @clientid=@@identity
		end
	return @clientid
end
GO
/****** Object:  UserDefinedFunction [dbo].[FindClientPerson]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[FindClientPerson] (
	@imie varchar(50),
	@nazwisko varchar(50),
	@adres varchar(50),
	@companyID int=null
) returns int as
begin
	declare @clientid int;
	set @clientid=(select ClientID from ClientPerson where Firstname=@imie and Lastname=@nazwisko)
	if (@clientid is null)
		begin
			exec AddClientPerson @imie,@nazwisko,@adres,@companyID
			set @clientid=@@identity
		end
	return @clientid
end
GO
/****** Object:  UserDefinedFunction [dbo].[GetClientFinishedOrdersCount]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[GetClientFinishedOrdersCount]
(
	@ClientID INT
)
RETURNS INT
AS
BEGIN
	DECLARE @result INT
	SET @result = (SELECT COUNT(*) FROM Orders WHERE ClientID=@ClientID AND OrderDate < GETDATE())
	RETURN @result
END
GO
/****** Object:  UserDefinedFunction [dbo].[GetOrderValue]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[GetOrderValue](
	@orderid int
) returns money as
begin
	declare @value money
	set @value =(select sum(UnitPrice*Quantity*(1-DiscountValue)) 
		from orders inner join [Order Details] on orders.OrderID=[Order Details].OrderID 
			inner join MenuHist on [Order Details].MenuHistID=MenuHist.MenuHistID 
		where orders.OrderID=@orderid)
	return @value
end


GO
/****** Object:  UserDefinedFunction [dbo].[IsTableFree]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[IsTableFree]
(
	@TableID INT,
	@Date DATE
)
RETURNS BIT
AS
BEGIN
	IF (@TableID NOT IN (SELECT TableID FROM TablesAssigned INNER JOIN
		Reservations ON Reservations.ReservationID = TablesAssigned.ReservationID INNER JOIN
		(SELECT ReservationID, Date FROM IndividualReservation UNION
		 SELECT ReservationID, Date FROM PersonalCompanyReservations UNION
		 SELECT ReservationID, Date FROM CompanyReservations) AS AllReservations ON
		 AllReservations.ReservationID = Reservations.ReservationID
		WHERE AllReservations.Date = @Date))
	BEGIN
		RETURN 1
	END

	RETURN 0
END
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[ClientID] [int] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[EmployeeID] [int] NULL,
	[DiscountValue] [real] NOT NULL,
	[Takeaway] [bit] NOT NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ClientPerson]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientPerson](
	[ClientID] [int] NOT NULL,
	[Firstname] [varchar](50) NOT NULL,
	[Lastname] [varchar](50) NOT NULL,
	[Address] [varchar](50) NOT NULL,
	[CompanyID] [int] NULL,
 CONSTRAINT [PK_ClientPerson] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Order Details]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Order Details](
	[OrderID] [int] NOT NULL,
	[MenuHistID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
 CONSTRAINT [PK_Order Details] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC,
	[MenuHistID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MenuHist]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MenuHist](
	[MenuHistID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[Since] [date] NOT NULL,
	[Until] [date] NULL,
	[UnitPrice] [money] NOT NULL,
 CONSTRAINT [PK_MenuHist] PRIMARY KEY CLUSTERED 
(
	[MenuHistID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [varchar](50) NOT NULL,
	[CategoryID] [int] NOT NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[IndividualOrdersView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IndividualOrdersView]
AS
SELECT        dbo.Orders.ClientID, dbo.ClientPerson.Firstname, dbo.ClientPerson.Lastname, dbo.Orders.OrderID, dbo.Products.ProductName, dbo.[Order Details].Quantity, dbo.Orders.DiscountValue, dbo.Orders.OrderDate, 
                         dbo.Orders.Takeaway, dbo.MenuHist.UnitPrice
FROM            dbo.Orders LEFT OUTER JOIN
                         dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID INNER JOIN
                         dbo.ClientPerson ON dbo.Orders.ClientID = dbo.ClientPerson.ClientID LEFT OUTER JOIN
                         dbo.MenuHist ON dbo.[Order Details].MenuHistID = dbo.MenuHist.ProductID LEFT OUTER JOIN
                         dbo.Products ON dbo.MenuHist.ProductID = dbo.Products.ProductID
WHERE        (dbo.Products.ProductName IS NOT NULL)
GO
/****** Object:  View [dbo].[IndividualOrdersValuesView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IndividualOrdersValuesView]
AS
SELECT        ClientID, Firstname, Lastname, OrderID, OrderDate, ROUND(SUM(UnitPrice * Quantity) * (1 - DiscountValue), 2) AS OrderValue
FROM            dbo.IndividualOrdersView
GROUP BY ClientID, Firstname, Lastname, OrderID, OrderDate, DiscountValue
GO
/****** Object:  Table [dbo].[ClientCompany]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ClientCompany](
	[ClientID] [int] NOT NULL,
	[CompanyName] [varchar](50) NOT NULL,
	[Address] [varchar](50) NOT NULL,
	[phone] [varchar](50) NOT NULL,
 CONSTRAINT [PK_ClientCompany] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[CompanyOrdersSumView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[CompanyOrdersSumView] as
	select CompanyName,sum(Quantity*UnitPrice) as [Total value] from orders 
	join ClientCompany on orders.ClientID=ClientCompany.ClientID 
	join [Order Details] on orders.OrderID=[Order Details].OrderID
	join MenuHist on MenuHist.MenuHistID=[Order Details].MenuHistID
	group by CompanyName
GO
/****** Object:  Table [dbo].[Category]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[MenuView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[MenuView] as
select products.ProductName,category.CategoryName,menuhist.UnitPrice 
from menuhist left join products on menuhist.productid=products.productid 
left join category on products.categoryid=category.categoryid 
where menuhist.until is null and menuhist.Since < getdate()
GO
/****** Object:  View [dbo].[CompanyClientReport]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CompanyClientReport]
AS
SELECT        dbo.ClientCompany.CompanyName, Orders.OrderID, dbo.Orders.OrderDate, dbo.Products.ProductName, dbo.[Order Details].Quantity
FROM            dbo.ClientCompany INNER JOIN
                         dbo.Orders ON dbo.ClientCompany.ClientID = dbo.Orders.ClientID INNER JOIN
                         dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID INNER JOIN
                         dbo.Products ON dbo.Products.ProductID = dbo.[Order Details].MenuHistID INNER JOIN
                         dbo.MenuHist ON dbo.Products.ProductID = dbo.MenuHist.ProductID
GO
/****** Object:  View [dbo].[MenuHistMonthView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MenuHistMonthView]
AS
SELECT        dbo.MenuHist.ProductID, dbo.Products.ProductName, dbo.Category.CategoryName, dbo.MenuHist.UnitPrice, dbo.MenuHist.Since, dbo.MenuHist.Until
FROM            dbo.MenuHist INNER JOIN
                         dbo.Products ON dbo.MenuHist.ProductID = dbo.Products.ProductID INNER JOIN
                         dbo.Category ON dbo.Products.CategoryID = dbo.Category.CategoryID
GO
/****** Object:  View [dbo].[MenuHistWeekView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MenuHistWeekView]
AS
SELECT        dbo.MenuHist.ProductID, dbo.Products.ProductName, dbo.Category.CategoryName, dbo.MenuHist.Since, dbo.MenuHist.Until, dbo.MenuHist.UnitPrice
FROM            dbo.MenuHist INNER JOIN
                         dbo.Products ON dbo.MenuHist.ProductID = dbo.Products.ProductID INNER JOIN
                         dbo.Category ON dbo.Products.CategoryID = dbo.Category.CategoryID
WHERE        (DATEDIFF(WEEK, GETDATE(), ISNULL(dbo.MenuHist.Until, GETDATE())) < 1) OR
                         (DATEDIFF(WEEK, GETDATE(), dbo.MenuHist.Since) < 1)
GO
/****** Object:  Table [dbo].[TablesAssigned]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TablesAssigned](
	[ReservationID] [int] NOT NULL,
	[TableID] [int] NOT NULL,
 CONSTRAINT [PK_TablesAssigned] PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC,
	[TableID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tables]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tables](
	[TableID] [int] IDENTITY(1,1) NOT NULL,
	[Capacity] [int] NOT NULL,
 CONSTRAINT [PK_Tables] PRIMARY KEY CLUSTERED 
(
	[TableID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reservations]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reservations](
	[ReservationID] [int] IDENTITY(1,1) NOT NULL,
	[OrderID] [int] NULL,
 CONSTRAINT [PK_Reservations] PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[TableUsageView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TableUsageView]
AS
SELECT        dbo.Tables.TableID, dbo.Tables.Capacity, dbo.Orders.OrderDate
FROM            dbo.TablesAssigned INNER JOIN
                         dbo.Reservations ON dbo.TablesAssigned.ReservationID = dbo.Reservations.ReservationID INNER JOIN
                         dbo.Tables ON dbo.TablesAssigned.TableID = dbo.Tables.TableID INNER JOIN
                         dbo.Orders ON dbo.Reservations.OrderID = dbo.Orders.OrderID
GO
/****** Object:  View [dbo].[TableUsageWeekView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TableUsageWeekView]
AS
SELECT        dbo.Tables.TableID, dbo.Tables.Capacity, dbo.Orders.OrderDate
FROM            dbo.Tables INNER JOIN
                         dbo.TablesAssigned ON dbo.Tables.TableID = dbo.TablesAssigned.TableID INNER JOIN
                         dbo.Reservations ON dbo.TablesAssigned.ReservationID = dbo.Reservations.ReservationID INNER JOIN
                         dbo.Orders ON dbo.Reservations.OrderID = dbo.Orders.OrderID
WHERE        (DATEDIFF(WEEK, GETDATE(), dbo.Orders.OrderDate) < 1)
GO
/****** Object:  Table [dbo].[TemporaryDiscounts]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TemporaryDiscounts](
	[DiscountID] [int] IDENTITY(1,1) NOT NULL,
	[SinceDate] [date] NOT NULL,
	[K2] [money] NOT NULL,
	[R2%] [real] NOT NULL,
	[D1] [int] NOT NULL,
 CONSTRAINT [PK_OtherDiscounts] PRIMARY KEY CLUSTERED 
(
	[DiscountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TemporaryDiscountsAssigned]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TemporaryDiscountsAssigned](
	[ClientID] [int] NOT NULL,
	[DiscountID] [int] NOT NULL,
	[DateAssigned] [date] NOT NULL,
 CONSTRAINT [PK_DiscountsAssigned] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC,
	[DiscountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[TemporaryDiscountsReportMonthView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TemporaryDiscountsReportMonthView]
AS
SELECT        dbo.TemporaryDiscounts.DiscountID, dbo.ClientPerson.ClientID, dbo.ClientPerson.Firstname, dbo.ClientPerson.Lastname
FROM            dbo.TemporaryDiscounts INNER JOIN
                         dbo.TemporaryDiscountsAssigned ON dbo.TemporaryDiscounts.DiscountID = dbo.TemporaryDiscountsAssigned.DiscountID INNER JOIN
                         dbo.ClientPerson ON dbo.TemporaryDiscountsAssigned.ClientID = dbo.ClientPerson.ClientID
WHERE        (DATEDIFF(MONTH, GETDATE(), DATEADD(DAY, dbo.TemporaryDiscounts.D1, dbo.TemporaryDiscountsAssigned.DateAssigned)) < 1)
GO
/****** Object:  View [dbo].[TemporaryDiscountsReportWeekView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[TemporaryDiscountsReportWeekView]
AS
SELECT        dbo.TemporaryDiscounts.DiscountID, dbo.ClientPerson.ClientID, dbo.ClientPerson.Firstname, dbo.ClientPerson.Lastname
FROM            dbo.TemporaryDiscounts INNER JOIN
                         dbo.TemporaryDiscountsAssigned ON dbo.TemporaryDiscounts.DiscountID = dbo.TemporaryDiscountsAssigned.DiscountID INNER JOIN
                         dbo.ClientPerson ON dbo.TemporaryDiscountsAssigned.ClientID = dbo.ClientPerson.ClientID
WHERE        (DATEDIFF(MONTH, GETDATE(), DATEADD(DAY, dbo.TemporaryDiscounts.D1, dbo.TemporaryDiscountsAssigned.DateAssigned)) < 1)
GO
/****** Object:  Table [dbo].[PermanentDiscountsAssigned]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PermanentDiscountsAssigned](
	[ClientID] [int] NOT NULL,
	[PermanentDiscountID] [int] NOT NULL,
	[DateAssigned] [date] NOT NULL,
 CONSTRAINT [PK_PermanentDiscountsAssigned] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PermanentDiscount]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PermanentDiscount](
	[DiscountID] [int] IDENTITY(1,1) NOT NULL,
	[SinceDate] [date] NOT NULL,
	[Z1] [int] NOT NULL,
	[K1] [money] NOT NULL,
	[R1%] [real] NOT NULL,
 CONSTRAINT [PK_PermanentDiscount] PRIMARY KEY CLUSTERED 
(
	[DiscountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[NewPermanentDiscountsMonthView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[NewPermanentDiscountsMonthView]
AS
SELECT        dbo.PermanentDiscount.DiscountID, dbo.ClientPerson.ClientID, dbo.ClientPerson.Firstname, dbo.ClientPerson.Lastname
FROM            dbo.PermanentDiscount INNER JOIN
                         dbo.PermanentDiscountsAssigned ON dbo.PermanentDiscount.DiscountID = dbo.PermanentDiscountsAssigned.PermanentDiscountID INNER JOIN
                         dbo.ClientPerson ON dbo.PermanentDiscountsAssigned.ClientID = dbo.ClientPerson.ClientID
WHERE        (DATEDIFF(MONTH, GETDATE(), dbo.PermanentDiscountsAssigned.DateAssigned) < 1)
GO
/****** Object:  View [dbo].[NewPermanentDiscountsWeekView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[NewPermanentDiscountsWeekView]
AS
SELECT        dbo.PermanentDiscount.DiscountID, dbo.ClientPerson.ClientID, dbo.ClientPerson.Firstname, dbo.ClientPerson.Lastname
FROM            dbo.PermanentDiscount INNER JOIN
                         dbo.PermanentDiscountsAssigned ON dbo.PermanentDiscount.DiscountID = dbo.PermanentDiscountsAssigned.PermanentDiscountID INNER JOIN
                         dbo.ClientPerson ON dbo.PermanentDiscountsAssigned.ClientID = dbo.ClientPerson.ClientID
WHERE        (DATEDIFF(WEEK, GETDATE(), dbo.PermanentDiscountsAssigned.DateAssigned) < 1)
GO
/****** Object:  View [dbo].[CompanyOrdersView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[CompanyOrdersView] as
	select OrderDate,CompanyName,sum(quantity*UnitPrice) as TotalValue from orders 
	join ClientCompany on orders.ClientID=ClientCompany.ClientID 
	join [Order Details] on orders.OrderID=[Order Details].OrderID
	join MenuHist on MenuHist.MenuHistID=[Order Details].MenuHistID
	group by orders.OrderID,OrderDate,CompanyName
GO
/****** Object:  View [dbo].[AllTemporaryDiscountsView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AllTemporaryDiscountsView]
AS
SELECT        dbo.TemporaryDiscountsAssigned.ClientID, dbo.TemporaryDiscounts.[R2%], dbo.TemporaryDiscountsAssigned.DateAssigned, DATEADD(DAY, dbo.TemporaryDiscounts.D1, dbo.TemporaryDiscountsAssigned.DateAssigned) 
                         AS Expires
FROM            dbo.TemporaryDiscounts INNER JOIN
                         dbo.TemporaryDiscountsAssigned ON dbo.TemporaryDiscounts.DiscountID = dbo.TemporaryDiscountsAssigned.DiscountID
GO
/****** Object:  View [dbo].[AllPermanentDiscountsView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AllPermanentDiscountsView]
AS
SELECT        dbo.PermanentDiscountsAssigned.ClientID, dbo.PermanentDiscount.[R1%], dbo.PermanentDiscountsAssigned.DateAssigned, NULL AS Expires
FROM            dbo.PermanentDiscount INNER JOIN
                         dbo.PermanentDiscountsAssigned ON dbo.PermanentDiscount.DiscountID = dbo.PermanentDiscountsAssigned.PermanentDiscountID
GO
/****** Object:  View [dbo].[NewDishesView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[NewDishesView]
AS
SELECT   COUNT(*) AS [New dishes]
FROM         dbo.MenuHist
WHERE     (DATEDIFF(DAY, Since, GETDATE()) < 14)
GO
/****** Object:  Table [dbo].[IndividualReservation]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IndividualReservation](
	[ReservationID] [int] NOT NULL,
	[ClientID] [int] NOT NULL,
	[IsPaid] [bit] NOT NULL,
	[status] [bit] NOT NULL,
	[ReservationDate] [date] NOT NULL,
	[Date] [date] NOT NULL,
 CONSTRAINT [PK_IndividualReservation] PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyReservations]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyReservations](
	[ReservationID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[status] [bit] NOT NULL,
	[ReservationDate] [date] NOT NULL,
	[Date] [date] NOT NULL,
 CONSTRAINT [PK_CompanyReservations] PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PersonalCompanyReservations]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonalCompanyReservations](
	[ReservationID] [int] NOT NULL,
	[CompanyID] [int] NOT NULL,
	[status] [bit] NOT NULL,
	[ReservationDate] [date] NOT NULL,
	[Date] [date] NOT NULL,
 CONSTRAINT [PK_PersonalCompanyReservations] PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[UnconfirmedTableReservations]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[UnconfirmedTableReservations] as
select ReservationID,CompanyID as ClientID, ReservationDate,Date from PersonalCompanyReservations where status=0
union
select ReservationID,ClientID,ReservationDate,Date from IndividualReservation where status=0
union
select ReservationID,CompanyID as ClientID,ReservationDate,Date from CompanyReservations where status=0


GO
/****** Object:  View [dbo].[CompanyOrderPricesView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CompanyOrderPricesView]
AS
SELECT        TOP (100) PERCENT dbo.ClientCompany.ClientID, dbo.ClientCompany.CompanyName, AllCompanyReservations.ReservationID, dbo.Orders.OrderID, SUM(dbo.[Order Details].Quantity * dbo.MenuHist.UnitPrice) AS Expr1
FROM            (SELECT        ReservationID, CompanyID, status, ReservationDate, Date
                          FROM            dbo.CompanyReservations
                          UNION
                          SELECT        ReservationID, CompanyID, status, ReservationDate, Date
                          FROM            dbo.PersonalCompanyReservations) AS AllCompanyReservations INNER JOIN
                         dbo.Reservations ON AllCompanyReservations.ReservationID = dbo.Reservations.ReservationID INNER JOIN
                         dbo.Orders ON dbo.Reservations.OrderID = dbo.Orders.OrderID INNER JOIN
                         dbo.ClientCompany ON AllCompanyReservations.CompanyID = dbo.ClientCompany.ClientID INNER JOIN
                         dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID INNER JOIN
                         dbo.MenuHist ON dbo.[Order Details].MenuHistID = dbo.MenuHist.MenuHistID INNER JOIN
                         dbo.Products ON dbo.MenuHist.ProductID = dbo.Products.ProductID
GROUP BY dbo.ClientCompany.ClientID, dbo.ClientCompany.CompanyName, AllCompanyReservations.ReservationID, dbo.Orders.OrderID
GO
/****** Object:  Table [dbo].[CompanyReservationDetails]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyReservationDetails](
	[ReservationID] [int] NOT NULL,
	[TableNumber] [int] IDENTITY(1,1) NOT NULL,
	[TableCapacity] [int] NOT NULL,
 CONSTRAINT [PK_CompanyReservationsDetails] PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC,
	[TableNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[CompanyReservationTablesView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CompanyReservationTablesView]
AS
SELECT        dbo.CompanyReservations.ReservationID, dbo.CompanyReservationDetails.TableCapacity
FROM            dbo.CompanyReservations INNER JOIN
                         dbo.CompanyReservationDetails ON dbo.CompanyReservations.ReservationID = dbo.CompanyReservationDetails.ReservationID
GO
/****** Object:  View [dbo].[IndividualReservationTablesView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IndividualReservationTablesView]
AS
SELECT        ReservationID, 1 AS TableCapacity
FROM            dbo.IndividualReservation
GO
/****** Object:  Table [dbo].[PersonalCompanyReservationDetails]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PersonalCompanyReservationDetails](
	[ReservationID] [int] NOT NULL,
	[TableNumber] [int] NOT NULL,
	[EmployeeID] [int] NOT NULL,
 CONSTRAINT [PK_PersonalCompanyReservationDetails_1] PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC,
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[PersonalCompanyReservationTablesView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[PersonalCompanyReservationTablesView]
AS
SELECT        dbo.PersonalCompanyReservations.ReservationID, dbo.PersonalCompanyReservationDetails.TableNumber, COUNT(*) AS TableCapacity
FROM            dbo.PersonalCompanyReservations INNER JOIN
                         dbo.PersonalCompanyReservationDetails ON dbo.PersonalCompanyReservations.ReservationID = dbo.PersonalCompanyReservationDetails.ReservationID
GROUP BY dbo.PersonalCompanyReservations.ReservationID, dbo.PersonalCompanyReservationDetails.TableNumber
GO
/****** Object:  View [dbo].[ReservationTablesView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[ReservationTablesView]
AS
SELECT        ReservationID, TableCapacity
FROM            (SELECT        ReservationID, TableCapacity
                          FROM            dbo.CompanyReservationTablesView
                          UNION
                          SELECT        ReservationID, TableCapacity
                          FROM            dbo.IndividualReservationTablesView
                          UNION
                          SELECT        ReservationID, TableCapacity
                          FROM            dbo.PersonalCompanyReservationTablesView) AS AllReservationTablesInfo
GO
/****** Object:  View [dbo].[IndividualClientsOrderValuesView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[IndividualClientsOrderValuesView]
AS
SELECT dbo.Orders.ClientID, dbo.IndividualReservation.Date, SUM((dbo.[Order Details].Quantity * dbo.MenuHist.UnitPrice) * (1 - dbo.Orders.DiscountValue)) AS Expr1
FROM     dbo.IndividualReservation INNER JOIN
                  dbo.Reservations ON dbo.IndividualReservation.ReservationID = dbo.Reservations.ReservationID INNER JOIN
                  dbo.Orders ON dbo.Reservations.OrderID = dbo.Orders.OrderID INNER JOIN
                  dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID INNER JOIN
                  dbo.MenuHist ON dbo.[Order Details].MenuHistID = dbo.MenuHist.MenuHistID
GROUP BY dbo.Orders.ClientID, dbo.IndividualReservation.Date, dbo.Orders.OrderID
GO
/****** Object:  View [dbo].[CompanyClientsOrderValuesView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[CompanyClientsOrderValuesView]
AS
SELECT        dbo.ClientCompany.ClientID, AllCompanyReservations.Date, SUM(dbo.[Order Details].Quantity * dbo.MenuHist.UnitPrice) AS Expr1
FROM            dbo.Orders INNER JOIN
                         dbo.Reservations ON dbo.Orders.OrderID = dbo.Reservations.OrderID INNER JOIN
                         dbo.[Order Details] ON dbo.Orders.OrderID = dbo.[Order Details].OrderID INNER JOIN
                         dbo.MenuHist ON dbo.[Order Details].MenuHistID = dbo.MenuHist.MenuHistID INNER JOIN
                             (SELECT        ReservationID, CompanyID, status, ReservationDate, Date
                               FROM            dbo.CompanyReservations
                               UNION
                               SELECT        ReservationID, CompanyID, status, ReservationDate, Date
                               FROM            dbo.PersonalCompanyReservations) AS AllCompanyReservations ON AllCompanyReservations.ReservationID = dbo.Reservations.ReservationID INNER JOIN
                         dbo.ClientCompany ON AllCompanyReservations.CompanyID = dbo.ClientCompany.ClientID
GROUP BY dbo.ClientCompany.ClientID, AllCompanyReservations.Date
GO
/****** Object:  View [dbo].[MenuHistView]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[MenuHistView]
AS
SELECT        dbo.MenuHist.MenuHistID, dbo.Products.ProductName, dbo.MenuHist.Since, dbo.MenuHist.Until, dbo.MenuHist.UnitPrice
FROM            dbo.MenuHist INNER JOIN
                         dbo.Products ON dbo.MenuHist.ProductID = dbo.Products.ProductID
GO
/****** Object:  View [dbo].[AssignedTablesDates]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AssignedTablesDates]
AS
SELECT        dbo.Reservations.ReservationID, AllReservations.Date, dbo.TablesAssigned.TableID
FROM            dbo.TablesAssigned INNER JOIN
                         dbo.Reservations ON dbo.TablesAssigned.ReservationID = dbo.Reservations.ReservationID INNER JOIN
                             (SELECT        ReservationID, Date
                               FROM            dbo.IndividualReservation
                               UNION
                               SELECT        ReservationID, Date
                               FROM            dbo.CompanyReservations
                               UNION
                               SELECT        ReservationID, Date
                               FROM            dbo.PersonalCompanyReservations) AS AllReservations ON AllReservations.ReservationID = dbo.Reservations.ReservationID
GO
/****** Object:  Table [dbo].[Clients]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clients](
	[ClientID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Clients] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[Adress] [varchar](50) NOT NULL,
	[e-mail] [varchar](50) NOT NULL,
	[BirthDate] [date] NOT NULL,
	[HireDate] [date] NOT NULL,
	[phone] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IndividualReservationDetails]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IndividualReservationDetails](
	[ReservationID] [int] NOT NULL,
	[TableCapacity] [int] NOT NULL,
 CONSTRAINT [PK_IndividualOrderDetails_1] PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Parameters]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Parameters](
	[WZ] [money] NOT NULL,
	[WK] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [CompanyID_index]    Script Date: 10.02.2022 14:42:24 ******/
CREATE NONCLUSTERED INDEX [CompanyID_index] ON [dbo].[CompanyReservations]
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ClientID_index]    Script Date: 10.02.2022 14:42:24 ******/
CREATE NONCLUSTERED INDEX [ClientID_index] ON [dbo].[IndividualReservation]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ProductID_index]    Script Date: 10.02.2022 14:42:24 ******/
CREATE NONCLUSTERED INDEX [ProductID_index] ON [dbo].[MenuHist]
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ClientID_Index]    Script Date: 10.02.2022 14:42:24 ******/
CREATE NONCLUSTERED INDEX [ClientID_Index] ON [dbo].[Orders]
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [CompanyID_index]    Script Date: 10.02.2022 14:42:24 ******/
CREATE NONCLUSTERED INDEX [CompanyID_index] ON [dbo].[PersonalCompanyReservations]
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [OrderID_index]    Script Date: 10.02.2022 14:42:24 ******/
CREATE NONCLUSTERED INDEX [OrderID_index] ON [dbo].[Reservations]
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyReservations] ADD  CONSTRAINT [DF_CompanyReservations_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[IndividualReservation] ADD  CONSTRAINT [DF_IndividualReservation_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[Orders] ADD  CONSTRAINT [DF_Orders_DiscountValue]  DEFAULT ((0)) FOR [DiscountValue]
GO
ALTER TABLE [dbo].[Orders] ADD  CONSTRAINT [DF_Orders_Takeaway]  DEFAULT ((0)) FOR [Takeaway]
GO
ALTER TABLE [dbo].[PersonalCompanyReservations] ADD  CONSTRAINT [DF_PersonalCompanyReservations_status]  DEFAULT ((0)) FOR [status]
GO
ALTER TABLE [dbo].[ClientCompany]  WITH CHECK ADD  CONSTRAINT [FK_ClientCompany_Clients] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ClientID])
GO
ALTER TABLE [dbo].[ClientCompany] CHECK CONSTRAINT [FK_ClientCompany_Clients]
GO
ALTER TABLE [dbo].[ClientPerson]  WITH CHECK ADD  CONSTRAINT [FK_ClientPerson_ClientCompany] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[ClientCompany] ([ClientID])
GO
ALTER TABLE [dbo].[ClientPerson] CHECK CONSTRAINT [FK_ClientPerson_ClientCompany]
GO
ALTER TABLE [dbo].[ClientPerson]  WITH CHECK ADD  CONSTRAINT [FK_ClientPerson_Clients] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ClientID])
GO
ALTER TABLE [dbo].[ClientPerson] CHECK CONSTRAINT [FK_ClientPerson_Clients]
GO
ALTER TABLE [dbo].[CompanyReservationDetails]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservationsDetails_CompanyReservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[CompanyReservations] ([ReservationID])
GO
ALTER TABLE [dbo].[CompanyReservationDetails] CHECK CONSTRAINT [FK_CompanyReservationsDetails_CompanyReservations]
GO
ALTER TABLE [dbo].[CompanyReservations]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservations_ClientCompany] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[ClientCompany] ([ClientID])
GO
ALTER TABLE [dbo].[CompanyReservations] CHECK CONSTRAINT [FK_CompanyReservations_ClientCompany]
GO
ALTER TABLE [dbo].[CompanyReservations]  WITH CHECK ADD  CONSTRAINT [FK_CompanyReservations_Reservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
GO
ALTER TABLE [dbo].[CompanyReservations] CHECK CONSTRAINT [FK_CompanyReservations_Reservations]
GO
ALTER TABLE [dbo].[IndividualReservation]  WITH CHECK ADD  CONSTRAINT [FK_IndividualReservation_ClientPerson] FOREIGN KEY([ClientID])
REFERENCES [dbo].[ClientPerson] ([ClientID])
GO
ALTER TABLE [dbo].[IndividualReservation] CHECK CONSTRAINT [FK_IndividualReservation_ClientPerson]
GO
ALTER TABLE [dbo].[IndividualReservation]  WITH CHECK ADD  CONSTRAINT [FK_IndividualReservation_Reservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
GO
ALTER TABLE [dbo].[IndividualReservation] CHECK CONSTRAINT [FK_IndividualReservation_Reservations]
GO
ALTER TABLE [dbo].[IndividualReservationDetails]  WITH CHECK ADD  CONSTRAINT [FK_IndividualOrderDetails_IndividualReservation] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[IndividualReservation] ([ReservationID])
GO
ALTER TABLE [dbo].[IndividualReservationDetails] CHECK CONSTRAINT [FK_IndividualOrderDetails_IndividualReservation]
GO
ALTER TABLE [dbo].[MenuHist]  WITH CHECK ADD  CONSTRAINT [FK_MenuHist_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[MenuHist] CHECK CONSTRAINT [FK_MenuHist_Products]
GO
ALTER TABLE [dbo].[Order Details]  WITH CHECK ADD  CONSTRAINT [FK_Order Details_MenuHist1] FOREIGN KEY([MenuHistID])
REFERENCES [dbo].[MenuHist] ([MenuHistID])
GO
ALTER TABLE [dbo].[Order Details] CHECK CONSTRAINT [FK_Order Details_MenuHist1]
GO
ALTER TABLE [dbo].[Order Details]  WITH CHECK ADD  CONSTRAINT [FK_Order Details_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[Order Details] CHECK CONSTRAINT [FK_Order Details_Orders]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Clients] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ClientID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Clients]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Employees] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Employees]
GO
ALTER TABLE [dbo].[PermanentDiscountsAssigned]  WITH CHECK ADD  CONSTRAINT [FK_PermanentDiscountsAssigned_ClientPerson] FOREIGN KEY([ClientID])
REFERENCES [dbo].[ClientPerson] ([ClientID])
GO
ALTER TABLE [dbo].[PermanentDiscountsAssigned] CHECK CONSTRAINT [FK_PermanentDiscountsAssigned_ClientPerson]
GO
ALTER TABLE [dbo].[PermanentDiscountsAssigned]  WITH CHECK ADD  CONSTRAINT [FK_PermanentDiscountsAssigned_PermanentDiscount] FOREIGN KEY([PermanentDiscountID])
REFERENCES [dbo].[PermanentDiscount] ([DiscountID])
GO
ALTER TABLE [dbo].[PermanentDiscountsAssigned] CHECK CONSTRAINT [FK_PermanentDiscountsAssigned_PermanentDiscount]
GO
ALTER TABLE [dbo].[PersonalCompanyReservationDetails]  WITH CHECK ADD  CONSTRAINT [FK_PersonalCompanyReservationDetails_ClientPerson] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[ClientPerson] ([ClientID])
GO
ALTER TABLE [dbo].[PersonalCompanyReservationDetails] CHECK CONSTRAINT [FK_PersonalCompanyReservationDetails_ClientPerson]
GO
ALTER TABLE [dbo].[PersonalCompanyReservationDetails]  WITH CHECK ADD  CONSTRAINT [FK_PersonalCompanyReservationDetails_PersonalCompanyReservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[PersonalCompanyReservations] ([ReservationID])
GO
ALTER TABLE [dbo].[PersonalCompanyReservationDetails] CHECK CONSTRAINT [FK_PersonalCompanyReservationDetails_PersonalCompanyReservations]
GO
ALTER TABLE [dbo].[PersonalCompanyReservations]  WITH CHECK ADD  CONSTRAINT [FK_PersonalCompanyReservations_ClientCompany] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[ClientCompany] ([ClientID])
GO
ALTER TABLE [dbo].[PersonalCompanyReservations] CHECK CONSTRAINT [FK_PersonalCompanyReservations_ClientCompany]
GO
ALTER TABLE [dbo].[PersonalCompanyReservations]  WITH CHECK ADD  CONSTRAINT [FK_PersonalCompanyReservations_Reservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
GO
ALTER TABLE [dbo].[PersonalCompanyReservations] CHECK CONSTRAINT [FK_PersonalCompanyReservations_Reservations]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Category] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Category] ([CategoryID])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Category]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FK_Reservations_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FK_Reservations_Orders]
GO
ALTER TABLE [dbo].[TablesAssigned]  WITH CHECK ADD  CONSTRAINT [FK_TablesAssigned_Reservations] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
GO
ALTER TABLE [dbo].[TablesAssigned] CHECK CONSTRAINT [FK_TablesAssigned_Reservations]
GO
ALTER TABLE [dbo].[TablesAssigned]  WITH CHECK ADD  CONSTRAINT [FK_TablesAssigned_Tables] FOREIGN KEY([TableID])
REFERENCES [dbo].[Tables] ([TableID])
GO
ALTER TABLE [dbo].[TablesAssigned] CHECK CONSTRAINT [FK_TablesAssigned_Tables]
GO
ALTER TABLE [dbo].[TemporaryDiscountsAssigned]  WITH CHECK ADD  CONSTRAINT [FK_DiscountsAssigned_ClientPerson] FOREIGN KEY([ClientID])
REFERENCES [dbo].[ClientPerson] ([ClientID])
GO
ALTER TABLE [dbo].[TemporaryDiscountsAssigned] CHECK CONSTRAINT [FK_DiscountsAssigned_ClientPerson]
GO
ALTER TABLE [dbo].[TemporaryDiscountsAssigned]  WITH CHECK ADD  CONSTRAINT [FK_TemporaryDiscountsAssigned_TemporaryDiscounts] FOREIGN KEY([DiscountID])
REFERENCES [dbo].[TemporaryDiscounts] ([DiscountID])
GO
ALTER TABLE [dbo].[TemporaryDiscountsAssigned] CHECK CONSTRAINT [FK_TemporaryDiscountsAssigned_TemporaryDiscounts]
GO
/****** Object:  StoredProcedure [dbo].[AddCategory]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[AddCategory](@name varchar(50)) as
begin
insert into Category (CategoryName) values(@name);
end;
GO
/****** Object:  StoredProcedure [dbo].[AddClientCompany]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddClientCompany] (
	@companyname varchar(50),
	@adres varchar(50),
	@phone varchar(50)
) as
begin
	insert into Clients default values;
	insert into ClientCompany values(@@identity,@companyname,@adres,@phone);
end
GO
/****** Object:  StoredProcedure [dbo].[AddClientPerson]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddClientPerson] (
	@firstname varchar(50),
	@lastname varchar(50),
	@adres varchar(50),
	@companyID int=null
) as
begin
	insert into Clients default values;
	insert into ClientPerson values(@@IDENTITY,@firstname,@lastname,@adres,@companyID);
end;
GO
/****** Object:  StoredProcedure [dbo].[AddCompanyReservation]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AddCompanyReservation] 
	@CompanyID INT,
	@Date DATE
AS
BEGIN
	EXEC AddOrder @clientID=@CompanyID, @orderDate=@Date;
	
	DECLARE @OrderID INT = (SELECT TOP 1 OrderID FROM Orders WHERE ClientID = @CompanyID
							ORDER BY OrderID DESC)

	INSERT INTO Reservations(OrderID) VALUES (@OrderID)

	DECLARE @ReservationID INT = (SELECT ReservationID FROM Reservations WHERE OrderID = @OrderID)
	
	INSERT INTO CompanyReservations(ReservationID, CompanyID, ReservationDate, Date)
	VALUES (@ReservationID, @CompanyID, GETDATE(), @Date)
END
GO
/****** Object:  StoredProcedure [dbo].[AddCompanyReservationDetails]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddCompanyReservationDetails]
	@ReservationID INT,
	@TableCapacity INT
AS
BEGIN
	INSERT INTO CompanyReservationDetails(ReservationID, TableCapacity) VALUES
	(@ReservationID, @TableCapacity)
END
GO
/****** Object:  StoredProcedure [dbo].[AddEmployee]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




--select CategoryID from Category where CategoryName like @categoryname;

CREATE procedure [dbo].[AddEmployee](
	@firstname varchar(50),
	@lastname varchar(50),
	@adress varchar(50),
	@email varchar(50),
	@birthdate date,
	@hiredate as datetime=null,
	@phone varchar(50)
	) as	
begin
	begin try
		if @hiredate is null
			set @hiredate=getdate();
		insert into Employees values (@firstname,@lastname,@adress,@email,@birthdate,@hiredate,@phone);
	end try
	begin catch
		print 'zle dane'
	end catch
end;

GO
/****** Object:  StoredProcedure [dbo].[AddIndividualReservation]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[AddIndividualReservation] (
	@clientid int,
	@ispaid bit=0,
	@date date,
	@orderid int
) as
begin
	begin try
		declare @wz money
		set @wz=(select wz from Parameters)
		declare @wk int
		set @wk=(select wk from parameters)
		declare @reservationdate date
		set @reservationdate=getdate();
		declare @ordervalue money
		declare @amountofindividual int
		set @ordervalue=(select [dbo].[OrderValue](@clientid))
		set @amountofindividual=(select [dbo].[AmountOfindividualorders](@clientid))
		if @ordervalue>@wz and @amountofindividual>@wk
		begin 
			insert into Reservations default values;
			insert into IndividualReservation (ReservationID,ClientID,IsPaid,ReservationDate,Date) values (@@identity,@clientid,@ispaid,@reservationdate,@date);
		end
	end try
	begin catch
		print 'nie mozna zlozyc rezerwacji'
	end catch
end;
GO
/****** Object:  StoredProcedure [dbo].[AddMenu]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[AddMenu](
	@prodname varchar(50),
	@sincedate date,
	@untildate date=null,
	@unitprice money
)as
begin
	if (@sincedate > getdate())
	begin
		begin try
			declare @prodid int
			set @prodid=(select ProductID from Products where ProductName=@prodname);
			insert into MenuHist values(@prodid,@sincedate,@untildate,@unitprice);
		end try
		begin catch
			print 'bledne dane'
		end catch
	end
	else
	begin
		print 'poczatkowa data musi byc pozniejsza od dzisiejszej'
	end
end;
GO
/****** Object:  StoredProcedure [dbo].[AddOrder]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddOrder]( @clientID int, @orderDate date, @discountValue real=0, @takeaway bit=0)

AS
BEGIN
	if 
		not exists (select * from clients
		inner join PermanentDiscountsAssigned on clients.ClientID = PermanentDiscountsAssigned.ClientID
		inner join PermanentDiscount on PermanentDiscountsAssigned.PermanentDiscountID = PermanentDiscount.DiscountID
		where clients.clientID = @clientID and PermanentDiscount.[R1%] = @discountValue) 
		and not 
		exists (select * from clients
		inner join TemporaryDiscountsAssigned on clients.ClientID = TemporaryDiscountsAssigned.ClientID
		inner join TemporaryDiscounts on TemporaryDiscountsAssigned.DiscountID = TemporaryDiscounts.DiscountID
		where clients.clientID = @clientID and TemporaryDiscounts.[R2%] = @discountValue and TemporaryDiscounts.SinceDate <= @orderDate and DATEADD(day, TemporaryDiscounts.D1,TemporaryDiscounts.SinceDate) >= @orderDate)
	begin
		set @discountValue = 0.0
	end
	begin 
		if (@clientID in (SELECT ClientID FROM ClientCompany))
		begin
			SET @takeaway = 0
		end
		insert into Orders (ClientID,OrderDate,DiscountValue,Takeaway)
		values (@clientID,@orderDate,@discountValue,@takeaway)
	end


END
GO
/****** Object:  StoredProcedure [dbo].[AddOrderDetails]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddOrderDetails]
	@OrderID int,
	@MenuHistID int,
	@Quantity int
AS
BEGIN
	DECLARE @OrderDate DATE
	SET @OrderDate = (SELECT OrderDate FROM Orders WHERE OrderID=@OrderID)
	SET DATEFIRST 1
	IF (((SELECT CategoryName FROM Category INNER JOIN Products
		ON Products.CategoryID = Category.CategoryID INNER JOIN MenuHist
		ON Products.ProductID = MenuHist.ProductID WHERE MenuHistID = @MenuHistID) != 'Seafood') OR
		(DATEPART(WEEKDAY, @OrderDate) BETWEEN 4 AND 6 AND
		DATEDIFF(DAY, GETDATE(), @OrderDate) > DATEPART(WEEKDAY, @OrderDate)-1)) AND
		((SELECT Until FROM MenuHist WHERE MenuHistID=@MenuHistID) IS NULL OR
		(SELECT Until FROM MenuHist WHERE MenuHistID=@MenuHistID) > GETDATE())
		AND (SELECT Since FROM MenuHist WHERE MenuHistID=@MenuHistID) < @OrderDate
	BEGIN
		INSERT INTO [Order Details](OrderID, MenuHistID, Quantity) VALUES (@OrderID, @MenuHistID, @Quantity)
	END
END
GO
/****** Object:  StoredProcedure [dbo].[AddParameters]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddParameters] (
	@wz money,
	@wk int
) as
begin
	begin try
		update Parameters set WZ=@wz;
		update Parameters set WK=@wk;
	end try
	begin catch
		print 'nie udalo sie ustawic parametrow'
	end catch
end;
GO
/****** Object:  StoredProcedure [dbo].[AddPersonalCompanyReservation]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddPersonalCompanyReservation]
	@CompanyID INT,
	@Date DATE
AS
BEGIN
	EXEC AddOrder @clientID = @CompanyID, @orderDate = @Date;

	DECLARE @OrderID INT = (SELECT TOP 1 OrderID FROM Orders WHERE ClientID = @CompanyID
							ORDER BY OrderID DESC)

	INSERT INTO Reservations(OrderID) VALUES (@OrderID)
	
	DECLARE @ReservationID INT = (SELECT ReservationID FROM Reservations WHERE OrderID = @OrderID)

	INSERT INTO PersonalCompanyReservations(ReservationID, CompanyID, ReservationDate, Date)
	VALUES (@ReservationID, @CompanyID, GETDATE(), @Date)
END
GO
/****** Object:  StoredProcedure [dbo].[AddPersonalCompanyReservationDetails]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddPersonalCompanyReservationDetails]
	@ReservationID INT,
	@TableNumber INT,
	@EmployeeID INT
AS
BEGIN
	INSERT INTO PersonalCompanyReservationDetails(ReservationID, TableNumber, EmployeeID)
	VALUES (@ReservationID, @TableNumber, @EmployeeID)
END
GO
/****** Object:  StoredProcedure [dbo].[AddProduct]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[AddProduct](
	@prodname varchar(50),
	@categoryname varchar(50)
	) as
begin
	begin try
		declare @temp int;
		set @temp=(select CategoryID from Category where CategoryName=@categoryname);
		insert into Products (ProductName,CategoryID) values (@prodname,@temp);
	end try
	begin catch
		print 'Podana kategoria nie istnieje';
	end catch;
end;

--select CategoryID from Category where CategoryName like @categoryname;
GO
/****** Object:  StoredProcedure [dbo].[AddTable]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AddTable](
	@capacity int
) as
begin
	insert into Tables(Capacity) values (@capacity);
end
GO
/****** Object:  StoredProcedure [dbo].[AssignEmployee]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AssignEmployee] (@employeeID int, @orderID int)
	
AS
BEGIN
	update Orders set EmployeeID = @employeeID
	where Orders.OrderID = @orderID
END
GO
/****** Object:  StoredProcedure [dbo].[AssignTable]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AssignTable]
	@ReservationID INT,
	@TableID INT
AS
BEGIN

	DECLARE @Date DATE = 
	(SELECT Date FROM IndividualReservation 
	 WHERE ReservationID = @ReservationID
	 UNION
		  SELECT Date FROM PersonalCompanyReservations 
		  WHERE ReservationID = @ReservationID
	 UNION
		  SELECT Date FROM CompanyReservations
		  WHERE ReservationID = @ReservationID)
	DECLARE @TableFree BIT = ([dbo].IsTableFree(@TableID, @Date))
	
	IF (@TableFree = 1)
	BEGIN
		INSERT INTO TablesAssigned(ReservationID, TableID)
		VALUES (@ReservationID, @TableID)
	END
END
GO
/****** Object:  StoredProcedure [dbo].[CheckMenu]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[CheckMenu] as
begin
	declare @count int=(select count(*) from MenuView)
	declare @countLong int=(select count(*) from MenuHist where Since<getdate() and until is null and datediff(day,since,getdate())>14)
	if @count/2>@countLong
		begin
			print 'Nalezy zmienic menu'
		end
end
GO
/****** Object:  StoredProcedure [dbo].[CompanyMonthReport]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[CompanyMonthReport] (
	@companyname varchar(50)=null
)as
begin
	if @companyname is null
		begin
			select * from CompanyOrdersView where (month( getdate() ) > 1 
			AND month( getdate() ) = month( OrderDate ) + 1 AND year( getdate() ) = year( OrderDate ) ) 
			OR ( month( getdate() ) = 1 AND month( OrderDate ) = 12 AND year( getdate() ) = year( OrderDate) + 1)
		end
	else
		begin
			select * from CompanyOrdersView where (month( getdate() ) > 1 
			AND month( getdate() ) = month( OrderDate ) + 1 AND year( getdate() ) = year( OrderDate ) ) 
			OR ( month( getdate() ) = 1 AND month( OrderDate ) = 12 AND year( getdate() ) = year( OrderDate) + 1)
			and CompanyName=@companyname
		end
end
GO
/****** Object:  StoredProcedure [dbo].[CompanyWeekReport]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[CompanyWeekReport] (
	@companyname varchar(50)=null
) as
begin
	if @companyname is null
		begin
			select * from CompanyOrdersView where datediff(day,OrderDate,getdate())<7
		end
	else
		begin
			select * from CompanyOrdersView where datediff(day,OrderDate,getdate())<7 
			and CompanyName=@companyname
		end
end
GO
/****** Object:  StoredProcedure [dbo].[ConfirmReservation]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ConfirmReservation]
	@ReservationID INT
AS
BEGIN
	IF @ReservationID IN (SELECT ReservationID FROM IndividualReservation)
	BEGIN
		UPDATE IndividualReservation
		SET status=1
		WHERE ReservationID=@ReservationID
	END
	ELSE IF @ReservationID IN (SELECT ReservationID FROM CompanyReservations)
	BEGIN
		UPDATE CompanyReservations
		SET status=1
		WHERE ReservationID=@ReservationID
	END
	ELSE IF @ReservationID IN (SELECT ReservationID FROM PersonalCompanyReservations)
	BEGIN
		UPDATE PersonalCompanyReservations
		SET status=1
		WHERE ReservationID=@ReservationID
	END
END
GO
/****** Object:  StoredProcedure [dbo].[GetMonthCompanyReport]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetMonthCompanyReport]
	@companyid int=null,
	@date date
AS
BEGIN
	IF (@companyid IS NOT NULL)
	BEGIN
		DECLARE @year int
		SET @year = YEAR(@date)
		DECLARE @month int
		SET @month = MONTH(@date)

		SELECT * FROM [dbo].CompanyClientsOrderValuesView
		WHERE YEAR(Date) = @year AND MONTH(Date) = @month AND ClientID=@companyid
	END
	ELSE
	BEGIN
		SELECT * FROM [dbo].CompanyClientsOrderValuesView
		WHERE YEAR(Date) = @year AND MONTH(Date) = @month
	END
END
GO
/****** Object:  StoredProcedure [dbo].[GetTablesForReservation]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetTablesForReservation]
	@reservationID int
AS
BEGIN
	SELECT * FROM [dbo].ReservationTablesView WHERE
	ReservationID = @reservationID
END
GO
/****** Object:  StoredProcedure [dbo].[GrantPermanentDiscount]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GrantPermanentDiscount]
	@ClientID INT,
	@DiscountID INT
AS
BEGIN
	DECLARE @OrderCount INT = (SELECT COUNT(*) FROM Orders WHERE ClientID=@ClientID
	AND [dbo].GetOrderValue(OrderID) >= (SELECT K1 FROM PermanentDiscount WHERE DiscountID=@DiscountID)
	AND OrderDate > (SELECT SinceDate FROM PermanentDiscount WHERE DiscountID=@DiscountID))

	IF (@OrderCount >= (SELECT Z1 FROM PermanentDiscount WHERE DiscountID=@DiscountID)
	AND @ClientID NOT IN (SELECT ClientID FROM PermanentDiscountsAssigned) AND
	NOT EXISTS(SELECT * FROM PermanentDiscount WHERE SinceDate > 
	(SELECT SinceDate FROM PermanentDiscount WHERE DiscountID=@DiscountID)) )
	BEGIN
		INSERT INTO PermanentDiscountsAssigned(ClientID, PermanentDiscountID, DateAssigned)
		VALUES (@ClientID, @DiscountID, GETDATE())
	END
END
GO
/****** Object:  StoredProcedure [dbo].[GrantTemporaryDiscount]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GrantTemporaryDiscount]
	@ClientID INT,
	@DiscountID INT
AS
BEGIN
	DECLARE @TotalValue MONEY = (SELECT SUM([dbo].GetOrderValue(OrderID)) FROM Orders
	WHERE ClientID=@ClientID AND OrderDate > (SELECT SinceDate FROM TemporaryDiscounts
	WHERE DiscountID=@DiscountID))

	IF (@TotalValue > (SELECT K2 FROM TemporaryDiscount WHERE DiscountID = @DiscountID))
	BEGIN
		INSERT INTO TemporaryDiscountsAssigned(ClientID, DiscountID, DateAssigned)
		VALUES (@ClientID, @DiscountID, GETDATE())
	END
END
GO
/****** Object:  StoredProcedure [dbo].[IndividualMonthOrders]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[IndividualMonthOrders] (
	@ClientID INT
) as
begin
	if @ClientID is null
		begin
			select * from IndividualOrdersView 
			where ( month( getdate() ) > 1 AND month( getdate() ) = month( orderdate ) + 1 AND year( getdate() ) = year( orderdate ) ) OR ( month( getdate() ) = 1 AND month( orderdate ) = 12 AND year( getdate() ) = year( orderdate) + 1 )
		end
	else
		begin
			select * from IndividualOrdersView 
			where ( month( getdate() ) > 1 AND month( getdate() ) = month( orderdate ) + 1 AND year( getdate() ) = year( orderdate ) ) OR ( month( getdate() ) = 1 AND month( orderdate ) = 12 AND year( getdate() ) = year( orderdate) + 1 ) and ClientID=@ClientID
		end
end
GO
/****** Object:  StoredProcedure [dbo].[IndividualWeekOrders]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[IndividualWeekOrders] (
	@ClientID INT
) as
begin
	if @ClientID is null
		begin
			select * from IndividualOrdersView 
			where datediff(day,orderdate,getdate())<=7
		end
	else
		begin
			select * from IndividualOrdersView 
			where datediff(day,orderdate,getdate())<=7
				and ClientID=@ClientID
		end
end


GO
/****** Object:  StoredProcedure [dbo].[RemoveFromMenu]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[RemoveFromMenu](@menuhistid int, @untildate date) as
begin
	if exists (select * from MenuHist where MenuHistID = @menuhistid)
	begin
		update dbo.MenuHist
		set Until=@untildate
		where MenuHistID=@menuhistid
	end
	else
	begin
		print 'zadanej pozycji nie ma w menuhist'
	end
end


GO
/****** Object:  StoredProcedure [dbo].[SubmitIndividualReservation]    Script Date: 10.02.2022 14:42:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SubmitIndividualReservation]
	@OrderID INT,
	@IsPaid BIT,
	@TableCapacity INT=NULL
AS
BEGIN
	IF ([dbo].GetOrderValue(@OrderID) > (SELECT WZ FROM Parameters) AND
		[dbo].GetClientFinishedOrdersCount((SELECT ClientID FROM Orders WHERE OrderID=@OrderID)) >
		(SELECT WK FROM Parameters))
	BEGIN
		INSERT INTO Reservations(OrderID) VALUES (@OrderID)
		
		DECLARE @ReservationID INT
		SET @ReservationID = (SELECT ReservationID FROM Reservations WHERE OrderID=@OrderID)
		DECLARE @ClientID INT
		SET @ClientID = (SELECT ClientID FROM Orders WHERE OrderID = @OrderID)
		DECLARE @Date DATE
		SET @Date = (SELECT OrderDate FROM Orders WHERE OrderID=@OrderID)

		INSERT INTO IndividualReservation(ReservationID, ClientID, IsPaid, ReservationDate, Date)
		VALUES (@ReservationID, @ClientID, @IsPaid, GETDATE(), @Date)

		DECLARE @Takeaway BIT
		SET @Takeaway = (SELECT Takeaway FROM Orders WHERE OrderID=@OrderID)
		IF (@Takeaway = 0)
		BEGIN
			INSERT INTO IndividualReservationDetails(ReservationID, TableCapacity) 
			VALUES (@ReservationID, @TableCapacity)
		END
	END
	ELSE
	BEGIN
		DELETE FROM [Order Details] WHERE OrderID = @OrderID
		DELETE FROM Orders WHERE OrderID = @OrderID
	END
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "PermanentDiscount"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "PermanentDiscountsAssigned"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 451
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllPermanentDiscountsView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllPermanentDiscountsView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -96
         Left = 0
      End
      Begin Tables = 
         Begin Table = "TemporaryDiscounts"
            Begin Extent = 
               Top = 304
               Left = 202
               Bottom = 434
               Right = 372
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "TemporaryDiscountsAssigned"
            Begin Extent = 
               Top = 144
               Left = 0
               Bottom = 257
               Right = 170
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllTemporaryDiscountsView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllTemporaryDiscountsView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "TablesAssigned"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 102
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 6
               Left = 348
               Bottom = 102
               Right = 518
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AllReservations"
            Begin Extent = 
               Top = 6
               Left = 569
               Bottom = 102
               Right = 739
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AssignedTablesDates'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AssignedTablesDates'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ClientCompany"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Orders"
            Begin Extent = 
               Top = 6
               Left = 249
               Bottom = 136
               Right = 419
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order Details"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 251
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Products"
            Begin Extent = 
               Top = 138
               Left = 246
               Bottom = 251
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 252
               Left = 38
               Bottom = 382
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
     ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyClientReport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'    Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyClientReport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyClientReport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ClientCompany"
            Begin Extent = 
               Top = 14
               Left = 6
               Bottom = 144
               Right = 179
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 157
               Left = 10
               Bottom = 253
               Right = 180
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Orders"
            Begin Extent = 
               Top = 202
               Left = 308
               Bottom = 332
               Right = 478
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order Details"
            Begin Extent = 
               Top = 182
               Left = 936
               Bottom = 295
               Right = 1106
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 171
               Left = 1183
               Bottom = 301
               Right = 1353
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "AllCompanyReservations"
            Begin Extent = 
               Top = 41
               Left = 413
               Bottom = 171
               Right = 587
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyClientsOrderValuesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyClientsOrderValuesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyClientsOrderValuesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 63
               Left = 685
               Bottom = 159
               Right = 855
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Orders"
            Begin Extent = 
               Top = 79
               Left = 1223
               Bottom = 209
               Right = 1393
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ClientCompany"
            Begin Extent = 
               Top = 62
               Left = 23
               Bottom = 192
               Right = 196
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order Details"
            Begin Extent = 
               Top = 80
               Left = 1514
               Bottom = 193
               Right = 1684
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Products"
            Begin Extent = 
               Top = 58
               Left = 1966
               Bottom = 171
               Right = 2136
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 96
               Left = 1749
               Bottom = 226
               Right = 1919
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "AllCompanyReservations"
            Begin Extent = 
               Top = 48
               Left = 349
               Bottom = 203
               Right = 523
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyOrderPricesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'    End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyOrderPricesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyOrderPricesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ClientCompany"
            Begin Extent = 
               Top = 193
               Left = 1134
               Bottom = 321
               Right = 1307
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T1"
            Begin Extent = 
               Top = 36
               Left = 109
               Bottom = 132
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Orders"
            Begin Extent = 
               Top = 242
               Left = 582
               Bottom = 372
               Right = 752
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 46
               Left = 856
               Bottom = 142
               Right = 1026
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order Details"
            Begin Extent = 
               Top = 198
               Left = 38
               Bottom = 311
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 317
               Left = 252
               Bottom = 447
               Right = 422
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 14' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyOrdersView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'40
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyOrdersView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyOrdersView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "CompanyReservations"
            Begin Extent = 
               Top = 17
               Left = 342
               Bottom = 244
               Right = 516
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "CompanyReservationsDetails"
            Begin Extent = 
               Top = 24
               Left = 73
               Bottom = 172
               Right = 243
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyReservationTablesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'CompanyReservationTablesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "IndividualReservation"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 212
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 6
               Left = 250
               Bottom = 102
               Right = 420
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Orders"
            Begin Extent = 
               Top = 6
               Left = 458
               Bottom = 250
               Right = 628
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order Details"
            Begin Extent = 
               Top = 140
               Left = 48
               Bottom = 281
               Right = 258
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 6
               Left = 874
               Bottom = 136
               Right = 1044
            End
            DisplayFlags = 280
            TopColumn = 1
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualClientsOrderValuesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualClientsOrderValuesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualClientsOrderValuesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "IndividualOrdersView"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 3
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualOrdersValuesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualOrdersValuesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Orders"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Order Details"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ClientPerson"
            Begin Extent = 
               Top = 120
               Left = 246
               Bottom = 250
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Products"
            Begin Extent = 
               Top = 252
               Left = 246
               Bottom = 365
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
     ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualOrdersView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'    Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualOrdersView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualOrdersView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "IndividualReservation"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 212
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualReservationTablesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualReservationTablesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 41
               Left = 173
               Bottom = 171
               Right = 343
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Products"
            Begin Extent = 
               Top = 37
               Left = 414
               Bottom = 167
               Right = 584
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Category"
            Begin Extent = 
               Top = 59
               Left = 667
               Bottom = 155
               Right = 837
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MenuHistMonthView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MenuHistMonthView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "Products"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MenuHistView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MenuHistView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Products"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Category"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 102
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MenuHistWeekView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MenuHistWeekView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "MenuHist"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'NewDishesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'NewDishesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "PermanentDiscount"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PermanentDiscountsAssigned"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 451
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ClientPerson"
            Begin Extent = 
               Top = 6
               Left = 489
               Bottom = 136
               Right = 659
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'NewPermanentDiscountsMonthView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'NewPermanentDiscountsMonthView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "PermanentDiscount"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PermanentDiscountsAssigned"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 451
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ClientPerson"
            Begin Extent = 
               Top = 6
               Left = 489
               Bottom = 136
               Right = 659
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'NewPermanentDiscountsWeekView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'NewPermanentDiscountsWeekView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "PersonalCompanyReservations"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 212
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PersonalCompanyReservationDetails"
            Begin Extent = 
               Top = 10
               Left = 278
               Bottom = 123
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PersonalCompanyReservationTablesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'PersonalCompanyReservationTablesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "AllReservationTablesInfo"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 102
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ReservationTablesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'ReservationTablesView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "TablesAssigned"
            Begin Extent = 
               Top = 83
               Left = 239
               Bottom = 179
               Right = 409
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 90
               Left = 471
               Bottom = 186
               Right = 641
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Tables"
            Begin Extent = 
               Top = 86
               Left = 33
               Bottom = 195
               Right = 204
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Orders"
            Begin Extent = 
               Top = 61
               Left = 717
               Bottom = 186
               Right = 887
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TableUsageView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TableUsageView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Tables"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 102
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TablesAssigned"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 102
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 102
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Orders"
            Begin Extent = 
               Top = 6
               Left = 662
               Bottom = 136
               Right = 832
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TableUsageWeekView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TableUsageWeekView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "TemporaryDiscounts"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "TemporaryDiscountsAssigned"
            Begin Extent = 
               Top = 113
               Left = 247
               Bottom = 226
               Right = 417
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ClientPerson"
            Begin Extent = 
               Top = 70
               Left = 521
               Bottom = 200
               Right = 691
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TemporaryDiscountsReportMonthView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TemporaryDiscountsReportMonthView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "TemporaryDiscounts"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TemporaryDiscountsAssigned"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 119
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ClientPerson"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 136
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TemporaryDiscountsReportWeekView'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'TemporaryDiscountsReportWeekView'
GO
USE [master]
GO
ALTER DATABASE [u_obarzane] SET  READ_WRITE 
GO
