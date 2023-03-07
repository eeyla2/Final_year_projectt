#![allow(non_snake_case)]

import 'package:flutter/material.dart';
import 'package:legsfree/constants/routes.dart';
import 'package:legsfree/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //appbar that displays verify email
        title: const Text('Verify email'),
      ),
      body: Column(
        children: [
          const Text(
              "We've sent you a verification email. Place order it and verify your email before going to the login page"),
          const Text(
              'if you have not received a verification email in 2 minutes, press the button below to resend the email'),
          TextButton(
            onPressed: () async {
              //sends emailverification for the current user
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send Email verification'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
