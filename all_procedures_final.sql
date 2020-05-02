--User Stories
-- Register to the website by using my name, a unique username, password, and an Email
GO
CREATE PROC customerRegister
@username  VARCHAR(20),
@first_name VARCHAR(20),
@last_name VARCHAR(20) ,
@password VARCHAR(20),
@email VARCHAR(50)
AS
INSERT INTO Users(username, password , first_name , last_name, email)
VALUES(@username, @password, @first_name , @last_name , @email)
INSERT INTO CUSTOMER(username,points)
VALUES(@username,0)
--------------------------------------------------------------------------------------
GO
CREATE PROC vendorRegister
@username  VARCHAR(20),
@first_name VARCHAR(20),
@last_name VARCHAR(20) ,
@password  VARCHAR(20),
@email VARCHAR(50),
@company_name VARCHAR(20),
@bank_acc_no VARCHAR(20)
AS
INSERT INTO Users(username, password , first_name , last_name, email)
VALUES(@username, @password, @first_name, @last_name , @email)

INSERT INTO Vendor(username,activated, company_name ,bank_acc_no)
VALUES(@username,0, @company_name , @bank_acc_no)
---------------------------------------------------------------------------------------
--login using my username and password
GO
CREATE PROC userLogin
@username VARCHAR(20),
@password VARCHAR(20),
@success BIT OUTPUT ,
@type SMALLINT  OUTPUT 
-- success indicates that the user was found in the table.
--type indicates the type of the user : Customer–>0,Vendor–>1, Admin–>2,delivery–>3  
AS
--checking if the user found in table or not
IF (EXISTS (SELECT * FROM Users WHERE @username=username AND @password=password))
BEGIN
SET @success =1
END
ELSE
BEGIN
SET @success =0
SET @type=-1
END

IF(EXISTS (SELECT * FROM Customer WHERE @username=username))
BEGIN
SET @type = 0
END
ELSE
IF(EXISTS (SELECT * FROM Vendor WHERE @username=username))
BEGIN
SET @type=1
END
ElSE
IF(EXISTS (SELECT * FROM Admins WHERE @username=username))
BEGIN
SET @type=2
END
ElSE
IF(EXISTS (SELECT * FROM Delivery WHERE @username=username))
BEGIN
SET @type=3
END
-------------------------------------------------------------------------------------------------------
-- add my telephone number(s) 
GO
CREATE PROC addMobile
@username VARCHAR(20),
@mobile_number VARCHAR(20) 
AS
INSERT INTO User_mobile_numbers(mobile_number,username)
VALUES(@mobile_number, @username)
---------------------------------------------------------------------------------------------------------
--add my address(s) 
GO

CREATE PROC addAddress
@username VARCHAR(20),
@address VARCHAR(100)

