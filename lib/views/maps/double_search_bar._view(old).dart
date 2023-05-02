// import 'package:flutter/material.dart';

// import 'package:flutter/scheduler.dart';
// // import 'package:flutter/src/widgets/framework.dart';
// // import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
// import 'package:nil/nil.dart';
// import 'dart:developer' as devtools show log;

// import '../../constants/routes.dart';
// import '../../models/nodes_model.dart';
// import '../../services/local db helper/local_db_helper.dart';

// class DoubleSearchBarView extends StatefulWidget {
//   const DoubleSearchBarView({super.key});

//   @override
//   State<DoubleSearchBarView> createState() => _DoubleSearchBarStateView();
// }

// class _DoubleSearchBarStateView extends State<DoubleSearchBarView> {
// //varibales for the nodes
//   List<NodesModel> allNodes = [];
//   List<String> selectableDestinations = [];

//   final LocalDBhelper _localDBhelper = LocalDBhelper();

//   //variables for the Starter location search bar
//   late FloatingSearchBarController searchControllerStarting;
//   List<String> filteredSearchSuggestionsStarting = ["TEST"];
//   String? selectedTermStarting = '';
//   late List<String> searchSuggestionsStarting = [];
//   static const historyLengthStarting = 5;
//   late bool isSubmittedStartingBar;
//   late bool isTappedStartingTiles;

//   //variables for the Destination search bar
//   late FloatingSearchBarController searchControllerDestination;
//   List<String> filteredSearchSuggestionsDestination = ["Test"];
//   String? selectedTermDestination = '';
//   late List<String> searchSuggestionsDestination = [];
//   static const historyLengthDestination = 5;
//   late bool isSubmittedDestinationBar;
//   late bool isTappedDestinationTiles;

//   //late int number;

//   late bool nothingDoneYet = ((isSubmittedStartingBar == false) &&
//       (isTappedStartingTiles == false) &&
//       (isSubmittedDestinationBar == false) &&
//       (isTappedDestinationTiles == false));
//   late bool startLocationSearchChosen = ((isSubmittedStartingBar == true) &&
//       (isTappedStartingTiles == false) &&
//       (isSubmittedDestinationBar == false) &&
//       (isTappedDestinationTiles == false));
//   late bool startTileChosen = ((isSubmittedStartingBar == true) &&
//       (isTappedStartingTiles == true) &&
//       (isSubmittedDestinationBar == false) &&
//       (isTappedDestinationTiles == false));
//   late bool destinationChosen = ((isSubmittedStartingBar == true) &&
//       (isTappedStartingTiles == true) &&
//       (isSubmittedDestinationBar == true) &&
//       (isTappedDestinationTiles == false));
//   late bool destinationTileChosen = ((isSubmittedStartingBar == true) &&
//       (isTappedStartingTiles == true) &&
//       (isSubmittedDestinationBar == true) &&
//       (isTappedDestinationTiles == true));

//   //get nodes
//   getAllNodes() async {
//     allNodes = await _localDBhelper.getNodes();
//     //variable to store selectable destinations

//     //for loop that goes through all nodes
//     for (int j = 0; j < allNodes.length; ++j) {
//       //if node is selectable store it inside a selectableDestination variable
//       if (allNodes[j].isSelectable! == 1) {
//         selectableDestinations.add(allNodes[j].name!);
//       }
//       //print('Selectable Destinations = ${selectableDestinations.length}');
//     }
//   }

// //STARTER SEARCHBAR FUNCTIONS

//   //filter search terms so that the most relative search term returns
//   List<String> filteredSearchTermStarting({
//     required String? filter,
//   }) {
//     if (filter != null && filter.isNotEmpty) {
//       List<String> checkIfEmpty = searchSuggestionsStarting.reversed
//           .where((term) => term.startsWith(filter))
//           .toList();

//       if (checkIfEmpty.isNotEmpty) {
//         return checkIfEmpty;
//       } else {
//         return searchSuggestionsStarting.reversed.toList();
//       }
//     } else {
//       return searchSuggestionsStarting.reversed.toList();
//     }
//   }

//   void deleteSearchTermStarting(String term) {
//     searchSuggestionsStarting.removeWhere((t) => t == term);
//     filteredSearchSuggestionsStarting =
//         filteredSearchTermStarting(filter: null);
//   }

//   void addSearchTermStarting(String term) {
//     if (searchSuggestionsStarting.contains(term)) {
//       putSearchTermFirstStarting(term);
//       return;
//     }
//     searchSuggestionsStarting.add(term);
//     if (searchSuggestionsStarting.length > historyLengthStarting) {
//       searchSuggestionsStarting.removeRange(
//           0, (searchSuggestionsStarting.length - historyLengthStarting));
//     }

//     filteredSearchSuggestionsStarting =
//         filteredSearchTermStarting(filter: null);
//   }

//   void putSearchTermFirstStarting(String term) {
//     deleteSearchTermStarting(term);
//     addSearchTermStarting(term);
//   }

