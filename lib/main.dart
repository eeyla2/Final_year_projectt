//import 'package:material_floating_search_bar/material_floating_search_bar.dart';
//import 'package:graphs/graphs.dart';
//import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legsfree/firebase_options.dart';
import 'package:legsfree/views/Login_view.dart';
import 'package:legsfree/views/Register_view.dart';
import 'package:legsfree/views/Verify_email_view.dart';
import 'package:directed_graph/directed_graph.dart';

import 'constants/routes.dart';
//import 'ovals_painter.dart';
//import 'package:floating_search_bar/floating_search_bar.dart';

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
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          mainRoute: (context) => const MainView(),
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
//initialize variables
  final a = 'a';
  final b = 'b';
  final c = 'c';
  final d = 'd';
  final e = 'e';
  final f = 'f';
  final g = 'g';
  final h = 'h';
  final i = 'i';
  final k = 'k';
  final l = 'l';
  List<String> shortestPath = [];

//initialize comparator variable
  int comparator(
    String s1,
    String s2,
  ) {
    return s1.compareTo(s2);
  }

//initialize sum variable
  int sum(int left, int right) => left + right;

  var graph = WeightedDirectedGraph<String, int>(
    {},
    summation: (int a, int b) => a + b,
    zero: 0,
    comparator: (String a, String b) => a.compareTo(b),
  );

//override built-in function initState
  @override
  void initState() {
    super.initState();

    graph = WeightedDirectedGraph<String, int>(
      {
        a: {b: 1, h: 7, c: 2, e: 40, g: 7},
        b: {h: 6},
        c: {h: 5, g: 4},
        d: {e: 1, f: 2},
        e: {g: 2},
        f: {i: 3},
        i: {l: 3, k: 2},
        k: {g: 4, f: 5},
        l: {l: 0}
      },
      summation: sum,
      zero: 0,
      comparator: comparator,
    );

    shortestPath = graph.shortestPath(d, l);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'Main Page'), // have to change it so that it is at the bottom and has gadgets
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
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
      body: Column(
        children: [
          Image.asset(
            'images/map.png',
          ),
          SizedBox(
            width: 400,
            height: 400,
            child: CustomPaint(
              painter: LocationCircles(),
            ),
          ),
        ],
      ),
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

class LocationCircles extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = const Color(0xff885599)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(200, 100), 5, paint1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