AS
INSERT INTO User_Adresses(username,address)
VALUES(@username,@address)
---------------------------------------------------------------------------------------------------------
--As a Customer I should be able to:
--a) View list of all the products oﬀered on the website. 
GO
CREATE PROC showProducts
AS
SELECT  product_name,product_description,price,final_price,color
FROM Product
----------------------------------------------------------------------------------------------------------
--b) order the product by their price ascending
GO
CREATE PROC ShowProductsbyPrice
AS
SELECT product_name,product_description,price,color
FROM Product
ORDER BY price
--------------------------------------------------------------------------------------------------------
--c) Search products by name
GO
CREATE PROC searchbyname
@text VARCHAR(20)
AS
SELECT serial_no,product_name,product_description
FROM Product 
WHERE Product_name LIKE '%'+@text+'%'
--------------------------------------------------------------------------------------------------------
--d) Post questions related to a speciﬁc product
GO
CREATE PROC AddQuestion
@serial INT ,
@customer VARCHAR(20),
@Question VARCHAR(50)
AS
INSERT INTO Customer_Question_Product(serial_no, customer_name, question)
VALUES(@serial,@customer,@Question)
-------------------------------------------------------------------------------------------------------------
--e) Add/remove products to my cart
GO
CREATE PROC addToCart
@serial INT,
@customer_name VARCHAR(20)
AS
INSERT INTO CustomerAddstoCartProduct(serial_no, customer_name)
VALUES(@serial,@customer_name)
GO
CREATE PROC removefromCart
@customername VARCHAR(20),
@serial INT
AS
DELETE FROM  CustomerAddstoCartProduct  WHERE serial_no = @serial and customer_name = @customername
-------------------------------------------------------------------------------------------------------------
--Create (a) wish list(s)
GO
CREATE PROC createWishlist
@customername varchar(20),
@name varchar(20)
AS
INSERT INTO wishlist(username,name)
VALUES(@customername,@name)
------------------------------------------------------------------------------------------------------------------
--Add/remove products from my wish list
GO
CREATE PROC AddtoWishlist
@customername varchar(20),
@wishlistname varchar(20),
@serial int
AS
INSERT INTO wishlist_product(username, wish_name,serial_no)
values(@customername, @wishlistname, @serial)
GO
create proc removefromWishlist
@customername varchar(20),
@wishlistname varchar(20),
@serial int 
AS
DELETE FROM wishlist_product WHERE @customername = username AND @wishlistname = wish_name AND @serial = serial_no
-----------------------------------------------------------------------------------------------------------------------
--h) View details of products in my wishlist
GO
CREATE proc showWishlistProduct
@customername varchar(20),
@name varchar(20)
AS
SELECT p.product_name,p.product_description,p.price,p.final_price,p.category,p.color
FROM product p, wishlist_product wp
WHERE @customername = username AND @name=wish_name AND p.serial_no = wp.serial_no
------------------------------------------------------------------------------------------------------------------
--i) View products that I added to my cart
GO
CREATE proc viewMyCart
@customer varchar(20)
AS
SELECT  p.product_name,p.product_description,p.price,p.final_price,p.category,p.color
FROM Product p, CustomerAddstoCartProduct C
WHERE @customer = customer_name AND C.serial_no = p.serial_no AND C.customer_name=@customer
------------------------------------------------------------------------------------------------------------------
--j) make an order from the products I added in the cart
GO
CREATE PROC calculatepriceOrder
@customername VARCHAR(20),
@sum DECIMAL(10,2) OUTPUT
AS
SELECT @sum = SUM(p.price)
FROM CustomerAddstoCartProduct c INNER JOIN Product p ON p.serial_no=c.serial_no
WHERE @customername=c.customer_name
GO
CREATE PROC emptycart 
@customername VARCHAR(20)
AS
DELETE FROM CustomerAddstoCartProduct  WHERE @customername=customer_name
GO
 CREATE PROC makeOrder
@customername VARCHAR(20)
AS
--Creating an Order
DECLARE @sum DECIMAL(10,2)
EXEC calculatepriceOrder @customername , @sum OUTPUT
INSERT INTO Orders  (order_date,total_amount,customer_name)
VALUES(CURRENT_TIMESTAMP,@sum,@customername)
DECLARE @order INT
SELECT @order= MAX(o.order_no)
FROM Orders O

EXEC productsinorder @customername , @order

EXEC emptycart @customername
GO
CREATE PROC productsinorder
@customername VARCHAR(20),
@orderID INT
AS
--Updating the customer of the products
UPDATE Product
SET customer_username=@customername
WHERE serial_no IN(
SELECT serial_no
FROM CustomerAddstoCartProduct
WHERE customer_name=@customername)

--Updating Products' availability to zero
UPDATE Product
SET available=0
WHERE serial_no IN(
SELECT p.serial_no 
FROM Product p WHERE p.customer_username=@customername)
--Removing the products from all other Customers cart
DELETE FROM CustomerAddstoCartProduct WHERE serial_no IN(
SELECT p.serial_no 
FROM Product p WHERE p.customer_username=@customername)
------------------------------------------------------------------------------------------------------------------
--k) Cancel my order as long as the status is one of the following: not processed, or in process
GO
create proc cancelOrder
@orderid int
AS
--Exctracting the gift card used
DECLARE @giftcardcode VARCHAR(10)
SELECT @giftcardcode=Gift_Card_code_used
FROM Orders
WHERE @orderid=order_no
--Extracting the customerusername
DECLARE @cust_username VARCHAR(20)
SELECT @cust_username=customer_name
FROM Orders
WHERE @orderid=order_no