//   Widget listViewSearchStarting() {
//     int? listLength = filteredSearchSuggestionsStarting.length;
//     return ListView(
//       //padding: EdgeInsets.only(top: fsb.height +fsb.margins.vertical),
//       children: List.generate(
//         listLength,
//         growable: true,
//         (index) => ListTile(
//           title: Text(filteredSearchSuggestionsStarting[index]),
//           subtitle: const Text('University Park Campus'),
//           onTap: () {
//             setState(() {
//               isTappedStartingTiles = true;
//               isTappedDestinationTiles = false;
//               isSubmittedStartingBar = true;
//               isSubmittedDestinationBar = false;
//             });
//             devtools.log(
//                 "After start location tile tapped = nothingDoneYet = $nothingDoneYet, startLocationChosen =  $startLocationSearchChosen, destinationChosen = $destinationChosen,destinationTilesCHosen =  $destinationTileChosen");
//             //searchControllerDestination.open();
//           },
//         ),
//       ),
//     );
//   }

//   Widget listViewSearchDestination() {
//     int? listLength = filteredSearchSuggestionsDestination.length;
//     return ListView(
//       //padding: EdgeInsets.only(top: fsb.height +fsb.margins.vertical),
//       children: List.generate(
//         listLength,
//         growable: true,
//         (index) => ListTile(
//           title: Text(filteredSearchSuggestionsDestination[index]),
//           subtitle: const Text('University Park Campus'),
//           onTap: () {
//             setState(() {
//               isTappedDestinationTiles = true;
//               isTappedStartingTiles = true;
//               isSubmittedDestinationBar = true;
//               isSubmittedStartingBar = true;

//               SchedulerBinding.instance.addPostFrameCallback((_) {
//                 Navigator.of(context).pushNamedAndRemoveUntil(
//                   newMapsRoute,
//                   (_) => false,
//                 );
//                 // searchControllerDestination.open();
//                 //FocusManager.instance.primaryFocus?.unfocus();
//               });
//             });

//             devtools.log(
//                 "After destination tile pressed= nothingDoneYet = $nothingDoneYet, startLocationChosen =  $startLocationSearchChosen, destinationChosen = $destinationChosen,destinationTilesCHosen =  $destinationTileChosen");
//           },
//         ),
//       ),
//     );
//   }

//   defaultView() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(
//             Icons.search,
//             size: 30,
//           ),
//           Text(
//             'Start Searching',
//             style: Theme.of(context).textTheme.headlineMedium,
//           ),
//         ],
//       ),
//     );
//   }

// //DESTINATION SEARCHBAR FUNCTIONS

// //filter search terms so that the most relative search term returns
//   List<String> filteredSearchTermDestination({
//     required String? filter,
//   }) {
//     if (filter != null && filter.isNotEmpty) {
//       //List<String> checkIfEmpty =
//       List<String> checkIfEmpty = searchSuggestionsDestination.reversed
//           .where((term) => term.startsWith(filter))
//           .toList();
//       if (checkIfEmpty.isNotEmpty) {
//         return checkIfEmpty;
//       } else {
//         return searchSuggestionsDestination.reversed.toList();
//       }
//     } else {
//       return searchSuggestionsDestination.reversed.toList();
//     }
//   }

//   void deleteSearchTermDestination(String term) {
//     searchSuggestionsStarting.removeWhere((t) => t == term);
//     filteredSearchSuggestionsStarting =
//         filteredSearchTermStarting(filter: null);
//   }

//   void addSearchTermDestination(String term) {
//     if (searchSuggestionsStarting.contains(term)) {
//       putSearchTermFirstDestination(term);
//       return;
//     }
//     searchSuggestionsStarting.add(term);
//     if (searchSuggestionsStarting.length > historyLengthStarting) {
//       searchSuggestionsStarting.removeRange(
//           0, (searchSuggestionsStarting.length - historyLengthStarting));
//     }

//     filteredSearchSuggestionsStarting =
//         filteredSearchTermDestination(filter: null);
//   }

//   void putSearchTermFirstDestination(String term) {
//     deleteSearchTermStarting(term);
//     addSearchTermStarting(term);
//   }

//   @override
//   void initState() {
//     //get nodes
//     getAllNodes();
//     //starting bar intializations
//     searchSuggestionsStarting = selectableDestinations;
//     filteredSearchSuggestionsStarting =
//         filteredSearchTermStarting(filter: null);
//     searchControllerStarting = FloatingSearchBarController();
//     isSubmittedStartingBar = false;
//     isTappedStartingTiles = false;
//     //destination bar initilization
//     searchSuggestionsDestination = selectableDestinations;
//     filteredSearchSuggestionsDestination =
//         filteredSearchTermDestination(filter: null);
//     searchControllerDestination = FloatingSearchBarController();
//     isSubmittedDestinationBar = false;
//     isTappedDestinationTiles = false;

//     //number = 0;
//     super.initState();
//   }

//   getAllData() async {
//     await getAllNodes();
//   }

