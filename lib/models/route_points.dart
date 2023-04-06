import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legsfree/constants/route_points_var.dart';

class RoutePointsModel {
  int? id, location1, location2, points, position, routeID;
  RoutePointsModel(
      {this.id,
      this.location1,
      this.location2,
      this.points,
      this.position,
      this.routeID});
  factory RoutePointsModel.fromMap(Map<String, dynamic> json) =>
      RoutePointsModel(
          id: json[RoutePointsVar.id],
          location1: json[RoutePointsVar.location1],
          location2: json[RoutePointsVar.location2],
          points: json[RoutePointsVar.points],
          position: json[RoutePointsVar.position],
          routeID: json[RoutePointsVar.routeId]);
  Map<String,dynamic> toMap(){
    return {
      RoutePointsVar.id:id,
      RoutePointsVar.location1:location1,
      RoutePointsVar.location2:location2,
      RoutePointsVar.points:points,
      RoutePointsVar.position:position,
      RoutePointsVar.routeId:routeID,
    };
  }
  RoutePointsModel.fromDocumentSnapshot(DocumentSnapshot doc){
    id=doc[RoutePointsVar.id];
    location1=doc[RoutePointsVar.location1];
    location2=22;
    points=doc[RoutePointsVar.points];
    position=doc[RoutePointsVar.position];
    routeID=doc[RoutePointsVar.routeId];
  }
}