if exists ( select * 
from Orders o
where order_no= @orderid AND (o.order_status = 'not processed' or  o.order_status='in process'))
Begin
if(exists(select * from Giftcard g where g.expiry_date > CURRENT_TIMESTAMP AND g.code=@giftcardcode))
Begin
--Extracting number of points of the giftcard
DECLARE @point INT
SELECT @point=amount
FROM Giftcard
WHERE code=@giftcardcode
--Adding the points to the user
UPDATE Customer
SET points=points+@point
WHERE username=@cust_username
--Making the products in the Order availabe again
UPDATE Product
SET available=1
WHERE customer_order_id=@orderid
--
delete from Orders 
where  order_no =@orderid 
End
Else
--There is no valid giftcard
Begin
delete from Orders where @orderid =order_no
End
End
--------------------------------------------------------------------------------------------------------------------
--l) Return a delivered product(s).
GO
CREATE PROC returnProduct
@serial_no INT,
@orderID INT
AS
UPDATE Product
SET customer_username=NULL
WHERE serial_no=@serial_no

UPDATE Product
SET available=1
WHERE serial_no=@serial_no

DECLARE @customer VARCHAR(20)
SELECT @customer=customer_name
FROM Orders
WHERE order_no=@orderID

DECLARE @price DECIMAL(10,2)
SELECT @price=price
FROM Product
WHERE serial_no=@serial_no

DECLARE @method VARCHAR(20)
SELECT @method=payment_type
FROM Orders
WHERE @serial_no=order_no

IF(@method='credit')
BEGIN
UPDATE Orders 
SET credit_amount=credit_amount-@price
END
ELSE
BEGIN
UPDATE Orders 
SET cash_amount=cash_amount-@price
END


IF EXISTS (SELECT * FROM Orders o , Giftcard g WHERE o.Gift_Card_code_used=g.code AND order_no=@orderID AND Gift_Card_code_used IS NOT NULL AND g.expiry_date>CURRENT_TIMESTAMP)
BEGIN

DECLARE @code VARCHAR(10)
SELECT @code=Gift_Card_code_used
FROM Orders o 
WHERE order_no=@orderID 

DECLARE @point INT

SELECT @point=amount
FROM Giftcard
WHERE code=@code

UPDATE Customer
SET points=points+@point
WHERE username=@customer
END
ELSE
BEGIN  
UPDATE Orders 
SET total_amount=total_amount-@price

END
-----------------------------------------------------------------------------------------------------------------------------------------
--m) View all the products I previously bought so I can rate any of them
GO
CREATE PROC ShowproductsIbought
@customername VARCHAR(20)
AS
SELECT *
FROM Product
WHERE customer_username=@customername
------------------------------------------------------------------------------------------------------------------------------------------
--n) Rate products I bought on the system
GO
CREATE PROC rate 
@serialno int, 
@rate int , 
@customername varchar(20)
AS
UPDATE Product 
set rate=@rate 
where serial_no=@serialno and customer_username=@customername
------------------------------------------------------------------------------------------------------------------------------------------
--o) Pay in cash or using my credit card partially or totally and update points accordingly
GO
CREATE PROC SpecifyAmount
@customername varchar(20), 
@orderID int, 
@cash decimal(10,2), 
@credit decimal(10,2)
AS
DECLARE  @total DECIMAL(10,2)
DECLARE @remaining DECIMAL(10,2)
SELECT  @total=total_amount
FROM Orders
where order_no=@orderID
 
IF @credit IS NOT NULL or @credit <> 0 
BEGIN
set @remaining=@total-@credit
update Orders
set credit_amount=@credit , payment_type='credit'
where order_no=@orderID and customer_name=@customername
END
ELSE 
BEGIN
set @remaining=@total-@cash
update Orders
set cash_amount=@cash , payment_type='cash'
where order_no=@orderID and customer_name=@customername
END 

IF (@remaining<>0) --points must be used 
BEGIN
DECLARE @code VARCHAR(10)
SELECT code=@code
from Admin_Customer_Giftcard 
where customer_name=@customername
IF(@code IS NOT NULL)
BEGIN
update Orders
set Gift_Card_code_used=@code 
where order_no=@orderID and customer_name=@customername

