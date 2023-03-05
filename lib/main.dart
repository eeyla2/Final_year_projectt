//import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:legsfree/firebase_options.dart';
import 'package:legsfree/views/Login_view.dart';
import 'package:legsfree/views/Register_view.dart';
import 'package:legsfree/views/Verify_email_view.dart';
import 'package:directed_graph/directed_graph.dart';
import 'package:path/path.dart';
import 'constants/routes.dart';
import 'dart:developer' as devtools show log;
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

/*
class NetworkConnectivity {
  NetworkConnectivity();

  void checkConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      );

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        devtools.log(
          'connected',
        );
      }
    } on SocketException catch (_) {
      devtools.log('not connected');
    }
  }
}
*/
//mainview widget
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

//draws circles and lines
class LocationCircles extends CustomPainter {
  //override the paint function with the data and functions to paint
  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = ui.PointMode.polygon; // drawing as a polygon
    const points = [
      //the points the line will drawe in between
      Offset(50, 100),
      Offset(150, 75),
      Offset(250, 250),
      Offset(130, 200),
      Offset(270, 100),
    ];
    var paint1 = Paint()
      ..color = const Color.fromARGB(255, 107, 14, 14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(200, 100), 5, paint1); //draw circle
    canvas.drawPoints(pointMode, points, paint1); // draw line between points
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

//finding location
Future initLocationServices() async {
//create location instance
  var location = Location();

//check if location services are enabled
  if (!await location.serviceEnabled()) {
    if (!await location.requestService()) {
      return devtools.log('Service Not Enabled');
    }
  }

//check that the permission for usage is given
  var permission = await location.hasPermission();
  if (permission == PermissionStatus.denied) {
    permission = await location.requestPermission();
    if (permission != PermissionStatus.granted) {
      return devtools.log('Permission not granted');
    }
  }

  location.enableBackgroundMode(enable: true);

//might not need

//output current lcoation to debug console
  var loc = await location.getLocation();
  devtools.log('${loc.latitude} ${loc.longitude}');

//get changing location
  location.onLocationChanged.listen(
    (LocationData currentLocation) {
      // Use current location
      //_locationData = currentLocation;
      devtools.log('${currentLocation.latitude} ${currentLocation.longitude}');
    },
  );
}






/*
class NetworkConnectivity {
  NetworkConnectivity._(); //constructor that is private to the class only

  static final _instance = NetworkConnectivity._(); //empty contructor
  static NetworkConnectivity get instance =>
      _instance; //store instance instead of empty contructor

  /// [Connectivity] is designed to work as a singleton.
  // When a second instance is created, the first instance will not be able to listen to the
  // EventChannel because it is overridden. Forcing the class to be a singleton class can prevent
  // misuse of creating a second instance from a programmer.
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast(); //controlls a stream
  Stream get myStream =>
      _controller.stream; //a stream instance out of the stream controller

  //check internet status
  void _checkStatus(ConnectivityResult result) async {
    bool isOnline =
        false; //set the variable up as false; this variable asks the question of whether there is internet connectivity

    //check for error of non-working socket
    try {
      // try setting up internet connection

      final result = await InternetAddress.lookup(
          'example.com'); //it looks up an internet host and tries to connect to it to make sure the internet has really connected
      isOnline = result.isNotEmpty &&
          result[0]
              .rawAddress
              .isNotEmpty; //is supposed to store true inside the variable
    } on SocketException catch (_) {
      //handle the potential error

      isOnline = false; //keep variable as false
    }
    _controller.sink.add({result: isOnline});
  }

  //initialization
  void initialise() async {
    ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    _checkStatus(result); //check result of the connnectivity

    //when connectivity of result is changed the new connectivity is printed
    ////and the check function is done again
    _networkConnectivity.onConnectivityChanged.listen(
      (result) {
        devtools.log(result.toString());
        _checkStatus(result);
      },
    );
  }

  void disposeStream() => _controller.close(); //closes Streamcontroller
}

class ConnectionCheckerDemo extends StatefulWidget {
  const ConnectionCheckerDemo({Key? key}) : super(key: key);

  @override
  State<ConnectionCheckerDemo> createState() => _ConnectionCheckerDemoState();
}

class _ConnectionCheckerDemoState extends State<ConnectionCheckerDemo> {
// Variables hold the connectivity type and its status
  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  String string = '';

//override init state of this statefeul
  @override
  void initState() {
    super.initState();

    _networkConnectivity.initialise(); //initialize connection
    _networkConnectivity.myStream.listen(
      (source) {
        _source = source; //store connection status
        devtools.log('source $_source');

        //going through the different formas of connections
        switch (_source.keys.toList()[0]) {
          case ConnectivityResult
              .mobile: //if the connection is connected to a cellular network
            string = _source.values.toList()[0]
                ? 'Mobile: Online'
                : 'Mobile: Offline'; //check if it's online of offline
            break;

          case ConnectivityResult
              .wifi: //if the connection is connected to a Wifi
            string = _source.values.toList()[0]
                ? 'WiFi: Online'
                : 'WiFi: Offline'; //check if it's online of offline
            break;

          case ConnectivityResult.none: //if it's not connected to anything
          default:
            string = 'Offline';
        }

        //refreshes pagew to set the connection status text
        setState(
          () {},
        );

        //snackbar with the latest connection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              string,
              style: const TextStyle(fontSize: 30),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xff6ae792),
      ),
      body: Center(
        child: Text(
          string,
          style: const TextStyle(fontSize: 54),
        ),
      ),
    );
  }
}
*/
