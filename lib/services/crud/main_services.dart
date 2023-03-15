//This file translates database data into actual dart language that can be implemented

import 'dart:io';
import 'dart:typed_data';
//import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';
import 'package:quiver/core.dart';

class MainService {
  Database? _db;
  //List<DatabaseRouteMaps> _main = [];

//deletes all nodes
  Future<int> deleteAllMaps() async {
    final db = _getDatabaseOrThrow();

    return await db.delete(routeMapTable);
  }

//get all the nodes
  Future<Iterable<DatabaseRouteMap>> getAllMaps() async {
    final db = _getDatabaseOrThrow();
    final imageInfo = await db.query(routeMapTable);

    return imageInfo
        .map((routeMapRow) => DatabaseRouteMap.fromRow(routeMapRow));
  }

//deletes node using nodeId inserted
  Future<void> deleteMaps({required int theImageInfoId}) async {
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
    }
  }

  Future<DatabaseRouteMap> updateMaps({
    required DatabaseRouteMap theImageInfo,
    required ImageInfo theImageInfoNew,
  }) async {
    final db = _getDatabaseOrThrow();

    await getMaps(theImageInfoId: theImageInfo.id);

    var imageFile = File(theImageInfoNew.mapFileName);
    var imageAsBytes = await imageFile.readAsBytes();

    final updateCount = await db.update(
      routeMapTable,
      {
        mapFileNameColumn: theImageInfoNew.mapFileName,
        mapsColumn: imageAsBytes,
        totalWeightColumn: theImageInfoNew.totalWeight,
      },
    );

    if (updateCount == 0) {
      throw CouldNotUpdateMapImage();
    } else {
      return await getMaps(theImageInfoId: theImageInfo.id);
    }
  }

//gets user from an email inserted
  Future<DatabaseRouteMap> getMaps({required int theImageInfoId}) async {
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
      return DatabaseRouteMap.fromRow(results.first);
    } else {
      throw CouldNotFindMapImage();
    }
  }

//create a new node
  Future<DatabaseRouteMap> createMaps(ImageInfo theImageInfo) async {
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
      },
    );
//return instance of database node using new nodeIdf
    return DatabaseRouteMap(
      id: routeMapId,
      location_1: theImageInfo.location1,
      location_2: theImageInfo.location2,
      maps: imageAsBytes,
      mapFileName: theImageInfo.mapFileName,
      totalWeight: theImageInfo.totalWeight,
    );
  }

//deletes all nodes
  Future<int> deleteAllWeights() async {
    final db = _getDatabaseOrThrow();

    return await db.delete(nodesWeightsTable);
  }

//get all the nodes
  Future<Iterable<DatabaseNodesWeights>> getAllWeights() async {
    final db = _getDatabaseOrThrow();
    final nodesWeight = await db.query(nodesWeightsTable);

    return nodesWeight
        .map((nodeWeightRow) => DatabaseNodesWeights.fromRow(nodeWeightRow));
  }

//deletes node using nodeId inserted
  Future<void> deleteWeights({required int theNodesWeightId}) async {
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
    }
  }

  Future<DatabaseNodesWeights> updateWeights({
    required DatabaseNodesWeights theNodesWeight,
    required NodesWeight theNodesWeightNewInfo,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNodesWeights(theNodesWeightsId: theNodesWeight.id);

    final updateCount = await db.update(
      nodesWeightsTable,
      {
        node1Column: theNodesWeightNewInfo.node1,
        node2Column: theNodesWeightNewInfo.node2,
      },
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNode();
    } else {
      return await getNodesWeights(theNodesWeightsId: theNodesWeight.id);
    }
  }

//gets user from an email inserted
  Future<DatabaseNodesWeights> getNodesWeights(
      {required int theNodesWeightsId}) async {
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
      return DatabaseNodesWeights.fromRow(results.first);
    } else {
      throw CouldNotFindNodesWeight();
    }
  }