update Admin_Customer_Giftcard 
set remaining_points=remaining_points-@remaining
where code=@code 
UPDATE Customer
SET points=points-@remaining
where username=@customername
END
END
------------------------------------------------------------------------------------------------------------------------------------------
-- Add as many credit cards as I want
GO
CREATE PROC AddCreditCard
@creditcardnumber varchar(20),
@expirydate datetime,
@cvv varchar(4),
@customername varchar(20)
AS
INSERT INTO Credit_Card (number,expiry_date ,cvv_code) 
VALUES (@creditcardnumber,@expirydate,@cvv)
INSERT INTO Customer_CreditCard (customer_name,cc_number)
VALUES(@customername,@creditcardnumber)
-------------------------------------------------------------------------------------------------------------------------------------------
--q) choose one credit card to pay the order with
GO
CREATE PROC ChooseCreditCard
@creditcard varchar(20), 
@orderid int
AS
UPDATE Orders
set creditCard_number=@creditcard
WHERE order_no=@orderid
-----------------------------------------------------------------------------------------------------------------------------------
--r) View all the delivery types in the system
GO
CREATE PROC viewDeliveryTypes
AS
SELECT type, time_duration,fees
FROM Delivery
----------------------------------------------------------------------------------------------------------------------------------
--s) Choose a delivery type for the order and accordignly update the remainingg days
GO
CREATE PROC specifydeliverytype
@orderID int,
@deliveryID int
AS 
DECLARE @days INT
SELECT @days=time_duration 
from Delivery
where id=@deliveryID

UPDATE Orders
set delivery_id= @deliveryID,remaining_days= @days
WHERE order_no=@orderID
---------------------------------------------------------------------------------------------------------------------------
--t) Track the delivery status of his/her order(s). (It should update the remaining days and show it to the customer) 
GO
CREATE PROC trackRemainingDays
@orderid int, 
@customername varchar(20),
@days int OUTPUT
AS
DECLARE @date_of_order datetime
DECLARE @daysremaining int 
DECLARE @dayspassed INT
SELECT @date_of_order=order_date ,@daysremaining=remaining_days
from Orders
where order_no=@orderid and customer_name=@customername
set @dayspassed=DAY(CURRENT_TIMESTAMP)-DAY(@date_of_order)
set @days= @daysremaining-@dayspassed
UPDATE Orders
set remaining_days=@days
WHERE order_no=@orderid
-----------------------------------------------------------------------------------------------------------------------------
-- As a customer I should get recommendation for products

--------------------------------------------------------------------------------------------------------------------------------
--As an activated Vendor I should be able to
--a) Post products on the system
GO
CREATE PROC postProduct
@vendorUsername VARCHAR(20),
@product_name VARCHAR(20),
@category VARCHAR(20),
@product_description TEXT,
@price DECIMAL (10,2),
@color VARCHAR(20)
AS
DECLARE @activated BIT
SELECT @activated=activated
FROM Vendor
WHERE username =@vendorUsername
IF(@activated=1)
BEGIN
INSERT INTO Product(product_name,category,product_description,price,final_price,color,vendor_username)
VALUES (@product_name,@category,@product_description,@price,@price,@color,@vendorUsername)
END
------------------------------------------------------------------------------------------------
--View the products I posted on the system
GO
CREATE PROC vendorviewProducts
@vendorname VARCHAR(20)
AS
SELECT *
FROM Product
WHERE vendor_username=@vendorname
----------------------------------------------------------------------------------------------------
--c) Edit products I posted on the system
GO
CREATE PROC EditProduct
@vendorname VARCHAR(29),
@serialnumber INT,
@product_name VARCHAR(20),
@category VARCHAR(20),
@product_description TEXT,
@price DECIMAL (10,2),
@color VARCHAR(20)
AS
IF (@Product_name IS NOT NULL)
BEGIN 
UPDATE Product
SET product_name=@product_name
WHERE @serialnumber=serial_no AND vendor_username=@vendorname
END
IF (@category IS NOT NULL)
BEGIN 
UPDATE Product
SET category=@category 
WHERE @serialnumber=serial_no AND vendor_username=@vendorname
END
IF (@product_description IS NOT NULL)
BEGIN 
UPDATE Product
SET product_description=@product_description 
WHERE @serialnumber=serial_no AND vendor_username=@vendorname
END
IF (@price IS NOT NULL)
BEGIN 
UPDATE Product
SET price=@price 
WHERE @serialnumber=serial_no AND vendor_username=@vendorname
END
IF (@color IS NOT NULL)
BEGIN 
UPDATE Product
SET color=@color
WHERE @serialnumber=serial_no AND vendor_username=@vendorname
END
--------------------------------------------------------------------------------------------------------------------------------
--d) Delete products I posted on the system 
GO
CREATE PROC deleteProduct
@vendorname VARCHAR (20),
@serialnumber INT
AS
DELETE FROM Product
WHERE vendor_username=@vendorname AND serial_no=@serialnumber
-----------------------------------------------------------------------------------------------------------------------------------
--e) View questions related to my products on the system
GO
CREATE PROC viewQuestions
@vendorname VARCHAR(20)
AS
SELECT * 
FROM Customer_Question_Product c
WHERE c.serial_no IN ( SELECT p.serial_no
					   FROM Product p
					   WHERE p.vendor_username=@vendorname)
