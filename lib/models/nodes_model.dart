import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legsfree/constants/nodes_var.dart';

class NodesModel {
  int? id, isSelectable, x, y;
  String? name;
  NodesModel({this.id, this.isSelectable, this.x, this.name, this.y});
  factory NodesModel.fromMap(Map<String, dynamic> json) => NodesModel(
      id: json[NodesVar.id],
      isSelectable: json[NodesVar.isSelectable],
      x: json[NodesVar.x],
      name: json[NodesVar.name],
      y: json[NodesVar.y]);
  Map<String, dynamic> toMap() {
    return {
      NodesVar.id: id,
      NodesVar.isSelectable: isSelectable,
      NodesVar.name: name,
      NodesVar.x: x,
      NodesVar.y: y
    };
  }

  NodesModel.fromDocumentSnapshot(DocumentSnapshot json) {
    id = json[NodesVar.id];
    isSelectable = json[NodesVar.isSelectable];
    x = json[NodesVar.x];
    name = json[NodesVar.name];
    y = json[NodesVar.y];
  }
}
