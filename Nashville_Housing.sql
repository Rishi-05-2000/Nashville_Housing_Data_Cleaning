--**Cleaning Data using SQL**:
--Name of the Dataset:"Nashville Housing" 

--------------------------------------------------------------------------------------------------------------------------

--(1)Importing the Data:
select *
from Portfolio_Project.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

--(2)Standardize the Date Format:
select Sale_date,CONVERT(date,SaleDate)
from Portfolio_Project.dbo.NashvilleHousing
--Error Occured:cannot find the object 'Nashville' because it does not exist or you do not have permissions.
--Solved by using this - "USE Portfolio_Project"
USE Portfolio_Project
UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

Alter Table NashvilleHousing
ADD Sale_date Date;

UPDATE NashvilleHousing
SET Sale_date = CONVERT(date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------

--(3)Populate the Property Address:
select *
from Portfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

--(4) Breaking out Address into Individual Columns(Address,City,State):
select PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as City
from Portfolio_Project.dbo.NashvilleHousing
--Error Occured:cannot find the object 'Nashville' because it does not exist or you do not have permissions.
--Solved by using this - "USE Portfolio_Project"
Alter Table NashvilleHousing
ADD Property_Split_Address nvarchar(255);
USE Portfolio_Project
UPDATE NashvilleHousing
SET Property_Split_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) 

Alter Table NashvilleHousing
ADD Property_Split_City nvarchar(255);

UPDATE NashvilleHousing
SET Property_Split_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

select OwnerAddress
from Portfolio_Project.dbo.NashvilleHousing

select 
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
from Portfolio_Project.dbo.NashvilleHousing

--Error Occured:cannot find the object 'Nashville' because it does not exist or you do not have permissions.
--Solved by using this - "USE Portfolio_Project"
USE Portfolio_Project
Alter Table NashvilleHousing
ADD Owner_Split_Address nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Split_Address = PARSENAME (REPLACE(OwnerAddress,',','.'),3) 


Alter Table NashvilleHousing
ADD Owner_Split_City nvarchar(255);

UPDATE NashvilleHousing
SET Property_Split_City = PARSENAME (REPLACE(OwnerAddress,',','.'),2) 


Alter Table NashvilleHousing
ADD Owner_Split_State nvarchar(255);

UPDATE NashvilleHousing
SET Owner_Split_State = PARSENAME (REPLACE(OwnerAddress,',','.'),1)


--Now it's time to Check the updated table:
select *
from Portfolio_Project.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
--(5) Change Y and N to Yes and No in the Soldasvacant field:

select distinct (SoldAsVacant),COUNT(SoldAsVacant)
from Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' then 'Yes'
		 WHEN SoldAsVacant = 'N' then 'NO'
		 ELSE SoldAsVacant
		 END
from Portfolio_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
		 WHEN SoldAsVacant = 'N' then 'NO'
		 ELSE SoldAsVacant
		 END


--------------------------------------------------------------------------------------------------------------------------
--(6)Removing Duplicates:

WITH RowNumCTE AS (
select *,
	ROW_NUMBER() OVER(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
from Portfolio_Project.dbo.NashvilleHousing
)
select*
from RowNumCTE
where row_num > 1
order by PropertyAddress

--------------------------------------------------------------------------------------------------------------------------
--(7)Delete Unused Columns:
select *
from Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE  Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress,PropertyAddress,TaxDistrict

ALTER TABLE  Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate