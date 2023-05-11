import 'package:flutter/material.dart';
import 'package:legsfree/models/nodes_model.dart';
import 'package:legsfree/models/route_map.dart';
import 'package:legsfree/models/route_points.dart';
import 'package:legsfree/services/local%20db%20helper/local_db_helper.dart';
import 'package:legsfree/views/maps/new_maps_view.dart';

class DoubleSearchBarView extends StatefulWidget {
  const DoubleSearchBarView({super.key, required this.weightClass});
  final int weightClass;
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
    print('WEIGHT CLASS ${widget.weightClass}');
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: size.height * 0.18,
        //BACK BUTTON
        leading: const BackButton(),
        //SEARCH FIELDS
        actions: [
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: size.height * 0.027,
                    width: size.width * 0.06,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 3),
                        shape: BoxShape.circle),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: CircleAvatar(
                        radius: size.width * 0.03,
                        backgroundColor: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  SizedBox(
                    height: size.height * 0.05,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ...List.generate(
                            6,
                            (index) => CircleAvatar(
                                  radius: 2,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.5),
                                ))
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Icon(Icons.location_on_outlined,
                      size: 30, color: Colors.white.withOpacity(0.5))
                ],
              ),
              SizedBox(width: size.width * 0.03),
              Column(
                children: [
                  _searchField(
                      size,
                      startLocation,
                      selectedStartLocation == ''
                          ? 'Search Start Location'
                          : selectedStartLocation,
                      selectedStartLocation == '' ? true : false,
                      selectedStartLocation == '' ? Colors.grey : Colors.black,
                      () {
                    selectedStartLocation = '';
                    startLocation.clear();
                    setState(() {});
                  }),
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
                      selectedDestination == '' ? Colors.grey : Colors.black,
                      () {
                    selectedDestination = '';
                    destination.clear();
                    setState(() {});
                  }),
                ],
              ),
              SizedBox(width: size.width * 0.03),
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
                          .map((item) {
                        if (selectedStartLocation != item.name) {
                          return ListTile(
                            title: Text(item.name!),
                            subtitle: const Text('University Park Campus'),
                            onTap: () {
                              setState(() {
                                destination.clear();
                                selectedDestination = item.name!;
                                _onSubmit();
                              });
                            },
                          );
                        } else {
                          return const SizedBox();
                        }
                      }).toList(),
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
      String hintText, bool enable, Color hintColor, VoidCallback onClear) {
    return Container(
      height: size.height * 0.06,
      width: size.width * 0.75,
      margin: EdgeInsets.only(top: size.height * 0.02),
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Expanded(
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
          ),
          InkWell(
              onTap: onClear,
              child: const Icon(Icons.close, color: Colors.black))
        ],
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
    print('AAA $selectedDestination');
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => NewMapsView(
                destination: selectedDestination,
                startLocation: selectedStartLocation,
                weightClass: widget.weightClass)));

   
    print('GET NODES POINTS ${getNodePoints.length}');
    isLoading = false;
    setState(() {});
  }
}
