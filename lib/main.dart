//import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'dart:async';
//import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:legsfree/error_handling/error_handler.dart';
import 'package:legsfree/services/auth/auth_service.dart';
import 'package:legsfree/views/maps/double_search_bar._view.dart';
import 'package:legsfree/views/maps/maps_view.dart';
import 'package:legsfree/views/maps/new_maps_view.dart';
import 'package:location/location.dart';
//import 'package:flutter/foundation.dart';
//import 'package:legsfree/firebase_options.dart';
import 'package:legsfree/views/login_view.dart';
import 'package:legsfree/views/register_view.dart';
import 'package:legsfree/views/verify_email_view.dart';
import 'constants/routes.dart';
import 'dart:developer' as devtools show log;

//import 'package:floating_search_bar/floating_search_bar.dart';

//import 'dart:developer' as devtools show log;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    //place MaterialApp in here for effeciency instead of using MyApp widget
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),

        //HomePage(),
        routes: {
          //mapping different routes
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          mapsRoute: (context) => const MainView(),
          verifyEmailRoute: (context) => const VerifyEmailView(),
          newMapsRoute: (context) => const NewMapsView(),
          doubleSearchBarRoute: (context) => const DoubleSearchBarView(),
        }),
  );
}

//homepage widget to separate the initialization process from login and register process
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        //initializes application for the currentplatform in use
        //initiallization process
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          //builds once app is initialized
          //connection
          switch (snapshot.connectionState) {
            case ConnectionState.done: //if connected successfully
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  //if user has been entered and email is verified return mainview
                  return const
                      //NewMapsView();
                      MainView();
                } else {
                  //if not show the verifyemailview page
                  return const VerifyEmailView();
                }
              } else {
                //if user not entered show loginview and from there you can go to registerview if you want
                return const LoginView();
              }
            //return const Text('done');
            default: //in all other cases
              return const CircularProgressIndicator(); //if the app is not connected yet show a circular indicator
          }
        },
      ),
    );
  }
}

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
