import 'dart:async';

import 'package:chat_app/data/models/chat_message.dart';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/logic/cubit/chat/chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final String currentUserId;
  bool _isInChatRoom = false;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _onlineStatusSubscription;
  StreamSubscription? _typingSubscription;
  StreamSubscription? _blockStatusSubscription;
  StreamSubscription? _amIBlockedStatusSubscription;

  Timer? typingTimer;

  ChatCubit({
    required ChatRepository chatRepository,
    required this.currentUserId,
  }) : _chatRepository = chatRepository,
       super(const ChatState());
  void enterChat(String receiverId) async {
    _isInChatRoom = true;
    try {
      emit(state.copyWith(status: ChatStatus.loading));
      final chatRoom = await _chatRepository.getorCreateChatRoom(
        currentUserId,
        receiverId,
      );
      if (chatRoom != null) {
        emit(
          state.copyWith(
            status: ChatStatus.loaded,
            chatRoomId: chatRoom.id,
            receiverId: receiverId,
          ),
        );
        subscribeToMessages(chatRoom.id);
        _subscribeToOnlineStatus(receiverId);
        _subscribeToTypingStatus(chatRoom.id);
        _subscribeToBlockStatus(receiverId);

        await _chatRepository.updateOnlineStatus(currentUserId, true);
      } else {
        emit(
          state.copyWith(
            status: ChatStatus.error,
            errorMessage: "Chat room not found",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void startTyping() {
    if (state.chatRoomId == null) return;
    typingTimer?.cancel();
    typingTimer = Timer(Duration(seconds: 2), () {
      _updateTypingStatus(false);
    });
    _updateTypingStatus(true);
  }

  Future<void> _updateTypingStatus(bool isTyping) async {
    try {
      await _chatRepository.updateTypingStatus(
        state.chatRoomId!,
        currentUserId,
        isTyping,
      );
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void sendMessage({
    required String content,
    required String receiverId,
  }) async {
    try {
      if (state.chatRoomId != null) {
        await _chatRepository.sendMessage(
          chatRoomId: state.chatRoomId!,
          content: content,
          senderId: currentUserId,
          receiverId: receiverId,
        );
      } else {
        emit(
          state.copyWith(
            status: ChatStatus.error,
            errorMessage: "Chat room not found",
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  void subscribeToMessages(String chatRoomId) {
    _messageSubscription?.cancel();
    _messageSubscription = _chatRepository
        .getMessages(chatRoomId)
        .listen(
          (messages) async {
            if (_isInChatRoom) {
              await _markMessagesAsRead(chatRoomId);
            }
            emit(state.copyWith(messages: messages, errorMessage: null));
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: ChatStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  void _subscribeToOnlineStatus(String userId) {
    _onlineStatusSubscription?.cancel();
    _onlineStatusSubscription = _chatRepository
        .getUserOnlineStatus(userId)
        .listen(
          (status) {
            final isOnline = status['isOnline'] as bool;
            final lastSeen = status['lastSeen'] as Timestamp?;
            emit(
              state.copyWith(
                isReceiverOnline: isOnline,
                receiverLastSeen: lastSeen,
              ),
            );
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: ChatStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  void _subscribeToTypingStatus(String chatRoomId) {
    _typingSubscription?.cancel();
    _typingSubscription = _chatRepository
        .getTypingStatus(chatRoomId)
        .listen(
          (status) {
            final isTyping = status['isTyping'] as bool;
            final typingUserId = status['typingUserId'] as String?;
            emit(
              state.copyWith(
                isReceiverTyping: isTyping && typingUserId != currentUserId,
              ),
            );
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: ChatStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  Future<void> _markMessagesAsRead(String chatRoomId) async {
    try {
      await _chatRepository.markMessageAsRead(chatRoomId, currentUserId);
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _chatRepository.blockUser(currentUserId, userId);
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _chatRepository.unblockUser(currentUserId, userId);
    } catch (e) {
      emit(
        state.copyWith(status: ChatStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> loadMoreMessages() async {
    if (state.status != ChatStatus.loaded ||
        state.messages!.isEmpty ||
        (state.hashMoreMessages == null) ||
        (state.isLoadingMore ?? false))
      return;
    try {
      emit(state.copyWith(isLoadingMore: true));
      final lastMessage = state.messages?.last;
      final lastDoc =
          await _chatRepository
              .getChatRoomMessages(state.chatRoomId!)
              .doc(lastMessage?.id)
              .get();
      final moreMessaages = await _chatRepository.getMoreMessages(
        state.chatRoomId!,
        lastDocument: lastDoc,
      );
      if(moreMessaages.isEmpty){
        emit(state.copyWith(hashMoreMessages: false , isLoadingMore: false));
        return;
      }
      emit(
        state.copyWith(
          messages: [...?state.messages, ...moreMessaages],
          isLoadingMore: false,
          hashMoreMessages: moreMessaages.length >= 20,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: e.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  void _subscribeToBlockStatus(String otherUserId) {
    _blockStatusSubscription?.cancel();
    _blockStatusSubscription = _chatRepository
        .isUserBlocked(currentUserId, otherUserId)
        .listen(
          (isBlocked) {
            emit(state.copyWith(isUserBlocked: isBlocked));
            _amIBlockedStatusSubscription?.cancel();
            _amIBlockedStatusSubscription = _chatRepository
                .amiBlocked(currentUserId, otherUserId)
                .listen((isBlocked) {
                  emit(state.copyWith(amIBlocked: isBlocked));
                });
          },
          onError: (error) {
            emit(
              state.copyWith(
                status: ChatStatus.error,
                errorMessage: error.toString(),
              ),
            );
          },
        );
  }

  void leaveChat() async {
    _isInChatRoom = false;
  }
}
