-- CLEANING DATA IN SQL QUERIES
select * from Nashville order by 1

--STANDARDIZE DATA FORMAT
select saledate, format(saledate, 'yyyy-MM-dd')
from Nashville 

alter table Nashville
add SaleDateFormated Date;

update Nashville
set SaleDateFormated = format(saledate, 'yyyy-MM-dd')

select SaleDateFormated 
from Nashville

--POPULATE PROPERTY ADDRESS DATA

select * from Nashville

 select uniqueID, ParcelID, PropertyAddress
 from Nashville
 where PropertyAddress is null

 select propertyaddress, count(*)
 from Nashville
 group by propertyaddress
 having count(*) > 1


 select ParcelID, count(*)
 from Nashville
 group by ParcelID
 having count(*) > 1

 select uniqueID, count(*)
 from Nashville
 group by uniqueID
 having count(*) > 1

 select a.uniqueID, a.parcelID, a.propertyaddress, b.uniqueID, b.parcelID, b.propertyaddress
 from Nashville a
 join Nashville b
 on a.ParcelID = b.ParcelID
 and a.uniqueID <> b.uniqueID
 where a.propertyaddress is null

 update a
 set a.propertyaddress = isnull(a.propertyaddress, b.propertyaddress)
  from Nashville a
 join Nashville b
 on a.ParcelID = b.ParcelID
 and a.uniqueID <> b.uniqueID
 where a.propertyaddress is null

 select * from Nashville
 where propertyaddress is null

--BREAKING OUT ADDRESS IN INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE) 
 select propertyaddress
 from Nashville

--Address 

alter table Nashville
add PropertySplitAddress varchar(200)
update Nashville
set PropertySplitAddress = SUBSTRING (propertyaddress, 1, CHARINDEX(',',propertyaddress)-1)

select Address
from Nashville

-- City

alter table Nashville
add PropertySplitCity varchar (100)
update Nashville
set PropertySplitCity = SUBSTRING (propertyaddress,CHARINDEX(',',propertyaddress)+1, len(propertyaddress))

select PropertySplitAddress, PropertySplitCity
from Nashville

---Owneraddress

select owneraddress
from Nashville
where OwnerAddress is not null

select SUBSTRING(owneraddress, 1, CHARINDEX(',',OwnerAddress)-1)
from Nashville
where OwnerAddress is not null

select SUBSTRING(owneraddress, charindex(',', owneraddress)+1, charindex('.',owneraddress)-1)
from Nashville
where OwnerAddress is not null

select charindex('.',owneraddress)
from Nashville
where OwnerAddress is not null

select 
parsename(replace(owneraddress,',','.'),3),
parsename(replace(owneraddress,',','.'),2),
parsename(replace(owneraddress,',','.'),1)
from Nashville
where OwnerAddress is not null 

alter table Nashville
add OwnerSplitAddress  varchar(200)
update Nashville
set OwnerSplitAddress = parsename(replace(owneraddress,',','.'),3)

alter table Nashville
add OwnerCity  varchar(200)
update Nashville
set OwnerCity  = parsename(replace(owneraddress,',','.'),2)

alter table Nashville
add OwnerState  varchar(200)
update Nashville
set OwnerState  = parsename(replace(owneraddress,',','.'),1)

select OwnerSplitAddress, OwnerCity, OwnerState
from Nashville
where OwnerAddress is not null

--CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD 

select distinct Soldasvacant
from Nashville

select Soldasvacant,
case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end
from Nashville

update Nashville
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
	 when soldasvacant = 'N' then 'No'
	 else soldasvacant
	 end

--REMOVE DULICATES

select * from Nashville

with ROWNUMBER as
(
select *, 
row_number () over (
			partition by ParcelID, 
			PropertyAddress, 
			SaleDate, 
			SalePrice 
			order by 
			UniqueID ) as Rownum
from Nashville
)
select * 
from ROWNUMBER
where Rownum > 1

--DELETE UNUSED COLUMNS 

select * from Nashville
alter table Nashville
drop column PropertyAddress, OwnerAddress, TaxDistrict
alter table Nashville
drop column SaleDate
