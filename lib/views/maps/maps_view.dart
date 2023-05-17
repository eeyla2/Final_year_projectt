//mainview widget
import 'dart:ui' as ui;
//import 'dart:async';
//import 'dart:math';

//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:connectivity_plus/connectivity_plus.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:legsfree/services/auth/auth_service.dart';
import 'package:legsfree/services/crud/main_services.dart';
import 'package:legsfree/views/maps/double_search_bar_view.dart';
//import 'package:legsfree/views/maps/double_search_bar._view.dart';
//import 'dart:developer' as devtools show log;
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/scheduler.dart';

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../main.dart';
import '../../models/nodes_model.dart';
import '../../services/local db helper/local_db_helper.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  //main services variables
  late final MainService _mainService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  //database variables
  List<NodesModel> allNodes = [];
  List<String> selectableDestinations = [];

  final LocalDBhelper _localDBhelper = LocalDBhelper();

  //search bar variables

  late FloatingSearchBarController searchController;
  List<String> filteredSearchSuggestions = [];
  String? selectedTerm = '';
  late List<String> searchSuggestions = [];
  static const historyLength = 5;

  //get nodes
  getAllNodes() async {
    allNodes = await _localDBhelper.getNodes();
    //variable to store selectable destinations

    //for loop that goes through all nodes
    for (int j = 0; j < allNodes.length; ++j) {
      //if node is selectable store it inside a selectableDestination variable
      if (allNodes[j].isSelectable! == 1) {
        selectableDestinations.add(allNodes[j].name!);
      }
      //print('Selectable Destinations = ${selectableDestinations.length}');
    }
  }

  //filter search terms so that the most relative search term returns
  List<String> filteredSearchTerm({
    required String? filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      return searchSuggestions.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return searchSuggestions.reversed.toList();
    }
  }

  void deleteSearchTerm(String term) {
    searchSuggestions.removeWhere((t) => t == term);
    filteredSearchSuggestions = filteredSearchTerm(filter: null);
  }

  void addSearchTerm(String term) {
    if (searchSuggestions.contains(term)) {
      putSearchTermFirst(term);
      return;
    }
    searchSuggestions.add(term);
    if (searchSuggestions.length > historyLength) {
      searchSuggestions.removeRange(
          0, (searchSuggestions.length - historyLength));
    }

    filteredSearchSuggestions = filteredSearchTerm(filter: null);
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  //override built-in function initState
  @override
  void initState() {
    //open database
    _mainService = MainService();
    _mainService.open();
    getAllNodes();
    //initialize location services
    searchSuggestions = selectableDestinations;
    //initLocationServices();
    filteredSearchSuggestions = filteredSearchTerm(filter: null);
    searchController = FloatingSearchBarController();

    super.initState();
  }

  getAllData() async {
    await getAllNodes();
  }

  @override
  void dispose() {
    _mainService.close();
    searchController.dispose();
    super.dispose();
  }

  int selectedButton = 0;
  List<String> buttonIcons = [
    'images/shortest_path.png',
    'images/scenic.png',
    'images/no_elevation.png'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ...List.generate(
              3,
              (index) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FloatingActionButton(
                      heroTag: index,
                      backgroundColor: selectedButton != index
                          ? Colors.grey
                          : Colors.blue.shade800,
                      onPressed: () {
                        setState(() {
                          selectedButton = index;
                        });
                      },
                      child: Center(
                          child: Image.asset(
                        buttonIcons[index],
                        fit: BoxFit.cover,
                        height: MediaQuery.of(context).size.height * 0.05,
                      )),
                    ),
                  ))
        ],
      ),
      resizeToAvoidBottomInset:
          false, //helps change the gadegst to fit in case other widgets appear
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: _mainService.getOrCreateUser(theemail: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 40.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 1,
                              child: Image.asset(
                                //loads an image on to the app
                                'images/map.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.14,
                      child: buildFloatingSearchBar(context),
                    ),
                  ],
                ),
              );

            default:
              return spinkit2;
          }
        },
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.14,
        width: MediaQuery.of(context).size.width * 0.1,
        padding: const EdgeInsets.only(
          top: 32,
          left: 15,
          right: 15,
          bottom: 32,
        ),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(36.0),
            topRight: Radius.circular(36.0),
          ),
          color: ui.Color.fromARGB(255, 102, 56, 163),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.bike_scooter_sharp,
                color: Colors.white,
                size: 30,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.explore_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.add_sharp,
                color: Colors.white,
                size: 30,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.settings_suggest_outlined,
                color: Colors.white,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //floating search bar implementation
  Widget buildFloatingSearchBar(BuildContext context) {
    //get a query(info) about the current media orientation
    //and if it has an orientation of a portrait return true
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    //return a floating search bar
    return FloatingSearchBar(
      hint: 'Get To Your Class...', // text shown inside search bar
      //all the characterstics of searchh bar
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInCirc,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      //height: double.infinity,
      debounceDelay: const Duration(milliseconds: 500),
      clearQueryOnClose: true, //check this again when needed
      controller: searchController,
      borderRadius: BorderRadius.circular(15),
      onQueryChanged: (query) {},

      onFocusChanged: (isFocused) {
        SchedulerBinding.instance.addPostFrameCallback(
          (_) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        DoubleSearchBarView(weightClass: selectedButton + 1)));
          },
        );
      },

      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        //implementation of a popupmenu
        PopupMenuButton<MenuAction>(
          color: Colors.grey[400],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogOutDialog(context);
                if (shouldLogout) {
                  await AuthService.firebase().logOut();
                  // Wrap Navigator with SchedulerBinding to wait for rendering state before navigating
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  });
                }
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                padding:
                    EdgeInsets.only(top: 20, left: 25, right: 10, bottom: 20),
                child: Text(
                  //selectionColor: Colors.deepPurple[100],
                  'Logout',
                  style: TextStyle(
                    color: Colors.black,
                    //fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ];
          },
        ),
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              searchController.open();
            },
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.white,
              elevation: 4.0,
              child: Container(
                  height: 56,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Text('',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall)),
            ));
      }, //builder
    );
  }
}

//pinkit with spinning Lines for loading page
const spinkit1 = SpinKitSpinningLines(
  color: Colors.black,
  size: 50.0,
);

//spinkit with spinninglines for second loading page
const spinkit2 = SpinKitSpinningLines(
  color: Colors.blue,
  size: 50.0,
);

class SearchResultsListView extends StatelessWidget {
  //variable
  final String? searchTerm;
  //constructor
  const SearchResultsListView({
    super.key,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    if (searchTerm == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search,
              size: 15,
            ),
            Text(
              'Start Searching',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      );
    }

    //final fsb = FloatingSearchBar.of(context);

    return ListView(
      //padding: EdgeInsets.only(top: fsb.height +fsb.margins.vertical),
      children: List.generate(
        50,
        (index) => ListTile(
          title: Text('$searchTerm search result'),
          subtitle: Text(index.toString()),
        ),
      ),
    );
  }
}