//   @override
//   Widget build(BuildContext context) {
//     nothingDoneYet = ((isSubmittedStartingBar == false) &&
//         (isTappedStartingTiles == false) &&
//         (isSubmittedDestinationBar == false) &&
//         (isTappedDestinationTiles == false));
//     startLocationSearchChosen = ((isSubmittedStartingBar == true) &&
//         (isTappedStartingTiles == false) &&
//         (isSubmittedDestinationBar == false) &&
//         (isTappedDestinationTiles == false));
//     startTileChosen = ((isSubmittedStartingBar == true) &&
//         (isTappedStartingTiles == true) &&
//         (isSubmittedDestinationBar == false) &&
//         (isTappedDestinationTiles == false));
//     destinationChosen = ((isSubmittedStartingBar == true) &&
//         (isTappedStartingTiles == true) &&
//         (isSubmittedDestinationBar == true) &&
//         (isTappedDestinationTiles == false));
//     destinationTileChosen = ((isSubmittedStartingBar == true) &&
//         (isTappedStartingTiles == true) &&
//         (isSubmittedDestinationBar == true) &&
//         (isTappedDestinationTiles == true));

//     return Scaffold(
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(150),
//           child: AppBar(
//             toolbarHeight: 150,
//             actions: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 //crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CircularButton(
//                     padding: const EdgeInsets.only(bottom: 10, right: 40),
//                     icon: const Icon(Icons.arrow_back),
//                     onPressed: () {
//                       SchedulerBinding.instance.addPostFrameCallback((_) {
//                         Navigator.of(context).pushNamedAndRemoveUntil(
//                           mapsRoute,
//                           (_) => false,
//                         );
//                         //FocusManager.instance.primaryFocus?.unfocus();
//                       });
//                     },
//                   ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: <Widget>[
//                       Expanded(
//                         child: Container(
//                           height: double.infinity,
//                           width: MediaQuery.of(context).size.height * 0.5,
//                           // change tomorrowwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
//                           color: const Color.fromARGB(255, 54, 184, 244),
//                           child: buildFloatingSearchBarStartLocation(context),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           height: double.infinity,
//                           width: MediaQuery.of(context).size.height * 0.5,
//                           // change tomorrowwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
//                           color: const Color.fromARGB(255, 54, 184, 244),
//                           child: buildFloatingSearchBarDestination(context),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         body: nothingDoneYet
//             ? defaultView()
//             : startLocationSearchChosen
//                 ? listViewSearchStarting()
//                 : startTileChosen
//                     ? defaultView()
//                     : destinationChosen
//                         ? listViewSearchDestination()
//                         : destinationTileChosen
//                             ? defaultView()
//                             : const SizedBox()
//         //Center(
//         //renderWidget(number),
//         //);
//         );
//   }

//   //floating search bar implementation
//   Widget buildFloatingSearchBarStartLocation(BuildContext context) {
//     //get a query(info) about the current media orientation
//     //and if it has an orientation of a portrait return true
//     final isPortrait =
//         MediaQuery.of(context).orientation == Orientation.portrait;
//     String hintVar = 'Search start location';
// //return a floating search bar
//     return FloatingSearchBar(
//       hint: hintVar,
//       // text shown inside search bar
//       //all the characterstics of searchh bar
//       scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
//       transitionDuration: const Duration(milliseconds: 800),
//       transitionCurve: Curves.easeInOut,
//       physics: const BouncingScrollPhysics(),
//       axisAlignment: isPortrait ? 0.0 : -1.0,
//       openAxisAlignment: 0.0,
//       width: MediaQuery.of(context).size.width * 0.8,
//       borderRadius: BorderRadius.circular(8),
//       elevation: 0,
//       backdropColor: Colors.blue,
//       //isPortrait ? 600 : 500,
//       //height: double.infinity,
//       closeOnBackdropTap: true,
//       debounceDelay: const Duration(milliseconds: 500),
//       clearQueryOnClose: false,
//       //check this again when needed
//       controller: searchControllerStarting,
//       onQueryChanged: (query) {
//         setState(() {
//           //searchControllerStarting.open();
//           filteredSearchSuggestionsStarting =
//               filteredSearchTermStarting(filter: query);
//         });
//         // Call your model, bloc, controller here.
//       },

//       onSubmitted: (query) {
//         setState(() {
//           //addSearchTerm(query);
//           selectedTermStarting = query;
//           isSubmittedStartingBar = true;
//           isTappedStartingTiles = false;
//           isTappedDestinationTiles = false;
//           isSubmittedDestinationBar = false;
//           // if (number == 0) {
//           //   //number = 1;
//           // }
//           devtools.log(
//               "After start location submitted = nothingDoneYet = $nothingDoneYet, startLocationChosen =  $startLocationSearchChosen, destinationChosen = $destinationChosen,destinationTilesCHosen =  $destinationTileChosen");
//         });
//         searchControllerStarting.close;
//         searchControllerDestination.open();
//         //hintVar = query;
//       },
//       onFocusChanged: (isFocused) {
//         if (isFocused == true) {
//           searchControllerDestination.close();
//           isSubmittedStartingBar = false;
//         }
//         // if (isFocused == false) {
//         //   searchControllerDestination.close();
//         // }
//       },

