#![allow(non_snake_case)]

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 110,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 00),
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      size: 100,
                    ),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 70.0),
                    width: MediaQuery.of(context).size.height * 0.6,
                    child: const Text(
                      "Verify your email",
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      // padding: const EdgeInsets.only(left: 149.0, right: 147.0),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 12.0, bottom: 12.0, left: 30, right: 20.0),
                        width: MediaQuery.of(context).size.height * 0.5,
                        child: Text(
                          "We've sent you a verification email. Place order it and verify your email before going to the login page. If you have not received a verification email in 2 minutes, press the button below to resend the email.",
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  //   child: Container(
                  //     //padding: const EdgeInsets.only( right: 147.0),
                  //     decoration: BoxDecoration(
                  //       color: Colors.deepPurple,
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Container(
                  //       padding: const EdgeInsets.only(left: 30.0),
                  //       width: MediaQuery.of(context).size.height * 0.5,
                  //       child: Text(
                  //         'If you have not received a verification email in 2 minutes, press the button below to resend the email',
                  //         style: TextStyle(
                  //           color: Colors.grey[200],
                  //           fontWeight: FontWeight.bold,
                  //           fontSize: 16,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  TextButton(
                    onPressed: () async {
                      //sends emailverification for the current user
                      await AuthService.firebase().sendEmailVerification();
                    },
                    child: const Text(
                      'Send Email Verification',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),

                  // TextButton(
                  //   onPressed: () async {
                  //     await AuthService.firebase().logOut();
                  //     SchedulerBinding.instance.addPostFrameCallback((_) {
                  //       Navigator.of(context).pushNamedAndRemoveUntil(
                  //         registerRoute,
                  //         (route) => false,
                  //       );
                  //     });
                  //   },
                  //   child: const Text('Restart'),
                  // ),
                ],
              ),
              Row(children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(left: 00),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    //size: 100,
                    onPressed: () async {
                      await AuthService.firebase().logOut();
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          registerRoute,
                          (route) => false,
                        );
                      });
                    },
                  ),
                ),
                const Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
