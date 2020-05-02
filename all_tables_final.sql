CREATE TABLE Users
(
username VARCHAR(20) ,
password VARCHAR(20) ,
first_name VARCHAR(20),
last_name VARCHAR(20),
email VARCHAR(50)NOT NULL UNIQUE,
CONSTRAINT pr_users
PRIMARY KEY (username)
);

CREATE TABLE User_mobile_numbers
(
mobile_number VARCHAR(20) UNIQUE,
username VARCHAR(20) ,
CONSTRAINT pr_mobile_numbers
PRIMARY KEY (mobile_number,username),
CONSTRAINT fr_username_mobiles
FOREIGN KEY (username) REFERENCES Users ON DELETE CASCADE ON UPDATE CASCADE 
);

CREATE TABLE User_Adresses
(
address VARCHAR(100),
username VARCHAR(20),
CONSTRAINT pr_addresses
PRIMARY KEY (address,username),
CONSTRAINT fr_username_adresses
FOREIGN KEY(username) REFERENCES Users ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE Customer
(
username VARCHAR(20)NOT NULL,
points INT DEFAULT 0,
CONSTRAINT pr_customer
PRIMARY KEY(username),
CONSTRAINT fr_username_customer
FOREIGN KEY(username) REFERENCES Users ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Admins
(
username VARCHAR(20),
CONSTRAINT pr_admin
PRIMARY KEY(username),
CONSTRAINT fr_username_admins
FOREIGN KEY (username) REFERENCES Users ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE Vendor
(
username VARCHAR(20),
activated BIT DEFAULT  0,
company_name VARCHAR(20) NOT NULL,
bank_acc_no VARCHAR(20) NOT NULL UNIQUE,
admin_username VARCHAR(20) ,
CONSTRAINT pr_vendor
PRIMARY KEY (username),
CONSTRAINT fr_username_vendor
FOREIGN KEY (username) REFERENCES Users ON  UPDATE CASCADE ON DELETE CASCADE,
CONSTRAINT fr_admin
FOREIGN KEY (admin_username) REFERENCES Admins ON DELETE NO ACTION  ON UPDATE NO ACTION
);

CREATE TABLE Delivery_personel
(
username VARCHAR(20) NOT NULL,
is_activated BIT DEFAULT 0,
CONSTRAINT pr_delivery_personel
PRIMARY KEY (username),
CONSTRAINT fr_username_delivery
FOREIGN KEY (username) REFERENCES Users  ON UPDATE CASCADE ON DELETE CASCADE
);
CREATE TABLE Delivery(
id INT IDENTITY (1,1),
type VARCHAR(20) ,
time_duration INT  ,
fees DECIMAL(5,3)  ,
username VARCHAR(20) ,
CONSTRAINT pr_delivery_type
PRIMARY KEY (id),
CONSTRAINT fr_usrAdmin
FOREIGN KEY (username) REFERENCES Admins ON DELETE NO ACTION ON UPDATE NO ACTION 
);

CREATE TABLE Credit_Card (
number varchar(20),
expiry_date DATE NOT NULL,
cvv_code varchar(4) NOT NULL,
CONSTRAINT pr_cc
PRIMARY KEY(number)
);


CREATE TABLE Orders(
order_no INT IDENTITY(1,1),
order_date datetime ,
total_amount DECIMAL(10,2)  ,
cash_amount DECIMAL(10,2) ,
credit_amount DECIMAL(10,2) ,
payment_type VARCHAR(20) ,
order_status varchar(100) DEFAULT 'NOT PROCESSED' ,
remaining_days INT ,
time_limit INT ,
Gift_Card_code_used VARCHAR(10),
customer_name varchar(20) ,
delivery_id INT ,
creditCard_number varchar(20) ,
CONSTRAINT pr_orders
PRIMARY KEY(order_no),
CONSTRAINT fr_name
FOREIGN KEY(customer_name) REFERENCES Customer ON DELETE NO ACTION ON UPDATE NO ACTION,
CONSTRAINT fr_D_id
FOREIGN KEY(delivery_id) REFERENCES Delivery ON DELETE NO ACTION ON UPDATE NO ACTION,
CONSTRAINT fr_cc_num
FOREIGN KEY(creditCard_number) REFERENCES Credit_Card ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fr_gf_code
FOREIGN KEY(Gift_Card_code_used) REFERENCES GiftCard ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Product(
serial_no INT IDENTITY(1,1),
product_name VARCHAR(20) NOT NULL,
category VARCHAR(20) NOT NULL,
product_description TEXT,
price DECIMAL(10,2) NOT NULL,
final_price DECIMAL(10,2) ,
color VARCHAR(20),
available BIT DEFAULT 1,
rate INT,
vendor_username VARCHAR(20) NOT NULL,
customer_username VARCHAR(20) ,
customer_order_id INT,
CONSTRAINT pr_product
PRIMARY KEY(serial_no),
CONSTRAINT fr_c_usr
FOREIGN KEY(customer_username) REFERENCES Customer ON DELETE NO ACTION ON UPDATE NO ACTION,
CONSTRAINT fr_v_usr
FOREIGN KEY(vendor_username) REFERENCES Vendor ON DELETE NO ACTION ON UPDATE NO ACTION,
CONSTRAINT fr_co_id
FOREIGN KEY(customer_order_id) REFERENCES Orders ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CustomerAddstoCartProduct(
serial_no INT ,
customer_name VARCHAR(20) ,
CONSTRAINT pr_custaddscart
PRIMARY KEY(serial_no,customer_name),
CONSTRAINT fr_serial_no
FOREIGN KEY(serial_no) REFERENCES Orders on delete cascade on update cascade,
CONSTRAINT fr_c_name
FOREIGN KEY(customer_name) REFERENCES Customer ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE Table Todays_Deals
(
  deal_id INT IDENTITY(1,1) ,
  deal_amount INT NOT NULL,
  expiry_date DATETIME NOT NULL,
  admin_username VARCHAR(20),
  CONSTRAINT pr_todays_deal
  PRIMARY KEY(deal_id),
  CONSTRAINT fr_admin_todays_deal
  FOREIGN KEY (admin_username) REFERENCES Admins ON DELETE NO ACTION ON UPDATE NO ACTION  
);
CREATE Table Todays_Deals_Product(
  deal_id INT ,
  serial_no INT ,
  CONSTRAINT pr_todays_deal_prod
  PRIMARY KEY(deal_id,serial_no), 
  CONSTRAINT fr_deal_id
  FOREIGN KEY (deal_id) REFERENCES Todays_Deals ON DELETE  CASCADE ON UPDATE CASCADE ,
  CONSTRAINT fr_seriall_deal
  FOREIGN KEY (serial_no) REFERENCES Product ON DELETE CASCADE ON UPDATE CASCADE
);
  CREATE Table offer
    (
      offer_id INT IDENTITY(1,1) ,
      offer_amount DECIMAL(10,2) NOT NULL ,
      expiry_date DATETIME NOT NULL ,
      CONSTRAINT pr_offer_id
      PRIMARY KEY (offer_id)
  );
 
CREATE TABLE offersOnProduct(
   offer_id INT ,
   serial_no INT ,
  CONSTRAINT pr_offersprod
  PRIMARY KEY (offer_id,serial_no),
  CONSTRAINT fr_offer_id
  FOREIGN KEY (offer_id) REFERENCES offer ON DELETE CASCADE ON UPDATE CASCADE, 
  CONSTRAINT fr_serial_prod
  FOREIGN KEY (serial_no) REFERENCES Product ON DELETE CASCADE ON UPDATE CASCADE
);

 CREATE TABLE Customer_Question_Product
(
   serial_no INT,
   customer_name  VARCHAR(20) NOT NULL ,
   question VARCHAR(50) NOT NULL,
   answer VARCHAR(200) ,
  CONSTRAINT pr_custquesprod
  PRIMARY KEY (serial_no, customer_name),
  CONSTRAINT fr_serial_no_cart
  FOREIGN KEY (serial_no) REFERENCES Product ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fr_customer_name
  FOREIGN KEY(customer_name) REFERENCES Customer ON DELETE NO ACTION ON UPDATE NO ACTION  
);
 CREATE TABLE Wishlist(
  username VARCHAR(20) NOT NULL,
  name VARCHAR(20) NOT NULL,
  CONSTRAINT pr_wishlist
  PRIMARY KEY(username,name),
  CONSTRAINT fr_user_name
  FOREIGN KEY (username) REFERENCES Customer ON DELETE NO ACTION ON UPDATE NO ACTION  
);
 CREATE TABLE Giftcard(
   code VARCHAR(10),
   expiry_date DATETIME NOT NULL ,
   amount INT NOT NULL,
   username VARCHAR(20) NOT NULL,
   CONSTRAINT pr_Giftcard
   PRIMARY KEY (code),
   CONSTRAINT fr_username_wishlist_customer 
   FOREIGN KEY (username) REFERENCES Admins ON DELETE NO ACTION ON UPDATE NO ACTION  
);

CREATE Table Wishlist_Product(
username VARCHAR(20) NOT NULL,
wish_name VARCHAR(20) NOT NULL,
serial_no INT NOT NULL,
CONSTRAINT pr_wishlist_prod
PRIMARY KEY(username,wish_name,serial_no),
CONSTRAINT fr_username_wishlist
FOREIGN KEY(username,wish_name) REFERENCES Wishlist ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fr_serial_no_product_wishlist
FOREIGN KEY(serial_no) REFERENCES Product ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE Table Admin_Customer_Giftcard(
code VARCHAR(10) ,
customer_name VARCHAR(20) NOT NULL,
admin_username VARCHAR(20) NOT NULL,
remaining_points INT,
CONSTRAINT pr_admin_customer_giftcard
PRIMARY KEY (code,customer_name,admin_username),
CONSTRAINT fr_code_giftcard
FOREIGN KEY (code) REFERENCES Giftcard ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fr_customer_name_giftcard
FOREIGN KEY (customer_name) REFERENCES Customer ON DELETE NO ACTION ON UPDATE NO ACTION,
CONSTRAINT fl_admin_username_giftcard
FOREIGN KEY (admin_username) REFERENCES Admins ON DELETE NO  ACTION ON UPDATE NO ACTION
);

CREATE Table Admin_Delivery_Order(
delivery_username VARCHAR(20) ,
order_no INT ,
admin_username VARCHAR(20) NOT NULL,
delivery_window VARCHAR(50),
CONSTRAINT pr_admin_delivery_order
PRIMARY KEY (delivery_username,order_no),
CONSTRAINT fr_delivery_username_order
FOREIGN KEY(delivery_username) REFERENCES Delivery_personel ON DELETE NO ACTION ON UPDATE NO ACTION,
CONSTRAINT fr_order_no_delivery
FOREIGN KEY(order_no) REFERENCES Orders ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT fr_admin_username_delivery
FOREIGN KEY(admin_username) REFERENCES Admins ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE Table Customer_CreditCard(
customer_name VARCHAR(20) NOT NULL,
cc_number VARCHAR(20) NOT NULL,
CONSTRAINT pr_customer_creditcard
PRIMARY KEY(customer_name,cc_number),
CONSTRAINT fr_customer_name_cc
FOREIGN KEY(customer_name) REFERENCES Customer ON DELETE NO ACTION ON UPDATE NO ACTION,
CONSTRAINT fr_cc_number
FOREIGN KEY(cc_number) REFERENCES Credit_Card ON DELETE CASCADE ON UPDATE CASCADE
);












