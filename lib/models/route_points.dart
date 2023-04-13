import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legsfree/constants/route_points_var.dart';

class RoutePointsModel {
  int? position;
  String? location1, location2, points, journeyName;
  RoutePointsModel(
      {this.location1,
      this.location2,
      this.points,
      this.position,
      this.journeyName});
  factory RoutePointsModel.fromMap(Map<String, dynamic> json) =>
      RoutePointsModel(
        location1: json[RoutePointsVar.location1].toString(),
        location2: json[RoutePointsVar.location2].toString(),
        points: json[RoutePointsVar.points].toString(),
        position: json[RoutePointsVar.position] as int,
        journeyName: json[RoutePointsVar.journeyName].toString(),
      );
  Map<String, dynamic> toMap() {
    return {
      RoutePointsVar.location1: location1,
      RoutePointsVar.location2: location2,
      RoutePointsVar.points: points,
      RoutePointsVar.position: position,
      RoutePointsVar.journeyName: journeyName,
    };
  }

  RoutePointsModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    location1 = doc[RoutePointsVar.location1].toString();
    location2 = doc[RoutePointsVar.location2].toString();
    points = doc[RoutePointsVar.points].toString();
    position = doc[RoutePointsVar.position] as int;
    journeyName = doc[RoutePointsVar.journeyName].toString();
  }
}
