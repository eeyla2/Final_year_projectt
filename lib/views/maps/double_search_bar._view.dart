import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:nil/nil.dart';

import '../../constants/routes.dart';
import '../../models/nodes_model.dart';
import '../../services/local db helper/local_db_helper.dart';

class DoubleSearchBarView extends StatefulWidget {
  const DoubleSearchBarView({super.key});

  @override
  State<DoubleSearchBarView> createState() => _DoubleSearchBarStateView();
}

class _DoubleSearchBarStateView extends State<DoubleSearchBarView> {
//varibales for the nodes
  List<NodesModel> allNodes = [];
  List<String> selectableDestinations = [];

  final LocalDBhelper _localDBhelper = LocalDBhelper();

  //variables for the Starter location search bar
  late FloatingSearchBarController searchControllerStarting;
  List<String> filteredSearchSuggestionsStarting = [];
  String? selectedTermStarting = '';
  late List<String> searchSuggestionsStarting = [];
  static const historyLengthStarting = 5;
  late bool isSubmitted;
  //variables for the Destination search bar
  late FloatingSearchBarController searchControllerDestination;
  List<String> filteredSearchSuggestionsDestination = [];
  String? selectedTermDestination = '';
  late List<String> searchSuggestionsDestination = [];
  static const historyLengthDestination = 5;

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

//STARTER SEARCHBAR FUNCTIONS

  //filter search terms so that the most relative search term returns
  List<String> filteredSearchTermStarting({
    required String? filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      return searchSuggestionsStarting.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return searchSuggestionsStarting.reversed.toList();
    }
  }

  void deleteSearchTermStarting(String term) {
    searchSuggestionsStarting.removeWhere((t) => t == term);
    filteredSearchSuggestionsStarting =
        filteredSearchTermStarting(filter: null);
  }

  void addSearchTermStarting(String term) {
    if (searchSuggestionsStarting.contains(term)) {
      putSearchTermFirstStarting(term);
      return;
    }
    searchSuggestionsStarting.add(term);
    if (searchSuggestionsStarting.length > historyLengthStarting) {
      searchSuggestionsStarting.removeRange(
          0, (searchSuggestionsStarting.length - historyLengthStarting));
    }

    filteredSearchSuggestionsStarting =
        filteredSearchTermStarting(filter: null);
  }

  void putSearchTermFirstStarting(String term) {
    deleteSearchTermStarting(term);
    addSearchTermStarting(term);
  }

//DESTINATION SEARCHBAR FUNCTIONS

//filter search terms so that the most relative search term returns
  List<String> filteredSearchTermDestination({
    required String? filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      return searchSuggestionsStarting.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return searchSuggestionsStarting.reversed.toList();
    }
  }

  void deleteSearchTermDestination(String term) {
    searchSuggestionsStarting.removeWhere((t) => t == term);
    filteredSearchSuggestionsStarting =
        filteredSearchTermStarting(filter: null);
  }

  void addSearchTermDestination(String term) {
    if (searchSuggestionsStarting.contains(term)) {
      putSearchTermFirstDestination(term);
      return;
    }
    searchSuggestionsStarting.add(term);
    if (searchSuggestionsStarting.length > historyLengthStarting) {
      searchSuggestionsStarting.removeRange(
          0, (searchSuggestionsStarting.length - historyLengthStarting));
    }

    filteredSearchSuggestionsStarting =
        filteredSearchTermDestination(filter: null);
  }

  void putSearchTermFirstDestination(String term) {
    deleteSearchTermStarting(term);
    addSearchTermStarting(term);
  }

  @override
  void initState() {
    getAllNodes();
    searchSuggestionsStarting = selectableDestinations;
    filteredSearchSuggestionsStarting =
        filteredSearchTermStarting(filter: null);
    searchControllerStarting = FloatingSearchBarController();
    isSubmitted = false;
    searchSuggestionsDestination = selectableDestinations;
    filteredSearchSuggestionsDestination =
        filteredSearchTermDestination(filter: null);
    searchControllerDestination = FloatingSearchBarController();
    super.initState();
  }

