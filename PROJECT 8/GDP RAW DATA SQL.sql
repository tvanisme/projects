create database GDP 

DROP TABLE IF EXISTS Raw_Data_GDP
--Step 1: Create Table 
CREATE TABLE Raw_Data_GDP
(
DEMO_IND nvarchar(200),
Indicator nvarchar(200),
[LOCATION] nvarchar (50),
Country nvarchar (200),
[TIME] nvarchar (50),
[Value] nvarchar(100),
[Flag Codes] nvarchar(200),
Flags nvarchar (200)
)

--Step 2:Import the Data

BULK INSERT Raw_Data_GDP 
FROM 'C:\Users\Admin\Desktop\PROJECT\gdp_raw_data.csv'
WITH 
(FORMAT = 'CSV',
FIRSTROW = 2);

UPDATE Raw_Data_GDP
SET [VALUE] = cast([value] as float)

--Step 3: Create the view we need 

--DROP VIEW GDP_EXCEL_INPUT

CREATE VIEW GDP_EXCEL_INPUT AS

SELECT a.*, b.GDP_Per_Capital FROM
(SELECT Country, [Time] AS Year_No, [value] as GDP_Value 
FROM Raw_Data_GDP 
WHERE Indicator = 'GDP (current US$)' ) a
LEFT JOIN 
(SELECT Country, [Time] AS Year_No, [value] as GDP_Per_Capital 
FROM Raw_Data_GDP 
WHERE Indicator = 'GDP per capita (current US$)' ) b
ON a.Country = b.Country AND a.Year_No = b.Year_No

--SELECT * FROM GDP_EXCEL_INPUT 

--Step 4: Create a Store Procedure 
CREATE PROCEDURE GDP_Excel_Input_Monthly AS 

DROP TABLE IF EXISTS Raw_Data_GDP
CREATE TABLE Raw_Data_GDP
(
DEMO_IND nvarchar(200),
Indicator nvarchar(200),
[LOCATION] nvarchar (50),
Country nvarchar (200),
[TIME] nvarchar (50),
[Value] nvarchar(100),
[Flag Codes] nvarchar(200),
Flags nvarchar (200)
)


BULK INSERT Raw_Data_GDP 
FROM 'C:\Users\Admin\Desktop\PROJECT\gdp_raw_data.csv'
WITH 
(FORMAT = 'CSV',
FIRSTROW = 2);

UPDATE Raw_Data_GDP
SET [VALUE] = cast([value] as float)

EXEC GDP_Excel_Input_Monthly
