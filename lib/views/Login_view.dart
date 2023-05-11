//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:legsfree/services/auth/auth_exceptions.dart';
import 'package:legsfree/services/auth/auth_service.dart';
import 'package:legsfree/utilities/show_error_dialog.dart';
//import 'dart:developer' as devtools show log;

import '../constants/routes.dart';

//import 'package:legfree/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  //texteditingcontroller allows the writing of the text into another place once done
  //password and email declared
  late final TextEditingController _email;
  late final TextEditingController _password;

//overwriting initialization function to initialize email and password
//before use
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

//overwriting dispose function to dispose of the functions once done
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.android,
                size: 100,
              ),
              const SizedBox(
                height: 55,
              ),
              Text(
                'LegsFree',
                style: GoogleFonts.bebasNeue(
                  fontSize: 54,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Login and make it to class on time!',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    //display text field to enter email
                    controller: _email, //control the text
                    autocorrect: false, //properties of text for email
                    keyboardType: TextInputType
                        .emailAddress, //special keyboard for email writing
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      //display text inside textbox
                      hintText: 'Enter email address',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    //display text field to enter email
                    controller: _password, //control the text
                    obscureText: true,
                    enableSuggestions: false, //properties of text for password
                    autocorrect: false,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      //display text inside textbox
                      hintText: 'Enter password',
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 149.0, right: 147.0),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                    //display text button to store information and redirecting user
                    onPressed: () async {
                      final email = _email
                          .text; //assigns the value of the password as the text entered to it
                      final password = _password
                          .text; //assigns the value of the email as the text entered to it
    
                      try {
                        //try to sign in the user
    
                        await AuthService.firebase().logIn(
                          email: email,
                          password: password,
                        );
    
                        final user = AuthService.firebase().currentUser;
                        if (user?.isEmailVerified ?? false) {
                          //user email verified
                          //SchedulerBinding.instance.addPostFrameCallback((_) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            //newMapsRoute,
                            mapsRoute,
                            (route) => false,
                          );
                          //});
                        } else {
                          //user email is not verified
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              verifyEmailRoute,
                              (route) => false,
                            );
                          });
                        }
                      } on UserNotFoundAuthException {
                        //if exception is user is not found display user not found
                        await showErrorDialog(context, 'User not Found');
                      } on WeakPasswordAuthException {
                        //if exception is wrong password entered print wrong password in terminal
                        await showErrorDialog(context, 'Wrong password');
                      } on GenericAuthException {
                        //if exception falls underFirebaseException but is not wrong password or user not found then display error
                        await showErrorDialog(context, 'Authentication Error');
                      }
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                //routes to register page if button is pressed
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    registerRoute,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Not registered? Register here',
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
