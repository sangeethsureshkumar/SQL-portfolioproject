--cleaning data in sql queries

SELECT *
FROM PORTFOLIO_PROJECT.dbo.nashvillehouse


--standardize date format

SELECT saledate,CONVERT(Date,saledate)
FROM PORTFOLIO_PROJECT.dbo.nashvillehouse


ALTER TABLE PORTFOLIO_PROJECT..nashvillehouse
ADD saledateconverted date;

UPDATE PORTFOLIO_PROJECT..nashvillehouse
SET saledateconverted=CONVERT(date,saledate)

SELECT saledateconverted
FROM PORTFOLIO_PROJECT.dbo.nashvillehouse

-------------------------------------------------------------------------------------------------------------

--populate property address data

SELECT propertyaddress
FROM PORTFOLIO_PROJECT.dbo.nashvillehouse


SELECT *
FROM PORTFOLIO_PROJECT.dbo.nashvillehouse
where PropertyAddress is null


SELECT a.ParcelID,a.propertyaddress,b.parcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PORTFOLIO_PROJECT.dbo.nashvillehouse a
JOIN PORTFOLIO_PROJECT.dbo.nashvillehouse b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.propertyaddress is null

update a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PORTFOLIO_PROJECT.dbo.nashvillehouse a
JOIN PORTFOLIO_PROJECT.dbo.nashvillehouse b
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]



--------------------------------------------------------------------------------------------------------


--breaking out address into individual columns (ADDRESS,city,state)

SELECT * 
FROM PORTFOLIO_PROJECT..nashvillehouse


SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress))as address
FROM PORTFOLIO_PROJECT..nashvillehouse



ALTER TABLE PORTFOLIO_PROJECT..nashvillehouse
add propertysplitaddress nvarchar(255);

UPDATE PORTFOLIO_PROJECT..nashvillehouse
SET propertysplitaddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE PORTFOLIO_PROJECT..nashvillehouse
add propertysplitcity nvarchar(255);

UPDATE PORTFOLIO_PROJECT..nashvillehouse
SET propertysplitcity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(propertyaddress))

--USING PARSENAME FOR SHORTCUT

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PORTFOLIO_PROJECT..nashvillehouse


ALTER TABLE PORTFOLIO_PROJECT..nashvillehouse
add ownersplitaddress nvarchar(255),
 ownersplitcity nvarchar(255),
 ownersplitstate nvarchar(255)


UPDATE PORTFOLIO_PROJECT..nashvillehouse
SET ownersplitaddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 ownersplitcity=PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 ownersplitstate =PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT * 
FROM PORTFOLIO_PROJECT..nashvillehouse

----------------------------------------------------------------------------------------------

--CHANGE Y AND N TO YES AND NO IN 'SOLD AS VACANT' FIELD


SELECT DISTINCT(SoldAsVacant),count(soldAsVacant)
FROM PORTFOLIO_PROJECT..nashvillehouse
Group by SoldAsVacant
Order by 2




select SoldAsVacant
,CASE
	WHEN SoldAsVacant='y' then 'YES'
	WHEN SoldAsVacant='n' then 'NO'
	ELSE SoldAsVacant
	END
FROM PORTFOLIO_PROJECT..nashvillehouse
ORDER BY 1


UPDATE PORTFOLIO_PROJECT..nashvillehouse
SET SoldAsVacant=CASE
	WHEN SoldAsVacant='y' then 'YES'
	WHEN SoldAsVacant='n' then 'NO'
	ELSE SoldAsVacant
	END

-----------------------------------------------------------------------------------
--REMOVE DUPLICATES(neglect that there is a unique id that is completely unique for each and every row)


WITH rownumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY 
		parcelID,
		PropertyAddress,
		SalePrice,
		Saledate,
		LegalReference
		ORDER BY 
			UNIQUEID
			)row_num
FROM PORTFOLIO_PROJECT..nashvillehouse
)
DELETE
FROM rownumCTE
where row_num >1



--WITH rownumCTE AS (
--SELECT *,
--	ROW_NUMBER() OVER(
--	PARTITION BY 
--		parcelID,
--		PropertyAddress,
--		SalePrice,
--		Saledate,
--		LegalReference
--		ORDER BY 
--			UNIQUEID
--			)row_num
--FROM PORTFOLIO_PROJECT..nashvillehouse
--)
--SELECT *
--FROM rownumCTE
--where row_num >1
--ORDER BY PropertyAddress




SELECT * 
FROM PORTFOLIO_PROJECT..nashvillehouse		


------------------------------------------------------------------------------
--DELETE UNUSED COLUMNS

SELECT * 
FROM PORTFOLIO_PROJECT..nashvillehouse		


 
ALTER TABLE PORTFOLIO_PROJECT..nashvillehouse
DROP COLUMN OwnerAddress,TaxDistrict,propertyaddress,saledate


--------------------------------------------------------------------------------