-------------------------------------------------------------------------------------------------------------------------------
--f) Answer questions related to my products on the system. 
GO
CREATE PROC answerQuestions
@vendorname varchar(20), 
@serialno int, 
@customername varchar(20),
@answer text
AS 
UPDATE Customer_Question_Product 
SET answer=@answer   
WHERE customer_name=@customername and @serialno IN (SELECT p.serial_no
					   FROM Product p
					   WHERE p.vendor_username=@vendorname)
------------------------------------------------------------------------------------------------------------------------------------
--g) create oﬀers on products I posted (one at a time) and update the product’s ﬁnal price accordingly
GO
CREATE PROC addOffer
@offeramount int, 
@expiry_date datetime
AS
INSERT INTO offer(offer_amount,expiry_date) VALUES(@offeramount,@expiry_date)

GO
CREATE PROC checkOfferonProduct
@serial int,
@activeoffer bit output
AS
IF (EXISTS (SELECT * FROM offersOnProduct op , offer o WHERE o.offer_id =op.offer_id AND op.serial_no=@serial AND o.expiry_date>CURRENT_TIMESTAMP ))
BEGIN
SET @activeoffer=1
END
ELSE
BEGIN
SET @activeoffer=0
END

GO
CREATE PROC checkandremoveExpiredoffer
@offerid int
AS
DECLARE @expirydate datetime
SELECT @expirydate=expiry_date
from offer
where offer_id=@offerid

DECLARE @serialno INT
SELECT @serialno=serial_no
FROM offersOnProduct 
WHERE @offerid=offer_id



IF @expirydate<current_timestamp
BEGIN
UPDATE Product
set final_price=price
where serial_no=@serialno

DELETE FROM offer
where offer_id=@offerid

END

GO
CREATE PROC applyOffer 
@offerid int, 
@serial int
AS
EXEC checkandremoveExpiredoffer @offerid

DECLARE @activeoffer BIT
EXEC checkOfferonProduct @serial , @activeoffer OUTPUT

IF(@activeoffer=0)
BEGIN
INSERT INTO offersOnProduct(offer_id,serial_no) VALUES (@offerid,@serial)

DECLARE @offer_amount DECIMAL(10,2)
SELECT @offer_amount =offer_amount
FROM offer
WHERE offer_id=@offerid

UPDATE Product
SET final_price =price-@offer_amount
WHERE serial_no=@serial

DECLARE @final DECIMAL (10,2)
SELECT @final=final_price
FROM Product
WHERE serial_no=@serial

