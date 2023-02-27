import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legsfree/firebase_options.dart';
import 'package:legsfree/views/Login_view.dart';
import 'package:legsfree/views/Register_view.dart';
import 'package:legsfree/views/Verify_email_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.dart' as locations;
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

//location class with properties
class Location {
  final int id;
  final String name;
  final LatLng coordinates; //latitude and longitude variable

//constructor
  Location({required this.id, required this.name, required this.coordinates});
}

//create a weighted graph that can calculate the shortest path using djikstra's algorithm
class WeightedDirectedGraph {
  //a Map with the key being an int and the variable a Map with has an int map and an int variable
  Map<int, Map<int, int>> graph = {};

//fucntion that adds vertex if the vertex does not already exist
  void addVertex(int vertex) {
    if (!graph.containsKey(vertex)) {
      graph[vertex] = {};
    }
  }

//function that adds edge by assigning a start, end and a weight for that edge
  void addEdge(int start, int end, int weight) {
    if (!graph.containsKey(start)) {
      addVertex(start);
    }
    if (!graph.containsKey(end)) {
      addVertex(end);
    }
    graph[start]![end] =
        weight; //might want to say ?. instead of ! not sure yet
  }

//list that calculates shortest path using djikstra's algorithm
  List<int> shortestPath(int start, int end) {
    var distances = {start: 0};
    var visited = {};
    var previous = {};
    var queue = [start];

    while (queue.isNotEmpty) {
      var current = queue.removeAt(0);
      visited[current] = true;

      for (var neighbor in graph[current]!.keys) {
        var distance = graph[current]![neighbor];
        var totalDistance = (distances[current] ?? 0) + distance!;

        if (!distances.containsKey(neighbor) ||
            totalDistance < distances[neighbor]!) {
          distances[neighbor] = totalDistance;
          previous[neighbor] = current;
        }

        if (!visited.containsKey(neighbor)) {
          queue.add(neighbor);
        }
      }
    }

    var path = [end];
    var current = end;
    while (current != start) {
      current = previous[current]!;
      path.insert(0, current);
    }

    return path;
  }
}

//mainview widget
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();

    setState(
      () {
        _markers.clear();
        for (final office in googleOffices.offices) {
          final marker = Marker(
            markerId: MarkerId(office.name),
            position: LatLng(office.lat, office.lng),
            infoWindow: InfoWindow(
              title: office.name,
              snippet: office.address,
            ),
          );
          _markers[office.name] = marker;
        }
      },
    );
  }

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
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
        markers: _markers.values.toSet(),
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

/*
class RoutingApp extends StatefulWidget {
  const RoutingApp({super.key});
  @override
  State<RoutingApp> createState() => _RoutingAppState();
}

class _RoutingAppState extends State<RoutingApp> {
  late GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  final List<LatLng> _path = [];

  // ignore: prefer_final_fields
  static CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 12,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _addMarker(LatLng location, String markerId) {
    final marker = Marker(
      markerId: MarkerId(markerId),
      position: location,
    );
    setState(
      () {
        _markers.add(marker);
      },
    );
  }

  void _addPolyline(LatLng start, LatLng end, String polylineId) {
    final id = PolylineId(polylineId);
    final polyline = Polyline(
      polylineId: id,
      points: [_path.isEmpty ? start : _path.last, end],
      color: Colors.blue,
      width: 5,
    );
    _path.add(end);
    setState(
      () {
        _polylines[id] = polyline;
      },
    );
  }

  void _clearMarkers() {
    setState(() {
      _markers.clear();
    });
  }

  void _clearPolylines() {
    setState(
      () {
        _polylines.clear();
        _path.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routing App'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: _initialCameraPosition,
        markers: _markers,
        polylines: Set<Polyline>.of(_polylines.values),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _clearMarkers,
            tooltip: 'Clear markers',
            child: const Icon(Icons.clear),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _clearPolylines,
            tooltip: 'Clear polylines',
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
*/