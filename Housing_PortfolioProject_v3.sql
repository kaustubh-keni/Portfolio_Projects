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

ALTER TABLE HousingProject
ADD PropertySplitAddress Nvarchar(255);

UPDATE HousingProject
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE HousingProject
ADD PropertySplitCity Nvarchar(255);

UPDATE HousingProject
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

--------------------------------------------------------------------------------------------------------------

SELECT OwnerAddress
FROM Housing_Project..HousingProject

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Housing_Project..HousingProject

ALTER TABLE HousingProject
ADD OwnerSplitAddress Nvarchar(255);

UPDATE HousingProject
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE HousingProject
ADD OwnerSplitCity Nvarchar(255);

UPDATE HousingProject
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE HousingProject
ADD OwnerSplitState Nvarchar(255);

UPDATE HousingProject
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Housing_Project..HousingProject
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Housing_Project..HousingProject
GROUP BY SoldAsVacant

UPDATE HousingProject
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
   SELECT *,
    ROW_NUMBER() OVER(
                      PARTITION BY ParcelID,
                                   PropertyAddress,
				                   SalePrice,
				                   SaleDate,
				                   LegalReference
                      ORDER BY UniqueID
					  ) as row_num 


FROM Housing_Project..HousingProject
                    )

SELECT *
FROM RowNumCTE
WHERE row_num > 1

------------------------------------------------------------------------------------------------------------------

-- Delete Unused columns

SELECT *
FROM Housing_Project..HousingProject

ALTER TABLE Housing_Project..HousingProject
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Housing_Project..HousingProject
DROP COLUMN Saledate

SELECT *
FROM Housing_Project..HousingProject