IF(@final<0)
BEGIN
UPDATE Product
SET final_price =0
WHERE serial_no=@serial
END
END
--------------------------------------------------------------------------------------------------------------------------------------
--As an Admin I should be able to
--a) Activate non-activated vendors
GO
CREATE PROC activateVendors 
@admin_username varchar(20),
@vendor_username varchar(20)
AS
UPDATE Vendor 
SET activated = 1, admin_username=@admin_username 
WHERE Vendor.username=@vendor_username
-------------------------------------------------------------------------------------------------------------------------------
--b) Invite delivery persons to the system
GO
CREATE PROC inviteDeliveryPerson --askkk
@delivery_username varchar(20),
@delivery_email varchar(50)
AS
INSERT INTO Users (username,email)VALUES (@delivery_username,@delivery_email)
INSERT INTO Delivery_personel(username,is_activated) VALUES(@delivery_username,0)
-------------------------------------------------------------------------------------------------------------------------------
--c) Review all the orders made through the website
GO
CREATE PROC reviewOrders
AS
SELECT *
FROM Orders
-------------------------------------------------------------------------------------------------------------------------------
--d) Update the order status to “in process”
GO
CREATE proc updateOrderStatusInProcess
@order_no int
AS
UPDATE Orders
SET order_status = 'IN PROCESS'
WHERE order_no=@order_no
----------------------------------------------------------------------------------------------------------------------------------------
--e) Add new delivery type on the system, specifying its time duration, and fees
GO
create proc addDelivery
@delivery_type varchar(20),
@time_duration int,
@fees decimal(5,3),
@admin_username varchar(20)
AS
insert into Delivery(type,time_duration,fees,username)
values(@delivery_type,@time_duration,@fees,@admin_username)
--------------------------------------------------------------------------------------------------------------------------------------
--f) Assign orders to deliver personnel
GO
create proc assignOrdertoDelivery
@delivery_username varchar(20),
@order_no int,
@admin_username varchar(20)
AS
insert into Admin_Delivery_Order(delivery_username, order_no, admin_username)
values(@delivery_username,@order_no,@admin_username)
-----------------------------------------------------------------------------------------------------------------------------------------
--g) Add a new Today’s Deals on products and update the product’s ﬁnal price accordingly
GO
CREATE PROC createTodaysDeal
@deal_amount INT,
@admin_username VARCHAR(20),
@expiry_date DATETIME
AS
INSERT INTO Todays_Deals(deal_amount,expiry_date,admin_username)
VALUES (@deal_amount,@expiry_date,@admin_username)

GO
CREATE PROC checkTodaysDealOnProduct
@serial_no INT,
@activeDeal BIT OUTPUT
AS
IF (EXISTS (SELECT * FROM Todays_Deals_Product WHERE @serial_no=serial_no))
BEGIN
SET @activeDeal=1
END
ELSE
BEGIN
SET @activeDeal=0
END

GO
CREATE PROC removeExpiredDeal
@deal_id INT
AS
UPDATE Product
SET final_price=price
WHERE serial_no IN (SELECT t1.serial_no
					FROM Todays_Deals_Product t1,Todays_Deals t2
					WHERE t1.deal_id=t2.deal_id AND t1.deal_id=@deal_id)

DELETE FROM Todays_Deals WHERE @deal_id=deal_id AND CURRENT_TIMESTAMP > expiry_date

GO
CREATE PROC addTodaysDealOnProduct
@deal_id INT,
@serial_no INT
AS
--Removing expired deals 
EXEC removeExpiredDeal @deal_id
--Check if the product has an active deal or not
DECLARE @activeDeal BIT
EXEC checkTOdaysDealOnProduct @serial_no , @activeDeal OUTPUT
--add the deal to the product od it doesn't have an active deal
IF(@activeDeal=0)
BEGIN
INSERT INTO Todays_Deals_Product VALUES (@deal_id,@serial_no)
DECLARE @discount_amount DECIMAL(10,2)
SELECT @discount_amount =deal_amount
FROM Todays_Deals
WHERE @deal_id=deal_id
UPDATE Product
SET final_price =price-@discount_amount
WHERE serial_no=@serial_no
DECLARE @final DECIMAL (10,2)
SELECT @final=final_price
FROM Product
WHERE serial_no=@serial_no

IF(@final<0)
BEGIN
UPDATE Product
SET final_price =0
WHERE serial_no=@serial_no
END
END
----------------------------------------------------------------------------------------------------------------------------------
-- Create Gift Cards
GO
-- it Create Gift Cards 
CREATE PROC createGiftCard
@code VARCHAR(10),
@expiry_date DATETIME,
@amount INT ,
@admin_username VARCHAR(20)
AS
INSERT INTO Giftcard(code,expiry_date,amount,username)
VALUES(@code,@expiry_date,@amount,@admin_username)
--------------------------------------------------------------------------------------------------------------------------------------
--i) Give Gift Cards to special customers
GO

