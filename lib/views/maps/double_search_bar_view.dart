import 'package:flutter/material.dart';
import 'package:legsfree/models/nodes_model.dart';
import 'package:legsfree/models/route_map.dart';
import 'package:legsfree/models/route_points.dart';
import 'package:legsfree/services/local%20db%20helper/local_db_helper.dart';
import 'package:legsfree/views/maps/new_maps_view.dart';

class DoubleSearchBarView extends StatefulWidget {
  const DoubleSearchBarView({super.key});

  @override
  State<DoubleSearchBarView> createState() => _DoubleSearchBarViewState();
}

class _DoubleSearchBarViewState extends State<DoubleSearchBarView> {
  TextEditingController startLocation = TextEditingController();
  TextEditingController destination = TextEditingController();
  String selectedStartLocation = '';
  String selectedDestination = '';
  List<NodesModel> allNodes = [];
  List<NodesModel> isSelectableNodes = [];

  List<RouteMapModel> routeMaps = [];
  List<RoutePointsModel> routePoints = [];
  List<NodesModel> getNodePoints = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      isSelectableNodes = await getIsSelectableNodes();
      isLoading = false;
      setState(() {});
      allNodes = await LocalDBhelper().getNodes();
      routeMaps = await LocalDBhelper().getRouteMap();
      routePoints = await LocalDBhelper().getRoutePoints();
    });
  }

  Future<List<NodesModel>> getIsSelectableNodes() async {
    List<NodesModel> isSelectableNodes = [];
    List<NodesModel> allNodes = await LocalDBhelper().getNodes();
    for (int i = 0; i < allNodes.length; i++) {
      if (allNodes[i].isSelectable == 1) {
        isSelectableNodes.add(allNodes[i]);
      }
    }
    return isSelectableNodes;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.height * 0.18,
        //BACK BUTTON
        leading: BackButton(),
        //SEARCH FIELDS
        actions: [
          Column(
            children: [
              _searchField(
                  size,
                  startLocation,
                  selectedStartLocation == ''
                      ? 'Search Start Location'
                      : selectedStartLocation,
                  selectedStartLocation == '' ? true : false,
                  selectedStartLocation == '' ? Colors.grey : Colors.black),
              _searchField(
                  size,
                  destination,
                  selectedDestination == ''
                      ? 'Search Destination'
                      : selectedDestination,
                  selectedStartLocation == ''
                      ? false
                      : selectedDestination == ''
                          ? true
                          : false,
                  selectedDestination == '' ? Colors.grey : Colors.black)
            ],
          )
        ],
      ),
      //SEARCH DATA
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          :
          //SEARCH START LOCATION
          startLocation.text.isNotEmpty
              ? ListView(
                  children: isSelectableNodes
                      .where((item) => item.name!
                          .toLowerCase()
                          .contains(startLocation.text.toLowerCase()))
                      .map((item) => ListTile(
                            title: Text(item.name!),
                            subtitle: const Text('University Park Campus'),
                            onTap: () {
                              setState(() {
                                startLocation.clear();
                                selectedStartLocation = item.name!;
                              });
                            },
                          ))
                      .toList(),
                )
              :
              //SEARCH DESTINATION
              destination.text.isNotEmpty
                  ? ListView(
                      children: isSelectableNodes
                          .where((item) => item.name!
                              .toLowerCase()
                              .contains(destination.text.toLowerCase()))
                          .map((item) => ListTile(
                                title: Text(item.name!),
                                subtitle: const Text('University Park Campus'),
                                onTap: () {
                                  setState(() {
                                    destination.clear();
                                    selectedDestination = item.name!;
                                    _onSubmit();
                                  });
                                },
                              ))
                          .toList(),
                    )
                  :
                  //SEARCH PLACEHOLDER
                  Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search,
                            size: 30,
                          ),
                          Text(
                            'Start Searching',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
    );
  }

  Container _searchField(Size size, TextEditingController controller,
      String hintText, bool enable, Color hintColor) {
    return Container(
      height: size.height * 0.06,
      width: size.width * 0.8,
      margin:
          EdgeInsets.only(right: size.width * 0.05, top: size.height * 0.02),
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: TextField(
        enabled: enable,
        controller: controller,
        onSubmitted: (val) {},
        onChanged: (val) {
          setState(() {});
        },
        decoration: InputDecoration(
            hintStyle: TextStyle(color: hintColor),
            border: InputBorder.none,
            hintText: hintText),
      ),
    );
  }

  _onSubmit() async {
    isLoading = true;
    setState(() {});
    // String journeyName = 'From $selectedStartLocation to $selectedDestination';
    // List<String> points = [];
    // //GET ROUTE POINTS
    // for (int i = 0; i < routePoints.length; i++) {
    //   if (routePoints[i].journeyName == journeyName) {
    //     points.add(routePoints[i].points!);
    //   }
    // }
    // print('FOUND ROUNTE POINT $points');
    // //GET ROUTE MAP
    // for (int i = 0; i < routeMaps.length; i++) {
    //   if (routeMaps[i].journeyName == journeyName) {
    //     print('FOUND ROUNTE MAP ${routeMaps[i].mapName}');
    //   }
    // }
    // //GET POINTS FROM NODES
    // for (int i = 0; i < allNodes.length; i++) {
    //   for (int p = 0; p < points.length; p++) {
    //     if (allNodes[i].name == points[p]) {
    //       getNodePoints.add(allNodes[i]);
    //     }
    //   }
    // }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => NewMapsView(
                destination: selectedDestination,
                startLocation: selectedStartLocation)));
    print('GET NODES POINTS ${getNodePoints.length}');
    isLoading = false;
    setState(() {});
  }
}
