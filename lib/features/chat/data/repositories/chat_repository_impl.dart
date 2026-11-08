import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  String _getRoomId(String user1, String user2) {
    final list = [user1, user2]..sort();
    return 'chat_${list[0]}_${list[1]}';
  }

  @override
  Stream<List<ChatMessageEntity>> getMessagesStream(String currentUserId, String peerUserId) {
    final roomId = _getRoomId(currentUserId, peerUserId);
    return _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> sendMessage(ChatMessageEntity message) async {
    final roomId = _getRoomId(message.senderId, message.receiverId);
    final model = ChatMessageModel(
      id: message.id,
      senderId: message.senderId,
      senderName: message.senderName,
      receiverId: message.receiverId,
      receiverName: message.receiverName,
      message: message.message,
      timestamp: message.timestamp,
      isRead: message.isRead,
    );

    // Save message doc in room sub-collection
    await _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .doc(message.id)
        .set(model.toFirestore());

    // Update main room metadata
    await _firestore.collection('chats').doc(roomId).set({
      'lastMessage': message.message,
      'lastTimestamp': Timestamp.fromDate(message.timestamp),
      'user1': message.senderId,
      'user2': message.receiverId,
    }, SetOptions(merge: true));
  }
}
