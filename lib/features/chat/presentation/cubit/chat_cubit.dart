import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  StreamSubscription<List<ChatMessageEntity>>? _messagesSubscription;

  ChatCubit(this._repository) : super(ChatInitial());

  void initChatStream(String currentUserId, String peerUserId) {
    emit(ChatLoading());
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository
        .getMessagesStream(currentUserId, peerUserId)
        .listen(
      (messages) {
        emit(ChatLoaded(messages));
      },
      onError: (error) {
        emit(ChatError(error.toString()));
      },
    );
  }

  Future<void> sendMessage(ChatMessageEntity message) async {
    try {
      await _repository.sendMessage(message);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
