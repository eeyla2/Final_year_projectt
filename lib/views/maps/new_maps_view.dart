import 'dart:ui' as ui;

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:directed_graph/directed_graph.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:legsfree/models/nodes_model.dart';
import 'package:legsfree/models/route_map.dart';
import 'package:legsfree/models/route_points.dart';
import 'package:legsfree/models/weights.dart';
// import 'package:legsfree/services/crud/crud_exceptions.dart';
// import 'package:legsfree/services/crud/main_services.dart';
import 'package:legsfree/services/local%20db%20helper/local_db_helper.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'dart:async';

import 'package:screenshot/screenshot.dart';

class NewMapsView extends StatefulWidget {
  const NewMapsView(
      {super.key,
      required this.destination,
      required this.startLocation,
      required this.weightClass});
  final String startLocation, destination;
  final int weightClass;
  @override
  State<NewMapsView> createState() => _NewMapsViewState();
}

class _NewMapsViewState extends State<NewMapsView> {
  //SCREEN SHOT CONTROLLER
  final ScreenshotController _screenshotController = ScreenshotController();
  //initialize lists to get nodesWeights and nodes and store selectableNodes
  //in separate variable
  List<NodesModel> allNodes = [];
  List<WeightsModel> nodesWeights = [];
  List<RouteMapModel> routeMaps = [];
  List<RoutePointsModel> pointsInBetween = [];
  List<String> selectableDestinations = [];
  bool isLoading = true;
  List<Offset> coordinates = [];
  bool isUpdatedOrAddedMap = false;
  int totalWeight = 0;
  String databaseMap = '';
  //LOCAL DB HELPER
  final LocalDBhelper _localDBhelper = LocalDBhelper();
  //GETTING ALL NODES
  getAllNodes() async {
    allNodes = await _localDBhelper.getNodes();
    //variable to store selectable destinations

//for loop that goes through all nodes
    for (int j = 0; j < allNodes.length; ++j) {
      //if node is selectable store it inside a selectableDestination variable
      if (allNodes[j].isSelectable! == 1) {
        selectableDestinations.add(allNodes[j].name!);
      }
      //print('Selectable Destinations = ${selectableDestinations.length}');
    }
    //devtools.log('Selectable Destinations = ${selectableDestinations.length}');

    // for (int j = 0; j < selectableDestinations.length; ++j) {
    //   //devtools.log('Selectable Destinations = ${selectableDestinations}');
    // }
  }

// GETTING ALL NODES WEIGHTS
  getAllNodesWeights() async {
    nodesWeights = await _localDBhelper.getWeights();
    //devtools.log('Total nodes weights = ${nodesWeights.length}');
  }

  // GETTING ALL NODES WEIGHTS
  getAllRouteMaps() async {
    routeMaps = await _localDBhelper.getRouteMap();
    //devtools.log('Total nodes weights = ${nodesWeights.length}');
  }

// GETTING ALL NODES WEIGHTS
  getAllPointsInBetween() async {
    pointsInBetween = await _localDBhelper.getRoutePoints();
    //await _localDBhelper.deleteAllDataFromTable('route_points', true);
    //devtools.log('Total nodes weights = ${nodesWeights.length}');
  }

  //initialize sum variable for graph
  int sum(int left, int right) => left + right;

//initialize weighted graph before inserting variables into it
  var graph = WeightedDirectedGraph<String, int>(
    {},
    summation: (int a, int b) => a + b,
    zero: 0,
    comparator: (String a, String b) => a.compareTo(b),
  );

//#######################get the nodes somewhere around here############################

//variable to indicate the futures are done when set to false

