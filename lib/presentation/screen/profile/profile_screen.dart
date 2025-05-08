import 'package:flutter/material.dart';
import 'package:chat_app/data/models/user_model.dart';
import 'package:chat_app/data/repositories/auth_repository.dart'; // Assuming this exists
import 'package:chat_app/data/services/service_locator.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final userRepository = getit<AuthRepository>(); // Ensure this is registered in your service locator

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
      ),
      body: FutureBuilder<UserModel>(
        future: userRepository.getUserData(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                
                  children: [CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(user.fullName[0].toUpperCase()),),]
                ),
                Text('Name: ${user.fullName}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Phone Number: ${user.phoneNumber}', style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
