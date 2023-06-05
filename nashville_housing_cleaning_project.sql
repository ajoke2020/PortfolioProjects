--Cleaning Data in SQL queries

SELECT*
FROM NashvilleHousing


--Standardize Date Format

SELECT Saledate,CONVERT(date, SaleDate)
FROM NashvilleHousing


Update Nashvillehousing
SET SaleDate = CONVERT(date, SaleDate)


--Populate Property Address date

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.propertyaddress, b.parcelID, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.uniqueID <> b.uniqueID
where a.propertyaddress is null

UPDATE a
SET propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.uniqueID <> b.uniqueID
where a.propertyaddress is null


--Breaking out address into individual columns (Address, city, state)
 
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM [Portfolio project 2].dbo.NashvilleSecond

ALTER TABLE NashvilleSecond
ADD PropertySplitAddress Nvarchar(255);
UPDATE NashvilleSecond
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleSecond
ADD PropertySplitCity Nvarchar(255);
UPDATE NashvilleSecond
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))  


--change Y and N to  yes and no in 'sold as vacant' field

SELECT Distinct (SoldAsVacant), count(SoldAsVacant)
FROM NashvilleSecond
group by SoldAsVacant
Order by 2


SELECT (SoldAsVacant)
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   else SoldAsVacant
	   end
FROM NashvilleSecond

UPDATE NashvilleSecond
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   else SoldAsVacant
	   end


SELECT PARSENAME(REPLACE(owneraddress, ',', '.') ,3)
,PARSENAME(REPLACE(owneraddress, ',', '.') ,2)
,PARSENAME(REPLACE(owneraddress, ',', '.') ,1)
FROM NashvilleSecond


ALTER TABLE NashvilleSecond
ADD OwnerSplitAddress Nvarchar(255);
UPDATE NashvilleSecond
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.') ,3)

ALTER TABLE NashvilleSecond
ADD OwnerSplitCity Nvarchar(255);
UPDATE NashvilleSecond
SET OwnerSplitCity = (REPLACE(owneraddress, ',', '.') ,2)

ALTER TABLE NashvilleSecond
ADD OwnerSplitState Nvarchar(255);
UPDATE NashvilleSecond
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.') ,1)


 --Removing duplicates

 WITH RowNumCTE as(
 SELECT *, ROW_NUMBER() OVER (
 PARTITION BY ParcelID, 
 propertyAddress, 
 saleprice,
 saleDate,
 legalReference
 ORDER BY
 uniqueID) row_num
 from NashvilleSecond
 )
 select *
 from RowNumCTE
 where row_num > 1

 --Delete unsused columns

 ALTER TABLE NashvilleSecond
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE NashvilleSecond
 DROP COLUMN Saledate

 
 select *
 from NashvilleSecond