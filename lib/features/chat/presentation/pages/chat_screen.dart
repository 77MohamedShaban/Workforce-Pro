import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/cach/shared_prefs.dart';
import '../../../../core/di/di.dart';
import '../../../../core/reusable_component/error_state_widget.dart';
import '../../../../core/reusable_component/loading_indicator.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_text_styles.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final UserEntity peerUser;

  const ChatScreen({super.key, required this.peerUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatCubit _chatCubit;
  late UserEntity _currentUser;

  @override
  void initState() {
    super.initState();
    _initUserAndChat();
  }

  void _initUserAndChat() {
    final fbUser = fb.FirebaseAuth.instance.currentUser;
    final cachedId = SharedPrefs.getData(key: 'user_id') as String?;
    final authUser = context.read<AuthCubit>().currentUser;

    final currentId = authUser?.id ?? fbUser?.uid ?? cachedId ?? 'user_001';
    final currentName = authUser?.fullName ?? fbUser?.displayName ?? (fbUser?.email?.split('@').first ?? 'Manager');

    _currentUser = UserEntity(
      id: currentId,
      email: authUser?.email ?? fbUser?.email ?? 'user@workforce.com',
      fullName: currentName,
      role: authUser?.role ?? 'manager',
    );

    _chatCubit = getIt<ChatCubit>();
    _chatCubit.initChatStream(_currentUser.id, widget.peerUser.id);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatCubit.close();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessageEntity(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: _currentUser.id,
      senderName: _currentUser.fullName,
      receiverId: widget.peerUser.id,
      receiverName: widget.peerUser.fullName,
      message: text,
      timestamp: DateTime.now(),
    );

    _chatCubit.sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _chatCubit,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppColors.navy,
                child: Text(
                  widget.peerUser.fullName.isNotEmpty ? widget.peerUser.fullName[0].toUpperCase() : 'U',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.peerUser.fullName,
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.peerUser.departmentName ?? 'Department'} • Online',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.success, fontSize: 11.sp),
                  ),
                ],
              )
            ],
          ),
        ),
        body: Column(
          children: [
            // Messages Stream List
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) {
                    _scrollToBottom();
                  } else if (state is ChatError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const LoadingIndicator();
                  }

                  if (state is ChatError) {
                    return ErrorStateWidget(
                      errorMessage: state.message,
                      onRetry: () {
                        _chatCubit.initChatStream(_currentUser.id, widget.peerUser.id);
                      },
                    );
                  }

                  if (state is ChatLoaded) {
                    if (state.messages.isEmpty) {
                      return Center(
                        child: Text(
                          'No messages yet. Say hello to ${widget.peerUser.fullName}!',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.all(16.w),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[index];
                        final isMe = msg.senderId == _currentUser.id;
                        return _buildMessageBubble(msg, isMe);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

            // Message Input Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  )
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        onTapUpOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r),
                            borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Material(
                      color: AppColors.blue,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _sendMessage,
                        child: Padding(
                          padding: EdgeInsets.all(12.w),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageEntity msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h, left: isMe ? 48.w : 0, right: isMe ? 0 : 48.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe ? AppColors.blue : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 2.r),
            bottomRight: Radius.circular(isMe ? 2.r : 16.r),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              DateFormat('hh:mm a').format(msg.timestamp),
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10.sp,
                color: isMe ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
