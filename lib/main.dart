import 'package:chat_app/config/theme/app_theme.dart';
import 'package:chat_app/data/repositories/chat_repository.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubit/auth/auth_cubit.dart';
import 'package:chat_app/logic/cubit/auth/auth_state.dart';
import 'package:chat_app/logic/observer/app_life_cycle_observer.dart';
import 'package:chat_app/presentation/home/home_screen.dart';
import 'package:chat_app/presentation/screen/auth/login_screen.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppLifeCycleObserver? _lifeCycleObserver; // make it nullable

  @override
  void initState() {
    super.initState();

    getit<AuthCubit>().stream.listen((state) {
      if (state.status == AuthStatus.authenticated && state.user != null) {
        _lifeCycleObserver = AppLifeCycleObserver(
          userId: state.user!.uid,
          chatRepository: getit<ChatRepository>(),
        );
        WidgetsBinding.instance.addObserver(_lifeCycleObserver!); // now safe
      }
    });
  }

  @override
  void dispose() {
    if (_lifeCycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifeCycleObserver!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // your build code stays the same
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Messenger App',
        debugShowCheckedModeBanner: false,
        navigatorKey: getit<AppRouter>().navigatorKey,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: BlocBuilder<AuthCubit, AuthState>(
            bloc: getit<AuthCubit>(),
            builder: (context, state) {
              if (state.status == AuthStatus.intitial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (state.status == AuthStatus.authenticated) {
                return const HomeScreen();
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}


// class _MyAppState extends State<MyApp> {
//   late AppLifeCycleObserver _lifeCycleobserver;
//   @override
//   void initState() {
//     getit<AuthCubit>().stream.listen((state) {
//       if (state.status == AuthStatus.authenticated && state.user != null) {
//         _lifeCycleobserver = AppLifeCycleObserver(
//           userId: state.user!.uid,
//           chatRepository: getit<ChatRepository>(),
//         );
//       }
//     });
//     WidgetsBinding.instance.addObserver(_lifeCycleobserver);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Messanger APP',
//       debugShowCheckedModeBanner: false,
//       navigatorKey: getit<AppRouter>().navigatorKey,
//       theme: AppTheme.lightTheme,
//       home: Scaffold(
//         body: BlocBuilder<AuthCubit, AuthState>(
//           bloc: getit<AuthCubit>(),
//           builder: (context, state) {
//             if (state.status == AuthStatus.intitial) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             } else if (state.status == AuthStatus.authenticated) {
//               return const HomeScreen();
//             }
//             return const LoginScreen();
//           },
//         ),
//       ),
//     );
//   }
// }
