import 'dart:io'; // Required for Platform.isIOS

import 'package:chat_app/core/utils/encryption/encrypt_message.dart';
import 'package:chat_app/data/models/chat_message.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubit/chat/chat_cubit.dart';
import 'package:chat_app/logic/cubit/chat/chat_state.dart';
import 'package:chat_app/presentation/widgets/loading_dots.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ChatMessageScreen extends StatefulWidget {
  final String? receiverId;
  final String? receiverName;

  const ChatMessageScreen({super.key, this.receiverId, this.receiverName});

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  late final ChatCubit _chatCubit;
  final _scrollController = ScrollController();
  List<ChatMessage> previousmessages = [];
  bool _isTyping = false;
  bool _showEmoji = false;

  void _onTyping() {
    final isType = messageController.text.isNotEmpty;
    if (isType != _isTyping) {
      setState(() {
        _isTyping = isType;
      });
      if (isType) {
        _chatCubit.startTyping();
      }
    }
  }

  void onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _chatCubit.loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _hasNewMessages(List<ChatMessage>? messages) {
    if (messages?.length != previousmessages.length) {
      _scrollToBottom();
      previousmessages = List.from(messages!);
    }
  }

  @override
  void initState() {
    _chatCubit = getit<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId!);
    messageController.addListener(_onTyping);
    _scrollController.addListener(onScroll);
    super.initState();
  }

  Future<void> handlesendMessage() async {
    final message = EncryptionService.encryptText(
      messageController.text.trim(),
    );

    messageController.clear();
    setState(() {
      _isTyping = false;
    });
    _chatCubit.sendMessage(content: message, receiverId: widget.receiverId!);
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    _chatCubit.leaveChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 225, 230, 230),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                child: Text(
                  widget.receiverName != null ? widget.receiverName![0].toUpperCase() : 'U',
                ),
              ),
              const SizedBox(width: 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName ?? '',
                    style: const TextStyle(fontSize: 18),
                  ),
                  BlocBuilder<ChatCubit, ChatState>(
                    bloc: _chatCubit,
                    builder: (context, state) {
                      if (state.amIBlocked!) {
                        return Text(
                          "You are blocked by ${widget.receiverName}",
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        );
                      } else if (state.isUserBlocked!) {
                        return Text(
                          "You have blocked ${widget.receiverName}",
                          style: const TextStyle(fontSize: 12, color: Colors.red),
                        );
                      } else if (state.isReceiverOnline) {
                        return Text(
                          "Online",
                          style: TextStyle(fontSize: 12, color: Colors.green[400]),
                        );
                      } else if (state.isReceiverTyping) {
                        return Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 4),
                              child: const LoadingDots(),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              "Typing...",
                              style: TextStyle(fontSize: 12, color: Colors.green),
                            ),
                          ],
                        );
                      } else if (state.receiverLastSeen != null) {
                        final formattedLastSeen = DateFormat('hh:mm a').format(state.receiverLastSeen!.toDate());
                        return Text(
                          "Last seen at $formattedLastSeen",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      } else {
                        return const Text(
                          "Offline",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            BlocBuilder<ChatCubit, ChatState>(
              bloc: _chatCubit,
              builder: (context, state) {
                if (state.isUserBlocked!) {
                  return TextButton.icon(
                    onPressed: () => _chatCubit.unblockUser(widget.receiverId!),
                    label: const Text("Unblock"),
                    icon: const Icon(Icons.block),
                  );
                }
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    if (value == "block") {
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Block User"),
                            content: const Text("Are you sure you want to block this user?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Block",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirm == true) {
                        _chatCubit.blockUser(widget.receiverId!);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'block',
                      child: Text("Block User"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<ChatCubit, ChatState>(
          bloc: _chatCubit,
          listener: (context, state) {
            if (state.status == ChatStatus.loaded) {
              _hasNewMessages(state.messages);
            }
          },
          builder: (context, state) {
            if (state.status == ChatStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == ChatStatus.error) {
              return Center(
                child: Text(
                  state.errorMessage ?? "Something went wrong",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: state.messages?.length ?? 0,
                    itemBuilder: (context, index) {
                      final message = state.messages![index];
                      final isMe = message.senderId == _chatCubit.currentUserId;
                      return MessageBubble(message: message, isMe: isMe);
                    },
                  ),
                ),
                Column(
                  children: [
                    if (!state.isUserBlocked! && !state.amIBlocked!)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.emoji_emotions_outlined),
                              onPressed: () {
                                setState(() {
                                  _showEmoji = !_showEmoji;
                                  if (_showEmoji) {
                                    FocusScope.of(context).unfocus();
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: TextField(
                                onTap: () {
                                  setState(() {
                                    _showEmoji = false;
                                  });
                                },
                                textCapitalization: TextCapitalization.sentences,
                                controller: messageController,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  hintText: "Type a message",
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _isTyping ? handlesendMessage : null,
                              color: _isTyping ? Colors.blue : Colors.grey,
                            ),
                          ],
                        ),
                      ),

if (_showEmoji)
  SizedBox(
    height: 250,
    child: EmojiPicker(
      textEditingController: messageController,
      onEmojiSelected: (category, emoji) {
        messageController
          ..text += emoji.emoji
          ..selection = TextSelection.fromPosition(
            TextPosition(offset: messageController.text.length),
          );
        setState(() {
          _isTyping = messageController.text.isNotEmpty;
        });
      },
      config: Config(
        height: 250,
        emojiViewConfig: EmojiViewConfig(
          backgroundColor: Colors.white, 
          emojiSizeMax: 32 * (Platform.isIOS ? 1.3 : 1.0),
          columns: 7,
        ),
        categoryViewConfig: const CategoryViewConfig(
          initCategory: Category.RECENT,
        ),
      ),
    ),
  ),


                    // if (_showEmoji)
                    //   SizedBox(
                    //     height: 250,
                    //     child: EmojiPicker(
                    //       textEditingController: messageController,
                    //       onEmojiSelected: (category, emoji) {
                    //         messageController
                    //           ..text += emoji.emoji
                    //           ..selection = TextSelection.fromPosition(
                    //             TextPosition(offset: messageController.text.length),
                    //           );
                    //         setState(() {
                    //           _isTyping = messageController.text.isNotEmpty;
                    //         });
                    //       },
                    //       config: Config(
                    //         height: 250,
                    //         emojiViewConfig: EmojiViewConfig(
                    //           columns: 7,
                    //           emojiSizeMax: 32.0 * (Platform.isIOS ? 1.30 : 1.0),
                    //           verticalSpacing: 0,
                    //           horizontalSpacing: 0,
                    //           gridPadding: EdgeInsets.zero,
                    //           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    //           loadingIndicator: const SizedBox.shrink(),
                    //         ),
                    //         categoryViewConfig: const CategoryViewConfig(
                    //           initCategory: Category.RECENT,
                    //         ),
                    //         bottomActionBarConfig: BottomActionBarConfig(
                    //           enabled: true,
                    //           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    //           buttonColor: Theme.of(context).primaryColor,
                    //         ),
                    //         skinToneConfig: const SkinToneConfig(
                    //           enabled: true,
                    //           dialogBackgroundColor: Colors.white,
                    //           indicatorColor: Colors.grey,
                    //         ),
                    //         searchViewConfig: SearchViewConfig(
                    //           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    //           buttonIconColor: Theme.of(context).primaryColor,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: EdgeInsets.only(
          top: 6,
          bottom: 6,
          left: isMe ? 60 : 10,
          right: isMe ? 10 : 60,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFD2F1FC) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              EncryptionService.decryptText(message.content) ?? "Decrypt error",
              style: const TextStyle(fontSize: 14, height: 1.3),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(message.timestamp.toDate()),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.status == MessageStatus.read
                        ? Icons.done_all
                        : Icons.check,
                    size: 16,
                    color: message.status == MessageStatus.read ? Colors.blue : Colors.grey,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
