//mainview widget
import 'dart:ui' as ui;
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
              return Stack(
                children: <Widget>[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    //scroll widget
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 1,
                      child: Image.asset(
                        //loads an image on to the app
                        'images/map.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 500,
                    height: 60,
                    //color: Colors.green,
                    child: buildFloatingSearchBar(context),
                  ),
                  SizedBox(
                    width: 500,
                    height: 60,
                    child: CustomPaint(
                      //paint
                      painter: LocationCircles(),
                    ),
                  ),
                ],
              );

            default:
              return spinkit2;
          }
        },
      ),
    );
  }
}

//pinkit with spinning Lines for loading page
const spinkit1 = SpinKitSpinningLines(
  color: Colors.black,
  size: 50.0,
);

//spinkit with spinninglines for second loading page
const spinkit2 = SpinKitSpinningLines(
  color: Colors.blue,
  size: 50.0,
);

//floating search bar implementation
Widget buildFloatingSearchBar(BuildContext context) {
  //get a query(info) about the current media orientation
  //and if it has an orientation of a portrait return true
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

//return a floating search bar
  return FloatingSearchBar(
    hint: 'Search destination', // text shown inside search bar
    //all the characterstics of searchh bar
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
      //implementation of the place icon in the search bar when it's pressed
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

//draws circles and lines
class LocationCircles extends CustomPainter {
  //override the paint function with the data and functions to paint
  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = ui.PointMode.polygon; // drawing as a polygon
    const points = [
      //the points the line will draw in between
      // Offset(650, 180), //22
      // Offset(645, 171), //Y101
      // Offset(633, 156), //Y102
      // Offset(635, 170), //W101
      // Offset(626, 192), //W102
      // Offset(614, 202), //W103
      // Offset(607, 218), //W104
      // Offset(615, 232), //W105
      // Offset(624, 252), //W106
      // Offset(622, 260), //W107
      // Offset(623, 262), //W201
      // Offset(635, 266), //W301
      // Offset(650, 254), //57
      // Offset(651, 269), //24
      Offset(450, 150), //57
      Offset(800, 500), //24
      //Offset(656, 280), //23
      //Offset(636, 282), //20
      //Offset(596, 280), //56
      //Offset(531, 272), //M
      //Offset(559, 152), //L
      //Offset(575, 163), //19
      //Offset(575, 246), //18
      //Offset(533, 326), //16
    ];
    var paint1 = Paint()
      ..color = const Color.fromARGB(255, 107, 14, 14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(533, 326), 14, paint1); //draw circle
    canvas.drawPoints(pointMode, points, paint1); // draw line between points
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
