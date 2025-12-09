-- ============================
-- 第七組 校園雲訂餐系統 SQL 查詢語法
-- 已包含 SELECT、JOIN、WHERE、GROUP BY、ORDER BY、INSERT、UPDATE、DELETE
-- ============================

-- ==================== 第 1 部分：基礎查詢 (SELECT) ====================
USE CampusFoodDB;
-- 1.1 查詢所有活躍用戶
SELECT 
    UserID,
    Name,
    Email,
    Role,
    IsActive,
    CreatedAt
FROM User
WHERE IsActive = 1
ORDER BY CreatedAt DESC;

-- 1.2 查詢所有開放的商店
SELECT 
    StoreID,
    StoreName,
    Description,
    PhoneNumber,
    Address,
    IsOpen,
    CreatedAt
FROM Store
WHERE IsOpen = 1
ORDER BY CreatedAt DESC;

-- 1.3 查詢特定商店的所有菜單項目
SELECT 
    MenuItemID,
    ItemName,
    Description,
    Price,
    IsAvailable
FROM MenuItem
WHERE StoreID = 1 AND IsAvailable = 1
ORDER BY Price DESC;

-- 1.4 查詢按價格排序的菜單
SELECT 
    m.MenuItemID,
    m.ItemName,
    s.StoreName,
    m.Price
FROM MenuItem m
JOIN Store s ON m.StoreID = s.StoreID
WHERE m.IsAvailable = 1
ORDER BY m.Price DESC
LIMIT 10;


-- ==================== 第 2 部分：WHERE 條件查詢 ====================

-- 2.1 查詢特定用戶的訂單
SELECT 
    OrderID,
    OrderStatus,
    TotalAmount,
    CreatedAt
FROM Orders
WHERE UserID = 12
ORDER BY CreatedAt DESC;

-- 2.2 查詢待確認的訂單
SELECT 
    o.OrderID,
    u.Name,
    s.StoreName,
    o.TotalAmount,
    o.OrderStatus,
    o.CreatedAt
FROM Orders o
JOIN User u ON o.UserID = u.UserID
JOIN Store s ON o.StoreID = s.StoreID
WHERE o.OrderStatus = 'Pending'
ORDER BY o.CreatedAt ASC;

-- 2.3 查詢 50 元以下的菜單
SELECT 
    m.MenuItemID,
    m.ItemName,
    s.StoreName,
    m.Price
FROM MenuItem m
JOIN Store s ON m.StoreID = s.StoreID
WHERE m.Price <= 50 AND m.IsAvailable = 1
ORDER BY m.Price ASC;

-- 2.4 查詢特定日期範圍內的訂單
SELECT 
    OrderID,
    UserID,
    StoreID,
    TotalAmount,
    OrderStatus,
    CreatedAt
FROM Orders
WHERE CreatedAt BETWEEN '2025-11-01' AND '2025-12-30'
ORDER BY CreatedAt DESC;

-- 2.5 查詢特定狀態的訂單
SELECT 
    OrderID,
    UserID,
    TotalAmount,
    OrderStatus,
    CreatedAt
FROM Orders
WHERE OrderStatus IN ('Confirmed', 'Pending')
ORDER BY CreatedAt ASC;


-- ==================== 第 3 部分：JOIN 多表查詢 ====================

-- 3.1 查詢用戶的訂單詳情（單一JOIN）
SELECT 
    o.OrderID,
    u.Name AS UserName,
    s.StoreName,
    o.TotalAmount,
    o.OrderStatus,
    o.CreatedAt
FROM Orders o
INNER JOIN User u ON o.UserID = u.UserID
INNER JOIN Store s ON o.StoreID = s.StoreID
ORDER BY o.CreatedAt DESC;

-- 3.2 查詢訂單及其項目（多JOIN）
SELECT 
    o.OrderID,
    u.Name AS UserName,
    s.StoreName,
    m.ItemName,
    oi.Quantity,
    oi.Price,
    (oi.Quantity * oi.Price) AS ItemTotal
FROM Orders o
INNER JOIN User u ON o.UserID = u.UserID
INNER JOIN Store s ON o.StoreID = s.StoreID
INNER JOIN OrderItem oi ON o.OrderID = oi.OrderID
INNER JOIN MenuItem m ON oi.MenuItemID = m.MenuItemID
WHERE o.OrderID = 1
ORDER BY oi.OrderItemID;

-- 3.3 查詢訂單、支付和評論
SELECT 
    o.OrderID,
    u.Name,
    s.StoreName,
    o.TotalAmount,
    p.PaymentMethod,
    p.PaymentStatus,
    r.Rating,
    r.Comment,
    r.CreatedAt AS ReviewDate
FROM Orders o
LEFT JOIN User u ON o.UserID = u.UserID
LEFT JOIN Store s ON o.StoreID = s.StoreID
LEFT JOIN Payment p ON o.OrderID = p.OrderID
LEFT JOIN Review r ON o.OrderID = r.OrderID
WHERE o.OrderID = 1;

-- 3.4 LeftJoin：查詢所有用戶及其訂單（包括無訂單用戶）
SELECT 
    u.UserID,
    u.Name,
    u.Email,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalSpent
FROM User u
LEFT JOIN Orders o ON u.UserID = o.UserID
WHERE u.Role = 'EndUser'
GROUP BY u.UserID
ORDER BY TotalSpent DESC;

-- 3.5 RightJoin：查詢所有商店及其訂單
SELECT 
    s.StoreID,
    s.StoreName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalRevenue
FROM Store s
RIGHT JOIN Orders o ON s.StoreID = o.StoreID
GROUP BY s.StoreID
ORDER BY TotalRevenue DESC;


