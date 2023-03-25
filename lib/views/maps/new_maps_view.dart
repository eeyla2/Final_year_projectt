import 'dart:ui' as ui;

import '../../services/crud/main_services.dart';
import 'package:directed_graph/directed_graph.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'dart:async';

class NewMapsView extends StatefulWidget {
  const NewMapsView({super.key});

  @override
  State<NewMapsView> createState() => _NewMapsViewState();
}

class _NewMapsViewState extends State<NewMapsView> {
  DatabaseNodes? _initNode;
  late final MainService _mainService;

//gets all data from database
  Future<List<DatabaseNodesWeights>> getNodesWeightsAsList() async {
    final nodes = await _mainService.getAllNodesWeights();

    return nodes.toList();
  }

  //gets all data from database
  Future<List<DatabaseNodes>> getNodesAsList() async {
    final nodes = await _mainService.getAllNodes();

    List<DatabaseNodes> asList = [];
    for (int i = 0; i < nodes.length; ++i) {
      asList = nodes.toList();
      devtools.log(asList[i].toString());
    }
    return asList;
  }

//#######################get the nodes somewhere around here############################
  List<String> lightestPath = [];

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

  List<DatabaseNodesWeights> nodesWeights = [];

  List<DatabaseNodes> nodesAllInfo = [];

//initializing
  void initialize(List<String> listOfPointsInBetween) async {
    nodesWeights = await getNodesWeightsAsList();

    for (int i = 0; i < nodesWeights.length; ++i) {
      devtools.log(nodesWeights[i].node_1);
    }
    List<DatabaseNodes> nodesAllInfo = await getNodesAsList();

//make sure all the nodes have been extracted
    for (int j = 0; j < nodesAllInfo.length; ++j) {
      for (int i = 0; i < nodesWeights.length; ++i) {
        nodesWeights[i].toString();

        List<DatabaseNodesWeights> specificNodeConnections =
            await _mainService.getNodesWeightsUseNode(
                theNodesName: nodesAllInfo[j].nodeName,
                theNodesWeightId: nodesAllInfo[j].id);

        graph.addEdge(
            specificNodeConnections[i].node_1,
            specificNodeConnections[i].node_2,
            specificNodeConnections[i].weight);
      }
    }

//calculate shortest path
    listOfPointsInBetween =
        graph.lightestPath('Physics Building', 'Student Services');
  }

  var attempt2 = [];

//override built-in function initState
  @override
  void initState() {
    //open database
    initialize(lightestPath);
    _mainService = MainService();
    String firstVertex = 'Physics Building';
    devtools.log('$graph.vertexExists(FirstVertex)');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('map route'),
      ),
      body: Stack(
        children: <Widget>[
          Text(
              '\nLightest path a -> $lightestPath , weight: ${graph.weightAlong(lightestPath)}'),
          Text(nodesWeights.toString()),
        ],
      ),
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
