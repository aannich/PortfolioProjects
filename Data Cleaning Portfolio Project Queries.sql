/*

Cleaning Data in SQL Queries

*/
SELECT * FROM PortolioProjet..NashvilleHousing
 

 -- Standarize date format
 ALTER TABLE NashvilleHousing
 ADD SaleDateConverted DATE

UPDATE PortolioProjet..NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDate, SaleDateConverted
FROM PortolioProjet..NashvilleHousing

-- Populate Property Address data

Select * FROM PortolioProjet..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


SELECT  a.UniqueID, a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN( PropertyAddress))
FROM PortolioProjet..NashvilleHousing

 ALTER TABLE PortolioProjet..NashvilleHousing
 ADD PropertySplitAddress varchar(255)

 UPDATE NashvilleHousing
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) 
 
 ALTER TABLE PortolioProjet..NashvilleHousing
 ADD PropertySplitCity varchar(255)

 UPDATE NashvilleHousing
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN( PropertyAddress))

 
 SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerSplitAddress ,
 PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerSplitCity,
 PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerSplitState
 FROM PortolioProjet..NashvilleHousing

 ALTER TABLE NashvilleHousing
 ADD OwnerSplitAddress varchar(255)

 UPDATE NashvilleHousing
 SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
 
 ALTER TABLE NashvilleHousing
 ADD OwnerSplitCity varchar(255)

 UPDATE NashvilleHousing
 SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
 
 ALTER TABLE NashvilleHousing
 ADD OwnerSplitState varchar(255)

 UPDATE NashvilleHousing
 SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


 -- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortolioProjet..NashvilleHousing
GROUP BY SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortolioProjet.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates 


--cte
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortolioProjet.dbo.NashvilleHousing
--order by ParcelID
)
--DELETE  FROM RowNumCTE
SELECT * FROM RowNumCTE
WHERE row_num > 1


-- Delete unused columns

Select *
From PortolioProjet.dbo.NashvilleHousing

ALTER TABLE PortolioProjet.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate