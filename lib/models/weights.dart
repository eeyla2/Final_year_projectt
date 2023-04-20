import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legsfree/constants/weight_var.dart';

class WeightsModel {
  String? node1, node2;
  int? weight, weightClass;
  WeightsModel({
    required this.node1,
    required this.node2,
    required this.weight,
    required this.weightClass,
  });
  factory WeightsModel.fromMap(Map<String, dynamic> json) => WeightsModel(
        node1: json[WeightVar.node1],
        node2: json[WeightVar.node2],
        weight: json[WeightVar.weight],
        weightClass: json[WeightVar.weightClass],
      );
  Map<String, dynamic> toMap() {
    return {
      WeightVar.node1: node1,
      WeightVar.node2: node2,
      WeightVar.weight: weight,
      WeightVar.weightClass: weightClass,
    };
  }

  WeightsModel.fromDocumentSnapshot(DocumentSnapshot json) {
    node1 = json[WeightVar.node1];
    node2 = json[WeightVar.node2];
    weight = json[WeightVar.weight];
    weightClass = json[WeightVar.weightClass];
  }
}