//       // body: isSubmitted
//       //     ? SearchResultsListView(searchTerm: selectedTermStarting)
//       //     : const SearchResultsListView(searchTerm: null),
//       // Specify a custom transition to be used for
//       // animating between opened and closed stated.
//       transition: CircularFloatingSearchBarTransition(),
//       actions: [
//         FloatingSearchBarAction.searchToClear(
//           showIfClosed: false,
//         ),
//       ],
//       builder: (context, transition) {
//         return nil;
//       }, //builder
//     );
//   }

//   //floating search bar implementation
//   Widget buildFloatingSearchBarDestination(BuildContext context) {
//     //get a query(info) about the current media orientation
//     //and if it has an orientation of a portrait return true
//     final isPortrait =
//         MediaQuery.of(context).orientation == Orientation.portrait;
// //return a floating search bar
//     return FloatingSearchBar(
//       hint: 'Search destination',
//       // text shown inside search bar
//       //all the characterstics of searchh bar
//       scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
//       transitionDuration: const Duration(milliseconds: 800),
//       transitionCurve: Curves.easeInOut,
//       physics: const BouncingScrollPhysics(),
//       axisAlignment: isPortrait ? 0.0 : -1.0,
//       openAxisAlignment: 0.0,
//       width: MediaQuery.of(context).size.width * 0.8,
//       borderRadius: BorderRadius.circular(8),
//       closeOnBackdropTap: true,
//       backdropColor: Colors.blue,
//       //height: double.infinity,
//       debounceDelay: const Duration(milliseconds: 500),
//       clearQueryOnClose: false,
//       //check this again when needed
//       controller: searchControllerDestination,
//       onQueryChanged: (query) {
//         setState(() {
//           // searchControllerDestination.open();
//           filteredSearchSuggestionsDestination =
//               filteredSearchTermDestination(filter: query);
//         });
//         // Call your model, bloc, controller here.
//       },

//       onSubmitted: (query) {
//         setState(() {
//           selectedTermDestination = query;
//           isSubmittedStartingBar = true;
//           isTappedDestinationTiles = false;
//           isTappedStartingTiles = true;
//           isSubmittedDestinationBar = true;
//           //number = 4;
//         });
//         searchControllerDestination.close;
//         devtools.log(
//             "After destination submitted = nothingDoneYet = $nothingDoneYet, startLocationChosen =  $startLocationSearchChosen, destinationChosen = $destinationChosen,destinationTilesCHosen =  $destinationTileChosen");
//         //hintVar = query;
//       },

//       onFocusChanged: (isFocused) {
//         if (isFocused == true) {
//           if (isSubmittedStartingBar == false) {
//             searchControllerStarting.close();
//           }
//           if (isSubmittedStartingBar == false) {
//             searchControllerStarting.open();
//             searchControllerDestination.close();
//           }
//         }
//       },

//       transition: CircularFloatingSearchBarTransition(),
//       actions: [
//         //implementation of the place icon in the search bar when it's pressed
//         FloatingSearchBarAction.searchToClear(
//           showIfClosed: false,
//         ),
//       ],
//       builder: (context, transition) {
//         return nil;
//       }, //builder
//     );
//   }
// }

// class SearchResultsListView extends StatelessWidget {
//   //variable
//   final String? searchTerm;
//   final List<String> filtered;
//   //bool tappedTile = false;
//   //constructor
//   const SearchResultsListView({
//     super.key,
//     required this.searchTerm,
//     required this.filtered,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if (searchTerm == null) {
//       return Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.search,
//               size: 30,
//             ),
//             Text(
//               'Start Searching',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       );
//     }

//     int? listLength = filtered.length;
//     // final fsb = FloatingSearchBar.of(context);

//     return ListView(
//       //padding: EdgeInsets.only(top: fsb.height +fsb.margins.vertical),
//       children: List.generate(
//         listLength,
//         growable: true,
//         (index) => ListTile(
//           title: Text(filtered[index]),
//           subtitle: const Text('University Park Campus'),
//           onTap: () {},
//         ),
//       ),
//     );
//   }
// }

// ///////////////////////////////////////////END//////////////////////////////////////////////////////






// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// // import 'package:flutter/src/widgets/framework.dart';
// // import 'package:flutter/src/widgets/placeholder.dart';
// import 'package:material_floating_search_bar/material_floating_search_bar.dart';
// import 'package:nil/nil.dart';
// import 'dart:developer' as devtools show log;

// import '../../constants/routes.dart';
// import '../../models/nodes_model.dart';
// import '../../services/local db helper/local_db_helper.dart';

// class DoubleSearchBarView extends StatefulWidget {
//   const DoubleSearchBarView({super.key});

