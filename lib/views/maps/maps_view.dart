//mainview widget

import 'dart:async';
//import 'dart:math';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legsfree/services/auth/auth_service.dart';
import 'package:legsfree/services/crud/main_services.dart';
import 'dart:developer' as devtools show log;
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/scheduler.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../main.dart';

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

//get the current signed in user email
  late final MainService _mainService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

//override built-in function initState
  @override
  void initState() {
    //open database

    _mainService = MainService();
    _mainService.open();

//initialize location services
    initLocationServices();

//connectivity
    connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    devtools.log(
      'Connection Status: ${connectionStatus.toString()}',
    );
    super.initState();
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    _mainService.close();
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.route_outlined),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logOut();
                    // Wrap Navigator with SchedulerBinding to wait for rendering state before navigating
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        loginRoute,
                        (_) => false,
                      );
                    });
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
      body: FutureBuilder(
        future: _mainService.getOrCreateUser(theemail: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _mainService.allNodes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      return spinkit2;
                    default:
                      return SingleChildScrollView(
                        //scroll widget
                        child: Column(
                          children: [
                            Stack(
                              //fit: StackFit.expand,
                              //stack widgets on top of each other
                              children: <Widget>[
                                Image.asset(
                                  //loads an image on to the app
                                  'images/map.png',
                                ),
                                const SizedBox(child: Text('no route')),
                                // SizedBox(
                                //a box of dimensions 400x400 and an x-y scale of 200 starting from the top left and going downwards and right
                                //  width: 400,
                                // height: 400,
                                // child: CustomPaint(
                                //paint
                                //   painter: LocationCircles(),
                                //),
                                //),
                                //buildFloatingSearchBar(context),
                              ],
                            ),
                          ], //children
                        ),
                      );
                  }
                },
              );

            default:
              return spinkit1;
          }
        },
      ),
    );
  }
}

//Widget searchBarUI() {

//  final isPortrait = MediaQuery.of(context).orientation = Orientation.portrait;

//return FloatingSearchBar(
//  hint: 'Searching.....',
//openAxisAlignment: 0.0,
//maxwidth: 600,
// axisalignment: 0.0,
// scrollPadding: const EdgeInsets.only(top: 16, bottom: 20),
//elevation: 4.0,
//onQueryChanged: (query) {},
//showDrawerHamburger: false,
//transitionCurve: Curves.easeInOut,
//transitionDuration: const Duration(milliseconds: 500),
//transition: CircularFloatingSearchBarTransition(),
//debounceDelay: const Duration(milliseconds: 500),
//actions: const [
// FloatingSearchBarAction(
//  showIfClosed: false,
//child: CircularButton(icon: null, onPressed: null),
//),
//],
//builder: (BuildContext context, Animation<double> transition) {  },);
//}

const spinkit1 = SpinKitSpinningLines(
  color: Colors.black,
  size: 50.0,
);

const spinkit2 = SpinKitSpinningLines(
  color: Colors.blue,
  size: 50.0,
);

Widget buildFloatingSearchBar(BuildContext context) {
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

  return FloatingSearchBar(
    hint: 'Search...',
    scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
    transitionDuration: const Duration(milliseconds: 800),
    transitionCurve: Curves.easeInOut,
    physics: const BouncingScrollPhysics(),
    axisAlignment: isPortrait ? 0.0 : -1.0,
    openAxisAlignment: 0.0,
    width: isPortrait ? 600 : 500,
    //height: double.infinity,
    debounceDelay: const Duration(milliseconds: 500),
    onQueryChanged: (query) {
      // Call your model, bloc, controller here.
    },
    // Specify a custom transition to be used for
    // animating between opened and closed stated.
    transition: CircularFloatingSearchBarTransition(),
    actions: [
      FloatingSearchBarAction(
        showIfOpened: false,
        child: CircularButton(
          icon: const Icon(Icons.place),
          onPressed: () {},
        ),
      ),
      FloatingSearchBarAction.searchToClear(
        showIfClosed: false,
      ),
    ],
    builder: (context, transition) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.white,
          elevation: 4.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Colors.accents.map((color) {
              return Container(height: 112, color: color);
            }).toList(),
          ),
        ),
      );
    },
  );
}
