//This file translates database data into actual dart language that can be implemented

import 'dart:async';
//import 'dart:html';
import 'dart:io';
import 'dart:typed_data';
//import 'dart:ui';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';
import 'package:quiver/core.dart';
//import 'dart:js';
//import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
//import 'package:sqflite_common_ffi/sqflite_ffi.dart';
//import 'package:sqflite/sqflite.dart';
//import 'package:path_provider/path_provider.dart';

class MainService {
  Database? _db; // stores database
  List<DatabaseRouteMap> _maps = []; //stores list of maps
  List<DatabaseNodesWeights> _weights = []; //stores list of weights
  List<DatabaseRoutePointsInBetween> _pointsInBetween =
      []; //stores list of pointsInBetween
  List<DatabaseNodes> _nodes = []; //stores list of nodes
  //List<DatabaseUser> _user = []; //stores list of maps

//creates a stream of a list of DtabaseRouteMap which would keep track of the changes in _maps in this case
  final _mapsStreamController =
      StreamController<List<DatabaseRouteMap>>.broadcast();
  final _weightsStreamController =
      StreamController<List<DatabaseNodesWeights>>.broadcast();
  final _pointsInBetweenStreamController =
      StreamController<List<DatabaseRoutePointsInBetween>>.broadcast();
  final _nodesStreamController =
      StreamController<List<DatabaseNodes>>.broadcast();
  //final _userStreamController =
  //  StreamController<List<DatabaseUser>>.broadcast();

  Stream<List<DatabaseRouteMap>> get allMaps => _mapsStreamController.stream;
  Stream<List<DatabaseNodes>> get allNodes => _nodesStreamController.stream;
//make mainservice a singleton
  static final MainService _shared = MainService._sharedInstance();
  MainService._sharedInstance();
  factory MainService() => _shared;

  Future<DatabaseUser> getOrCreateUser({required String theemail}) async {
    try {
      final user = await getUser(theemail: theemail);
      return user;
    } on CouldNotFindUser {
      final createAUser = await createUser(theemail: theemail);
      return createAUser;
    } catch (e) {
      rethrow;
    }
  }

//stores database inside variable _maps
  Future<void> _cacheMaps() async {
    final allMaps = await getAllMaps(); //get all maps
    _maps = allMaps
        .toList(); //changes iterable to list (remember an underscore means the variable is private to this class and it has to be used somewhere else publically)
    _mapsStreamController.add(_maps); //add it to stream
  }

//deletes all nodes
  Future<int> deleteAllMaps() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(routeMapTable);

    //delete maps from stream
    _maps = [];
    _mapsStreamController.add(_maps);

    return numberOfDeletions;
  }

//get all the nodes
  Future<Iterable<DatabaseRouteMap>> getAllMaps() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final imageInfo = await db.query(routeMapTable);

    return imageInfo
        .map((routeMapRow) => DatabaseRouteMap.fromRow(routeMapRow));
  }