//   @override
//   State<DoubleSearchBarView> createState() => _DoubleSearchBarStateView();
// }

// class _DoubleSearchBarStateView extends State<DoubleSearchBarView> {
// //varibales for the nodes
//   List<NodesModel> allNodes = [];
//   List<String> selectableDestinations = [];

//   final LocalDBhelper _localDBhelper = LocalDBhelper();

//   //variables for the Starter location search bar
//   late FloatingSearchBarController searchControllerStarting;
//   List<String> filteredSearchSuggestionsStarting = [];
//   String? selectedTermStarting = '';
//   late List<String> searchSuggestionsStarting = [];
//   static const historyLengthStarting = 5;
//   late bool isSubmittedStartingBar;
//   late bool isTappedStartingTiles;
//   //variables for the Destination search bar
//   late FloatingSearchBarController searchControllerDestination;
//   List<String> filteredSearchSuggestionsDestination = [];
//   String? selectedTermDestination = '';
//   late List<String> searchSuggestionsDestination = [];
//   static const historyLengthDestination = 5;
//   late bool isSubmittedDestinationBar;
//   late bool isTappedDestinationTiles;

//   late int number;

//   late bool nothingDoneYet = ((isSubmittedStartingBar == false) &&
//       (isTappedStartingTiles == false) &&
//       (isSubmittedDestinationBar == false) &&
//       (isTappedDestinationTiles == false));
//   late bool startLocationSearchChosen = ((isSubmittedStartingBar == true) &&
//       (isTappedStartingTiles == false) &&
//       (isSubmittedDestinationBar == false) &&
//       (isTappedDestinationTiles == false));
//   late bool startTileChosen = ((isSubmittedStartingBar == true) &&
//       (isTappedStartingTiles == true) &&
//       (isSubmittedDestinationBar == false) &&
//       (isTappedDestinationTiles == false));
//   late bool destinationChosen = ((isSubmittedStartingBar == true) &&
//       (isTappedStartingTiles == true) &&
//       (isSubmittedDestinationBar == true) &&
//       (isTappedDestinationTiles == false));
//   late bool destinationTileChosen = ((isSubmittedStartingBar == true) &&
//       (isTappedStartingTiles == true) &&
//       (isSubmittedDestinationBar == true) &&
//       (isTappedDestinationTiles == true));
//   //get nodes
//   getAllNodes() async {
//     allNodes = await _localDBhelper.getNodes();
//     //variable to store selectable destinations

//     //for loop that goes through all nodes
//     for (int j = 0; j < allNodes.length; ++j) {
//       //if node is selectable store it inside a selectableDestination variable
//       if (allNodes[j].isSelectable! == 1) {
//         selectableDestinations.add(allNodes[j].name!);
//       }
//       //print('Selectable Destinations = ${selectableDestinations.length}');
//     }
//   }

// //STARTER SEARCHBAR FUNCTIONS

//   //filter search terms so that the most relative search term returns
//   List<String> filteredSearchTermStarting({
//     required String? filter,
//   }) {
//     if (filter != null && filter.isNotEmpty) {
//       return searchSuggestionsStarting.reversed
//           .where((term) => term.startsWith(filter))
//           .toList();
//     } else {
//       return searchSuggestionsStarting.reversed.toList();
//     }
//   }

//   void deleteSearchTermStarting(String term) {
//     searchSuggestionsStarting.removeWhere((t) => t == term);
//     filteredSearchSuggestionsStarting =
//         filteredSearchTermStarting(filter: null);
//   }

//   void addSearchTermStarting(String term) {
//     if (searchSuggestionsStarting.contains(term)) {
//       putSearchTermFirstStarting(term);
//       return;
//     }
//     searchSuggestionsStarting.add(term);
//     if (searchSuggestionsStarting.length > historyLengthStarting) {
//       searchSuggestionsStarting.removeRange(
//           0, (searchSuggestionsStarting.length - historyLengthStarting));
//     }

//     filteredSearchSuggestionsStarting =
//         filteredSearchTermStarting(filter: null);
//   }

//   void putSearchTermFirstStarting(String term) {
//     deleteSearchTermStarting(term);
//     addSearchTermStarting(term);
//   }

//   listViewSearchStarting() {
//     int? listLength = filteredSearchSuggestionsStarting.length;
//     return ListView(
//       //padding: EdgeInsets.only(top: fsb.height +fsb.margins.vertical),
//       children: List.generate(
//         listLength,
//         growable: true,
//         (index) => ListTile(
//           title: Text(filteredSearchSuggestionsStarting[index]),
//           subtitle: const Text('University Park Campus'),
//           onTap: () {
//             setState(() {
//               isTappedStartingTiles = true;
//               isTappedDestinationTiles = false;
//               isSubmittedStartingBar = true;
//               isSubmittedDestinationBar = false;
//             });
//             devtools.log(
//                 "After start location tile tapped = nothingDoneYet = $nothingDoneYet, startLocationChosen =  $startLocationSearchChosen, destinationChosen = $destinationChosen,destinationTilesCHosen =  $destinationTileChosen");
//             //searchControllerDestination.open();
//             devtools.log('ola');
//           },
//         ),
//       ),
//     );
//   }