//create a new node
  Future<DatabaseNodesWeights> createNodesWeights(
      NodesWeight theWeights) async {
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

//if the results variable is not empty that means there is an email similar to ours
//in that case throw an exception
    if ((resultX.isNotEmpty) && (resultY.isNotEmpty)) {
      throw NodesWeightAlreadyExists();
    }

//insert x and y variable of argument and return a node id
    final weightId = await db.insert(
      nodesWeightsTable,
      {
        node1Column: theWeights.node1,
        node2Column: theWeights.node2,
      },
    );
//return instance of database node using new nodeIdf
    return DatabaseNodesWeights(
      id: weightId,
      node_1: theWeights.node1,
      node_2: theWeights.node1,
      weight: theWeights.weight,
    );
  }

//deletes all nodes
  Future<int> deleteAllPointsInBetween() async {
    final db = _getDatabaseOrThrow();

    return await db.delete(routePointsInBetweenTable);
  }

//get all the nodes
  Future<Iterable<DatabaseRoutePointsInBetween>> getAllPointsInBetween() async {
    final db = _getDatabaseOrThrow();
    final pointsInBetween = await db.query(routePointsInBetweenTable);

    return pointsInBetween.map((pointsInBetweenRow) =>
        DatabaseRoutePointsInBetween.fromRow(pointsInBetweenRow));
  }

//deletes node using nodeId inserted
  Future<void> deletePointsInBetween(
      {required int theRoutePointsInBetweenId}) async {
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
    }
  }

  Future<DatabaseRoutePointsInBetween> updatePointsInBetween({
    required DatabaseRoutePointsInBetween theRoutePointsInBetween,
    required PointsInBetween theRoutePointsInBetweenNewInfo,
  }) async {
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
      return await getPointsInBetween(
          theRoutePointsInBetweenId: theRoutePointsInBetween.id);
    }
  }

//gets user from an email inserted
  Future<DatabaseRoutePointsInBetween> getPointsInBetween(
      {required int theRoutePointsInBetweenId}) async {
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
    if (results.isNotEmpty) {
      return DatabaseRoutePointsInBetween.fromRow(results.first);
    } else {
      throw CouldNotFindRoutePointsInBetween();
    }
  }

//create a new node
  Future<DatabaseRoutePointsInBetween> createPointsInBetween(
      PointsInBetween points) async {
    final db = _getDatabaseOrThrow();

    final results = await db.query(
      routePointsInBetweenTable, //checks user table
      where: 'points = ?', //in this case we are looking for an x
      whereArgs: [
        points.pointsInBetween,
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
      },
    );

//return instance of database node using new nodeIdf
    return DatabaseRoutePointsInBetween(
      id: pointsInBetweenId,
      location_1: points.location1,
      location_2: points.location2,
      pointsInBetween: points.pointsInBetween,
    );
  }

//deletes all nodes
  Future<int> deleteAllNodes() async {
    final db = _getDatabaseOrThrow();

    return await db.delete(nodesTable);
  }

//get all the nodes
  Future<Iterable<DatabaseNodes>> getAllNodes() async {
    final db = _getDatabaseOrThrow();
    final nodes = await db.query(nodesTable);

    return nodes.map((nodeRow) => DatabaseNodes.fromRow(nodeRow));
  }

