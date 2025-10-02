-- Step 1: Create a new normalized table to store one product per row
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100)
);

-- Step 2: Insert split products into the new table
-- This example assumes a max of 3 products per order (adjust as necessary)
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT OrderID, CustomerName,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', 1), ',', -1)) AS Product
FROM ProductDetail
UNION ALL
SELECT OrderID, CustomerName,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', 2), ',', -1)) AS Product
FROM ProductDetail
WHERE LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) >= 1
UNION ALL
SELECT OrderID, CustomerName,
       TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', 3), ',', -1)) AS Product
FROM ProductDetail
WHERE LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) >= 2;

-- Now each product will be on a separate row with atomic values.

-- Step 1: Create Orders table to store OrderID and CustomerName
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Insert unique orders
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- Step 2: Create normalized OrderDetails table without CustomerName
CREATE TABLE OrderDetails_2NF (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Insert product details
INSERT INTO OrderDetails_2NF (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;
