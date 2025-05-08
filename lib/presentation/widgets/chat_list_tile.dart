import 'package:chat_app/core/utils/encryption/encrypt_message.dart';
import 'package:chat_app/data/models/chat_room_model.dart';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chat;
  final VoidCallback onTap;
  final String currentUserId;
  const ChatListTile({
    super.key,
    required this.chat,
    required this.onTap,
    required this.currentUserId,
  });

  String get otherUserId {
    final otherUser = chat.participants.firstWhere(
      (userId) => userId != currentUserId,
    );
    return chat.participantsNames![otherUser] ?? "Umknown";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(otherUserId[0].toUpperCase()),
      ),
      title: Text(
        otherUserId[0].toUpperCase() + otherUserId.substring(1).toLowerCase(),
      ),
      subtitle: Expanded(
        child: Text(
          EncryptionService.decryptText(chat.lastMessage!) ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: const Color.fromARGB(255, 148, 44, 44)),
        ),
      ),
      trailing: StreamBuilder<int>(
        stream: getit<ChatRepository>().getUnreadMessagesCount(
          chat.id,
          currentUserId,
        ),
        builder: (context, snapshot) {
          final count = snapshot.data;
          if (!snapshot.hasData) {
            return const SizedBox.shrink();
          }
          return Container(
            decoration: BoxDecoration(
              color: count == 0 ? Colors.white : Colors.green,
              shape: BoxShape.circle,
            ),

            padding: const EdgeInsets.all(2),
            child:
                count == 0
                    ? const SizedBox.shrink()
                    : Text(
                      count.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            // child: Text(
            //   count == 0 ? "" :
            //   count.toString() ,
            // ),
          );
        },
      ),
    );
  }
}
