import 'package:equatable/equatable.dart';

class ChatMessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        receiverId,
        receiverName,
        message,
        timestamp,
        isRead,
      ];
}
