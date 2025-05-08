import 'package:chat_app/core/common/custom_Input.dart';
import 'package:chat_app/core/common/custom_button.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubit/auth/auth_cubit.dart';
import 'package:chat_app/logic/cubit/auth/auth_state.dart';
import 'package:chat_app/presentation/home/home_screen.dart';
import 'package:chat_app/presentation/screen/auth/signup_screen.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address (e.g., example@email.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Future<void> handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (_formkey.currentState?.validate() ?? false) {
      try {
        getit<AuthCubit>().signIn(
          email: emailController.text,
          password: passwordController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields correctly.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: getit<AuthCubit>(),
      listenWhen: (previous, current) {
        return previous.status != current.status ||
            previous.error != current.error;
      },
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          getit<AppRouter>().pushAndRemoveUntil(const HomeScreen());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(
          0xFFF8F8F8,
        ), // Light background for modern look
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Text(
                    "Welcome Back",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    // style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    //   fontWeight: FontWeight.bold,
                    // ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Login to your account",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    // style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //   color: Colors.grey,
                    //   fontSize: 14,
                    // ),
                  ),
                  const SizedBox(height: 40),
                  CustomInput(
                    controller: emailController,
                    hintText: "Email",
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    validator: _validateEmail,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 20),
                  CustomInput(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    focusNode: _passwordFocus,
                    validator: _validatePassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    hintText: "Password",
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  const SizedBox(height: 40),
                  CustomButton(text: "Login", onPressed: handleSignIn),
                  const SizedBox(height: 20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(text:(" ")),
                          TextSpan(
                            text: "Sign Up",
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    getit<AppRouter>().push(
                                      const SignupScreen(),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:chat_app/core/common/custom_Input.dart';
// import 'package:chat_app/core/common/custom_button.dart';
// import 'package:chat_app/data/services/service_locator.dart';
// import 'package:chat_app/logic/cubit/auth/auth_cubit.dart';
// import 'package:chat_app/logic/cubit/auth/auth_state.dart';
// import 'package:chat_app/presentation/home/home_screen.dart';
// import 'package:chat_app/presentation/screen/auth/signup_screen.dart';
// import 'package:chat_app/router/app_router.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formkey = GlobalKey<FormState>();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _isPasswordVisible = false;

//   final _emailFocus = FocusNode();
//   final _passwordFocus = FocusNode();
//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter your email address';
//     }
//     final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//     if (!emailRegex.hasMatch(value)) {
//       return 'Please enter a valid email address (e.g., example@email.com)';
//     }
//     return null;
//   }

//   // Password validation
//   String? _validatePassword(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter a password';
//     }
//     if (value.length < 6) {
//       return 'Password must be at least 6 characters long';
//     }
//     return null;
//   }

//   Future<void> handleSignIn() async {
//     FocusScope.of(context).unfocus();
//     if (_formkey.currentState?.validate() ?? false) {
//       // Perform signup logic here
//       // For example, call your authentication service to create a new user
//       try {
//         getit<AuthCubit>().signIn(
//           email: emailController.text,
//           password: passwordController.text,
//         );
//       } catch (e) {
//         // Handle signup error (e.g., show a snackbar or dialog)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('SignIN failed: $e')));
//       }
//     } else {
//       // If the form is not valid, show an error message or highlight the fields
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please fill in all required fields correctly.'),
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     _emailFocus.dispose();
//     _passwordFocus.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthCubit, AuthState>(
//       bloc: getit<AuthCubit>(),
//       listenWhen: (previous, current) {
//         return previous.status != current.status ||
//             previous.error != current.error;
//       },
//       listener: (context, state) {
//          if (state.status == AuthStatus.authenticated) {
//           // Navigate to the home screen or perform any authenticated action
//           getit<AppRouter>().pushAndRemoveUntil(const HomeScreen());
//         }
//       },
//       child: Scaffold(
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Form(
//               key: _formkey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 30),
//                   Text(
//                     "Welcome Back",
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     "Login to your account",
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       color: Colors.grey,
//                       fontSize: 14,
//                     ),
//                   ),
//                   SizedBox(height: 30),
//                   CustomInput(
//                     controller: emailController,
//                     hintText: "Email",
//                     focusNode: _emailFocus,
//                     keyboardType: TextInputType.emailAddress,
//                     obscureText: false,
//                     validator: _validateEmail,
//                     prefixIcon: Icon(Icons.email_outlined),
//                   ),
//                   SizedBox(height: 20),
//                   CustomInput(
//                     controller: passwordController,
//                     obscureText: _isPasswordVisible,
//                     focusNode: _passwordFocus,
//                     validator: _validatePassword,
//                     prefixIcon: Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _isPasswordVisible = !_isPasswordVisible;
//                         });
//                       },
//                       icon: Icon(
//                         _isPasswordVisible
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                       ),
//                     ),
//                     hintText: "Password",
//                     keyboardType: TextInputType.visiblePassword,
//                   ),
//                   SizedBox(height: 50),
//                   CustomButton(text: "Login", onPressed: handleSignIn),
//                   SizedBox(height: 20),
//                   Center(
//                     child: RichText(
//                       text: TextSpan(
//                         text: "Don't have an account?",
//                         style: TextStyle(color: Colors.grey[600]),
//                         children: [
//                           TextSpan(
//                             text: "Sign Up",
//                             style: Theme.of(
//                               context,
//                             ).textTheme.bodyLarge?.copyWith(
//                               color: Theme.of(context).primaryColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             recognizer:
//                                 TapGestureRecognizer()
//                                   ..onTap = () {
//                                     // Navigator.push(
//                                     //   context,
//                                     //   MaterialPageRoute(
//                                     //     builder:
//                                     //         (context) => const SignupScreen(),
//                                     //   ),
//                                     // );
//                                     getit<AppRouter>().push(SignupScreen());
//                                   },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
