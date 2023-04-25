import 'dart:ui' as ui;

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:directed_graph/directed_graph.dart';
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

class NewMapsView extends StatefulWidget {
  const NewMapsView({super.key});

  @override
  State<NewMapsView> createState() => _NewMapsViewState();
}

class _NewMapsViewState extends State<NewMapsView> {
  //initialize lists to get nodesWeights and nodes and store selectableNodes
  //in separate variable
  List<NodesModel> allNodes = [];
  List<WeightsModel> nodesWeights = [];
  List<RouteMapModel> routeMaps = [];
  List<RoutePointsModel> pointsInBetween = [];
  List<String> selectableDestinations = [];
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
  bool isLoading = true;
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
      List<WeightsModel> weights =
          await _localDBhelper.getNodesWeightsForOneNode(allNodes[j].name!);
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

    isLoading = false;
    //storeLightestPaths();

    //await storeLightestPath(selectableDestinations);

    return listOfPointsInBetween;
  }

  storeLightestPathAndPointsInBetween() async {
    var startLocation = '', destination = '';
    for (int j = 0; j < selectableDestinations.length; ++j) {
      for (int i = 0; i < selectableDestinations.length; ++i) {
        startLocation = selectableDestinations[j];
        destination = selectableDestinations[i];
        //take into consideration condition where thedestination and start point are both the same
        if ((startLocation != destination)) {
          //get weight and lightest path
          var lightestPath = graph.lightestPath(startLocation, destination);
          var weightOfLightestPath = graph.weightAlong(lightestPath);

          //the path is only drawn one directionalso it avoids replication which would appear as 0
          if (weightOfLightestPath == 0) {
            String transition = '';
            transition = startLocation;
            startLocation = destination;
            destination = transition;

            //calculat6e lightesdt weight and lightestPath
            lightestPath = graph.lightestPath(startLocation, destination);
            weightOfLightestPath = graph.weightAlong(lightestPath);
          }

          //for two selectable destinations see if the path exists in database
          var journeyNameToGetWeight = 'From $startLocation to $destination';
          devtools.log('journey name= $journeyNameToGetWeight');

          //try to get the data to see if the route already exists
          var getMapInfo = await _localDBhelper
              .getRouteMapsForOneJourney(journeyNameToGetWeight);

          //get the route points for this journey
          var getPointsInfo = await _localDBhelper
              .getRoutePointsForOneJourney(journeyNameToGetWeight);

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
              var updateWeightCount =
                  await _localDBhelper.updateRoutePoints(updatedPoints);

              counter++;
            }
            return counter;
          }

          //if data exists update it
          if (getMapInfo.isNotEmpty) {
            devtools.log(' lightest path= $lightestPath');
            //devtools.log(' lightest path length= ${lightestPath.length}');
            int counterOutsideLoop = 0;

            //if the new and old data have the same length
            if (lightestPath.length == getPointsInfo.length) {
              //implement the function updateRoutePoints
              newRoutePoints(getPointsInfo);
            }
            //if new data has a greater length than old data
            else if (lightestPath.length > getPointsInfo.length) {
              //countinue the counter outside the loop after done updating exisiting loops
              counterOutsideLoop = await newRoutePoints(getPointsInfo);

              devtools.log(' count outside of loop= $counterOutsideLoop');
              devtools
                  .log(' count length of points info= ${getPointsInfo.length}');
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
                        location1: selectableDestinations[j],
                        location2: selectableDestinations[i],
                        points: lightestPath[counterOutsideLoop],
                        position: (counterOutsideLoop + 1),
                        journeyName: journeyNameToGetWeight);
                //devtools.log('here after addition');
                //implement the new point into the local database
                var addedRoutePoint = _localDBhelper.addRoutePointsInFirebase(
                    updateRouteWithNewPointsInBetween);

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
                devtools
                    .log(' count of deleted route points = $deletedCounter');
                counterOutsideLoop++;
              }
            }
            //}
            for (int t = 0; t < getMapInfo.length; ++t) {
              // devtools.log(
              //     'weight of lightest path from the database= ${getMapInfo[t].totalWeight}');
              //updating the journey weight
              getMapInfo[t].totalWeight = weightOfLightestPath;
              //storing it in a variable
              var updatedWeight = getMapInfo[t];
              //updating
              var updateWeightCount =
                  await _localDBhelper.updateRouteMap(updatedWeight);
              //  devtools.log(
              //      'weight of lightest path from the database= ${getWeight[t].totalWeight!}');
              // devtools.log(
              //     'updated weight count from the database= $updateWeightCount');
            }
          }

          if (getMapInfo.isEmpty) {
            //add route if it does not exist in database
            RouteMapModel newRoute = RouteMapModel(
              location1: selectableDestinations[j],
              location2: selectableDestinations[i],
              weightClass: 1,
              totalWeight: weightOfLightestPath,
              isKnown: 1,
              journeyName: journeyNameToGetWeight,
              mapName: 'nothing',
              maps: 'none yet',
            );
            var addedRoutes = _localDBhelper.addRouteMapsInFirebase(newRoute);

            devtools.log('Here It Is');
            // devtools.log('added route count from the database= $addedRoutes');
            // MAYBBE SET A COUNTER FOR THE ROUTESSSS
          }
        }
      }

      if (startLocation == destination) {
        devtools.log(
            'skipped as the destination and starting location are the same');
      }
      devtools.log('new destination');
    }
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
    await storeLightestPathAndPointsInBetween();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
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
          const SizedBox(
            width: 500,
            height: 60,
            child: CustomPaint(
                //paint
                // painter: LocationCircles(),
                ),
          ),
        ],
      ),
    );
  }
}

//draws circles and lines
class LocationCircles extends CustomPainter {
  late List<NodesModel> coordinates;

  LocationCircles(this.coordinates);

//override the paint function with the data and functions to paint
  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = ui.PointMode.polygon; // drawing as a polygon
    List<Offset> points = [];
    for (int i = 0; i < coordinates.length; ++i) {
      var coordinatesOffset =
          Offset(coordinates[i].x!.toDouble(), coordinates[i].y!.toDouble());
      points.add(coordinatesOffset);
      //  points = [
      //   //the points the line will draw in between
      //   Offset(650, 180), //22
      //   Offset(645, 171), //Y101
      //   Offset(633, 156), //Y102
      //   Offset(635, 170), //W101
      //   Offset(626, 192), //W102
      //   Offset(614, 202), //W103
      //   Offset(607, 218), //W104
      //   Offset(615, 232), //W105
      //   Offset(624, 252), //W106
      //   Offset(622, 260), //W107
      //   Offset(623, 262), //W201
      //   Offset(635, 266), //W301
      //   Offset(650, 254), //57
      //   // Offset(651, 269), //24
      //   //Offset(656, 280), //23
      //   //Offset(636, 282), //20
      //   //Offset(596, 280), //56
      //   //Offset(531, 272), //M
      //   //Offset(559, 152), //L
      //   //Offset(575, 163), //19
      //   //Offset(575, 246), //18
      //   //Offset(533, 326), //16
      // ];
    }

    var paint1 = Paint()
      ..color = const Color.fromARGB(255, 107, 14, 14)
      //..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    // ..StrokeJoin = StrokeJoin.round;
    //PaintingStyle.fill;

    canvas.drawCircle(const Offset(533, 326), 6, paint1); //draw circle
    canvas.drawPoints(pointMode, points, paint1); // draw line between points
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
