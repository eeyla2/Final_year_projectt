import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legsfree/constants/nodes_var.dart';

class NodesModel {
  int? isSelectable, x, y;
  String? name;

  NodesModel({this.isSelectable, this.x, this.name, this.y});

  factory NodesModel.fromMap(Map<String, dynamic> json) => NodesModel(
        isSelectable: json[NodesVar.isSelectable],
        x: json[NodesVar.x],
        name: json[NodesVar.name],
        y: json[NodesVar.y],
      );

  Map<String, dynamic> toMap() {
    return {
      NodesVar.isSelectable: isSelectable,
      NodesVar.name: name,
      NodesVar.x: x,
      NodesVar.y: y
    };
  }

  NodesModel.fromDocumentSnapshot(DocumentSnapshot json) {
    isSelectable = json[NodesVar.isSelectable];
    x = json[NodesVar.x];
    name = json[NodesVar.name];
    y = json[NodesVar.y];
  }
}
