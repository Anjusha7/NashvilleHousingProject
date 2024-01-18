-- data cleaning project on the Nashvile Hosuing Data 

--lets view the data

select * 
FROM [Portfolio].[dbo].[nashvilleHousing]

-- I) lets standardise the date format 

--		 1. we can either update the existing column

select saledate, convert(date,saledate)
FROM [Portfolio].[dbo].[nashvilleHousing]

--		2. or we can either create a new col with the updated date format

alter table nashvilleHousing
add altereddate date

update nashvilleHousing
set altereddate = CONVERT(date,saledate)


-- II) LETS POPULATE THE PROPERTY ADDRESS DATA 
-- HERE FROM THE EXPLORATORY ANALYSIS WE UNDERSTOOD THAT THE PROPERTY ADDRESS THAT ARE MISSING ACTUALLY EXIST FOR THOSE PARCEL ID WITH A DIFFERENT UNIUEID 
--SO NOW WE WILL JOIN THE TWO TABLES ON THE SAME PARCEL ID AND COPY THE VALUE FROM THE EXISTING ADDRESS TO THE MISSING ADDRESS 

--SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
--FROM [Portfolio].[dbo].[nashvilleHousing] AS A 
--JOIN [Portfolio].[dbo].[nashvilleHousing] AS B 
--ON A.ParcelID = B.ParcelID
--AND A.[UniqueID ] <> B.[UniqueID ]
--WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Portfolio].[dbo].[nashvilleHousing] AS A 
JOIN [Portfolio].[dbo].[nashvilleHousing] AS B 
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--III) LETS SPLIT THE ADDRESS TO GET CITY AND STREET 

--select
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address, 
--SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as address
--from [Portfolio].[dbo].[nashvilleHousing]

alter table nashvilleHousing
add SplitAddress nvarchar(255)

update nashvilleHousing
set SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

 alter table nashvilleHousing
 add SplitCity nvarchar(255)

 update nashvilleHousing
 set SplitCity=  SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

select *
from [Portfolio].[dbo].[nashvilleHousing]


--IV) WE NEED TO DO THE SAME TO THE OWNER ADDRESS, BUT WE WILL DO IT SIMPLER USING "PARSENAME" FUNCTION

--SELECT
--PARSENAME(REPLACE(owneraddress, ',','.'),3),
--PARSENAME(REPLACE(owneraddress, ',','.'),2),
--PARSENAME(REPLACE(owneraddress, ',','.'),1)
--from [Portfolio].[dbo].[nashvilleHousing]

alter table nashvilleHousing
add ownerSplitAddress nvarchar(255)

update nashvilleHousing
set ownerSplitAddress= PARSENAME(REPLACE(owneraddress, ',','.'),3)


alter table nashvilleHousing
add ownerSplitCity nvarchar(255)

update nashvilleHousing
set ownerSplitCity= PARSENAME(REPLACE(owneraddress, ',','.'),2)

alter table nashvilleHousing
add ownerSplitState nvarchar(255)

update nashvilleHousing
set ownerSplitState= PARSENAME(REPLACE(owneraddress, ',','.'),1)


select *
from [Portfolio].[dbo].[nashvilleHousing]


--V) DURING MORE RESEARCH WE FIND THAT THE SOLDASVACANT COL HAS 2 TYPES OF YES AND NO FUNCTION. 
--SO WE CAN DO A CASE STATEMENT TO CHANGE IT 

--SELECT DISTINCT(SOLDASVACANT), COUNT(SOLDASVACANT)
--from [Portfolio].[dbo].[nashvilleHousing]
--GROUP BY SOLDASVACANT
--ORDER BY 2


--SELECT SOLDASVACANT,
--CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
--	 when SoldAsVacant = 'N' then 'No'
--	 else SoldAsVacant
--	 end 
--from [Portfolio].[dbo].[nashvilleHousing]

update nashvilleHousing
set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end 

--VI) NEXT LETS REMOVE SOME DUPLICTAES 
-- THERE MIGHT BE SOME DUPLICATES IN THE ROWS AND TO CHECK THAT WE CAN USE A WINDOWS FUNCTION - ROW NUM : TO PROVIDE A SEQUENTIAL NO TO EACH ROW

WITH ROWNUMCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY PARCELID,
				PROPERTYADDRESS,
				SALEDATE,
				SALEPRICE,
				LEGALREFERENCE
	ORDER BY	UNIQUEID) 
	AS ROW_NUM

from [Portfolio].[dbo].[nashvilleHousing]
--ORDER BY ParcelID
)

DELETE
FROM ROWNUMCTE
WHERE ROW_NUM>1


--VII)NOW AS THE LAST PART LETS DELETE ALL THE COLUMNS THAT HAVE BEEN ALTERED/REGENERATED


ALTER TABLE [Portfolio].[dbo].[nashvilleHousing]
DROP COLUMN OWNERADDRESS, PROPERTYADDRESS, SALEDATE, TAXDISTRICT

SELECT *
from [Portfolio].[dbo].[nashvilleHousing]
