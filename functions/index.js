const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


exports.addChatMessage = functions.firestore
  .document('/chats/{chatId}/messages/{messageId}')
  .onCreate(async (snapshot, context) => {
    const chatId = context.params.chatId;
    const messageData = snapshot.data();
    const chatRef = admin
      .firestore()
      .collection('chats')
      .doc(chatId);
    const chatDoc = await chatRef.get();
    const chatData = chatDoc.data();
    if (chatDoc.exists) {
      const readStatus = chatData.readStatus;
      for (let userId in readStatus) {
        if (
          readStatus.hasOwnProperty(userId) &&
          userId !== messageData.senderId
        ) {
          readStatus[userId] = false;
        }
      }
      chatRef.update({
        recentMessage: messageData.text,
        recentSender: messageData.senderId,
        recentTimestamp: messageData.timestamp,
        readStatus: readStatus
      });
    }
});