  //variable to display the listOfPointsinBetween two destinations
  //List<String> listOfPointsInBetween = []; //it will have the result

//initialize comparator variable
  int comparator(
    String s1,
    String s2,
  ) {
    return s1.compareTo(s2);
  }

//INITIALIZING GRAPH WITH DATA
  Future<List<String>> initializeGraph() async {
//make sure the node weight for a specific node to all its connections have been extracted with first loop
    for (int j = 0; j < allNodes.length; ++j) {
      List<WeightsModel> weights = await _localDBhelper
          .getNodesWeightsForOneNode(allNodes[j].name!, widget.weightClass);
      //make sure all nodes weight for node used in the first loop are inserted into second loop
      for (int i = 0; i < weights.length; ++i) {
        if (weights[i].weight != null) {
          graph.addEdge(
            weights[i].node1!,
            weights[i].node2!,
            weights[i].weight!,
          );
        } else {
          devtools.log('${weights[i].node1} has no connections');
        }
      }
    }

    List<String> listOfPointsInBetween =
        graph.lightestPath('Physics Building', 'Student Services');
    // devtools.log('LIST OF POINTS ${listOfPointsInBetween}');

    graph.data.forEach((key, value) {
      devtools.log('$key and $value');
    });

    //storeLightestPaths();

    //await storeLightestPath(selectableDestinations);

    return listOfPointsInBetween;
  }

  storeLightestPathAndPointsInBetween(
      String startLocation, String destination) async {
    print('CHECK NEW MAPS $startLocation $destination');
    //take into consideration condition where thedestination and start point are both the same
    if ((startLocation != destination)) {
      //get weight and lightest path
      var lightestPath = graph.lightestPath(startLocation, destination);

      var weightOfLightestPath = graph.weightAlong(lightestPath);
      totalWeight = weightOfLightestPath;
      devtools.log('TOTAL WEIGHT $weightOfLightestPath');
      //the path is only drawn one directionalso it avoids replication which would appear as 0
      // if (weightOfLightestPath == 0) {
      //   String transition = '';
      //   transition = startLocation;
      //   startLocation = destination;
      //   destination = transition;
      //   //calculat6e lightesdt weight and lightestPath
      //   lightestPath = graph.lightestPath(startLocation, destination);
      //   weightOfLightestPath = graph.weightAlong(lightestPath);
      // }

      //for two selectable destinations see if the path exists in database
      var journeyNameToGetWeight = 'From $startLocation to $destination';
      devtools.log('journey name= $journeyNameToGetWeight');

      //try to get the data to see if the route already exists

      //get the route points for this journey
      var getPointsInfo = await _localDBhelper.getRoutePointsForOneJourney(
          journeyNameToGetWeight, widget.weightClass);

      newRoutePoints(List item) async {
        int counter = 0;
        for (int y = 0; y < item.length; ++y) {
          //updating the journey weight
          getPointsInfo[y].points = lightestPath[counter];
          getPointsInfo[y].position = (counter + 1);
          devtools.log('when is it stopping = $counter');
          //storing it in a variable
          var updatedPoints = getPointsInfo[y];

          // devtools.log(
          //     'points of lightest path from the database= ${updatedPoints.points}');
          //updating

          await _localDBhelper.updateRoutePoints(updatedPoints);

          counter++;
        }
        return counter;
      }

      //if data exists update it
      if (getPointsInfo.isNotEmpty) {
        devtools.log(' lightest path= $lightestPath');
        //devtools.log(' lightest path length= ${lightestPath.length}');
        int counterOutsideLoop = 0;

        //if the new and old data have the same length
        if (lightestPath.length == getPointsInfo.length) {
          for (int i = 0; i < lightestPath.length; i++) {
            if (lightestPath[i] != getPointsInfo[i].points) {
              //UPDATE
              newRoutePoints(getPointsInfo);
              isUpdatedOrAddedMap = true;
              break;
            }
          }
          //implement the function updateRoutePoints
        }
        //if new data has a greater length than old data
        else if (lightestPath.length > getPointsInfo.length) {
          //UPDATE
          isUpdatedOrAddedMap = true;
          //countinue the counter outside the loop after done updating exisiting loops
          counterOutsideLoop = await newRoutePoints(getPointsInfo);

          devtools.log(' count outside of loop= $counterOutsideLoop');
          devtools.log(' count length of points info= ${getPointsInfo.length}');
          //devtools.log(
          //  'count outside of loop= ${lightestPath.length - counterOutsideLoop}');
          //devtools.log('here bro');
          int addedCounter = 0;
          for (int t = 0;
              t < (lightestPath.length - getPointsInfo.length);
              ++t) {
            //devtools.log('here inside for loop');
            //create a New point in between
            RoutePointsModel updateRouteWithNewPointsInBetween =
                RoutePointsModel(
                    location1: startLocation,
                    weightClass: widget.weightClass,
                    location2: destination,
                    points: lightestPath[counterOutsideLoop],
                    position: (counterOutsideLoop + 1),
                    journeyName: journeyNameToGetWeight);
            //devtools.log('here after addition');
            //implement the new point into the local database
            _localDBhelper
                .addRoutePointsInFirebase(updateRouteWithNewPointsInBetween);

            //LocalDBhelper.addRoutePointsInFirebase(
            //updateRouteWithNewPointsInBetween);
            //addedCounter += addedRoutePoint;
            //devtools.log('here when done');
            devtools.log('count of added route points = $addedCounter');
            counterOutsideLoop++;
            //increase counter
          }
        }
        //if new data is shorter than old data
        else if (lightestPath.length < getPointsInfo.length) {
          isUpdatedOrAddedMap = true;
          //continue counter outside loop after done updating existing loops
          //devtools.log('here cabron');
          counterOutsideLoop = await newRoutePoints(lightestPath);
          int deletedCounter = 0;

          for (int t = 0;
              t < (getPointsInfo.length - lightestPath.length);
              ++t) {
            //delet the rest of the points.
            var deletedRoutePoint = await _localDBhelper
                .deleteRoutePoints(getPointsInfo[counterOutsideLoop]);

            deletedCounter += deletedRoutePoint;
            devtools.log(' count of deleted route points = $deletedCounter');
            counterOutsideLoop++;
          }
        }
      }

      if (getPointsInfo.isEmpty) {
        isUpdatedOrAddedMap = true;
        //add route if it does not exist in database
        for (int i = 0; i < lightestPath.length; ++i) {
          RoutePointsModel routePointModel = RoutePointsModel(
              location1: widget.startLocation,
              weightClass: widget.weightClass,
              location2: widget.destination,
              points: lightestPath[i],
              position: i + 1,
              journeyName: journeyNameToGetWeight);
          _localDBhelper.addRoutePointsInFirebase(routePointModel);
        }

        devtools.log('Here It Is');
        // devtools.log('added route count from the database= $addedRoutes');
        // MAYBBE SET A COUNTER FOR THE ROUTESSSS
      }
    }

    if (startLocation == destination) {
      devtools
          .log('skipped as the destination and starting location are the same');
    }
    devtools.log('new destination');
  }

