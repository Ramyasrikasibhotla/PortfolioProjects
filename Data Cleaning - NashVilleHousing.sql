/*
Data Cleaning using SQL Queries
*/

SELECT * FROM PortfolioProject.dbo.NashvilleHousing

-- Standardise date format
SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Populate property address data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Address Split ( Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

-- Split Owner Address

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',','.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
FROM PortfolioProject.dbo.NashvilleHousing
WHERE OwnerAddress IS NOT NULL


ALTER TABLE NashvilleHousing
ADD OwnerPropertySplitAddress nvarchar(255)

UPDATE NashvilleHousing
SET OwnerPropertySplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerPropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET OwnerPropertySplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)


ALTER TABLE NashvilleHousing
ADD OwnerPropertySplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerPropertySplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

-- Change Y and N to Yes and NO in SoledAsVacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldASVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ElSE SoldAsVacant
	 END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ElSE SoldAsVacant
	 END

-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference,
				 OwnerName,
				 OwnerAddress
				 ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE 
WHERE row_num > 1
--ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE	PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate