import 'package:chat_app/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus{
  intitial ,
   loading ,
    authenticated ,
     unauthenticated ,
      error
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? error; // Assuming you have a user ID after authentication

  const AuthState({
    this.status = AuthStatus.intitial,
     this.error,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? error,
    UserModel? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
  
  @override
  List<Object?> get props => [status, error, user];
}