//deletes node using nodeId inserted
  Future<void> deleteMaps({required int theImageInfoId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locates database

//this returns the number of deleted nodes which can only be 0 or 1
    final deletedCount = await db.delete(
      routeMapTable, //choose the table to delete from in this case the nodesTable
      where:
          'route_map_id = ?', //delete as long as it is under the column 'id' and is equal to some value
      whereArgs: [
        theImageInfoId
      ], //delete if its arguments are equal to that of the argument of this function
    );

//if deleted count is 0 then the user does not exist,
//if it is 1 the the user was deleted

//if deleted count was 0 and exception is thrown
    if (deletedCount != 1) {
      throw CouldNotDeleteMapImage();
    } else {
      //delete from stream and the list
      _maps.removeWhere((map) => map.id == theImageInfoId);
      _mapsStreamController.add(_maps);
    }
  }

  Future<DatabaseRouteMap> updateMaps({
    required DatabaseRouteMap theImageInfo,
    required ImageInfo theImageInfoNew,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

//make sure map exists
    await getMaps(theImageInfoId: theImageInfo.id);

    var imageFile = File(theImageInfoNew.mapFileName);
    var imageAsBytes = await imageFile.readAsBytes();

//update database
    final updateCount = await db.update(
      routeMapTable,
      {
        mapFileNameColumn: theImageInfoNew.mapFileName,
        mapsColumn: imageAsBytes,
        totalWeightColumn: theImageInfoNew.totalWeight,
        journeyNameColumn: theImageInfoNew.journeyName,
        weightClassMapsColumn: theImageInfoNew.weightClass,
        isKnownColumn: theImageInfoNew.isKnown,
      },
    );

    if (updateCount == 0) {
      throw CouldNotUpdateMapImage();
    } else {
      final updatedMap =
          await getMaps(theImageInfoId: theImageInfo.id); //get updated value
      _maps.removeWhere((map) => map.id == updatedMap.id); //remove from stream
      _maps.add(updatedMap); // update list with mew updated value
      _mapsStreamController.add(_maps); // update stream with new updated list
      return updatedMap;
    }
  }

//gets user from an email inserted
  Future<DatabaseRouteMap> getMaps({required int theImageInfoId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locate database and store it

    final results = await db.query(
      routeMapTable, //choose nodes table
      limit: 1, //only look for one node
      where: 'route_map_Id = ?', // we are looking for x and y
      whereArgs: [
        theImageInfoId,
      ], //the x and y we are looking for has the same content as our argument
    );
//if no results were returned throw an exception or return the map we are looking for
//in the list created above
    if (results.isNotEmpty) {
      final map = DatabaseRouteMap.fromRow(results.first);

      //remove existing map from stream with the same identity of our updated value
      _maps.removeWhere((map) => map.id == theImageInfoId);

      //after removing the old value we insert the new value into the local list cache and the stream
      //NOTE: in this case we are only updating the stream so the value is not affected, but the rather it is like we are getting updating it's status
      _maps.add(map);
      _mapsStreamController.add(_maps);

      return map;
    } else {
      throw CouldNotFindMapImage();
    }
  }

//create a new node
  Future<DatabaseRouteMap> createMaps(ImageInfo theImageInfo) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final resultlocation1 = await db.query(
      routeMapTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'location_1 = ?', //in this case we are looking for an x
      whereArgs: [
        theImageInfo.location1
      ], //the x we are looking for is that similar to the argument's x variable
    );

    final resultlocation2 = await db.query(
      routeMapTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'location_2 = ?', //in this case we are looking for a y
      whereArgs: [
        theImageInfo.location2
      ], //the y we are looking for is that similar to the argument y variable
    );

    final resultTotalWeight = await db.query(
      routeMapTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'total_weight = ?', //in this case we are looking for a y
      whereArgs: [
        theImageInfo.totalWeight
      ], //the y we are looking for is that similar to the argument y variable
    );

//if the results variable is not empty that means there is an email similar to ours
//in that case throw an exception
    if ((resultlocation1.isNotEmpty) &&
        (resultlocation2.isNotEmpty) &&
        (resultTotalWeight.isNotEmpty)) {
      throw MapImageAlreadyExists();
    }

//change imagefilename to a file so it can be converted into an image
    var imageFile = File(theImageInfo.mapFileName);
    var imageAsBytes = await imageFile.readAsBytes();

//insert x and y variable of argument and return a node id
    final routeMapId = await db.insert(
      routeMapTable,
      {
        location1RouteMapColumn: theImageInfo.location1,
        location2RouteMapColumn: theImageInfo.location2,
        mapsColumn: imageAsBytes,
        mapFileNameColumn: theImageInfo.mapFileName,
        totalWeightColumn: theImageInfo.totalWeight,
        journeyNameColumn: theImageInfo.journeyName,
        weightClassMapsColumn: theImageInfo.weightClass,
        isKnownColumn: theImageInfo.isKnown,
      },
    );
//return instance of database node using new nodeIdf
    final map = DatabaseRouteMap(
      id: routeMapId,
      location_1: theImageInfo.location1,
      location_2: theImageInfo.location2,
      maps: imageAsBytes,
      mapFileName: theImageInfo.mapFileName,
      totalWeight: theImageInfo.totalWeight,
      journeyName: theImageInfo.journeyName,
      weightClass: theImageInfo.weightClass,
      isKnown: theImageInfo.isKnown,
    );

//add new map to list of maps and update the streamcontroller
    _maps.add(map);
    _mapsStreamController.add(_maps);

    return map;
  }

//stores database inside variable _maps
  Future<void> _cacheNodesWeights() async {
    final allWeights = await getAllNodesWeights(); //get all maps
    _weights = allWeights
        .toList(); //changes iterable to list (remember an underscore means the variable is private to this class and it has to be used somewhere else publically)
    _weightsStreamController.add(_weights); //add it to stream
  }

//deletes all nodes
  Future<int> deleteAllNodesWeights() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final numberOfNodesWeights = await db.delete(nodesWeightsTable);

//delete maps from stream
    _weights = [];
    _weightsStreamController.add(_weights);

    return numberOfNodesWeights;
  }

//get all the nodes
  Future<Iterable<DatabaseNodesWeights>> getAllNodesWeights() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final nodesWeight = await db.query(nodesWeightsTable);

    return nodesWeight
        .map((nodeWeightRow) => DatabaseNodesWeights.fromRow(nodeWeightRow));
  }

