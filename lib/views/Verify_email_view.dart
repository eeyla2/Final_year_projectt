#![allow(non_snake_case)]

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          const Text('Please verify email address:'),
          TextButton(
            onPressed: () async {
              //sends emailverification for the current user
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
            child: const Text('Send Email verification'),
          )
        ],
      ),
    );
  }
}
