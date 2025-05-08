import 'package:chat_app/data/repositories/auth_repository.dart';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/data/repositories/contact_repository.dart';
import 'package:chat_app/logic/cubit/auth/auth_cubit.dart';
import 'package:chat_app/logic/cubit/chat/chat_cubit.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final getit = GetIt.instance;
Future<void> setupLocator() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  getit.registerLazySingleton(() => AppRouter());
  getit.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  getit.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getit.registerLazySingleton(() => AuthRepository());
  getit.registerLazySingleton(() => ContactRepository());
  getit.registerLazySingleton(() => ChatRepository());
  getit.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: getit<AuthRepository>()),
  );
  getit.registerFactory(
    () => ChatCubit(
      chatRepository: ChatRepository(),
      currentUserId: getit<FirebaseAuth>().currentUser?.uid ?? '',
    ),
  );

  // getit.registerLazySingleton(() => ChatRepository());
}
