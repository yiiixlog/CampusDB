校園餐飲點餐系統 - 資料庫設計
本專案示範如何同時使用 SQL（關聯式資料庫） 與 NoSQL（文件資料庫） 來實作一個校園餐飲點餐系統，並比較兩者在設計與使用上的差異與取捨。

專案簡介
這是一個校園餐飲管理的全端應用程式，包含學生點餐、店家管理、訂單追蹤、訊息與公告等功能。此版本特別著重在資料庫設計：同時提供傳統 SQL 與 MongoDB NoSQL 的實作，方便學習與比較。

📁 專案結構
bash
├── backend/        # Node.js + Express 後端 API（主要連接 SQL）
├── frontend/       # 前端網頁介面（學生 / 店家）
└── Nosql/          # MongoDB NoSQL 設計與範例（Message / PublicNotice）
🗄️ SQL 資料庫（CAMPUS.sql）
Schema 概觀
所有關聯式表格與欄位定義集中在 CAMPUS.sql

主要涵蓋以下實體（實際欄位以 SQL 檔為準）：

使用者（學生 / 店家 / 管理員）

店家／餐廳

菜單與品項

訂單與訂單明細

付款與交易紀錄

評價／評論

訊息（Message）

公告（PublicNotice）

這些表之間透過 主鍵 / 外鍵 建立關聯，確保：

訂單一定連到有效的使用者與店家

付款一定對應到既有訂單

訊息與公告可以追溯發送者與接收者

SQL 設計特性
✅ ACID 交易：適合處理訂單、付款等需要強一致性的操作

✅ 結構清楚：固定欄位與關聯，方便做複雜報表與統計

✅ 參照完整性：外鍵避免孤兒資料（例如沒有使用者的訂單）

⚠️ Schema 變動成本較高：新增欄位、調整關聯需做遷移

⚠️ 水平擴充較不直覺：多機分散需要額外設計

📦 NoSQL 資料庫（MongoDB）
在本專案中，MongoDB 主要用來處理訊息與公告類資料，這類資料寫入頻繁、格式相對簡單，且未來欄位可能會調整或擴充，因此使用文件型結構較有彈性。

Message 集合（mongoDB-Message）
用來存放即時訊息或互動紀錄，例如系統訊息、訂單相關通知、聊天紀錄等。

javascript
// mongoDB-Message
{
  id: ObjectId,        // MongoDB 內部主鍵
  senderId: String,    // 發送者 ID，對應 SQL 中的使用者 / 店家主鍵
  type: String,        // 訊息類型（例如：system / order / chat）
  targetRole: String,  // 接收方角色（student / store / admin）
  message: String,     // 訊息內容文字
  createdAt: Date      // 建立時間
}
設計重點：

查詢常見條件為 senderId、type、createdAt，適合建立索引

訊息多、變動快，存在 MongoDB 可減輕 SQL 壓力

結構簡單、欄位未來要新增（例如已讀狀態、附件連結）也很方便

PublicNotice 集合（mongoDB-Publicnotice）
用來存放系統公告、店家公告等，可針對某些角色或特定使用者推送。

javascript
// mongoDB-Publicnotice
{
  id: ObjectId,        // MongoDB 內部主鍵
  senderId: String,    // 發送者 ID（例如管理員 / 店家）
  receiverId: String,  // 接收者 ID（單一使用者、店家或群組 ID）
  senderRole: String,  // 發送者角色（admin / store / system）
  message: String,     // 公告內容
  createdAt: Date      // 建立時間
}
設計重點：

將 senderRole、receiverId 與內容放在同一文件

可依 receiverId 或 senderRole 快速撈出對應公告

未來若要支援多接收者、群組、標籤等，也可透過新增欄位完成

💡 SQL 與 NoSQL 的使用場景對比
需求 / 場景	SQL（CAMPUS.sql）較適合	NoSQL（MongoDB）較適合
訂單、付款、店家、菜單等核心業務資料	✅ 強一致性、交易安全、關聯清楚	⚠️ 也可，但維護複雜關聯會變麻煩
定期報表、營收統計、排行查詢	✅ JOIN + Aggregation 很好用	⚠️ 需要額外 Aggregation Pipeline 設計
高頻率訊息、公告、通知	⚠️ 表結構固定、寫入頻繁會壓力較大	✅ 文件簡單、寫入快、易於水平擴充
結構常變動的資料（例如訊息附加欄位）	⚠️ 每次都要改 Schema、Migration	✅ 直接新增欄位即可
要強制保證 FK 關聯的資料	✅ 外鍵與約束直接支援	⚠️ 需在應用程式層自己控管
🏗️ 系統分層概念
後端 API（backend/）
後端以 Express 提供 REST API，底層同時對接：

SQL（CAMPUS.sql）：處理使用者、店家、訂單、付款等核心業務

MongoDB（Message / PublicNotice）：處理訊息與公告

大致結構可以想像成：

text
Express Server
    ↓
├── SQL 模組（MySQL / 其他 RDB）
│   ├── 使用者 / 店家 / 訂單 / 付款
│   └── 報表與查詢
│
└── NoSQL 模組（MongoDB）
    ├── Message（訊息）
    └── PublicNotice（公告）
前端（frontend/）
主要支援以下操作（依實作調整）：

學生登入、瀏覽店家與菜單、建立／查詢訂單

店家管理菜單、查看訂單狀態

檢視公告、接收系統或店家訊息

🛠️ 使用技術
後端：Node.js、Express.js

SQL 資料庫：MySQL（Schema 於 CAMPUS.sql）

NoSQL 資料庫：MongoDB（Message、PublicNotice 集合）

前端：HTML / CSS / JavaScript（或實際使用之框架）

套件管理：npm / pnpm

🚀 學習重點整理
從 SQL（CAMPUS.sql）學到的重點
如何用多張表（Users、Orders、Stores、Payments…）設計完整關聯

如何透過主鍵／外鍵維持資料一致性

如何利用 JOIN 與聚合做出營收、訂單量等報表

從 NoSQL（MongoDB）學到的重點
如何為「訊息、公告」這種高頻、結構彈性的資料設計文件 Schema

如何在不破壞現有資料的前提下，平滑新增欄位（例如讀取狀態、標籤）

如何運用索引與查詢條件，快速查詢某個使用者／角色相關訊息與公告

📝 開發建議
SQL 端（CAMPUS.sql）
避免在高頻寫入場景（例如聊天訊息）過度依賴 SQL，將壓力交給 MongoDB

堅持使用 Prepared Statement，避免 SQL Injection

對常用查詢欄位（如 user_id、store_id、order_time）建立索引

NoSQL 端（MongoDB）
對 senderId、receiverId、createdAt 建立索引，優化查詢效能

未來如果需要支援多接收者，可以把 receiverId 改成陣列 receiverIds

透過應用程式層（而不是 DB 約束）來保證 senderId / receiverId 存在於 SQL 中

👥 團隊說明
本專案為課程專題／學習型專案，目標是讓組員實際體驗：

同一個業務需求，在 SQL 與 NoSQL 上要怎麼設計與取捨

何時該把資料放在關聯式資料庫，何時適合放在文件資料庫

如何在後端同時對接兩種資料庫，並讓前端透過統一 API 使用

