import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legsfree/constants/weight_var.dart';

class WeightsModel {
  String? node1, node2;
  int? weight, weightClass, weightID;
  WeightsModel({
    this.node1,
    this.node2,
    this.weight,
    this.weightClass,
    this.weightID,
  });
  factory WeightsModel.fromMap(Map<String, dynamic> json) => WeightsModel(
      node1: json[WeightVar.node1],
      node2: json[WeightVar.node2],
      weight: json[WeightVar.weight],
      weightClass: json[WeightVar.weightClass],
      weightID: json[WeightVar.weightID]);
  Map<String, dynamic> toMap() {
    return {
      WeightVar.node1: node1,
      WeightVar.node2: node2,
      WeightVar.weight: weight,
      WeightVar.weightClass: weightClass,
      WeightVar.weightID: weightID
    };
  }

  WeightsModel.fromDocumentSnapshot(DocumentSnapshot json) {
    node1 = json[WeightVar.node1];
    node2 = json[WeightVar.node2];
    weight = json[WeightVar.weight];
    weightClass = json[WeightVar.weightClass];
    weightID = json[WeightVar.weightID];
  }
}
