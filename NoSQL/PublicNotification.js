const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
    // 發送公告的用戶 ID
    sender: {
        type: String,
        required: true,
    },
    message: {
        type: String,
        required: true
    },
    type: {
        type: String,
        required: true,
        enum: ['announcement', 'system'] 
    },
    targetRole: {
        type: String,
        enum: ['student', 'store', 'admin', 'all'], 
        required: true
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Notification', notificationSchema);