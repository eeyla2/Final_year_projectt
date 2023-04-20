import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legsfree/constants/route_points_var.dart';
import 'package:legsfree/constants/routes_map_var.dart';

class RouteMapModel {
  //variables
  int? isKnown, totalWeight, weightClass;
  String? journeyName, mapName, location1, location2, maps;
  //constructor
  RouteMapModel(
      {required this.isKnown,
      required this.journeyName,
      required this.location1,
      required this.location2,
      required this.mapName,
      required this.maps,
      required this.totalWeight,
      required this.weightClass});
  //named second constructor
  // RouteMapModel.routeWeight({
  //   required String startLocation,
  //   required String destination,
  //   required int weightRoute,
  // }) {
  //   location1 = startLocation;
  //   location2 = destination;
  //   totalWeight = weightRoute;
  // }
  //extracting data from database
  factory RouteMapModel.fromMap(Map<String, dynamic> json) => RouteMapModel(
        isKnown: json[RouteMapsVar.isKnown],
        journeyName: json[RouteMapsVar.journeyName],
        location1: json[RouteMapsVar.location1],
        location2: json[RouteMapsVar.location2],
        mapName: json[RouteMapsVar.mapName],
        maps: json[RouteMapsVar.maps],
        totalWeight: json[RouteMapsVar.totalWeight],
        weightClass: json[RouteMapsVar.weightClass],
      );
  //sending data to databse
  Map<String, dynamic> toMap() {
    return {
      RouteMapsVar.isKnown: isKnown,
      RouteMapsVar.journeyName: journeyName,
      RouteMapsVar.location1: location1,
      RoutePointsVar.location2: location2,
      RouteMapsVar.mapName: mapName,
      RouteMapsVar.maps: maps,
      RouteMapsVar.totalWeight: totalWeight,
      RouteMapsVar.weightClass: weightClass,
    };
  }

  RouteMapModel.fromDocumentSnapshot(DocumentSnapshot json) {
    isKnown = json[RouteMapsVar.isKnown];
    journeyName = json[RouteMapsVar.journeyName];
    location1 = json[RouteMapsVar.location1];
    location2 = json[RouteMapsVar.location2];
    mapName = json[RouteMapsVar.mapName];
    maps = json[RouteMapsVar.maps];
    totalWeight = json[RouteMapsVar.totalWeight];
    weightClass = json[RouteMapsVar.weightClass];
  }
}
