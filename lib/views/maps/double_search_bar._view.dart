import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

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

  //variables for the search bar
  late FloatingSearchBarController searchController;
  List<String> filteredSearchSuggestions = [];
  String? selectedTerm = '';
  late List<String> searchSuggestions = [];
  static const historyLength = 5;
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

  @override
  void initState() {
    getAllNodes();
    searchSuggestions = selectableDestinations;
    filteredSearchSuggestions = filteredSearchTerm(filter: null);
    searchController = FloatingSearchBarController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              width:
                  500.0, // change tomorrowwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww
              color: Colors.red,
              child: buildFloatingSearchBarStartLocation(context),
            ),
          ),
        ],
      ),
    );
  }

  getAllData() async {
    await getAllNodes();
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
      controller: searchController,
      onQueryChanged: (query) {
        setState(() {
          searchController.open();
          filteredSearchSuggestions = filteredSearchTerm(filter: query);
        });
        // Call your model, bloc, controller here.
      },
      body: SearchResultsListView(searchTerm: selectedTerm),
      onSubmitted: (query) {
        setState(() {
          //addSearchTerm(query);
          selectedTerm = query;
        });
        searchController.close;
      },
      // onFocusChanged: (isFocused) {

      // },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        //implementation of the place icon in the search bar when it's pressed
        // FloatingSearchBarAction(
        //   showIfOpened: false,
        //   child: CircularButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {},
        //   ),
        // ),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: filteredSearchSuggestions
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
                              searchController.clear();
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            putSearchTermFirst(term);
                            selectedTerm = term;
                          });
                          searchController.close();
                        },
                      ),
                    )
                    .toList(),
              )

              // child: Builder(
              //   builder: (context) {
              //     if (filteredSearchSuggestions.isEmpty &&
              //         searchController.query.isEmpty) {
              //       return Container(
              //           height: 56,
              //           width: double.infinity,
              //           alignment: Alignment.center,
              //           child: Text('',
              //               maxLines: 1,
              //               overflow: TextOverflow.ellipsis,
              //               style: Theme.of(context).textTheme.headlineSmall));
              //     } else if (filteredSearchSuggestions.isEmpty) {
              //       return ListTile(
              //         title: Text(searchController.query),
              //         leading: const Icon(Icons.search),
              //         onTap: () {
              //           setState(() {
              //             searching(searchController.query);
              //             selectedTerm = searchController.query;
              //           });
              //           searchController.close();
              //         },
              //       );
              //     } else {
              //       return Column(
              //         mainAxisSize: MainAxisSize.min,
              //         children: filteredSearchSuggestions
              //             .map(
              //               (term) => ListTile(
              //                 title: Text(
              //                   term,
              //                   maxLines: 1,
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //                 leading: const Icon(Icons.history),
              //                 trailing: IconButton(
              //                   icon: const Icon(Icons.clear),
              //                   onPressed: () {
              //                     setState(() {
              //                       deleteSearchTerm(term);
              //                     });
              //                   },
              //                 ),
              //                 onTap: () {
              //                   setState(() {
              //                     putSearchTermFirst(term);
              //                     selectedTerm = term;
              //                   });
              //                   searchController.close();
              //                 },
              //               ),
              //             )
              //             .toList(),
              //       );
              //     }
              //   },
              // ),
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
        50,
        (index) => ListTile(
          title: Text('$searchTerm search result'),
          subtitle: Text(index.toString()),
        ),
      ),
    );
  }
}