//deletes node using nodeId inserted
  Future<void> deleteNode({required int nodeId}) async {
    final db = _getDatabaseOrThrow(); //locates database

//this returns the number of deleted nodes which can only be 0 or 1
    final deletedCount = await db.delete(
      nodesTable, //choose the table to delete from in this case the nodesTable
      where:
          'node_id = ?', //delete as long as it is under the column 'id' and is equal to some value
      whereArgs: [
        nodeId
      ], //delete if its arguments are equal to that of the argument of this function
    );

//if deleted count is 0 then the user does not exist,
//if it is 1 the the user was deleted

//if deleted count was 0 and exception is thrown
    if (deletedCount != 1) {
      throw CouldNotDeleteNode();
    }
  }

  Future<DatabaseNodes> updateNode({
    required DatabaseNodes thenode,
    required Coordinates thenodeNewInfo,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNode(theId: thenode.id);

    final updateCount = await db.update(
      nodesTable,
      {
        xColumn: thenode.x,
        yColumn: thenode.y,
      },
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNode();
    } else {
      return await getNode(theId: thenode.id);
    }
  }

//gets user from an email inserted
  Future<DatabaseNodes> getNode({required int theId}) async {
    final db = _getDatabaseOrThrow(); //locate database and store it

//ask if x exists and store the result as a list inside results
    /* final results = await db.query(
      nodesTable, //choose nodes table
      limit: 1, //only look for one node
      where: 'x = ? and y = ?', // we are looking for x and y

      whereArgs: [
        node.x,
        node.y,
      ], //the x and y we are looking for has the same content as our argument
    );
*/

    final results = await db.query(
      nodesTable, //choose nodes table
      limit: 1, //only look for one node
      where: 'node_Id = ?', // we are looking for x and y
      whereArgs: [
        theId,
      ], //the x and y we are looking for has the same content as our argument
    );
//if no results were returned throw an exception or return the node we are looking for
//in the list created above
    if (results.isNotEmpty) {
      return DatabaseNodes.fromRow(results.first);
    } else {
      throw CouldNotFindNode();
    }
  }

//create a new node
  Future<DatabaseNodes> createNode(Coordinates thenode) async {
    final db = _getDatabaseOrThrow();

    final resultX = await db.query(
      nodesTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'x = ?', //in this case we are looking for an x
      whereArgs: [
        thenode.x
      ], //the x we are looking for is that similar to the argument's x variable
    );

    final resultY = await db.query(
      nodesTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'y = ?', //in this case we are looking for a y
      whereArgs: [
        thenode.y
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
        xColumn: thenode.x,
        yColumn: thenode.y,
      },
    );
//return instance of database node using new nodeIdf
    return DatabaseNodes(
      id: nodeId,
      x: thenode.x,
      y: thenode.y,
    );
  }

//deletes user from an email inserted
  Future<void> deleteUser({required String theemail}) async {
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

//opens database
  Future<void> open() async {
    //if database is open already then throw an exception
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
//try to open database and create tables
    try {
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

//create routeMapsTable ONLY if it does not exist and then execute it
      await db.execute(createRouteMapsTable);

//create weights table ONLY if it does not exist and then execute it
      await db.execute(createWeightsTable);

      //create routePointsTable table ONLY if it does not exist and then execute it
      await db.execute(createRoutePointsInBetweenTable);
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

//constructor
  DatabaseNodes({
    required this.id,
    required this.x,
    required this.y,
  });

  DatabaseNodes.fromRow(Map<String, Object?> map)
      : id = map[nodesIdColumn] as int,
        x = map[xColumn] as int,
        y = map[yColumn] as int;

  @override
  String toString() => 'Nodes , ID = $id, x-coordinate = $x, y-coordinate = $y';

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

//constructor
  DatabaseRouteMap({
    required this.id,
    required this.maps,
    required this.mapFileName,
    required this.location_1,
    required this.location_2,
    required this.totalWeight,
  });

  //String photo(String mapName)

  DatabaseRouteMap.fromRow(Map<String, Object?> map)
      : id = map[routeMapIdColumn] as int,
        maps = map[mapsColumn] as Uint8List,
        mapFileName = map[mapFileNameColumn] as String,
        location_1 = map[location1RouteMapColumn] as int,
        location_2 = map[location2RouteMapColumn] as int,
        totalWeight = map[totalWeightColumn] as int;

  @override
  String toString() =>
      'Route_maps , ID = $id, location 1 = $location_1, location_2 = $location_2';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNodesWeights {
  //variables
  final int id;
  final int node_1;
  final int node_2;
  final int weight;

//constructor
  DatabaseNodesWeights({
    required this.id,
    required this.node_1,
    required this.node_2,
    required this.weight,
  });

  DatabaseNodesWeights.fromRow(Map<String, Object?> map)
      : id = map[weightsIdColumn] as int,
        node_1 = map[xColumn] as int,
        node_2 = map[yColumn] as int,
        weight = map[weightColumn] as int;

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

//constructor
  DatabaseRoutePointsInBetween({
    required this.id,
    required this.location_1,
    required this.location_2,
    required this.pointsInBetween,
  });

  DatabaseRoutePointsInBetween.fromRow(Map<String, Object?> map)
      : id = map[routePointsIdColumn] as int,
        location_1 = map[location1RouteMapColumn] as int,
        location_2 = map[location2RouteMapColumn] as int,
        pointsInBetween = map[pointsInBetweenColumn] as int;

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
  final int x, y;

  Coordinates({required this.x, required this.y});

  @override
  String toString() => 'coordinates , x= $x, starting location = $y';

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
  final int location1, location2, pointsInBetween;

  PointsInBetween(
      {required this.location1,
      required this.location2,
      required this.pointsInBetween});

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
  final int node1;
  final int node2;
  final int weight;

  NodesWeight(this.node1, this.node2, this.weight);

  @override
  String toString() =>
      'weight between two nodes ,  node1 = $node1, node2 = $node2, weight = $weight';

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

  ImageInfo(this.location1, this.location2, this.totalWeight, this.mapImage,
      this.mapFileName);

  @override
  String toString() =>
      'total route weight, location1 = $location1, location2 = $location2, weight = $totalWeight, file name =$mapFileName';

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

const dbName = 'legsfree.db';
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
const routeMapIdColumn = 'route_map__id';
const mapFileNameColumn = 'map_name';
const mapsColumn = 'maps';
const location1RouteMapColumn = 'location_1';
const location2RouteMapColumn = 'location_2';
const totalWeightColumn = 'total_weight';
const weightsIdColumn = 'weights_Id';
const node1Column = 'node_1';
const node2Column = 'node_2';
const weightColumn = 'weight';
const routePointsIdColumn = 'route_points_id';
const location1RoutePointsColumn = 'location_1';
const location2RoutePointsColumn = 'location_2';
const pointsInBetweenColumn = 'points';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	"user_id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("user_id" AUTOINCREMENT)
);''';

const createNodesTable = '''CREATE TABLE IF NOT EXISTS "nodes" (
	"node_id"	INTEGER NOT NULL,
	"x"	INTEGER NOT NULL,
	"y"	INTEGER NOT NULL,
	PRIMARY KEY("node_id" AUTOINCREMENT)
);''';

const createRouteMapsTable = '''CREATE TABLE IF NOT EXISTS "route_map" (
	"route_map_id"	INTEGER NOT NULL,
	"maps"	BLOB NOT NULL,
	"total_weight"	INTEGER NOT NULL,
	"location_1"	INTEGER NOT NULL,
	"location_2"	INTEGER NOT NULL,
  "map_name"	TEXT NOT NULL,
	PRIMARY KEY("route_map_id" AUTOINCREMENT)
);''';

const createWeightsTable = '''CREATE TABLE IF NOT EXISTS "weights" (
	"node_1"	INTEGER NOT NULL,
	"node_2"	INTEGER NOT NULL,
	"weight"	INTEGER NOT NULL,
	"weights_id"	INTEGER NOT NULL,
	PRIMARY KEY("weights_id" AUTOINCREMENT)
);''';

const createRoutePointsInBetweenTable =
    '''CREATE TABLE IF NOT EXISTS "route_points" (
	"route_points_id"	INTEGER NOT NULL,
	"location_1"	INTEGER NOT NULL,
	"location_2"	INTEGER NOT NULL,
	"points"	INTEGER NOT NULL,
	PRIMARY KEY("route_points_id" AUTOINCREMENT)
);''';
