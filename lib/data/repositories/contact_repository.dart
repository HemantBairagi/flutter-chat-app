import "dart:developer";
import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/services/base_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactRepository extends BaseRepository {
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
  Future<bool> requestContactPremission() async {
    return await FlutterContacts.requestPermission();
  }
  String normalizeNumber(String number) {
  // Remove all non-digit characters
  String digitsOnly = number.replaceAll(RegExp(r'\D'), '');

  // Remove country code if present (assumes +91 for India)
  if (digitsOnly.startsWith('91') && digitsOnly.length > 10) {
    digitsOnly = digitsOnly.substring(digitsOnly.length - 10);
  }

  return digitsOnly;
}

Future<List<Map<String, dynamic>>> getRegisteredContacts() async {
  try {
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: true,
    );

    final List<Map<String, dynamic>> phoneNumber = contacts
        .where((contact) => contact.phones.isNotEmpty)
        .map<Map<String, dynamic>>(
          (contact) => {
            "name": contact.displayName,
            "phoneNumber": normalizeNumber(contact.phones.first.normalizedNumber),
            'photo': contact.photo,
          },
        )
        .toList();

    log(phoneNumber.toString());

    final usersSnapshot = await firestore.collection('users').get();
    final List<UserModel> registeredUser = usersSnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();

    final List<Map<String, dynamic>> matchedContact = phoneNumber
        .where((contact) {
          final phoneNumber = contact['phoneNumber'];
          return registeredUser.any((user) => user.phoneNumber == phoneNumber);
        })
        .map<Map<String, dynamic>>((contact) {
          final phoneNumber = contact['phoneNumber'];
          final user = registeredUser.firstWhere(
              (user) => user.phoneNumber == phoneNumber);
          return {
            'id': user.uid,
            'name': contact['name'],
            'phoneNumber': contact['phoneNumber'],
          };
        })
        .toList();

    log(matchedContact.toString());
    return matchedContact;
  } catch (e) {
    print("Error getting contacts: $e");
    return [];
  }
}



}
//   Future<List<Map<String, dynamic>>> getRegisteredContacts() async {
//     try {
//       // get device contacts
//       final contacts = await FlutterContacts.getContacts(
//         withProperties: true,
//         withPhoto: true,
//       );

//       // print(contacts.toString());
//       // get registered contacts
//       final phoneNumber =
//           contacts
//               .where((contact) => contact.phones.isNotEmpty)
//               .map(
//                 (contact) => {
//                   "name": contact.displayName,
//                   "phoneNumber": normalizeNumber(contact.phones.first.normalizedNumber),
//                   'photo': contact.photo,
//                 },
//               )
//               .toList();
//               log(phoneNumber.toString());
//       final usersSnapshot = await firestore.collection('users').get();
//       final registeredUser =
//           usersSnapshot.docs
//               .map((doc) => UserModel.fromFirestore(doc))
//               .toList();
//       // filter the registered users from the phone numbers
//       final matchedContact =
//           phoneNumber
//               .where((contact) {
//                 final phoneNumber = contact['phoneNumber'];
//                 return registeredUser.any(
//                   (user) =>
//                       user.phoneNumber == phoneNumber
//                 );
//               })
//               .map((contact) {
//                 final phoneNumber = contact['phoneNumber'];
//                 final user = registeredUser.firstWhere(
//                   (user) =>
//                       user.phoneNumber == phoneNumber                );
//                 return {
//                   'id': user.uid,
//                   'name': contact['name'],
//                   'phoneNumber': contact['phoneNumber'],
//                 };
//               })
//               .toList();
//               log(matchedContact.toString());
//       return matchedContact;
//     } catch (e) {
//       print("Error getting contacts: $e");
//       return [];
//     }
//   }
// }
