//This file translates database data into actual dart language that can be implemented

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
          'id = ?', //delete as long as it is under the column 'id' and is equal to some value
      whereArgs: [
        nodeId
      ], //delete if its arguments are equal to that of the argument of this function
    );

//if deleted count is 0 then the user does not exist,
//if it is 1 the the user was deleted

//if deleted count was 0 and exception is thrown
    if (deletedCount != 1) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNodes> updateNode({
    required DatabaseNodes node,
    required Coordinates nodeNewInfo,
  }) async {
    final db = _getDatabaseOrThrow();

    await getNode(nodeId: node.id);

    final updateCount = await db.update(
      nodesTable,
      {
        xColumn: node.x,
        yColumn: node.y,
      },
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNode();
    } else {
      return await getNode(nodeId: node.id);
    }
  }

//gets user from an email inserted
  Future<DatabaseNodes> getNode({required nodeId}) async {
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
      where: 'nodeId = ?', // we are looking for x and y
      whereArgs: [
        nodeId,
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
  Future<DatabaseNodes> createNode(Coordinates node) async {
    final db = _getDatabaseOrThrow();

    final resultX = await db.query(
      nodesTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'x = ?', //in this case we are looking for an x
      whereArgs: [
        node.x
      ], //the x we are looking for is that similar to the argument's x variable
    );

    final resultY = await db.query(
      nodesTable, //checks user table
      limit: 1, //in this case for only 1 item
      where: 'y = ?', //in this case we are looking for a y
      whereArgs: [
        node.y
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
        xColumn: node.x,
        yColumn: node.y,
      },
    );
//return instance of database node using new nodeIdf
    return DatabaseNodes(
      id: nodeId,
      x: node.x,
      y: node.y,
    );
  }

//deletes user from an email inserted
  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow(); //locates database

//this returns the number of deleted users which can only be 0 or 1
    final deletedCount = await db.delete(
      userTable, //choose the table to delete from in this case the userTable
      where:
          'email = ?', //delete as long as it is under the column 'email' and is equal to some value
      whereArgs: [
        email.toLowerCase()
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
  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow(); //locate database and store it

//ask if email exists and store the result as a list inside results
    final results = await db.query(
      userTable, //chjoose user table
      limit: 1, //only look for one email
      where: 'email = ?', // we are looking for email
      whereArgs: [
        email.toLowerCase()
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
  Future<DatabaseUser> createUser({required String email}) async {
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
        email.toLowerCase()
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
          emailColumn: email
              .toLowerCase(), //insert the email argument into the emailColumn
        });

//return an instance of the databaseuser with the userId returned and email argument
    return DatabaseUser(
      id: userId,
      email: email,
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
      await db.execute(createRoutePointsTable);
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
  final Blob maps;
  final int location_1;
  final int location_2;

//constructor
  DatabaseRouteMap({
    required this.id,
    required this.maps,
    required this.location_1,
    required this.location_2,
  });

  DatabaseRouteMap.fromRow(Map<String, Object?> map)
      : id = map[routeMapIdColumn] as int,
        maps = map[mapsColumn] as Blob,
        location_1 = map[location1RouteMapColumn] as int,
        location_2 = map[location2RouteMapColumn] as int;

  @override
  String toString() =>
      'Route_maps , ID = $id, location 1 = $location_1, location_2 = $location_2';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseWeights {
  //variables
  final int id;
  final int node_1;
  final int node_2;
  final int weight;

//constructor
  DatabaseWeights({
    required this.id,
    required this.node_1,
    required this.node_2,
    required this.weight,
  });

  DatabaseWeights.fromRow(Map<String, Object?> map)
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

class DatabaseRoutePoints {
  //variables
  final int id;
  final int location_1;
  final int location_2;
  final int points;

//constructor
  DatabaseRoutePoints({
    required this.id,
    required this.location_1,
    required this.location_2,
    required this.points,
  });

  DatabaseRoutePoints.fromRow(Map<String, Object?> map)
      : id = map[routePointsIdColumn] as int,
        location_1 = map[location1RouteMapColumn] as int,
        location_2 = map[location2RouteMapColumn] as int,
        points = map[pointsColumn] as int;

  @override
  String toString() =>
      'Route points , ID = $id, starting location = $location_1, ending node = $location_2, weight =$points';

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

const dbName = 'legsfree.db';
const userTable = 'user';
const nodesTable = 'nodes';
const routeMapTable = 'route_map';
const weightsTable = 'weights';
const routepointsTable = 'route_points';
const userIdColumn = 'user_id';
const emailColumn = 'email';
const nodesIdColumn = 'node_id';
const xColumn = 'x';
const yColumn = 'y';
const routeMapIdColumn = 'route_map__id';
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
const pointsColumn = 'points';
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
	PRIMARY KEY("route_map_id" AUTOINCREMENT)
);''';

const createWeightsTable = '''CREATE TABLE "weights" (
	"node 1"	INTEGER NOT NULL,
	"node 2"	INTEGER NOT NULL,
	"weight"	INTEGER NOT NULL,
	"weights_id"	INTEGER NOT NULL,
	PRIMARY KEY("weights_id" AUTOINCREMENT)
);''';

const createRoutePointsTable = '''CREATE TABLE IF NOT EXISTS "route_points" (
	"route_points_id"	INTEGER NOT NULL,
	"location_1"	INTEGER NOT NULL,
	"location_2"	INTEGER NOT NULL,
	"points"	INTEGER NOT NULL,
	PRIMARY KEY("route_points_id" AUTOINCREMENT)
);''';
