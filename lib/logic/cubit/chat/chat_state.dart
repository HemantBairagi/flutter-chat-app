import 'package:chat_app/data/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final String? errorMessage;
  final String? receiverId;
  final String? chatRoomId;
  final List<ChatMessage>? messages;
  final bool isReceiverOnline;
  final bool isReceiverTyping;
  final Timestamp? receiverLastSeen;
  final bool? hashMoreMessages;
  final bool? isLoadingMore;
  final bool? isUserBlocked;
  final bool? amIBlocked;

  const ChatState({
    this.status = ChatStatus.initial,
    this.isReceiverOnline=false,
    this.isReceiverTyping=false,
    this.receiverLastSeen,
    this.hashMoreMessages= true,
    this.isLoadingMore= false,
    this.isUserBlocked=false,
    this.amIBlocked=false, 
    this.errorMessage,
    this.receiverId,
    this.chatRoomId,
    this.messages = const [],
  });

  ChatState copyWith({
    ChatStatus? status,
    String? errorMessage,
    String? receiverId,
    String? chatRoomId,
    List<ChatMessage>? messages,
    bool? isReceiverOnline,
    bool? isReceiverTyping,
    Timestamp? receiverLastSeen,
    bool? hashMoreMessages,
    bool? isLoadingMore,
    bool? isUserBlocked,
    bool? amIBlocked,

  }) {
    return ChatState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      receiverId: receiverId ?? this.receiverId,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      messages: messages ?? this.messages,
      isReceiverOnline: isReceiverOnline ?? this.isReceiverOnline,
      isReceiverTyping: isReceiverTyping ?? this.isReceiverTyping,
      receiverLastSeen: receiverLastSeen ?? this.receiverLastSeen,
      hashMoreMessages: hashMoreMessages ?? this.hashMoreMessages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isUserBlocked: isUserBlocked ?? this.isUserBlocked,
      amIBlocked: amIBlocked ?? this.amIBlocked,

    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    receiverId,
    chatRoomId,
    messages,
    isReceiverOnline,
    isReceiverTyping,
    receiverLastSeen,
    hashMoreMessages,
    isLoadingMore,
    isUserBlocked,
    amIBlocked,
    

  ];
}
