const mongoose = require('mongoose');

const chatMessageSchema = new mongoose.Schema({
    senderId: {
        type: String,
        required: true
    },
    receiverId: {
        type: String,
        required: true
    },
    senderRole: {
        type: String,
        enum: ['student', 'store', 'admin'], 
        required: true
    },
    message: {
        type: String,
        required: true
    },
    // 儲存時間戳，排序聊天紀錄
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('ChatMessage', chatMessageSchema);