-- ==================== 第 4 部分：GROUP BY 分組聚合 ====================

-- 4.1 統計各商店的訂單數量和總收入
SELECT 
    s.StoreID,
    s.StoreName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalRevenue,
    AVG(o.TotalAmount) AS AvgOrderValue,
    MAX(o.TotalAmount) AS MaxOrder,
    MIN(o.TotalAmount) AS MinOrder
FROM Store s
LEFT JOIN Orders o ON s.StoreID = o.StoreID
GROUP BY s.StoreID
ORDER BY TotalRevenue DESC;

-- 4.2 統計各菜單項目的銷售量
SELECT 
    m.MenuItemID,
    m.ItemName,
    s.StoreName,
    COUNT(oi.OrderItemID) AS TimesSold,
    SUM(oi.Quantity) AS TotalQuantity,
    SUM(oi.Quantity * oi.Price) AS TotalRevenue
FROM MenuItem m
LEFT JOIN OrderItem oi ON m.MenuItemID = oi.MenuItemID
LEFT JOIN Store s ON m.StoreID = s.StoreID
GROUP BY m.MenuItemID
ORDER BY TotalRevenue DESC;

-- 4.3 按用戶統計訂單金額
SELECT 
    u.UserID,
    u.Name,
    COUNT(o.OrderID) AS OrderCount,
    SUM(o.TotalAmount) AS TotalSpent,
    AVG(o.TotalAmount) AS AvgOrderValue,
    MAX(o.CreatedAt) AS LastOrderDate
FROM User u
LEFT JOIN Orders o ON u.UserID = o.UserID
WHERE u.Role = 'EndUser'
GROUP BY u.UserID
ORDER BY TotalSpent DESC;


-- ==================== 第 5 部分：ORDER BY 排序 ====================

-- 5.1 按評分排序的餐廳
SELECT 
    s.StoreID,
    s.StoreName,
    COUNT(r.ReviewID) AS ReviewCount,
    AVG(r.Rating) AS AvgRating
FROM Store s
LEFT JOIN Orders o ON s.StoreID = o.StoreID
LEFT JOIN Review r ON o.OrderID = r.OrderID
GROUP BY s.StoreID
ORDER BY AvgRating DESC, ReviewCount DESC;

-- 5.2 按銷售額排名的菜單（降序）
SELECT 
    m.ItemName,
    s.StoreName,
    SUM(oi.Quantity * oi.Price) AS Sales,
    COUNT(oi.OrderItemID) AS TimesSold
FROM MenuItem m
LEFT JOIN OrderItem oi ON m.MenuItemID = oi.MenuItemID
LEFT JOIN Store s ON m.StoreID = s.StoreID
GROUP BY m.MenuItemID
ORDER BY Sales DESC
LIMIT 10;

-- 5.3 按最近訂單排序
SELECT 
    o.OrderID,
    u.Name,
    s.StoreName,
    o.TotalAmount,
    o.CreatedAt
FROM Orders o
JOIN User u ON o.UserID = u.UserID
JOIN Store s ON o.StoreID = s.StoreID
ORDER BY o.CreatedAt DESC
LIMIT 20 OFFSET 0;  -- 第 1 頁，每頁 20 筆


-- ==================== 第 6 部分：INSERT 插入數據 ====================

-- 6.1 插入新用戶
DELETE FROM User
WHERE Email = 'newuser@yuntech.edu.tw';

INSERT INTO User 
(Name, Email, Phone, PasswordHash, Role, IsActive, CreatedAt, UpdatedAt)
VALUES 
('新用戶名', 'newuser@yuntech.edu.tw', '0987654321', 'hashedPassword123', 'EndUser', 1, NOW(), NOW());


-- ==================== 第 7 部分：UPDATE 更新數據 ====================

-- 7.1 更新訂單狀態
UPDATE Orders 
SET 
    OrderStatus = 'Confirmed',
    UpdatedAt = NOW()
WHERE OrderID = 1;

-- 7.2 更新用戶最後登入時間
UPDATE User 
SET 
    LastLogin = NOW(),
    UpdatedAt = NOW()
WHERE UserID = 5;

-- 7.3 更新菜單項目價格
UPDATE MenuItem 
SET 
    Price = 75.00,
    UpdatedAt = NOW()
WHERE MenuItemID = 10 AND StoreID = 2;

-- 7.4 將所有待支付訂單標記為已確認
UPDATE Orders 
SET 
    OrderStatus = 'Confirmed',
    UpdatedAt = NOW()
WHERE OrderStatus = 'Pending' AND CreatedAt < DATE_SUB(NOW(), INTERVAL 30 MINUTE);

-- 7.5 更新支付狀態
UPDATE Payment 
SET 
    PaymentStatus = 'Completed',
    UpdatedAt = NOW()
WHERE OrderID = 1 AND PaymentStatus = 'Pending';


-- ==================== 第 8 部分：DELETE 刪除數據 ====================

-- 8.1 軟刪除已取消的訂單
-- 先備份資料，改用狀態欄位標記
UPDATE Orders 
SET OrderStatus = 'Cancelled'
WHERE OrderID = 999 AND OrderStatus = 'Pending';

-- 8.2 硬刪除過期的訂單項目
DELETE FROM OrderItem 
WHERE OrderID IN (
    SELECT OrderID FROM Orders 
    WHERE OrderStatus = 'Cancelled' 
    AND CreatedAt < DATE_SUB(NOW(), INTERVAL 90 DAY)
);

-- ==================== 第 9 部分：索引優化 ====================

-- 9.1 檢查現有索引
SHOW INDEX FROM User;
SHOW INDEX FROM Orders;
SHOW INDEX FROM MenuItem;