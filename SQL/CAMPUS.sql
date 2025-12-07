-- 雲訂餐系統資料庫初始化腳本
-- 創建資料庫
CREATE DATABASE IF NOT EXISTS CampusFoodDB
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE CampusFoodDB;

-- 1. 用戶表
CREATE TABLE User (
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Phone VARCHAR(20),
    SSOID VARCHAR(50) UNIQUE,
    PasswordHash VARCHAR(255),
    Role ENUM('Admin', 'Store', 'EndUser', 'SystemAdmin', 'ServiceProvider') DEFAULT 'EndUser',
    IsActive BOOLEAN DEFAULT 1,
    LastLogin DATETIME,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. 商店表
CREATE TABLE Store (
    StoreID INT AUTO_INCREMENT PRIMARY KEY,
    StoreName VARCHAR(100) NOT NULL,
    Description TEXT,
    PhoneNumber VARCHAR(20),
    Address VARCHAR(255),
    ManagerID INT,
    IsOpen BOOLEAN DEFAULT 1,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ManagerID) REFERENCES User(UserID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. 菜單項目表
CREATE TABLE MenuItem (
    MenuItemID INT AUTO_INCREMENT PRIMARY KEY,
    StoreID INT NOT NULL,
    ItemName VARCHAR(100) NOT NULL,
    Description TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    Category VARCHAR(50),
    IsAvailable BOOLEAN DEFAULT 1,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. 訂單表
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    StoreID INT NOT NULL,
    OrderStatus ENUM('Pending', 'Confirmed', 'Preparing', 'Ready', 'Delivered', 'Cancelled') DEFAULT 'Pending',
    TotalAmount DECIMAL(10, 2) NOT NULL,
    DeliveryAddress VARCHAR(255),
    DeliveryTime DATETIME,
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID),
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. 訂單項目表
CREATE TABLE OrderItem (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    MenuItemID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    Price DECIMAL(10, 2) NOT NULL,
    Notes TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItem(MenuItemID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. 支付記錄表
CREATE TABLE Payment (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentMethod ENUM('Cash', 'Card', 'Mobile') DEFAULT 'Cash',
    PaymentStatus ENUM('Pending', 'Completed', 'Failed', 'Refunded') DEFAULT 'Pending',
    TransactionID VARCHAR(100),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. 評論表
CREATE TABLE Review (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT,
    OrderID INT NOT NULL,
    Rating INT CHECK (Rating >= 1 AND Rating <= 5),
    Comment TEXT,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (UserID) REFERENCES User(UserID) ON DELETE SET NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 建立索引
CREATE INDEX idx_user_email ON User(Email);
CREATE INDEX idx_user_ssoid ON User(SSOID);
CREATE INDEX idx_store_isopen ON Store(IsOpen);
CREATE INDEX idx_menuitem_store ON MenuItem(StoreID);
CREATE INDEX idx_menuitem_available ON MenuItem(IsAvailable);
CREATE INDEX idx_orders_user ON Orders(UserID);
CREATE INDEX idx_orders_store ON Orders(StoreID);
CREATE INDEX idx_orders_status ON Orders(OrderStatus);
CREATE INDEX idx_orderitem_order ON OrderItem(OrderID);
CREATE INDEX idx_review_order ON Review(OrderID);
CREATE INDEX idx_review_user ON Review(UserID);

-- ==================== 示例資料 ====================

INSERT INTO User (Name, Email, Phone, SSOID, PasswordHash, Role, IsActive) VALUES 
('管理員', 'admin@yuntech.edu.tw', '0912345678', 'admin001', 'admin123', 'SystemAdmin', 1),
('超級香自助餐', 'store1@gmail.com', '0912345679', 'store001', 'store123', 'ServiceProvider', 1),
('二蘭拉麵', 'store2@gmail.com', '0912345680', 'store002', 'store123', 'ServiceProvider', 1),
('秦楷翔', 'A11423007@yuntech.edu.tw', '0912345678', 'A11423007', '123456', 'EndUser', 1),
('蘇怡甄', 'A11423011@yuntech.edu.tw', '0912345679', 'A11423011', '123456', 'EndUser', 1),
('林思妤', 'A11423017@yuntech.edu.tw', '0912345680', 'A11423017', '123456', 'EndUser', 1),
('潘妍華', 'A11423020@yuntech.edu.tw', '0912345681', 'A11423020', '123456', 'EndUser', 1);


-- 插入商店
INSERT INTO Store (StoreName, Description, PhoneNumber, Address, ManagerID, IsOpen) VALUES 
('雲林食堂', '提供新鮮便當和飲品', '05-5342210', '雲林縣斗六市大學路三段 123 號', 5, 1),
('美味小廚', '特色家常菜和湯品', '05-5342211', '雲林縣斗六市大學路三段 123 號', 5, 1),
('快速餐廳', '速凍食品和快餐', '05-5342212', '雲林縣斗六市大學路三段 123 號', 5, 1),
('健康綠食', '素食和健康餐點', '05-5342213', '雲林縣斗六市大學路三段 123 號', 5, 1),
('超級香自助餐', '經典台式自助選菜，價格實惠', '05-5342288', '雲林縣斗六市大學路三段666號', 2, 1),
('二蘭拉麵', '日式拉麵與丼飯專賣，湯頭濃郁', '05-5342277', '雲林縣斗六市大學路三段888號', 3, 1);



-- 插入菜單項目 - 雲林食堂
INSERT INTO MenuItem (StoreID, ItemName, Description, Price, Category, IsAvailable) VALUES
(1, '古早味滷肉飯', '傳統滷肉搭配香米飯', 45.00, '主食', 1),
(1, '招牌排骨飯', '酥脆排骨配豐富配菜', 55.00, '主食', 1),
(1, '蛋花湯', '清湯蛋花爽口清新', 25.00, '湯品', 1),
(1, '紅茶', '冬瓜紅茶清涼解渴', 35.00, '飲品', 1);

-- 插入菜單項目 - 美味小廚
INSERT INTO MenuItem (StoreID, ItemName, Description, Price, Category, IsAvailable) VALUES
(2, '紅燒肉飯', '肥瘦適中軟嫩入味', 50.00, '主食', 1),
(2, '清蒸魚飯', '鮮美清蒸魚肉健康', 60.00, '主食', 1),
(2, '蕃茄雞湯', '濃郁蕃茄雞湯暖胃', 30.00, '湯品', 1),
(2, '青茶', '清爽青茶解膩', 30.00, '飲品', 1);

-- 插入菜單項目 - 快速餐廳
INSERT INTO MenuItem (StoreID, ItemName, Description, Price, Category, IsAvailable) VALUES
(3, '炸雞腿便當', '金黃香脆炸雞腿', 50.00, '主食', 1),
(3, '起司漢堡', '起司多汁漢堡', 55.00, '主食', 1),
(3, '薯條', '現炸脆薯條', 20.00, '小食', 1),
(3, '可樂', '冰涼可樂', 25.00, '飲品', 1);

-- 插入菜單項目 - 健康綠食
INSERT INTO MenuItem (StoreID, ItemName, Description, Price, Category, IsAvailable) VALUES
(4, '豆腐便當', '健康豆腐搭配青菜', 40.00, '主食', 1),
(4, '蕎麥麵', '營養蕎麥麵低卡', 45.00, '主食', 1),
(4, '綠色蔬菜湯', '新鮮蔬菜清湯', 28.00, '湯品', 1),
(4, '蔬果果汁', '新鮮蔬果果汁', 40.00, '飲品', 1);

-- 插入菜單項目 - 超級香自助餐
INSERT INTO MenuItem (StoreID, ItemName, Description, Price, Category, IsAvailable) VALUES
(5, '控肉飯', '厚切控肉配滷蛋與高麗菜', 50.00, '主食', 1),
(5, '麻婆豆腐', '自家製辣味麻婆豆腐', 40.00, '主食', 1),
(5, '酸辣湯', '料多實在酸辣湯', 25.00, '湯品', 1),
(5, '豆漿', '新鮮現磨豆漿', 15.00, '飲品', 1);

-- 插入菜單項目 - 二蘭拉麵
INSERT INTO MenuItem (StoreID, ItemName, Description, Price, Category, IsAvailable) VALUES
(6, '豚骨拉麵', '濃郁日式豚骨湯頭+叉燒', 85.00, '主食', 1),
(6, '味噌拉麵', '經典味噌風味拉麵', 80.00, '主食', 1),
(6, '親子丼', '雞肉與蛋丼飯', 70.00, '主食', 1),
(6, '日式煎餃', '皮薄餡多的煎餃', 40.00, '小食', 1);


-- 插入示例訂單
INSERT INTO Orders (UserID, StoreID, OrderStatus, TotalAmount, DeliveryAddress) VALUES
(1, 1, 'Pending', 240.00, '雲林縣斗六市大學路三段 456 號'),
(2, 2, 'Confirmed', 180.00, '雲林縣斗六市大學路三段 789 號'),
(3, 3, 'Preparing', 150.00, '雲林縣斗六市大學路三段 321 號'),
(4, 4, 'Ready', 165.00, '雲林縣斗六市大學路三段 654 號');

-- 插入示例訂單項目
INSERT INTO OrderItem (OrderID, MenuItemID, Quantity, Price) VALUES
(1, 1, 2, 45.00),
(1, 2, 1, 55.00),
(1, 3, 1, 25.00),
(1, 4, 1, 35.00),
(2, 5, 2, 50.00),
(2, 7, 1, 30.00),
(3, 9, 1, 50.00),
(3, 11, 2, 20.00),
(4, 13, 2, 40.00),
(4, 15, 1, 28.00);

-- 插入示例評論
INSERT INTO Review (UserID, OrderID, Rating, Comment) VALUES
(1, 1, 5, '非常好吃，便當盛大又新鮮，推薦！'),
(2, 2, 4, '食物很好吃，配菜也豐富'),
(3, 3, 5, '炸雞很香脆，速度也很快'),
(4, 4, 5, '健康又美味，以後還要點');

-- 提示信息
SELECT '✅ 資料庫初始化完成！' as Status;
SELECT '📋 用戶數量：' as Info, COUNT(*) FROM User;
SELECT '🏪 商店數量：' as Info, COUNT(*) FROM Store;
SELECT '🍽️ 菜單項目：' as Info, COUNT(*) FROM MenuItem;
SELECT '📦 訂單數量：' as Info, COUNT(*) FROM Orders;