//   listViewSearchDestination() {
//     int? listLength = filteredSearchSuggestionsDestination.length;
//     return ListView(
//       //padding: EdgeInsets.only(top: fsb.height +fsb.margins.vertical),
//       children: List.generate(
//         listLength,
//         growable: true,
//         (index) => ListTile(
//           title: Text(filteredSearchSuggestionsDestination[index]),
//           subtitle: const Text('University Park Campus'),
//           onTap: () {
//             setState(() {
//               isTappedDestinationTiles = true;
//               isTappedStartingTiles = true;
//               isSubmittedDestinationBar = true;
//               isSubmittedStartingBar = true;

//               SchedulerBinding.instance.addPostFrameCallback((_) {
//                 Navigator.of(context).pushNamedAndRemoveUntil(
//                   newMapsRoute,
//                   (_) => false,
//                 );
//                 // searchControllerDestination.open();
//                 //FocusManager.instance.primaryFocus?.unfocus();
//               });
//             });

//             devtools.log(
//                 "After destination tile pressed= nothingDoneYet = $nothingDoneYet, startLocationChosen =  $startLocationSearchChosen, destinationChosen = $destinationChosen,destinationTilesCHosen =  $destinationTileChosen");
//           },
//         ),
//       ),
//     );
//   }

//   defaultView() {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(
//             Icons.search,
//             size: 30,
//           ),
//           Text(
//             'Start Searching',
//             style: Theme.of(context).textTheme.headlineMedium,
//           ),
//         ],
//       ),
//     );
//   }
// //DESTINATION SEARCHBAR FUNCTIONS

// //filter search terms so that the most relative search term returns
//   List<String> filteredSearchTermDestination({
//     required String? filter,
//   }) {
//     if (filter != null && filter.isNotEmpty) {
//       return searchSuggestionsStarting.reversed
//           .where((term) => term.startsWith(filter))
//           .toList();
//     } else {
//       return searchSuggestionsStarting.reversed.toList();
//     }
//   }

//   void deleteSearchTermDestination(String term) {
//     searchSuggestionsStarting.removeWhere((t) => t == term);
//     filteredSearchSuggestionsStarting =
//         filteredSearchTermStarting(filter: null);
//   }

//   void addSearchTermDestination(String term) {
//     if (searchSuggestionsStarting.contains(term)) {
//       putSearchTermFirstDestination(term);
//       return;
//     }
//     searchSuggestionsStarting.add(term);
//     if (searchSuggestionsStarting.length > historyLengthStarting) {
//       searchSuggestionsStarting.removeRange(
//           0, (searchSuggestionsStarting.length - historyLengthStarting));
//     }

//     filteredSearchSuggestionsStarting =
//         filteredSearchTermDestination(filter: null);
//   }

//   void putSearchTermFirstDestination(String term) {
//     deleteSearchTermStarting(term);
//     addSearchTermStarting(term);
//   }

//   @override
//   void initState() {
//     //get nodes
//     getAllNodes();
//     //starting bar intializations
//     searchSuggestionsStarting = selectableDestinations;
//     filteredSearchSuggestionsStarting =
//         filteredSearchTermStarting(filter: null);
//     searchControllerStarting = FloatingSearchBarController();
//     isSubmittedStartingBar = false;
//     isTappedStartingTiles = false;
//     //destination bar initilization
//     searchSuggestionsDestination = selectableDestinations;
//     filteredSearchSuggestionsDestination =
//         filteredSearchTermDestination(filter: null);
//     searchControllerDestination = FloatingSearchBarController();
//     isSubmittedDestinationBar = false;
//     isTappedDestinationTiles = false;

//     number = 0;
//     super.initState();
//   }

//   getAllData() async {
//     await getAllNodes();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(150),
//           child: AppBar(
//             toolbarHeight: 150,
//             actions: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 //crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   CircularButton(
//                     padding: const EdgeInsets.only(bottom: 10, right: 40),
//                     icon: const Icon(Icons.arrow_back),
//                     onPressed: () {
//                       SchedulerBinding.instance.addPostFrameCallback((_) {
//                         Navigator.of(context).pushNamedAndRemoveUntil(
//                           mapsRoute,
//                           (_) => false,
//                         );
//                         //FocusManager.instance.primaryFocus?.unfocus();
//                       });
//                     },
//                   ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: <Widget>[
//                       Expanded(
//                         child: Container(
//                           height: double.infinity,
//                           width: MediaQuery.of(context).size.height *
//                               0.5, // change tomorrowwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
//                           color: const Color.fromARGB(255, 54, 184, 244),
//                           child: buildFloatingSearchBarStartLocation(context),
//                         ),
//                       ),
//                       Expanded(
//                         child: Container(
//                           height: double.infinity,
//                           width: MediaQuery.of(context).size.height *
//                               0.5, // change tomorrowwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
//                           color: const Color.fromARGB(255, 54, 184, 244),
//                           child: buildFloatingSearchBarDestination(context),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         body: nothingDoneYet
//             ? defaultView()
//             : startLocationSearchChosen
//                 ? listViewSearchStarting()
//                 : startTileChosen
//                     ? defaultView()
//                     : destinationChosen
//                         ? listViewSearchDestination()
//                         : destinationTileChosen
//                             ? defaultView()
//                             : const SizedBox()
//         //Center(
//         //renderWidget(number),
//         //);
//         );
//   }

