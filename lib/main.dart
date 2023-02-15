import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legsfree/firebase_options.dart';
import 'package:legsfree/views/Login_view.dart';
import 'package:legsfree/views/Register_view.dart';
import 'package:legsfree/views/Verify_email_view.dart';
//import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    //place MaterialApp in here for effeciency instead of using MyApp widget
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
        routes: {
          //mapping different routes
          '/login/': (context) => const LoginView(),
          '/register/': (context) => const RegisterView(),
          '/main/': (context) => const MainView(),
        }),
  );
}

//homepage widget to separate the initialization process from login and register process
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        //initializes application for the currentplatform in use
        //initiallization process
        options: DefaultFirebaseOptions.currentPlatform, //this line not working
      ),
      builder: (context, snapshot) {
        //builds once app is initialized
        //connection
        switch (snapshot.connectionState) {
          case ConnectionState.done: //if connected successfully
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified) {
                //if user has been entered and email is verified return mainview
                return const MainView();
              } else {
                //if not show the verifyemailview page
                return const VerifyEmailView();
              }
            } else {
              //if user not entered show loginview and from there you can go to registerview if you want
              return const LoginView();
            }
            return const Text('done');
          default: //in all other cases
            return const CircularProgressIndicator(); //if the app is not connected yet show a circular indicator
        }
      },
    );
  }
}

enum MenuAction { logout }

//mainview widget
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main app'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login/',
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text(' Logout'),
                ),
              ];
            },
          )
        ],
      ),
      body: const Text('Hello World'),
    );
  }
}

//shows dialog that asks you whether you are sure you wan tto logout or not
Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign out'), //the title
        content: const Text(
            'Are you sure you want to sign out?'), // the question written in the dialog
        actions: [
          //the actions which are the buttons
          TextButton(
            //cancel button
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            //logout button
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Logout'),
          ),
        ],
      );
    },
  ).then(
      (value) => value ?? false); //incase you want to cancel the whole process
}