  renderPoints() async {
//
  }
//override built-in function initState
  @override
  void initState() {
    super.initState();
    getAllData();
  }

  getAllData() async {
    await getAllNodes();
    await getAllNodesWeights();
    await getAllPointsInBetween();
    await getAllRouteMaps();
    await initializeGraph();
    await storeLightestPathAndPointsInBetween(
        widget.startLocation, widget.destination);
    coordinates = await getCoordinates();
    setState(() {
      isLoading = false;
    });
    await getScreenshot();
    devtools.log('HELLO PRINT $isUpdatedOrAddedMap');
  }

//get the coordinates to draw the page
  Future<List<Offset>> getCoordinates() async {
    //variables declared
    List<NodesModel> nodes = [];
    List<Offset> coordinates = [];
    var journeyName = 'From ${widget.startLocation} to ${widget.destination}';

    //get route points for certain journey
    List<RoutePointsModel> routePoints = await _localDBhelper
        .getRoutePointsForOneJourney(journeyName, widget.weightClass);
    print('SCREENSHOT ROUTE POINTS ${routePoints.length}');

    //for loop that gets the nodes matching the route points for that root
    for (int i = 0; i < routePoints.length; i++) {
      await _localDBhelper
          .getNodesForOneNode(routePoints[i].points!)
          .then((value) {
        nodes.add(value[0]);
      });
    }
    print('SCREENSHOT NODES ${nodes.length}');

    //getting X and Y coordinates of those nodes
    for (int a = 0; a < nodes.length; a++) {
      coordinates.add(Offset(nodes[a].x!.toDouble(), nodes[a].y!.toDouble()));
    }
    devtools.log('NEW NODES ARE ${coordinates.length}');
    return coordinates;
  }

//takes screenshot of the image
  getScreenshot() async {
    try {
      //get maps for one route
      var journeyName = 'From ${widget.startLocation} to ${widget.destination}';
      List<RouteMapModel> maps = await _localDBhelper.getRouteMapsForOneJourney(
          journeyName, widget.weightClass);

      //if there is no map for that journey
      if (maps.isEmpty) {
        //url is stored
        final url =
            await uploadScreenshot('$journeyName ${widget.weightClass}');
        devtools.log('GET SCREENSHOT');
        print(url);

        //upload a new map with that screenshot
        RouteMapModel newRoute = RouteMapModel(
          location1: widget.startLocation,
          location2: widget.destination,
          weightClass: widget.weightClass,
          totalWeight: totalWeight,
          isKnown: 1,
          journeyName: journeyName,
          mapURL: url,
        );
        _localDBhelper.addRouteMapsInFirebase(newRoute);
      } else if (maps.isNotEmpty && isUpdatedOrAddedMap == true) {
        //if there is a map for that journey and routepoints were updated

        //new screenshot taken and url created
        final url = await uploadScreenshot(journeyName);
        devtools.log('GET SCREENSHOT');
        print(url);

        //change in values for the weight and url f the journey
        routeMaps[0].totalWeight = totalWeight;
        routeMaps[0].mapURL = url;

        //updated the route in firebase
        _localDBhelper.updateRouteMap(routeMaps[0]);
      }
      if (isUpdatedOrAddedMap == false) {
        //if the map is not updated or added
        //show image using the url
        databaseMap = maps[0].mapURL!;
        setState(() {});
      }
    } catch (e) {
      print(e);
    }
  }

//function to upload a screenshot
  Future<String?> uploadScreenshot(String mapName) async {
    //takes screenshot
    final image = await _screenshotController.capture();

    //gives file name the mapName which is the journey name and weight class
    final fileName = mapName;

    //returns location of the file
    final ref = FirebaseStorage.instance.ref().child('screenshots/$fileName');

//upload the image process
    final uploadTask = ref.putData(image!);

    //once the screenshot is uploaded upload it to firebase storage
    final snapshot = await uploadTask.whenComplete(() {});

    // a url to the photo is returned.
    return await snapshot.ref.getDownloadURL();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(coordinates);
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   foregroundColor: Colors.black,
        //   elevation: 0,
        //   centerTitle: true,

        // ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : databaseMap != ''
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 1,
                      child: Image.network(
                        databaseMap,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Screenshot(
                      controller: _screenshotController,
                      child: Stack(
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 1,
                            child: Image.asset(
                              'images/map.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          isUpdatedOrAddedMap == true
                              ? IgnorePointer(
                                  ignoring: true,
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height * 1,
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    child: CustomPaint(
                                      willChange: true,
                                      painter: NewMapsCircles(
                                          coordinates: coordinates),
                                      child: const SizedBox(),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ));
  }
}

//draws circles and lines
class NewMapsCircles extends CustomPainter {
  //override the paint function with the data and functions to paint
  NewMapsCircles({required this.coordinates});
  final List<Offset> coordinates;
  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = ui.PointMode.polygon; // drawing as a polygon

    var paint1 = Paint()
      ..color = const Color.fromARGB(255, 107, 14, 14)
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    //canvas.drawCircle(const Offset(533, 326), 6, paint1); //draw circle
    //canvas.drawCircle(const Offset(200, 100), 14, paint1); //draw circle
    canvas.drawPoints(
        pointMode, coordinates, paint1); // draw line between points
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
