/* MongoDB Schema */

// ==================== 查找特定用戶的所有消息 ====================
db.messages.find({
  targetRole: "student"
}).sort({ createdAt: -1 });

// ==================== 查找特定時間範圍的消息 ====================
db.messages.find({
  createdAt: {
    $gte: ISODate("2025-12-01T00:00:00Z"),
    $lt: ISODate("2025-12-07T00:00:00Z")
  }
}).sort({ createdAt: -1 });

// ==================== 查找特定時間範圍的公告 ====================
db.publicnotices.find({
  createdAt: {
    $gte: ISODate("2025-12-06T00:00:00.000Z"), 
    $lt: ISODate("2025-12-07T00:00:00.000Z")
  }
});


// ==================== 查找特定店鋪的公告 ====================
db.publicnotices.find({
  receiverId: "uuid-of-store"
}).sort({ createdAt: -1 });


// ==================== 查找特定店鋪的公告 ====================
db.publicnotices.find({
  receiverId: null,
  senderRole: "admin"
}).sort({ createdAt: -1 });