import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

//immutable means the class needs to have all it's fields finalized once they are initialized
@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;

//constructor
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  });

//copies user from firebase into the AuthUser class creating an instance of it
  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}