  getAllData() async {
    await getAllNodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              width:
                  500.0, // change tomorrowwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
              color: const Color.fromARGB(255, 54, 184, 244),
              child: buildFloatingSearchBarStartLocation(context),
            ),
          ),
          // Expanded(
          //   child: Container(
          //     height: double.infinity,
          //     width:
          //         500.0, // change tomorrowwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
          //     color: const Color.fromARGB(255, 54, 184, 244),
          //     child: buildFloatingSearchBarDestination(context),
          //   ),
          // ),
        ],
      ),
    );
  }

  //floating search bar implementation
  Widget buildFloatingSearchBarStartLocation(BuildContext context) {
    //get a query(info) about the current media orientation
    //and if it has an orientation of a portrait return true
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

//return a floating search bar
    return FloatingSearchBar(
      hint: 'Search destination', // text shown inside search bar
      //all the characterstics of searchh bar
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      //height: double.infinity,
      debounceDelay: const Duration(milliseconds: 500),
      clearQueryOnClose: true, //check this again when needed
      controller: searchControllerStarting,
      onQueryChanged: (query) {
        setState(() {
          searchControllerStarting.open();
          filteredSearchSuggestionsStarting =
              filteredSearchTermStarting(filter: query);
        });
        // Call your model, bloc, controller here.
      },

      onSubmitted: (query) {
        setState(() {
          //addSearchTerm(query);
          selectedTermStarting = query;
          isSubmitted = true;
        });
        searchControllerStarting.close;
        searchControllerDestination.open();
      },
      body: isSubmitted
          ? SearchResultsListView(searchTerm: selectedTermStarting)
          : SearchResultsListView(searchTerm: null),
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
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
            child: Builder(
              builder: (context) {
                //when nothing has been entered
                if (filteredSearchSuggestionsStarting.isEmpty &&
                    searchControllerStarting.query.isEmpty) {
                  //return empty widget
                  return nil;
                }
                //when the result does not match anything from the list
                else if (filteredSearchSuggestionsStarting.isEmpty) {
                  //display what ever is being typed
                  return ListTile(
                    title: Text(searchControllerStarting.query),
                    leading: const Icon(Icons.search),
                    onTap: () {
                      setState(() {
                        addSearchTermStarting(searchControllerStarting.query);
                        selectedTermStarting = searchControllerStarting.query;
                      });
                      searchControllerStarting.close();
                    },
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: filteredSearchSuggestionsStarting
                        .map(
                          (term) => ListTile(
                            //display drop down list tiles
                            title: Text(
                              term,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: const Icon(Icons.history),
                            onTap: () {
                              setState(() {
                                putSearchTermFirstStarting(term);
                                selectedTermStarting = term;
                              });
                              searchControllerStarting.close();
                            },
                          ),
                        )
                        .toList(),
                  );
                }
              },
            ),
          ),
        );
      }, //builder
    );
  }

  //floating search bar implementation
  Widget buildFloatingSearchBarDestination(BuildContext context) {
    //get a query(info) about the current media orientation
    //and if it has an orientation of a portrait return true
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
//return a floating search bar
    return FloatingSearchBar(
      hint: 'Search destination', // text shown inside search bar
      //all the characterstics of searchh bar
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      //height: double.infinity,
      debounceDelay: const Duration(milliseconds: 500),
      clearQueryOnClose: true, //check this again when needed
      controller: searchControllerDestination,
      onQueryChanged: (query) {
        setState(() {
          searchControllerDestination.open();
          filteredSearchSuggestionsDestination =
              filteredSearchTermDestination(filter: query);
        });
        // Call your model, bloc, controller here.
      },

      onSubmitted: (query) {
        setState(() {
          //addSearchTerm(query);
          selectedTermDestination = query;
        });
        searchControllerDestination.close;
      },

      // onFocusChanged: (isFocused) {
      //   if (isFocused == true) {
      //     isOutOfSearchBox = false;
      //   }
      //   if (isFocused == false) {
      //     isOutOfSearchBox = true;
      //   }
      // },

      // body: isOutOfSearchBox
      //     ?  SearchResultsListView(searchTerm: selectedTermDestination) : SearchResultsListView(searchTerm: null)
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        //implementation of the place icon in the search bar when it's pressed
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
            child: Builder(
              builder: (context) {
                if (filteredSearchSuggestionsDestination.isEmpty &&
                    searchControllerDestination.query.isEmpty) {
                  return Container(
                    height: 56,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Text('',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall),
                  );
                } else if (filteredSearchSuggestionsDestination.isEmpty) {
                  return ListTile(
                    title: Text(searchControllerDestination.query),
                    leading: const Icon(Icons.search),
                    onTap: () {
                      setState(() {
                        // addSearchTermDestination(
                        //     searchControllerDestination.query);
                        // selectedTermDestination =
                        //     searchControllerDestination.query;
                      });
                      // searchControllerDestination.close();
                    },
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: filteredSearchSuggestionsDestination
                        .map(
                          (term) => ListTile(
                            title: Text(
                              term,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: const Icon(Icons.history),
                            trailing: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  //deleteSearchTerm(term);
                                  // searchControllerDestination.close();
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                // putSearchTermFirstDestination(term);
                                // selectedTermDestination = term;
                              });
                              // searchControllerDestination.close();
                            },
                          ),
                        )
                        .toList(),
                  );
                }
              },
            ),
          ),
        );
      }, //builder
    );
  }
}

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

    final fsb = FloatingSearchBar.of(context);

    return ListView(
      //padding: EdgeInsets.only(top: fsb.height +fsb.margins.vertical),
      children: List.generate(
        10,
        (index) => ListTile(
          title: Text('$searchTerm'),
          subtitle: const Text('University Park Campus'),
        ),
      ),
    );
  }
}
