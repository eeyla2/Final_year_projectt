//mainview widget

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legsfree/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;

import '../constants/routes.dart';
import '../enums/menu_action.dart';
import '../main.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
//connectivity variables
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> connectivitySubscription;

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

    initLocationServices();
    //have to have it's own class
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
        l: {l: 0},
      },
      summation: sum,
      zero: 0,
      comparator: comparator,
    );

//calculate shortest path
    shortestPath = graph.shortestPath(d, l);

//connectivity
    connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    devtools.log(
      'Connection Status: ${connectionStatus.toString()}',
    );
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      devtools.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, //helps change the gadegst to fit in case other widgets appear
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
                    await AuthService.firebase().logOut();
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
      body: SingleChildScrollView(
        //scroll widget
        child: Column(
          children: [
            Stack(
              //stack widgets on top of each other
              children: <Widget>[
                Image.asset(
                  //loads an image on to the app
                  'images/map.png',
                ),
                SizedBox(
                  //a box of dimensions 400x400 and an x-y scale of 200 starting from the top left and going downwards and right
                  width: 400,
                  height: 400,

                  child: CustomPaint(
                    //paint
                    painter: LocationCircles(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
