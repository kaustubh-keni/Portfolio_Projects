/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM Housing_Project..HousingProject

------------------------------------------------------------------------------------------------------
-- Standarize Date Format

SELECT SaleDate, CONVERT(DATE, SALEDATE) AS SaleDateConverted
FROM Housing_Project..HousingProject

UPDATE HousingProject
SET SaleDate = CONVERT(DATE, SALEDATE)

--ALTER TABLE Housing_Project
--ADD SaleDateConverted = CONVERT(DATE, SALEDATE)

------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM Housing_Project..HousingProject
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing_Project..HousingProject a
JOIN Housing_Project..HousingProject b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing_Project..HousingProject a
JOIN Housing_Project..HousingProject b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


------------------------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

SELECT PropertyAddress
FROM Housing_Project..HousingProject

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
FROM Housing_Project..HousingProject