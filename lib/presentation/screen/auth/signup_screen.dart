import 'package:chat_app/core/common/custom_Input.dart';
import 'package:chat_app/core/common/custom_button.dart';
import 'package:chat_app/data/services/service_locator.dart';
import 'package:chat_app/logic/cubit/auth/auth_cubit.dart';
import 'package:chat_app/presentation/screen/auth/login_screen.dart';
import 'package:chat_app/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isPasswordVisible = false;

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _phoneFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    usernameController.dispose();
    phoneController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _usernameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your full name";
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your username";
    }
    return null;
  }

  // Email validation
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

  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Phone validation
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    final phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (e.g., +1234567890)';
    }
    return null;
  }

  Future<void> handleSignup() async {
   FocusScope.of(context).unfocus();
    if (_formkey.currentState?.validate() ?? false) {
      // Perform signup logic here
      // For example, call your authentication service to create a new user
      try{
         getit<AuthCubit>().signUp(
          fullName: nameController.text,
          username: usernameController.text,
          email: emailController.text,
          phoneNumber: phoneController.text,
          password: passwordController.text,
        );
      } catch (e) {
        // Handle signup error (e.g., show a snackbar or dialog)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Signup failed: $e'),
          ),
        );
      }
  } else{
      // If the form is not valid, show an error message or highlight the fields
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all required fields correctly.'),
        ),
      );
  }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Text(
                    "Sign Up",
                    style: GoogleFonts.poppins(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Craete a New Account",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 30),
                  CustomInput(
                    controller: nameController,
                    hintText: "name",
                    keyboardType: TextInputType.name,
                    obscureText: false,
                    prefixIcon: Icon(Icons.person_2_outlined),
                    focusNode: _nameFocus,
                    validator: _validateName,
                  ),
                  SizedBox(height: 20),
        
                  CustomInput(
                    controller: usernameController,
                    hintText: "username",
                    keyboardType: TextInputType.name,
                    obscureText: false,
                    prefixIcon: Icon(Icons.pets_rounded),
                    focusNode: _usernameFocus,
                    validator: _validateUsername,
                  ),
        
                  SizedBox(height: 20),
                  CustomInput(
                    controller: phoneController,
                    hintText: "Phone",
                    keyboardType: TextInputType.number,
                    obscureText: false,
                    focusNode: _phoneFocus,
                    prefixIcon: Icon(Icons.phone_enabled_outlined),
                    validator: _validatePhone,
                  ),
        
                  SizedBox(height: 20),
                  CustomInput(
                    controller: emailController,
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    focusNode: _emailFocus,
                    prefixIcon: Icon(Icons.email_outlined),
                    validator: _validateEmail,
                  ),
        
                  SizedBox(height: 20),
                  CustomInput(
                    controller: passwordController,
                    obscureText: _isPasswordVisible,
                    prefixIcon: Icon(Icons.lock_outline),
                    focusNode: _passwordFocus,
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
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 50),
                  CustomButton(
                    text: "Create Account",
                    onPressed:handleSignup,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Already have an account?",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        children: [
                          TextSpan(text:("  ")),

                          TextSpan(
                            text: "Login",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    getit<AppRouter>().push(LoginScreen());
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
