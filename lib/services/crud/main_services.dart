//This file translates database data into actual dart language that can be implemented

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'crud_exceptions.dart';

class NotesService {
  Database? _db;
  List<DatabaseMainView> _main = [];

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

//create mainview table ONLY if it does not exist and then execute it
      await db.execute(createMainViewTable);
    } on MissingPlatformDirectoryException {
      //if the MissingPlatformDirectory exception is thrown then our own exception is thrown
      throw UnableToGetDocumentException();
    }
  }
}

//data read from the sqlite database table and passed to xthis service
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
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseMainView {
  //variables
  final int id;
  final int userId;
  final Blob maps;

//constructor
  DatabaseMainView({
    required this.id,
    required this.userId,
    required this.maps,
  });

  DatabaseMainView.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        maps = map[mapsColumn] as Blob;

  @override
  String toString() => 'Main , ID = $id, userID = $userId';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'legsfree.db';
const mainTable = 'mainview';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const mapsColumn = 'maps_id';
const createMainViewTable = '''CREATE TABLE IF NOT EXISTS "mainview" (
	       "id"	INTEGER NOT NULL,
	       "maps"	BLOB NOT NULL,
	       "user_id"	INTEGER NOT NULL,
	       FOREIGN KEY("user_id") REFERENCES "user",
	       PRIMARY KEY("id" AUTOINCREMENT)
);''';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	        "id"	INTEGER NOT NULL,
	        "email"	TEXT NOT NULL UNIQUE,
	        PRIMARY KEY("id" AUTOINCREMENT)
);''';
