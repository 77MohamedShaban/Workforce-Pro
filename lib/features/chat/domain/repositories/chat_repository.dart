import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatMessageEntity>> getMessagesStream(String currentUserId, String peerUserId);
  Future<void> sendMessage(ChatMessageEntity message);
}