CREATE PROC removeExpiredGiftCard
@code VARCHAR(10)
AS
DECLARE @points INT
SELECT @points=amount
FROM Giftcard
WHERE code=@code

UPDATE Customer
SET points=points-@points
WHERE username IN ( SELECT g1.customer_name
                    FROM Admin_Customer_Giftcard g1,Giftcard g2
					WHERE g2.expiry_date<CURRENT_TIMESTAMP AND g1.code=g2.code)
DELETE FROM  Giftcard WHERE @code = code AND CURRENT_TIMESTAMP > expiry_date

GO

CREATE PROC checkGiftCardOnCustomer
@code VARCHAR(10),
@activeGiftCard BIT OUTPUT
AS 
--checking if the gift card exists or not
IF (EXISTS (SELECT * FROM Admin_Customer_Giftcard WHERE @code=code))
BEGIN
SET @activeGiftCard =1
END
ELSE
BEGIN
SET @activeGiftCard =0
END

GO
CREATE PROC giveGiftCardtoCustomer
@code varchar(10),
@customer_name VARCHAR(20),
@admin_username VARCHAR(20)

AS
EXEC removeExpiredGiftCard @code
IF(NOT EXISTS (SELECT * FROM Admin_Customer_Giftcard WHERE customer_name=@customer_name))
BEGIN
INSERT INTO  Admin_Customer_Giftcard (code,customer_name,admin_username)
VALUES (@code,@customer_name,@admin_username)

DECLARE @points INT
SELECT @points=amount
FROM Giftcard
WHERE @code=code

UPDATE Customer
SET points = points + @points
WHERE username=@customer_name
END
--------------------------------------------------------------------------------------------------------------------------
--As a delivery personnel I should be able to
--a) Accept the admin invitation to the system
GO
create proc  acceptAdminInvitation
@delivery_username varchar(20)
AS
update Delivery_personel
set is_activated = 1
where username = @delivery_username
--------------------------------------------------------------------------------------------------------------------------------
--b) Add additional credentials to the system other than the username (password.. etc.) 
GO
create proc deliveryPersonUpdateInfo
@username varchar(20),
@first_name varchar(20),
@last_name varchar(20),
@password varchar(20),
@email varchar(50)
AS
IF @first_name IS NOT NULL
BEGIN
update Users
set  first_name = @first_name 
where username = @username
END
IF @last_name IS NOT NULL
BEGIN
update Users
set  last_name=@last_name 
where username = @username
END
IF @password IS NOT NULL
BEGIN
update Users
set  password=@password 
where username = @username
END
IF @email IS NOT NULL
BEGIN
update Users
set  email=@email
where username = @username
END
-----------------------------------------------------------------------------------------------------------------------------------
--c) View all the orders I am assigned to
GO
CREATE proc viewmyorders
@deliveryperson varchar(20)
AS
select o.*
from Orders o inner join Admin_Delivery_Order a ON a.order_no=o.order_no
WHERE a.delivery_username=@deliveryperson
--------------------------------------------------------------------------------------------------------------------------------------
--d) Specify a delivery window for each customer order
GO
CREATE proc specifyDeliveryWindow
@delivery_username varchar(20),
@order_no int,
@delivery_window varchar(50)
AS
update Admin_Delivery_Order
set delivery_window = @delivery_window
WHERE delivery_username = @delivery_username AND order_no = @order_no
--------------------------------------------------------------------------------------------------------------------------------------
--e) Update the status of an order when it’s out for delivery
GO
create proc updateOrderStatusOutforDelivery
@order_no int
AS
update Orders
set order_status = 'Out for delivery'
where order_no = @order_no
------------------------------------------------------------------------------------------------------------------------------------
--f) Update the status of an order when it gets delivered
GO
create proc  updateOrderStatusDelivered
@order_no int
AS
update Orders
set order_status = 'Delivered'
where order_no = @order_no
