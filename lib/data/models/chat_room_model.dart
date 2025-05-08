import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageSenderId;
  final Timestamp? lastMessageTime;
  final Map<String, Timestamp>? lastReadTime;
  final Map<String, String>? participantsNames;
  final bool isTyping;
  final String? isTypingUserId;
  final bool isCallActive;

  ChatRoomModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageSenderId,
    this.lastMessageTime,
    Map<String, Timestamp>? lastReadTime,
    Map<String, String>? participantsNames,
    this.isTyping = false,
    this.isTypingUserId,
    this.isCallActive = false,
  }) : lastReadTime = lastReadTime ?? {},
       participantsNames = participantsNames ?? {};

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime,
      'lastReadTime': lastReadTime?.map((key, value) => MapEntry(key, value)),
      'participantsNames': participantsNames,
      'isTyping': isTyping,
      'isTypingUserId': isTypingUserId,
      'isCallActive': isCallActive,
    };
  }

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    if (doc.data() == null) {
      throw Exception("Document data is null");
    }
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageSenderId: data['lastMessageSenderId'],
      lastMessageTime: data['lastMessageTime'] ,
      lastReadTime: Map<String, Timestamp>.from(
          (data['lastReadTime'] ?? {} )),
      participantsNames:
       Map<String, String>.from(data['participantsNames'] ?? {}),
      isTyping: data['isTyping'] ?? false,
      isTypingUserId: data['isTypingUserId'] ,
      isCallActive: data['isCallActive']?? false,
    );
  }
}