//deletes node using nodeId inserted
  Future<void> deleteNodesWeights({required int theNodesWeightId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locates database

//this returns the number of deleted nodes which can only be 0 or 1
    final deletedCount = await db.delete(
      nodesWeightsTable, //choose the table to delete from in this case the nodesTable
      where:
          'id = ?', //delete as long as it is under the column 'id' and is equal to some value
      whereArgs: [
        theNodesWeightId
      ], //delete if its arguments are equal to that of the argument of this function
    );

//if deleted count is 0 then the user does not exist,
//if it is 1 the the user was deleted

//if deleted count was 0 and exception is thrown
    if (deletedCount != 1) {
      throw CouldNotDeleteNodesWeight();
    } else {
      //delete from stream and the list
      _weights.removeWhere((weights) => weights.id == theNodesWeightId);
      _weightsStreamController.add(_weights);
    }
  }

  Future<DatabaseNodesWeights> updateNodesWeights({
    required DatabaseNodesWeights theNodesWeight,
    required NodesWeight theNodesWeightNewInfo,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNodesWeightsUseId(theNodesWeightsId: theNodesWeight.id);

    final updateCount = await db.update(
      nodesWeightsTable,
      {
        node1Column: theNodesWeightNewInfo.node1,
        node2Column: theNodesWeightNewInfo.node2,
        weightColumn: theNodesWeightNewInfo.weight,
        weightClassWeightsColumn: theNodesWeightNewInfo.weightClass,
      },
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNode();
    } else {
      final updatedWeight = await getNodesWeightsUseId(
          theNodesWeightsId: theNodesWeight.id); //get updated value
      _weights.removeWhere(
          (node) => node.id == updatedWeight.id); //remove from stream
      _weights.add(updatedWeight); // update list with mew updated value
      _weightsStreamController
          .add(_weights); // update stream with new updated list
      return updatedWeight;
    }
  }

//gets user from an email inserted
  Future<DatabaseNodesWeights> getNodesWeightsUseId(
      {required int theNodesWeightsId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locate database and store it

    final results = await db.query(
      nodesWeightsTable, //choose nodes table
      limit: 1, //only look for one node
      where: 'weights_Id = ?', // we are looking for x and y
      whereArgs: [
        theNodesWeightsId,
      ], //the x and y we are looking for has the same content as our argument
    );
//if no results were returned throw an exception or return the node we are looking for
//in the list created above
    if (results.isNotEmpty) {
      final weights = DatabaseNodesWeights.fromRow(results.first);

      //remove existing map from stream with the same identity of our updated value
      _weights.removeWhere((weights) => weights.id == theNodesWeightsId);

      //after removing the old value we insert the new value into the local list cache and the stream
      //NOTE: in this case we are only updating the stream so the value is not affected, but the rather it is like we are getting updating it's status
      _weights.add(weights);
      _weightsStreamController.add(_weights);

      return weights;
    } else {
      throw CouldNotFindNodesWeight();
    }
  }

//gets user from an email inserted
  Future<List<DatabaseNodesWeights>> getNodesWeightsUseNode(
      {required String theNodesName, required int theNodesWeightId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locate database and store it

    final results = await db.query(
      nodesWeightsTable, //choose nodes table
      where: 'node_1 = ?', // we are looking for x and y
      whereArgs: [
        theNodesName,
      ], //the x and y we are looking for has the same content as our argument
    );
//if no results were returned throw an exception or return the node we are looking for
//in the list created above
    if (results.isNotEmpty) {
      late List<DatabaseNodesWeights> weights = [];

      for (int i = 0; i < results.length; ++i) {
        weights[i] = DatabaseNodesWeights.fromRow(results[i]);

        //remove existing map from stream with the same identity of our updated value
        _weights.removeWhere((weights) =>
            weights.id ==
            theNodesWeightId); //////////////Not 100% correct//////////////////////

        //after removing the old value we insert the new value into the local list cache and the stream
        //NOTE: in this case we are only updating the stream so the value is not affected, rather it is like we are getting updates of its status
        _weights.add(weights[i]);
        _weightsStreamController.add(_weights);
      }
      return weights;
    } else {
      throw CouldNotFindNodesWeight();
    }
  }

//create a new node
  Future<DatabaseNodesWeights> createNodesWeights(
      NodesWeight theWeights) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final resultX = await db.query(
      nodesWeightsTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'node_1 = ?', //in this case we are looking for an x
      whereArgs: [
        theWeights.node1
      ], //the x we are looking for is that similar to the argument's x variable
    );

    final resultY = await db.query(
      nodesWeightsTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'node_2 = ?', //in this case we are looking for a y
      whereArgs: [
        theWeights.node2
      ], //the y we are looking for is that similar to the argument y variable
    );

    final resultWeightClass = await db.query(
      nodesWeightsTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'weight_class = ?', //in this case we are looking for a y
      whereArgs: [
        theWeights.weightClass
      ], //the y we are looking for is that similar to the argument y variable
    );

//if the results variable is not empty that means there is an email similar to ours
//in that case throw an exception
    if ((resultX.isNotEmpty) &&
        (resultY.isNotEmpty) &&
        (resultWeightClass.isNotEmpty)) {
      throw NodesWeightAlreadyExists();
    }

//insert x and y variable of argument and return a node id
    final weightId = await db.insert(
      nodesWeightsTable,
      {
        node1Column: theWeights.node1,
        node2Column: theWeights.node2,
        weightColumn: theWeights.weight,
        weightClassWeightsColumn: theWeights.weightClass,
      },
    );
//return instance of database node using new nodeIdf
    final node = DatabaseNodesWeights(
      id: weightId,
      node_1: theWeights.node1,
      node_2: theWeights.node1,
      weight: theWeights.weight,
      weightClass: theWeights.weightClass,
    );

    //add new map to list of maps and update the streamcontroller
    _weights.add(node);
    _weightsStreamController.add(_weights);

    return node;
  }

//stores database inside variable _maps
  Future<void> _cachePointsInBetween() async {
    final allPointsInbetween = await getAllPointsInBetween(); //get all maps
    _pointsInBetween = allPointsInbetween
        .toList(); //changes iterable to list (remember an underscore means the variable is private to this class and it has to be used somewhere else publically)
    _pointsInBetweenStreamController.add(_pointsInBetween); //add it to stream
  }

//deletes all nodes
  Future<int> deleteAllPointsInBetween() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final numberOfPointsInBetween = await db.delete(routePointsInBetweenTable);

    //delete maps from stream
    _pointsInBetween = [];
    _pointsInBetweenStreamController.add(_pointsInBetween);

    return numberOfPointsInBetween;
  }

//get all the nodes
  Future<Iterable<DatabaseRoutePointsInBetween>> getAllPointsInBetween() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final pointsInBetween = await db.query(routePointsInBetweenTable);

    return pointsInBetween.map((pointsInBetweenRow) =>
        DatabaseRoutePointsInBetween.fromRow(pointsInBetweenRow));
  }

//deletes node using nodeId inserted
  Future<void> deletePointsInBetween(
      {required int theRoutePointsInBetweenId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locates database

//this returns the number of deleted nodes which can only be 0 or 1
    final deletedCount = await db.delete(
      routePointsInBetweenTable, //choose the table to delete from in this case the nodesTable
      where:
          'id = ?', //delete as long as it is under the column 'id' and is equal to some value
      whereArgs: [
        theRoutePointsInBetweenId
      ], //delete if its arguments are equal to that of the argument of this function
    );

//if deleted count is 0 then the user does not exist,
//if it is 1 the the user was deleted

//if deleted count was 0 and exception is thrown
    if (deletedCount != 1) {
      throw CouldNotDeletePointsInBetween();
    } else {
      //delete from stream and the list
      _pointsInBetween.removeWhere(
          (pointsInbetween) => pointsInbetween.id == theRoutePointsInBetweenId);
      _pointsInBetweenStreamController.add(_pointsInBetween);
    }
  }

  Future<DatabaseRoutePointsInBetween> updatePointsInBetween({
    required DatabaseRoutePointsInBetween theRoutePointsInBetween,
    required PointsInBetween theRoutePointsInBetweenNewInfo,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getPointsInBetween(
        theRoutePointsInBetweenId: theRoutePointsInBetween.id);

    final updateCount = await db.update(
      routePointsInBetweenTable,
      {
        pointsInBetweenColumn: theRoutePointsInBetweenNewInfo.pointsInBetween,
      },
    );

    if (updateCount == 0) {
      throw CouldNotUpdatePointsInBetween();
    } else {
      final updatedPointsInBetween = await getPointsInBetween(
          theRoutePointsInBetweenId:
              theRoutePointsInBetween.id); //get updated value
      _pointsInBetween.removeWhere((pointsInBetween) =>
          pointsInBetween.id == updatedPointsInBetween.id); //remove from stream
      _pointsInBetween
          .add(updatedPointsInBetween); // update list with mew updated value
      _pointsInBetweenStreamController
          .add(_pointsInBetween); // update stream with new updated list
      return updatedPointsInBetween;
    }
  }

//gets user from an email inserted
  Future<DatabaseRoutePointsInBetween> getPointsInBetween(
      {required int theRoutePointsInBetweenId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locate database and store it

    final results = await db.query(
      nodesTable, //choose nodes table
      limit: 1, //only look for one node
      where: 'route_points_Id = ?', // we are looking for x and y
      whereArgs: [
        theRoutePointsInBetweenId,
      ], //the x and y we are looking for has the same content as our argument
    );
//if no results were returned throw an exception or return the node we are looking for
//in the list created above
    if ((results.isNotEmpty)) {
      final getPointInBetween =
          DatabaseRoutePointsInBetween.fromRow(results.first);

      //remove existing map from stream with the same identity of our updated value
      _pointsInBetween.removeWhere(
          (pointsInBetween) => pointsInBetween.id == theRoutePointsInBetweenId);

      //after removing the old value we insert the new value into the local list cache and the stream
      //NOTE: in this case we are only updating the stream so the value is not affected, but the rather it is like we are getting updating it's status
      _pointsInBetween.add(getPointInBetween);
      _pointsInBetweenStreamController.add(_pointsInBetween);

      return getPointInBetween;
    } else {
      throw CouldNotFindRoutePointsInBetween();
    }
  }

//create a new node
  Future<DatabaseRoutePointsInBetween> createPointsInBetween(
      PointsInBetween points) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      routePointsInBetweenTable, //checks user table
      where: 'route_id = ?', //in this case we are looking for an x
      whereArgs: [
        points.routeId,
      ], //the x we are looking for is that similar to the argument's x variable
    );

//if the results variable is not empty that means there is an email similar to ours
//in that case throw an exception
    if ((results.isNotEmpty)) {
      throw PointsInBetweenAlreadyExists();
    }

//insert 2 locations and points in between return an id for the pointsInBetweenThem
    final pointsInBetweenId = await db.insert(
      nodesTable,
      {
        location1RouteMapColumn: points.location1,
        location2RouteMapColumn: points.location2,
        pointsInBetweenColumn: points.pointsInBetween,
        routeIdColumn: points.routeId,
        positionColumn: points.position,
      },
    );

//return instance of database node using new nodeIdf
    final pointsInBetween = DatabaseRoutePointsInBetween(
      id: pointsInBetweenId,
      location_1: points.location1,
      location_2: points.location2,
      pointsInBetween: points.pointsInBetween,
      routeId: points.routeId,
      position: points.position,
    );

    //add new map to list of maps and update the streamcontroller
    _pointsInBetween.add(pointsInBetween);
    _pointsInBetweenStreamController.add(_pointsInBetween);

    return pointsInBetween;
  }

//stores database inside variable _maps
  Future<void> _cacheNodes() async {
    final allNodes = await getAllNodes(); //get all maps
    _nodes = allNodes
        .toList(); //changes iterable to list (remember an underscore means the variable is private to this class and it has to be used somewhere else publically)
    _nodesStreamController.add(_nodes); //add it to stream
  }

//deletes all nodes
  Future<int> deleteAllNodes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final numberOfNodes = await db.delete(nodesTable);

    //delete maps from stream
    //  _nodes = [];
    // _nodesStreamController.add(_nodes);

    return numberOfNodes;
  }

//get all the nodes
  Future<Iterable<DatabaseNodes>> getAllNodes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final nodes = await db.query(nodesTable);

    return nodes.map((nodeRow) => DatabaseNodes.fromRow(nodeRow));
  }

