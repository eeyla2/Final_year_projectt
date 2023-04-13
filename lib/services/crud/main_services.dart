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
