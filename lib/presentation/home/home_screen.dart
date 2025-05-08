// import 'dart:developer';

// import 'package:chat_app/data/repositories/auth_repository.dart';
// import 'package:chat_app/data/repositories/chat_repository.dart';
// import 'package:chat_app/data/repositories/contact_repository.dart';
// import 'package:chat_app/data/services/service_locator.dart';
// import 'package:chat_app/logic/cubit/auth/auth_cubit.dart';
// import 'package:chat_app/presentation/chat/chat_message_screen.dart';
// import 'package:chat_app/presentation/screen/auth/login_screen.dart';
// import 'package:chat_app/presentation/widgets/chat_list_tile.dart';
// import 'package:chat_app/router/app_router.dart';
// import 'package:flutter/material.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late final ContactRepository _contactRepository;
//   late final ChatRepository _chatRepository;
//   late final String _currentUserId;


//   @override
//   void initState() {
//     _contactRepository = getit<ContactRepository>();
//     _chatRepository = getit<ChatRepository>();
//     _currentUserId = getit<AuthRepository>().currentUserId ?? '';    

//     super.initState();
//   }

//   void _showContactList(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Text(
//                 "Contacts",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               Expanded(
//                 child: FutureBuilder<List<Map<String, dynamic>>>(
//                   future: _contactRepository.getRegisteredContacts(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) {
//                       return Center(child: Text("Error ${snapshot.error?.toString() ?? 'Unknown error'}"));
//                     }
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//                     final contacts = snapshot.data;
//                     if (contacts == null || contacts.isEmpty) {
//                       return Center(child: Text("No contacts found"));
//                     }
//                 //  print(contacts.runtimeType);
                
//                     return Expanded(
//                       child: ListView.builder(
//                         itemCount: contacts.length,
//                         itemBuilder: (context, index) {
//                           final contact = contacts[index];
//                           return ListTile(
//                             leading: CircleAvatar(
//                               backgroundColor: Colors.grey,
//                               child: Text(contact['name'][0].toUpperCase()),
//                             ),
//                             title: Text(contact['name']),
//                             onTap: (){
//                               getit<AppRouter>().push(
//                                 ChatMessageScreen(
//                                   receiverId: contact['id'],
//                                   receiverName: contact['name'],
//                                 ),
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ChaTTie'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.logout),
//             onPressed: () async {
//               await getit<AuthCubit>().signOut();
//               getit<AppRouter>().pushAndRemoveUntil(const LoginScreen());
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder(
//   stream: _chatRepository.getChatRooms(_currentUserId),
//   builder: (context, snapshot) {
//     if (snapshot.hasError) {
//       return Center(
//         child: Text("Error ${snapshot.error?.toString() ?? 'Unknown error'}"),
//       );
//     }
//     if (snapshot.connectionState == ConnectionState.waiting) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final chats = snapshot.data;

//     return chats == null || chats.isEmpty
//         ? const Center(child: Text("No chats available"))
//         : Expanded(
//           child: ListView.builder(
//               itemCount: chats.length,
//               itemBuilder: (context, index) {
//                 final chatRoom = chats[index];
//                 final receiverId = chatRoom.participants
//                     .firstWhere((userId) => userId != _currentUserId);
//                 final receiverName = chatRoom.participantsNames?[receiverId] ?? "Unknown";
          
//                 return ChatListTile(
//                   chat: chatRoom,
//                   onTap: () {
//                     getit<AppRouter>().push(ChatMessageScreen(
//                       receiverId: receiverId,
//                       receiverName: receiverName,
//                     ));
//                   },
//                   currentUserId: _currentUserId,
//                 );
//               },
//             ),
//         );
//   },
// )
// ,
//       floatingActionButton: FloatingActionButton(
//         onPressed: ()=>  _showContactList(context)
//         ,
//         backgroundColor: const Color.fromARGB(255, 19, 200, 164),
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }




import 'dart:developer';

import 'package:chat_app/data/repositories/auth_repository.dart';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/data/repositories/contact_repository.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubit/auth/auth_cubit.dart';
import 'package:chat_app/presentation/chat/chat_message_screen.dart';
import 'package:chat_app/presentation/screen/auth/login_screen.dart';
import 'package:chat_app/presentation/screen/profile/profile_screen.dart';
import 'package:chat_app/presentation/widgets/chat_list_tile.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;
  late final ChatRepository _chatRepository;
  late final String _currentUserId;

  @override
  void initState() {
    _contactRepository = getit<ContactRepository>();
    _chatRepository = getit<ChatRepository>();
    _currentUserId = getit<AuthRepository>().currentUserId ?? '';
    super.initState();
  }

  void _showContactList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Contacts",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactRepository.getRegisteredContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error ${snapshot.error?.toString() ?? 'Unknown error'}"));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final contacts = snapshot.data;
                    if (contacts == null || contacts.isEmpty) {
                      return Center(child: Text("No contacts found"));
                    }

                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Text(contact['name'][0].toUpperCase()),
                          ),
                          title: Text(contact['name']),
                          onTap: () {
                            getit<AppRouter>().push(
                              ChatMessageScreen(
                                receiverId: contact['id'],
                                receiverName: contact['name'],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChaTTie'),
        actions: <Widget>[_showMenubar(context, _currentUserId)]
          // IconButton(
          //   icon: Icon(Icons.logout),
          //   onPressed: () async {
          //     await getit<AuthCubit>().signOut();
          //     getit<AppRouter>().pushAndRemoveUntil(const LoginScreen());
          //   },
          // ),
        // ],
      ),
      body: StreamBuilder(
        stream: _chatRepository.getChatRooms(_currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error ${snapshot.error?.toString() ?? 'Unknown error'}"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data;

          if (chats == null || chats.isEmpty) {
            return const Center(child: Text("No chats available"));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatRoom = chats[index];

              // Avoid crash if currentUserId is the only participant
              final receiverId = chatRoom.participants
                  .firstWhere((userId) => userId != _currentUserId, orElse: () => '');

              if (receiverId.isEmpty) {
                debugPrint('Skipping chat room with only current user: ${chatRoom.id}');
                return SizedBox.shrink();
              }

              final receiverName = chatRoom.participantsNames?[receiverId] ?? "Unknown";

              return ChatListTile(
                chat: chatRoom,
                onTap: () {
                  getit<AppRouter>().push(ChatMessageScreen(
                    receiverId: receiverId,
                    receiverName: receiverName,
                  ));
                },
                currentUserId: _currentUserId,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactList(context),
        backgroundColor: const Color.fromARGB(255, 19, 200, 164),
        child: Icon(Icons.add),
      ),
    );
  }
}

Widget _showMenubar(BuildContext context, String currentUserId){
    final FocusNode buttonFocusNode = FocusNode(debugLabel: 'Menu Button');

  return MenuAnchor(
      childFocusNode: buttonFocusNode,
      menuChildren: <Widget>[
        MenuItemButton(onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context)  {
                return ProfileScreen(userId: currentUserId);
              },
            ),
          );
        }, child: const Text('Profile')),
        MenuItemButton(onPressed: () {}, child: const Text('Setting')),
        MenuItemButton(onPressed: () {}, child: const Text('Send Feedback')),
      ],
      builder: (_, MenuController controller, Widget? child) {
        return IconButton(
          focusNode: buttonFocusNode,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          icon: const Icon(Icons.more_vert),
        );
      },
    );
}