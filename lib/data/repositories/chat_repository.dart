import 'dart:developer';
import 'package:chat_app/data/models/chat_message.dart';
import 'package:chat_app/data/models/chat_room_model.dart';
import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository extends BaseRepository {
  CollectionReference get _chatRooms => firestore.collection('chatRooms');
  CollectionReference getChatRoomMessages(String chatRoomId) =>
      _chatRooms.doc(chatRoomId).collection('messages');
  Future<ChatRoomModel?> getorCreateChatRoom(
    String currentUserId,
    String otherUserId,
  ) async {
    final users = [currentUserId, otherUserId]..sort();
    final roomId = users.join('_');

    final roomdoc = await _chatRooms.doc(roomId).get();
    if (roomdoc.exists) {
      return ChatRoomModel.fromFirestore(roomdoc);
    }
    final currentUserData =
        (await firestore.collection('users').doc(currentUserId).get()).data()
            as Map<String, dynamic>;
    final otherUserData =
        (await firestore.collection('users').doc(otherUserId).get()).data()
            as Map<String, dynamic>;
    final participantsNames = {
      currentUserId: currentUserData['username']?.toString() ?? "",
      otherUserId: otherUserData['username']?.toString() ?? "",
    };
    final newRoom = ChatRoomModel(
      id: roomId,
      participants: users,
      participantsNames: participantsNames,
      lastReadTime: {
        currentUserId: Timestamp.now(),
        otherUserId: Timestamp.now(),
      },
    );
    await _chatRooms.doc(roomId).set(newRoom.toMap());
    return newRoom;
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String content,
    required String senderId,
    required String receiverId,
    MessageType type = MessageType.text,
  }) async {
    final batch = firestore.batch();
    final messageRef = getChatRoomMessages(chatRoomId).doc();
    final message = ChatMessage(
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      type: MessageType.text,
      timestamp: Timestamp.now(),
      readBy: [senderId],
      status: MessageStatus.sent,
      chatRoomId: chatRoomId,
      id: messageRef.id,
    );

    batch.set(messageRef, message.toMap());

    batch.update(_chatRooms.doc(chatRoomId), {
      "lastMessage": content,
      "lastMessageTime": message.timestamp,
      "lastMessageSenderId": senderId,
    });

    await batch.commit();
  }

  Stream<List<ChatMessage>> getMessages(
    String roomId, {
    DocumentSnapshot? lastDocument,
  }) {
    var query = getChatRoomMessages(
      roomId,
    ).orderBy('timestamp', descending: true).limit(20);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }
    return query.snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList(),
    );
  }

  Future<List<ChatMessage>> getMoreMessages(
    String roomId, {
    required DocumentSnapshot? lastDocument,
  }) async {
    var query = getChatRoomMessages(
      roomId,
    ).orderBy('timestamp', descending: true).limit(20);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    // Execute the query
    final snapshot = await query.get();

    // Map the result to ChatMessage list
    return snapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
  }

Stream<List<ChatRoomModel>> getChatRooms(String userId) {
  return _chatRooms
      .where('participants', arrayContains: userId)
      .orderBy('lastMessageTime', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => ChatRoomModel.fromFirestore(doc)).toList());
}

 
Stream<int> getUnreadMessagesCount(String chatRoomId, String userId) {
  return getChatRoomMessages(chatRoomId)
      .where('receiverId', isEqualTo: userId)
      .where('status', isEqualTo: MessageStatus.sent.toString()) // fixed this line
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}
       
Future<void> markMessageAsRead(String chatRoomId  , String userId) async {
  final batch = firestore.batch();
  final unreadMessage = await getChatRoomMessages(chatRoomId)
      .where('receiverId', isEqualTo: userId)
      .where('status', isEqualTo: MessageStatus.sent.toString())
      .get();
      // print(unreadMessage.docs);
  for (final doc in unreadMessage.docs) { 
    batch.update(doc.reference, {
      'status': MessageStatus.read.toString(),
      'readBy': FieldValue.arrayUnion([userId]),
    });
  }
  await batch.commit();
}

Stream<Map<String, dynamic>> getUserOnlineStatus(String userId) {
  return firestore.collection('users').doc(userId).snapshots().map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        'isOnline': data['isOnline'] ?? false,
        'lastSeen': data['lastSeen'],
      };
    } else {
      return {};
    }
  });

}

Future<void> updateOnlineStatus(String userId, bool isOnline) async {
  try{
  await firestore.collection('users').doc(userId).update({
    'isOnline': isOnline,
    'lastSeen': isOnline ? Timestamp.now() : Timestamp.now(),
  });
  }catch(e){
    log("Error updating online status: $e");
  }
}

  Future<void> updateTypingStatus(String chatRoomId, String userId, bool isTyping) async {
    await _chatRooms.doc(chatRoomId).update({
      'isTyping': isTyping,
      'isTypingUserId': isTyping ? userId : null,
    });
  }

Stream<Map<String, dynamic>> getTypingStatus(String chatRoomId)
{  return _chatRooms.doc(chatRoomId).snapshots().map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        'isTyping': data['isTyping'] ?? false,
        'isTypingUserId': data['isTypingUserId'],
      };
    } else {
      return {
        'isTyping': false,
        'isTypingUserId': null,
      };
    }
  });

}
Future<void> blockUser(String currentUserId , String blockedUserId) async{
final userRef = firestore.collection('users').doc(currentUserId);
await userRef.update({
  'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
});
}
Future<void> unblockUser(String currentUserId , String blockedUserId) async{
final userRef = firestore.collection('users').doc(currentUserId);
await userRef.update({
  'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
});
}
Stream<bool> isUserBlocked(String currentUserId , String otherUserId)  {
  return firestore.collection('users').doc(currentUserId).snapshots().map((doc) {
    final userData = UserModel.fromFirestore(doc);
    return userData.blockedUsers.contains(otherUserId);
  });
}
Stream<bool> amiBlocked(String currentUserId , String otherUserId)  {
  return firestore.collection('users').doc(otherUserId).snapshots().map((doc) {
    final userData = UserModel.fromFirestore(doc);
    return userData.blockedUsers.contains(currentUserId);
  });
}
}