//deletes node using nodeId inserted
  Future<void> deleteNode({required int theNodeId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locates database

//this returns the number of deleted nodes which can only be 0 or 1
    final deletedCount = await db.delete(
      nodesTable, //choose the table to delete from in this case the nodesTable
      where:
          'node_id = ?', //delete as long as it is under the column 'id' and is equal to some value
      whereArgs: [
        theNodeId
      ], //delete if its arguments are equal to that of the argument of this function
    );

//if deleted count is 0 then the user does not exist,
//if it is 1 the the user was deleted

//if deleted count was 0 and exception is thrown
    if (deletedCount != 1) {
      throw CouldNotDeleteNode();
    } else {
      //delete from stream and the list
      // _nodes.removeWhere((nodes) => nodes.id == theNodeId);
      //_nodesStreamController.add(_nodes);
    }
  }

  Future<DatabaseNodes> updateNode({
    required DatabaseNodes theNode,
    required Coordinates theNodeNewInfo,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNodeUseNodeId(theNodeId: theNode.id);

    final updateCount = await db.update(
      nodesTable,
      {
        xColumn: theNode.x,
        yColumn: theNode.y,
        isSelectableColumn: theNode.isSelectable,
      },
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNode();
    } else {
      final updatedNode =
          await getNodeUseNodeId(theNodeId: theNode.id); //get updated value
      // _nodes.removeWhere((map) => map.id == updatedNode.id); //remove from stream
      //_nodes.add(updatedNode); // update list with mew updated value
      //_nodesStreamController.add(_nodes); // update stream with new updated list
      return updatedNode;
    }
  }

//gets user from an email inserted
  Future<List<DatabaseNodes>> getNodeUseNodeName(
      {required String theNodeName}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locate database and store it

    final results = await db.query(
      nodesTable, //choose nodes table
      where: 'node_name = ?', // we are looking for x and y
      whereArgs: [
        theNodeName,
      ], //the x and y we are looking for has the same content as our argument
    );
//if no results were returned throw an exception or return the node we are looking for
//in the list created above
    if (results.isNotEmpty) {
      late List<DatabaseNodes> nodes = [];
      for (int i = 0; i < results.length; ++i) {
        final nodes = DatabaseNodes.fromRow(results[i]);

        //remove existing map from stream with the same identity of our updated value
        //_nodes.removeWhere((nodes) => nodes.id == theNodeName);

        //after removing the old value we insert the new value into the local list cache and the stream
        //NOTE: in this case we are only updating the stream so the value is not affected, but the rather it is like we are getting updating it's status
        //_nodes.add(nodes);
        //_nodesStreamController.add(_nodes);
      }
      return nodes;
    } else {
      throw CouldNotFindNode();
    }
  }

//gets user from an email inserted
  Future<DatabaseNodes> getNodeUseNodeId({required int theNodeId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locate database and store it

    final results = await db.query(
      nodesTable, //choose nodes table
      where: 'node_Id = ?', // we are looking for x and y
      whereArgs: [
        theNodeId,
      ], //the x and y we are looking for has the same content as our argument
    );
//if no results were returned throw an exception or return the node we are looking for
//in the list created above
    if (results.isNotEmpty) {
      final getNode = DatabaseNodes.fromRow(results.first);

      //remove existing map from stream with the same identity of our updated value
      // _nodes.removeWhere((node) => node.id == theNodeId);

      //after removing the old value we insert the new value into the local list cache and the stream
      //NOTE: in this case we are only updating the stream so the value is not affected, but the rather it is like we are getting updating it's status
      // _nodes.add(getNode);
      // _nodesStreamController.add(_nodes);

      return getNode;
    } else {
      throw CouldNotFindNode();
    }
  }

//create a new node
  Future<DatabaseNodes> createNode(Coordinates theNode) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final resultX = await db.query(
      nodesTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'x = ?', //in this case we are looking for an x
      whereArgs: [
        theNode.x
      ], //the x we are looking for is that similar to the argument's x variable
    );

    final resultY = await db.query(
      nodesTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'y = ?', //in this case we are looking for a y
      whereArgs: [
        theNode.y
      ], //the y we are looking for is that similar to the argument y variable
    );

//if the results variable is not empty that means there is an email similar to ours
//in that case throw an exception
    if ((resultX.isNotEmpty) && (resultY.isNotEmpty)) {
      throw NodeAlreadyExists();
    }

//insert x and y variable of argument and return a node id
    final nodeId = await db.insert(
      nodesTable,
      {
        xColumn: theNode.x,
        yColumn: theNode.y,
        isSelectableColumn: theNode.isSelectable,
        nodeNameColumn: theNode.nodeName,
      },
    );
//return instance of database node using new nodeIdf
    final nodes = DatabaseNodes(
      id: nodeId,
      x: theNode.x,
      y: theNode.y,
      isSelectable: theNode.isSelectable,
      nodeName: theNode.nodeName,
    );

    //add new map to list of maps and update the streamcontroller
    // _nodes.add(nodes);
    // _nodesStreamController.add(_nodes);

    return nodes;
  }

//deletes user from an email inserted
  Future<void> deleteUser({required String theemail}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locates database

//this returns the number of deleted users which can only be 0 or 1
    final deletedCount = await db.delete(
      userTable, //choose the table to delete from in this case the userTable
      where:
          'email = ?', //delete as long as it is under the column 'email' and is equal to some value
      whereArgs: [
        theemail.toLowerCase()
      ], //delete if its arguments are equal to that of the argument of this function
    );

//if deleted count is 0 then the user does not exist,
//if it is 1 the the user was deleted

//if deleted count was 0 and exception is thrown
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

//gets user from an email inserted
  Future<DatabaseUser> getUser({required String theemail}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locate database and store it

//ask if email exists and store the result as a list inside results
    final results = await db.query(
      userTable, //chjoose user table
      limit: 1, //only look for one email
      where: 'email = ?', // we are looking for email
      whereArgs: [
        theemail.toLowerCase()
      ], //the email we are looking for has the same content as our argument
    );

//if no results were returned throw an exception else return the email we are looking for
//in the list created above
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

//creates a user from an email inserted
  Future<DatabaseUser> createUser({required String theemail}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow(); //locates database

    //asking if there is an email similar to the email we want to create
    //db.query returns a list of the rows that contain the same information
    //we are asking for which is in this case an email. if there is no email
    //similar to the one we are asking for then it returns an empty list
    final results = await db.query(
      userTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'email = ?', //in this case we are looking for an email
      whereArgs: [
        theemail.toLowerCase()
      ], //the email we are looking for is that similar to the argument of the function
    );

//if the results variable is not empty that means there is an email similar to ours
//in that case throw an exception
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

//insert data into table and returns a userId
    final userId = await db.insert(
        userTable, // choose usertable
        {
          emailColumn: theemail
              .toLowerCase(), //insert the email argument into the emailColumn
        });

//return an instance of the databaseuser with the userId returned and email argument
    return DatabaseUser(
      id: userId,
      email: theemail,
    );
  }

//helps locate db if the db is open and returns an exception otherwise
  Database _getDatabaseOrThrow() {
    final db = _db;

    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

//closes database
  Future<void> close() async {
    final db = _db; //store mian database in function database to avoid error

    //if db is closed throw an exception otherwise close db
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      //empty
    }
  }

//opens database
  Future<void> open() async {
    //if database is open already then throw an exception
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
//try to open database and create tables
    try {
      // Use the ffi web factory in web apps (flutter or dart)

      //this already throws an exception if it were unable to get a directory
      final docsPath = await getApplicationDocumentsDirectory(); //get real path
      final dbPath = join(docsPath.path,
          dbName); //merge path with the name we chose for the database to make easier to access
      final db = await openDatabase(dbPath); //open database through app
      _db = db; // store in variable inside the class outside this function

//creates the user table ONLY if it does not exist
//then execute it
      await db.execute(createUserTable);

//create nodes table ONLY if it does not exist and then execute it
      await db.execute(createNodesTable);
      //await _cacheNodes();
//create routeMapsTable ONLY if it does not exist and then execute it
      await db.execute(createRouteMapsTable);
      //await _cacheMaps();
//create weights table ONLY if it does not exist and then execute it
      await db.execute(createWeightsTable);
      // await _cacheNodesWeights();
      //create routePointsTable table ONLY if it does not exist and then execute it
      await db.execute(createRoutePointsInBetweenTable);
      //await _cachePointsInBetween(); // stores database inside variable _maps
    } on MissingPlatformDirectoryException {
      //if the MissingPlatformDirectory exception is thrown then our own exception is thrown
      throw UnableToGetDocumentException();
    }
  }
}

//data read from the sqlite database table and passed to x this service
@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

//this is a row inside the table that is being used to insantiate the class automatically
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[userIdColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNodes {
  //variables
  final int id;
  final int x;
  final int y;
  final int isSelectable;
  final String nodeName;

//constructor
  DatabaseNodes({
    required this.id,
    required this.x,
    required this.y,
    required this.isSelectable,
    required this.nodeName,
  });

  DatabaseNodes.fromRow(Map<String, Object?> map)
      : id = map[nodesIdColumn] as int,
        x = map[xColumn] as int,
        y = map[yColumn] as int,
        isSelectable = map[isSelectableColumn] as int,
        nodeName = map[nodeNameColumn] as String;

  @override
  String toString() =>
      'Nodes , ID = $id, x-coordinate = $x, y-coordinate = $y, Is it selectable = $isSelectable, node name = $nodeName';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseRouteMap {
  //variables
  final int id;
  final Uint8List maps;
  final String mapFileName;
  final int location_1;
  final int location_2;
  final int totalWeight;
  final String journeyName;
  final int weightClass;
  final bool isKnown;

//constructor
  DatabaseRouteMap({
    required this.id,
    required this.maps,
    required this.mapFileName,
    required this.location_1,
    required this.location_2,
    required this.totalWeight,
    required this.journeyName,
    required this.weightClass,
    required this.isKnown,
  });

  //String photo(String mapName)

  DatabaseRouteMap.fromRow(Map<String, Object?> map)
      : id = map[routeMapIdColumn] as int,
        maps = map[mapsColumn] as Uint8List,
        mapFileName = map[mapFileNameColumn] as String,
        location_1 = map[location1RouteMapColumn] as int,
        location_2 = map[location2RouteMapColumn] as int,
        totalWeight = map[totalWeightColumn] as int,
        journeyName = map[journeyNameColumn] as String,
        weightClass = map[weightClassWeightsColumn] as int,
        isKnown = map[isKnownColumn] as bool;

  @override
  String toString() =>
      'Route_maps , ID = $id, location 1 = $location_1, location 2 = $location_2, weight class = $weightClass, journeyName = $journeyName';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNodesWeights {
  //variables
  final int id;
  final String node_1;
  final String node_2;
  final int weight;
  final int weightClass;

//constructor
  DatabaseNodesWeights({
    required this.id,
    required this.node_1,
    required this.node_2,
    required this.weight,
    required this.weightClass,
  });

  DatabaseNodesWeights.fromRow(Map<String, Object?> map)
      : id = map[weightsIdColumn] as int,
        node_1 = map[xColumn] as String,
        node_2 = map[yColumn] as String,
        weight = map[weightColumn] as int,
        weightClass = map[weightClassWeightsColumn] as int;

  @override
  String toString() =>
      'Nodes , ID = $id, starting node = $node_1, ending node = $node_2, weight =$weight';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseRoutePointsInBetween {
  //variables
  final int id;
  final int location_1;
  final int location_2;
  final int pointsInBetween;
  final int routeId;
  final int position;

//constructor
  DatabaseRoutePointsInBetween({
    required this.id,
    required this.location_1,
    required this.location_2,
    required this.pointsInBetween,
    required this.routeId,
    required this.position,
  });

  DatabaseRoutePointsInBetween.fromRow(Map<String, Object?> map)
      : id = map[routePointsIdColumn] as int,
        location_1 = map[location1RouteMapColumn] as int,
        location_2 = map[location2RouteMapColumn] as int,
        pointsInBetween = map[pointsInBetweenColumn] as int,
        routeId = map[routeIdColumn] as int,
        position = map[routeIdColumn] as int;

  @override
  String toString() =>
      'Route points , ID = $id, starting location = $location_1, ending node = $location_2, weight =$pointsInBetween';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

//stores x and y coordinates
class Coordinates {
  final int x, y, isSelectable;
  final String nodeName;

  Coordinates(
      {required this.x,
      required this.y,
      required this.isSelectable,
      required this.nodeName});

  @override
  String toString() =>
      'coordinates, x = $x, y = $y,  Is it selectable = $isSelectable, node name= $nodeName';

//comparing coordinates #### MIGHT HAVE TO CHANGE LOCATION #####
  @override
  bool operator ==(covariant Coordinates other) {
    if ((x == other.x) && (y == other.y)) {
      return true;
    } else {
      return false;
    }
  }

  //hashcode for overriden == operator
  @override
  int get hashCode => hash2(x.hashCode, y.hashCode);
}

//stores location 1 and location 2 and the points between them if you take the lightest path
class PointsInBetween {
  final int location1, location2, pointsInBetween, routeId, position;

  PointsInBetween({
    required this.location1,
    required this.location2,
    required this.pointsInBetween,
    required this.routeId,
    required this.position,
  });

  @override
  String toString() =>
      'Points in between ,  Points = $pointsInBetween, starting location = $location1, end location  = $location2';

//comparing coordinates #### MIGHT HAVE TO CHANGE LOCATION #####
  @override
  bool operator ==(covariant PointsInBetween other) =>
      pointsInBetween == other.pointsInBetween;

  //hashcode for overriden == operator
  @override
  int get hashCode => pointsInBetween.hashCode;
}

class NodesWeight {
  final String node1;
  final String node2;
  final int weight;
  final int weightClass;

  NodesWeight(this.node1, this.node2, this.weight, this.weightClass);

  @override
  String toString() =>
      'weight between two nodes ,  node1 = $node1, node2 = $node2, weight = $weight, weightClass = $weightClass';

//comparing coordinates #### MIGHT HAVE TO CHANGE LOCATION #####
  @override
  bool operator ==(covariant NodesWeight other) {
    //comparing coordinates #### MIGHT HAVE TO CHANGE LOCATION #####
    if ((node1 == other.node1) && (node2 == other.node2)) {
      return true;
    } else {
      return false;
    }
  }

  //hashcode for overriden == operator
  @override
  int get hashCode => hash2(node1.hashCode, node2.hashCode);
}

class ImageInfo {
  final int location1;
  final int location2;
  Uint8List mapImage;
  final String mapFileName;
  final int totalWeight;
  final String journeyName;
  final int weightClass;
  final bool isKnown;

  ImageInfo(this.location1, this.location2, this.totalWeight, this.mapImage,
      this.mapFileName, this.journeyName, this.weightClass, this.isKnown);

  @override
  String toString() =>
      'total route weight, location1 = $location1, location2 = $location2, weight = $totalWeight, file name =$mapFileName, Journey =$journeyName, Weight class =$weightClass';

//comparing coordinates #### MIGHT HAVE TO CHANGE LOCATION #####
  @override
  bool operator ==(covariant ImageInfo other) {
    //comparing coordinates #### MIGHT HAVE TO CHANGE LOCATION #####
    if ((location1 == other.location1) &&
        (location2 == other.location2) &&
        (totalWeight == other.totalWeight)) {
      return true;
    } else {
      return false;
    }
  }

  //hashcode for overriden == operator
  @override
  int get hashCode =>
      hash3(location1.hashCode, location2.hashCode, totalWeight);
}

const dbName = 'maps.db';
//const dbName = 'wrongdatabase';
const userTable = 'user';
const nodesTable = 'nodes';
const routeMapTable = 'route_map';
const nodesWeightsTable = 'weights';
const routePointsInBetweenTable = 'route_points';
const userIdColumn = 'user_id';
const emailColumn = 'email';
const nodesIdColumn = 'node_id';
const xColumn = 'x';
const yColumn = 'y';
const isSelectableColumn = 'isSelectable';
const nodeNameColumn = 'node_name';
const routeMapIdColumn = 'route_map_id';
const mapFileNameColumn = 'map_name';
const mapsColumn = 'maps';
const location1RouteMapColumn = 'location_1';
const location2RouteMapColumn = 'location_2';
const totalWeightColumn = 'total_weight';
const journeyNameColumn = 'journey_name';
const weightClassMapsColumn = 'weight_class';
const isKnownColumn = 'isKnown';
const weightsIdColumn = 'weights_Id';
const node1Column = 'node_1';
const node2Column = 'node_2';
const weightColumn = 'weight';
const weightClassWeightsColumn = 'weight_class';
const routePointsIdColumn = 'route_points_id';
const location1RoutePointsColumn = 'location_1';
const location2RoutePointsColumn = 'location_2';
const pointsInBetweenColumn = 'points';
const routeIdColumn = 'route_id';
const positionColumn = 'position';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"user_id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("user_id" AUTOINCREMENT)
);''';

const createNodesTable = '''CREATE TABLE IF NOT EXISTS "nodes" (
	"node_id"	INTEGER NOT NULL,
	"x"	INTEGER NOT NULL,
	"y"	INTEGER NOT NULL,
  "isSelectable"	INTEGER NOT NULL,
  "node_name"	TEXT NOT NULL,
	PRIMARY KEY("node_id" AUTOINCREMENT)
);''';

const createRouteMapsTable = '''CREATE TABLE IF NOT EXISTS "route_map" (
	"route_map_id"	INTEGER NOT NULL,
	"maps"	BLOB NOT NULL,
	"total_weight"	INTEGER NOT NULL,
	"location_1"	INTEGER NOT NULL,
	"location_2"	INTEGER NOT NULL,
  "map_name"	TEXT NOT NULL,
  "journey_name"	TEXT NOT NULL,
	"weight_class"	INTEGER NOT NULL,
	"isKnown"	INTEGER NOT NULL,
	PRIMARY KEY("route_map_id" AUTOINCREMENT)
);''';

const createWeightsTable = '''CREATE TABLE IF NOT EXISTS "weights" (
	"node_1"	TEXT NOT NULL,
	"node_2"	TEXT NOT NULL,
	"weight"	INTEGER NOT NULL,
	"weights_id"	INTEGER NOT NULL,
  "weight_class"	INTEGER NOT NULL,
	PRIMARY KEY("weights_id" AUTOINCREMENT)
);''';

const createRoutePointsInBetweenTable =
    '''CREATE TABLE IF NOT EXISTS "route_points" (
	"route_points_id"	INTEGER NOT NULL,
	"location_1"	INTEGER NOT NULL,
	"location_2"	INTEGER NOT NULL,
	"points"	INTEGER NOT NULL,
	"route_id"	INTEGER NOT NULL,
	"position"	INTEGER NOT NULL,
	PRIMARY KEY("route_points_id" AUTOINCREMENT),
	FOREIGN KEY("route_id") REFERENCES "route_map"("route_map_id")
);''';