//   // Widget renderWidget(int number) {
//   //   switch (number) {
//   //     case 0:
//   //       return defaultView();
//   //     //break;
//   //     case 1:
//   //       return listViewSearchStarting();
//   //     //break;
//   //     case 2:
//   //       return defaultView();
//   //     //break;
//   //     case 3:
//   //       return listViewSearchDestination();
//   //     //break;
//   //     case 4:
//   //       return nil;
//   //     default:
//   //       return nil;
//   //   }
//   // }

//   //floating search bar implementation
//   Widget buildFloatingSearchBarStartLocation(BuildContext context) {
//     //get a query(info) about the current media orientation
//     //and if it has an orientation of a portrait return true
//     final isPortrait =
//         MediaQuery.of(context).orientation == Orientation.portrait;
//     String hintVar = 'Search start location';
// //return a floating search bar
//     return FloatingSearchBar(
//       hint: hintVar, // text shown inside search bar
//       //all the characterstics of searchh bar
//       scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
//       transitionDuration: const Duration(milliseconds: 800),
//       transitionCurve: Curves.easeInOut,
//       physics: const BouncingScrollPhysics(),
//       axisAlignment: isPortrait ? 0.0 : -1.0,
//       openAxisAlignment: 0.0,
//       width: MediaQuery.of(context).size.width * 0.8,
//       borderRadius: BorderRadius.circular(8),
//       elevation: 0,
//       backdropColor: Colors.blue,
//       //isPortrait ? 600 : 500,
//       //height: double.infinity,
//       closeOnBackdropTap: true,
//       debounceDelay: const Duration(milliseconds: 500),
//       clearQueryOnClose: false, //check this again when needed
//       controller: searchControllerStarting,
//       onQueryChanged: (query) {
//         setState(() {
//           //searchControllerStarting.open();
//           filteredSearchSuggestionsStarting =
//               filteredSearchTermStarting(filter: query);
//         });
//         // Call your model, bloc, controller here.
//       },

//       onSubmitted: (query) {
//         setState(() {
//           //addSearchTerm(query);
//           selectedTermStarting = query;
//           isSubmittedStartingBar = true;
//           isTappedStartingTiles = false;
//           isTappedDestinationTiles = false;
//           isSubmittedDestinationBar = false;
//           if (number == 0) {
//             number = 1;
//           }
//           devtools.log(
//               "After start location submitted = nothingDoneYet = $nothingDoneYet, startLocationChosen =  $startLocationSearchChosen, destinationChosen = $destinationChosen,destinationTilesCHosen =  $destinationTileChosen");
//         });
//         searchControllerStarting.close;
//         searchControllerDestination.open();
//         //hintVar = query;
//       },
//       onFocusChanged: (isFocused) {
//         if (isFocused == true) {
//           searchControllerDestination.close();
//           isSubmittedStartingBar = false;
//         }
//         // if (isFocused == false) {
//         //   searchControllerDestination.close();
//         // }
//       },

//       // body: isSubmitted
//       //     ? SearchResultsListView(searchTerm: selectedTermStarting)
//       //     : const SearchResultsListView(searchTerm: null),
//       // Specify a custom transition to be used for
//       // animating between opened and closed stated.
//       transition: CircularFloatingSearchBarTransition(),
//       actions: [
//         FloatingSearchBarAction.searchToClear(
//           showIfClosed: false,
//         ),
//       ],
//       builder: (context, transition) {
//         return nil;
//       }, //builder
//     );
//   }

//   //floating search bar implementation
//   Widget buildFloatingSearchBarDestination(BuildContext context) {
//     //get a query(info) about the current media orientation
//     //and if it has an orientation of a portrait return true
//     final isPortrait =
//         MediaQuery.of(context).orientation == Orientation.portrait;
// //return a floating search bar
//     return FloatingSearchBar(
//       hint: 'Search destination', // text shown inside search bar
//       //all the characterstics of searchh bar
//       scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
//       transitionDuration: const Duration(milliseconds: 800),
//       transitionCurve: Curves.easeInOut,
//       physics: const BouncingScrollPhysics(),
//       axisAlignment: isPortrait ? 0.0 : -1.0,
//       openAxisAlignment: 0.0,
//       width: MediaQuery.of(context).size.width * 0.8,
//       borderRadius: BorderRadius.circular(8),
//       closeOnBackdropTap: true,
//       backdropColor: Colors.blue,
//       //height: double.infinity,
//       debounceDelay: const Duration(milliseconds: 500),
//       clearQueryOnClose: false, //check this again when needed
//       controller: searchControllerDestination,
//       onQueryChanged: (query) {
//         setState(() {
//           // searchControllerDestination.open();
//           filteredSearchSuggestionsStarting =
//               filteredSearchTermDestination(filter: query);
//         });
//         // Call your model, bloc, controller here.
//       },

