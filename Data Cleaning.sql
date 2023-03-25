Select *
From PortfolioProject..NashvilleHousing

--Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

--Populate PropertyAddress Data

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is Null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelId
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null
Order by a.ParcelID

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelId
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

-- Breaking out Address INto Individual Columns(Address, City)

Select *
From PortfolioProject..NashvilleHousing

SELECT
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, 
 LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertyConvertedAddress NVARCHAR(255);

Update NashvilleHousing
Set PropertyConvertedAddress =  SUBSTRING(PropertyAddress, 1, 
CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, 
 LEN(PropertyAddress))

 -- Breakout the Owner Address column(Address, City and State)
 Select
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
Set OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Change Y and N in "Sold as vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	 When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 End



--Remove Duplicate

WITH RowNumCTE AS (
Select*,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 LegalReference
					 Order by 
						UniqueID
						) row_num
From PortfolioProject..NashvilleHousing
)

Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress

WITH RowNumCTE AS (
Select*,
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 LegalReference
					 Order by 
						UniqueID
						) row_num
From PortfolioProject..NashvilleHousing
)

Delete 
From RowNumCTE
where row_num > 1
--order by PropertyAddress


--Delete Unsused Columns
Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
Drop Column SaleDate