import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:directed_graph/directed_graph.dart';
import 'package:legsfree/models/nodes_model.dart';
import 'package:legsfree/models/route_map.dart';
import 'package:legsfree/models/route_points.dart';
import 'package:legsfree/models/weights.dart';
import 'package:legsfree/services/crud/main_services.dart';
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

    for (int j = 0; j < selectableDestinations.length; ++j) {
      //devtools.log('Selectable Destinations = ${selectableDestinations}');
    }
  }

  // GETTING ALL NODES WEIGHTS
  getAllNodesWeights() async {
    nodesWeights = await _localDBhelper.getWeights();
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
        graph.addEdge(
          weights[i].node1!,
          weights[i].node2!,
          weights[i].weight!,
        );
      }
    }

    List<String> listOfPointsInBetween =
        graph.lightestPath('Physics Building', 'Student Services');
    //devtools.log('LIST OF POINTS ${listOfPointsInBetween}');

    // graph.data.forEach((key, value) {
    //   devtools.log('$key and $value');
    // });

    isLoading = false;
    //storeLightestPaths();

    return listOfPointsInBetween;
  }

  storeLightestPath() async {
    //nested loops that calculate the lightestpath between one destination and all the others.
    for (int j = 0; j < selectableDestinations.length; ++j) {
      for (int i = 0; i < selectableDestinations.length; ++i) {
        if ((selectableDestinations[j] != selectableDestinations[i])) {
          //
          //get weight and lightest path
          var lightestPath = graph.lightestPath(
              selectableDestinations[j], selectableDestinations[i]);
          var weightOfLightestPath = graph.weightAlong(lightestPath);
          //devtools.log('weight of lightest path = ${weightOfLightestPath}');
        }
      }
    }
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
    await initializeGraph();
    await storeLightestPath();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('map route'),
      ),
      // body: FutureBuilder(
      //     future: initializeGraph(),
      //     builder: (context, snapshot) {
      //       switch (snapshot.connectionState) {
      //         case ConnectionState.done:
      //           //lightestPath = snapshot.data as List<String>;
      //           return Stack(
      //             children: <Widget>[
      //               Text(
      //                   '\nLightest path a -> $lightestPath , weight: ${graph.weightAlong(lightestPath)}'),
      //               Text(nodesWeights.toString()),
      //             ],
      //           );

      //         default:
      //           return const CircularProgressIndicator();
      //       }
      //     }),
    );
  }
}

//draws circles and lines
class LocationCircles extends CustomPainter {
  //override the paint function with the data and functions to paint
  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = ui.PointMode.polygon; // drawing as a polygon
    const points = [
      //the points the line will draw in between
      Offset(650, 180), //22
      Offset(645, 171), //Y101
      Offset(633, 156), //Y102
      Offset(635, 170), //W101
      Offset(626, 192), //W102
      Offset(614, 202), //W103
      Offset(607, 218), //W104
      Offset(615, 232), //W105
      Offset(624, 252), //W106
      Offset(622, 260), //W107
      Offset(623, 262), //W201
      Offset(635, 266), //W301
      Offset(650, 254), //57
      // Offset(651, 269), //24
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
    canvas.drawCircle(const Offset(533, 326), 6, paint1); //draw circle
    canvas.drawPoints(pointMode, points, paint1); // draw line between points
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