//       onSubmitted: (query) {
//         setState(() {
//           selectedTermDestination = query;
//           isSubmittedStartingBar = true;
//           isTappedDestinationTiles = false;
//           isTappedStartingTiles = true;
//           isSubmittedDestinationBar = true;
//           number = 4;
//         });
//         searchControllerDestination.close;
//         devtools.log(
//             "After destination submitted = nothingDoneYet = $nothingDoneYet, startLocationChosen =  $startLocationSearchChosen, destinationChosen = $destinationChosen,destinationTilesCHosen =  $destinationTileChosen");
//         //hintVar = query;
//       },

//       onFocusChanged: (isFocused) {
//         if (isFocused == true) {
//           if (isSubmittedStartingBar == false) {
//             searchControllerStarting.close();
//           }
//           if (isSubmittedStartingBar == false) {
//             searchControllerStarting.open();
//             searchControllerDestination.close();
//           }
//         }
//         // if (isFocused == false) {
//         //   searchControllerDestination.close();
//         // }
//       },
//       // body: isOutOfSearchBox
//       //     ?  SearchResultsListView(searchTerm: selectedTermDestination) : SearchResultsListView(searchTerm: null)
//       // Specify a custom transition to be used for
//       // animating between opened and closed stated.
//       transition: CircularFloatingSearchBarTransition(),
//       actions: [
//         //implementation of the place icon in the search bar when it's pressed
//         FloatingSearchBarAction.searchToClear(
//           showIfClosed: false,
//         ),
//       ],
//       builder: (context, transition) {
//         return nil;
//         // return ClipRRect(
//         //   borderRadius: BorderRadius.circular(8),
//         //   child: Material(
//         //     color: Colors.white,
//         //     elevation: 4.0,
//         //     child: Builder(
//         //       builder: (context) {
//         //         if (filteredSearchSuggestionsStarting.isEmpty &&
//         //             searchControllerStarting.query.isEmpty) {
//         //           //return empty widget
//         //           return nil;
//         //         }
//         //         //when the result does not match anything from the list
//         //         else if (filteredSearchSuggestionsStarting.isEmpty) {
//         //           // display what ever is being typed
//         //           return ListTile(
//         //             title: Text(searchControllerStarting.query),
//         //             onTap: () {
//         //               setState(() {
//         //                 addSearchTermStarting(searchControllerStarting.query);
//         //                 selectedTermStarting = searchControllerStarting.query;
//         //               });
//         //               searchControllerStarting.close();
//         //             },
//         //           );
//         //         } else {
//         //           return Column(
//         //             mainAxisSize: MainAxisSize.min,
//         //             children: filteredSearchSuggestionsStarting
//         //                 .map(
//         //                   (term) => ListTile(
//         //                     //display drop down list tiles
//         //                     title: Text(
//         //                       term,
//         //                       maxLines: 1,
//         //                       overflow: TextOverflow.ellipsis,
//         //                     ),
//         //                     leading: const Icon(Icons.history),
//         //                     onTap: () {
//         //                       setState(() {
//         //                         putSearchTermFirstStarting(term);
//         //                         selectedTermStarting = term;
//         //                       });
//         //                       searchControllerStarting.close();
//         //                     },
//         //                   ),
//         //                 )
//         //                 .toList(),
//         //           );
//         //         }
//         //       },
//         //     ),
//         //   ),
//         // );
//       }, //builder
//     );
//   }
// }

// // class SearchResultsListView extends StatelessWidget {
// //   //variable
// //   final String? searchTerm;
// //   final List<String> filtered;
// //   //bool tappedTile = false;
// //   //constructor
// //   const SearchResultsListView({
// //     super.key,
// //     required this.searchTerm,
// //     required this.filtered,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     if (searchTerm == null) {
// //       return Center(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             const Icon(
// //               Icons.search,
// //               size: 30,
// //             ),
// //             Text(
// //               'Start Searching',
// //               style: Theme.of(context).textTheme.headlineMedium,
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     int? listLength = filtered.length;
// //     // final fsb = FloatingSearchBar.of(context);

// //     return ListView(
// //       //padding: EdgeInsets.only(top: fsb.height +fsb.margins.vertical),
// //       children: List.generate(
// //         listLength,
// //         growable: true,
// //         (index) => ListTile(
// //           title: Text(filtered[index]),
// //           subtitle: const Text('University Park Campus'),
// //           onTap: () {},
// //         ),
// //       ),
// //     );
// //   }
// // }
