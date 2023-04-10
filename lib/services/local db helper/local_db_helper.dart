import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:connectivity/connectivity.dart';
import 'package:legsfree/constants/nodes_var.dart';
import 'package:legsfree/models/nodes_model.dart';
import 'package:legsfree/models/route_map.dart';
import 'package:legsfree/models/route_points.dart';
import 'package:legsfree/models/weights.dart';
//import 'package:legsfree/services/crud/crud_exceptions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../constants/route_points_var.dart';
import '../../constants/routes_map_var.dart';
import '../../constants/weight_var.dart';
import 'db_exceptions.dart';

class LocalDBhelper {
  Future<Database> initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'legsfreeapp.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    //NODES TABLE
    await db.execute(
      "CREATE TABLE nodes(id INTEGER, ${NodesVar.isSelectable} INTEGER, ${NodesVar.x} INTEGER, ${NodesVar.y} INTEGER, ${NodesVar.name} TEXT)",
    );
    //ROUTE MAPS
    await db.execute(
        'CREATE TABLE route_map(id INTEGER, ${RouteMapsVar.isKnown} INTEGER, ${RouteMapsVar.journeyName} TEXT, ${RouteMapsVar.location1} INTEGER, ${RouteMapsVar.location2} INTEGER, ${RouteMapsVar.mapName} TEXT, ${RouteMapsVar.maps} INTEGER, ${RouteMapsVar.totalWeight} INTEGER, ${RouteMapsVar.weightClass} INTEGER)');
    //ROUTE POINTS
    await db.execute(
        'CREATE TABLE route_points(id INTEGER, ${RoutePointsVar.location1} INTEGER, ${RoutePointsVar.location2} INTEGER, ${RoutePointsVar.points} INTEGER, ${RoutePointsVar.position} INTEGER, ${RoutePointsVar.routeId} INTEGER)');
    //WEIGHTS
    await db.execute(
        'CREATE TABLE weights(weight_id INTEGER, ${WeightVar.node1} TEXT, ${WeightVar.node2} TEXT, ${WeightVar.weight} INTEGER, ${WeightVar.weightClass} INTEGER)');
  }

  //GET NODES TABLE DATA
  Future<List<NodesModel>> getNodes() async {
    final database = await initDatabase();

    //GET DATA FROM LOCAL DB
    List<NodesModel> nodesList = [];
    var nodes = await database.query('nodes', orderBy: 'id');

    if (nodes.isNotEmpty) {
      nodesList = nodes.map((e) => NodesModel.fromMap(e)).toList();
    } else {
      throw CouldNotFindNode();
    }

    if (await isInternet()) {
      nodesList = [];
      await deleteAllDataFromTable('nodes', true);
      //ADDING DATA FROM FIREBASE
      return await FirebaseFirestore.instance
          .collection('nodes')
          .orderBy('id')
          .get()
          .then((value) async {
        for (int i = 0; i < value.docs.length; i++) {
          NodesModel nodes = NodesModel.fromDocumentSnapshot(value.docs[i]);
          nodesList.add(nodes);
          addNodesDataInLocalDB(nodes);
        }
        print('NODES DATA IS ${nodesList.length}');
        return nodesList;
      });
    } else {
      print('NODES DATA IS ${nodesList.length}');
      return nodesList;
    }
  }

  //GET ROUTE MAP
  Future<List<RouteMapModel>> getRouteMap() async {
    final database = await initDatabase();
    List<RouteMapModel> routeMapList = [];
    var routeMap = await database.query('route_map', orderBy: 'id');

    if (routeMap.isNotEmpty) {
      routeMapList = routeMap.map((e) => RouteMapModel.fromMap(e)).toList();
    }
    // else {
    //   throw CouldNotFindMapImage();
    // }
    if (await isInternet()) {
      routeMapList = [];
      await deleteAllDataFromTable('route_map', true);
      //ADDING DATA FROM FIREBASE
      return await FirebaseFirestore.instance
          .collection('route_map')
          .orderBy('id')
          .get()
          .then((value) async {
        for (int i = 0; i < value.docs.length; i++) {
          RouteMapModel routeMaps =
              RouteMapModel.fromDocumentSnapshot(value.docs[i]);
          routeMapList.add(routeMaps);
          addRouteMapDataInLocalDB(routeMaps)
              .then((value) => print('VAL $value'));
        }
        return routeMapList;
      });
    } else {
      return routeMapList;
    }
  }

  //GET ROUTE POINTS
  Future<List<RoutePointsModel>> getRoutePoints() async {
    final database = await initDatabase();
    List<RoutePointsModel> routePointList = [];
    var routePoints = await database.query('route_points', orderBy: 'id');

    if (routePoints.isNotEmpty) {
      routePointList =
          routePoints.map((e) => RoutePointsModel.fromMap(e)).toList();
    }
    // else {
    //   throw CouldNotFindPointsInBetween();
    // }

    if (await isInternet()) {
      routePointList = [];
      await deleteAllDataFromTable('route_points', true);
      //ADDING DATA FROM FIREBASE
      await FirebaseFirestore.instance
          .collection('route_points')
          .orderBy('id')
          .get()
          .then((value) async {
        for (int i = 0; i < value.docs.length; i++) {
          RoutePointsModel routePoints =
              RoutePointsModel.fromDocumentSnapshot(value.docs[i]);
          routePointList.add(routePoints);
          addRoutePointsDataInLocalDB(routePoints)
              .then((value) => print('VAL $value'));
        }
      });
      print('ROUTE POINTS DATA IS ${routePointList.length}');
      return routePointList;
    } else {
      print('ROUTE POINTS DATA IS ${routePointList.length}');
      return routePointList;
    }
  }

  //GET WEIGHT
  Future<List<WeightsModel>> getWeights() async {
    final database = await initDatabase();
    List<WeightsModel> weightList = [];
    var weight = await database.query('weights', orderBy: 'weight_id');

    if (weight.isNotEmpty) {
      weightList = weight.map((e) => WeightsModel.fromMap(e)).toList();
    } else {
      throw CouldNotFindNodesWeight();
    }

    if (await isInternet()) {
      weightList = [];
      await deleteAllDataFromTable('weights', true);
      //ADDING DATA FROM FIREBASE
      return await FirebaseFirestore.instance
          .collection('weights')
          .orderBy('weight_id')
          .get()
          .then((value) async {
        for (int i = 0; i < value.docs.length; i++) {
          WeightsModel weights =
              WeightsModel.fromDocumentSnapshot(value.docs[i]);
          weightList.add(weights);
          addWeightsDataInLocalDB(weights);
        }
        print('WEIGHTS DATA IS ${weightList.length}');
        return weightList;
      });
    } else {
      print('WEIGHTS DATA IS ${weightList.length}');
      return weightList;
    }
  }

  //ADD NODES DATA
  Future<int> addNodesDataInLocalDB(NodesModel modelData) async {
    final database = await initDatabase();
    return await database.insert('nodes', modelData.toMap());
  }

  //ADD ROUTEMAP DATA
  Future<int> addRouteMapDataInLocalDB(RouteMapModel modelData) async {
    final database = await initDatabase();
    return await database.insert('route_map', modelData.toMap());
  }

  //ADD ROUTE POINTS DATA
  Future<int> addRoutePointsDataInLocalDB(RoutePointsModel modelData) async {
    final database = await initDatabase();
    return await database.insert('route_points', modelData.toMap());
  }

  //ADD ROUTE POINTS DATA
  Future<int> addWeightsDataInLocalDB(WeightsModel modelData) async {
    final database = await initDatabase();
    return await database.insert('weights', modelData.toMap());
  }

  Future<bool> isDataAlreadySaved(
      dynamic firebaseData, String tableName) async {
    final db = await initDatabase();
    int count;
    if (tableName == 'weights') {
      print('WEIGHT');
      count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM $tableName WHERE weight_id = ?',
          [firebaseData['weight_id']]))!;
    } else {
      count = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM $tableName WHERE id = ?',
          [firebaseData['id']]))!;
    }
    return count > 0;
  }

  // DELETE NODE
  Future<void> deleteNode(int id) async {
    //DELETING FROM LOCAL DB
    final db = await initDatabase();
    final deletedCount =
        await db.delete('nodes', where: 'id = ?', whereArgs: [id]);

    if (deletedCount != 1) {
      throw CouldNotDeleteNode();
    }
    //DELETING FROM FIREBASE
    final firebaseData = await FirebaseFirestore.instance
        .collection('nodes')
        .where('id', isEqualTo: id)
        .get();
    await FirebaseFirestore.instance
        .collection('nodes')
        .doc(firebaseData.docs[0].id)
        .delete();
  }

  // DELETE ROUTE MAP
  Future<void> deleteRouteMap(int id) async {
    //DELETING FROM LOCAL DB
    final db = await initDatabase();
    final deletedCount =
        await db.delete('route_map', where: 'id = ?', whereArgs: [id]);

    if (deletedCount != 1) {
      throw CouldNotDeleteMapImage();
    }
    //DELETING FROM FIREBASE
    final firebaseData = await FirebaseFirestore.instance
        .collection('route_map')
        .where('id', isEqualTo: id)
        .get();
    await FirebaseFirestore.instance
        .collection('route_map')
        .doc(firebaseData.docs[0].id)
        .delete();
  }

  // DELETE ROUTE POINTS
  Future<void> deleteRoutePoints(int id) async {
    //DELETING FROM LOCAL DB
    final db = await initDatabase();
    final deletedCount =
        await db.delete('route_points', where: 'id = ?', whereArgs: [id]);

    if (deletedCount != 1) {
      throw CouldNotDeletePointsInBetween();
    }

    //DELETING FROM FIREBASE
    final firebaseData = await FirebaseFirestore.instance
        .collection('route_points')
        .where('id', isEqualTo: id)
        .get();
    await FirebaseFirestore.instance
        .collection('route_points')
        .doc(firebaseData.docs[0].id)
        .delete();
  }

  // DELETE ROUTE POINTS
  Future<void> deleteWeights(int id) async {
    //DELETING FROM LOCAL DB
    final db = await initDatabase();
    final deletedCount =
        await db.delete('weights', where: 'weight_id = ?', whereArgs: [id]);

    if (deletedCount != 1) {
      throw CouldNotDeleteNodesWeight();
    }
    //DELETING FROM FIREBASE
    final firebaseData = await FirebaseFirestore.instance
        .collection('weights')
        .where('weight_id', isEqualTo: id)
        .get();
    await FirebaseFirestore.instance
        .collection('weights')
        .doc(firebaseData.docs[0].id)
        .delete();
  }

  //DELETE ALL DATA FROM TABLE
  Future<void> deleteAllDataFromTable(
      String tableName, bool isLocalOnly) async {
    final db = await initDatabase();
    await db.delete(tableName);
    //DELETEING FROM FIREBASE
    if (!isLocalOnly) {
      final firebaseData =
          await FirebaseFirestore.instance.collection(tableName).get();
      for (int i = 0; i < firebaseData.docs.length; i++) {
        await FirebaseFirestore.instance
            .collection(tableName)
            .doc(firebaseData.docs[i].id)
            .delete();
      }
    }
  }

  // UPDATE NODES
  Future<int> updateNodes(NodesModel data) async {
    final db = await initDatabase();
    final updateCount = await db.update(
      'nodes',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNode();
    } else {
      //UPDATING FROM FIREBASE
      final firebaseData = await FirebaseFirestore.instance
          .collection('nodes')
          .where('id', isEqualTo: data.id)
          .get();
      await FirebaseFirestore.instance
          .collection('nodes')
          .doc(firebaseData.docs[0].id)
          .update(data.toMap());
      return updateCount;
    }
  }

  // UPDATE ROUTE MAP
  Future<int> updateRouteMap(RouteMapModel data) async {
    final db = await initDatabase();
    var updateCount = await db.update(
      'route_map',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );

    if (updateCount == 0) {
      throw CouldNotUpdateMapImage();
    } else {
      //UPDATING FROM FIREBASE
      final firebaseData = await FirebaseFirestore.instance
          .collection('route_map')
          .where('id', isEqualTo: data.id)
          .get();
      await FirebaseFirestore.instance
          .collection('route_map')
          .doc(firebaseData.docs[0].id)
          .update(data.toMap());
      return updateCount;
    }
  }

  //UPDATE ROUTE POINTS
  Future<int> updateRoutePoints(RoutePointsModel data) async {
    final db = await initDatabase();
    final updateCount = await db.update(
      'route_points',
      data.toMap(),
      where: 'id = ?',
      whereArgs: [data.id],
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNode();
    } else {
      //UPDATING FROM FIREBASE
      final firebaseData = await FirebaseFirestore.instance
          .collection('route_points')
          .where('id', isEqualTo: data.id)
          .get();
      await FirebaseFirestore.instance
          .collection('route_points')
          .doc(firebaseData.docs[0].id)
          .update(data.toMap());
      return updateCount;
    }
  }

  //UPDATE WEIGHTS
  Future<int> updateWeights(WeightsModel data) async {
    final db = await initDatabase();
    final updateCount = await db.update(
      'weights',
      data.toMap(),
      where: 'weight_id = ?',
      whereArgs: [data.weightID],
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNode();
    } else {
      //UPDATING FROM FIREBASE
      final firebaseData = await FirebaseFirestore.instance
          .collection('weights')
          .where('weight_id', isEqualTo: data.weightID)
          .get();
      await FirebaseFirestore.instance
          .collection('weights')
          .doc(firebaseData.docs[0].id)
          .update(data.toMap());
      return updateCount;
    }
  }

  //GET NODES WEIGHTS FOR ONE NODE
  Future<List<WeightsModel>> getNodesWeightsForOneNode(String nodeName) async {
    final database = await initDatabase();
    List<WeightsModel> weightsList = [];
    var weightsData = await database.query(
      'weights',
      where: 'node_1 = ?',
      whereArgs: [nodeName],
    );

    if (weightsData.isNotEmpty) {
      weightsList = weightsData.map((e) => WeightsModel.fromMap(e)).toList();
    } else {
      throw CouldNotFindSpecificNodesWeight(nodeName);
    }
    return weightsList;
  }

  //GET NODES FOR ONE NODE
  Future<List<NodesModel>> getNodesForOneNode(String name) async {
    final database = await initDatabase();
    List<NodesModel> nodesList = [];
    var nodesData = await database.query(
      'nodes',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (nodesData.isNotEmpty) {
      nodesList = nodesData.map((e) => NodesModel.fromMap(e)).toList();
    } else {
      throw CouldNotFindSpecificNode();
    }
    return nodesList;
  }

  //GET ROUTE MAPS FOR ONE JOURNEY
  Future<List<RouteMapModel>> getRouteMapsForOneJourney(
      String journeyName) async {
    final database = await initDatabase();
    List<RouteMapModel> routeMapsList = [];
    var routeMapsData = await database.query(
      'route_map',
      where: 'journey_name = ?',
      whereArgs: [journeyName],
    );

    if (routeMapsData.isNotEmpty) {
      routeMapsList =
          routeMapsData.map((e) => RouteMapModel.fromMap(e)).toList();
    } else {
      throw CouldNotFindSpecificMapImage();
    }
    return routeMapsList;
  }

  //GET ROUTE POINTS FOR ONE JOURNEY
  Future<List<RoutePointsModel>> getRoutePointsForOneJourney(
      int routeID, int position) async {
    final database = await initDatabase();
    List<RoutePointsModel> routePointsList = [];
    var routePointsData = await database.query(
      'route_points',
      where: 'route_id = ?',
      whereArgs: [routeID],
    );

    if (routePointsData.isNotEmpty) {
      // routePointsList =
      //     routePointsData.map((e) => RoutePointsModel.fromMap(e)).toList();
      for (int i = 0; i < routePointsData.length; i++) {
        if (routePointsData[i]['position'] == position) {
          routePointsList.add(RoutePointsModel.fromMap(routePointsData[i]));
        }
      }
    } else {
      throw CouldNotFindSpecificPointsInBetween();
    }
    return routePointsList;
  }

  //FOR CHECKING INTERNET
  Future<bool> isInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false; // No internet connection
    } else {
      return true; // Internet connection available
    }
  }
}
