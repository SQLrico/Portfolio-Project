/*

Data Cleaning using SQL Queries

*/


USE PortfolioProject

SELECT *
FROM nashville_housing;

-- Standardize Date Format

SELECT SaleDate
FROM nashville_housing;

UPDATE nashville_housing
SET SaleDate = CONVERT(Date, SaleDate);

ALTER TABLE nashville_housing
Add SaleDateConverted Date;

UPDATE nashville_housing
SET SaleDateConverted = CONVERT(Date, SaleDate);

SELECT SaleDateConverted
FROM nashville_housing;

-- Populate Property Address Data

SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL;

SELECT 
	a.ParcelID,
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

SELECT PropertyAddress
FROM nashville_housing
WHERE PropertyAddress IS NULL;

-- Breaking out PropertyAddress into individual columns (Address, City)
-- Using SUBSTRING function

SELECT PropertyAddress
FROM nashville_housing; 

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS City
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = CONVERT(SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE nashville_housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashville_housing
SET PropertySplitCity = CONVERT(SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT 
	PropertyAddress,
	PropertySplitAddress,
	PropertySplitCity
FROM nashville_housing;

-- Breaking out OwnerAddress into individual columns (Address, City, State)
-- Using PARSENAME function 

SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM nashville_housing;


ALTER TABLE nashville_housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE nashville_housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE nashville_housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


SELECT 
	OwnerAddress,
	OwnerSplitAddress,
	OwnerSplitCity,
	OwnerSplitState
FROM nashville_housing;


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT
	SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM nashville_housing;

UPDATE nashville_housing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;


-- Remove Duplicate Rows

WITH RowNumCTE AS (
SELECT 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY 
			UniqueID
			) row_num
FROM nashville_housing)

DELETE
FROM RowNumCTE
WHERE row_num > 1;


-- Delete Unused Columns

SELECT *
FROM nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN 
	SaleDate,
	OwnerAddress, 
	PropertyAddress,

	TaxDistrict;
