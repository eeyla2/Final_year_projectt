//exceptions

import 'dart:developer' as devtools show log;

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentException implements Exception {}

class DatabaseIsNotOpenException implements Exception {}

class NodeAlreadyExists implements Exception {}

class CouldNotDeleteNode implements Exception {}

class CouldNotFindNode implements Exception {}

class CouldNotFindSpecificNode implements Exception {}

class CouldNotUpdateNode implements Exception {}

class PointsInBetweenAlreadyExists implements Exception {}

class CouldNotFindPointsInBetween implements Exception {}

class CouldNotFindSpecificPointsInBetween implements Exception {}

class CouldNotUpdatePointsInBetween implements Exception {}

class CouldNotDeletePointsInBetween implements Exception {}

class NodesWeightAlreadyExists implements Exception {}

class CouldNotFindNodesWeight implements Exception {}

class CouldNotFindSpecificNodesWeight implements Exception {
  late String message;

  CouldNotFindSpecificNodesWeight(this.message) {
    devtools.log('this Weight could not be found = $message');
  }
}

class CouldNotUpdateNodesWeight implements Exception {}

class CouldNotDeleteNodesWeight implements Exception {}

class MapImageAlreadyExists implements Exception {}

class CouldNotFindMapImage implements Exception {}

class CouldNotFindSpecificMapImage implements Exception {}

class CouldNotUpdateMapImage implements Exception {}

class CouldNotDeleteMapImage implements Exception {}
