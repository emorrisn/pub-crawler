import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:pub_hopper_app/models/Location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../helpers/authenticationHelper.dart';
import '../../models/Crawl.dart';
import '../../models/database_models/UserDB.dart';
import '../../widgets/mapWidget.dart';

import '../../services/overpassAPI.dart';
import 'selectLocations/newCrawlSelectLocationsDrawer.dart';

class newCrawlSelectLocationsScreen extends StatefulWidget {
  const newCrawlSelectLocationsScreen({super.key});

  @override
  State<newCrawlSelectLocationsScreen> createState() => _SelectLocationsState();
}

class _SelectLocationsState extends State<newCrawlSelectLocationsScreen> {
  // Controllers
  late MapController mapController;
  late PopupController popupController;
  late PanelController panelController;
  // Data & Settings
  final OverpassApiService _overpassApi = OverpassApiService();
  late Crawl crawlDetails;
  late List<Location> locations;
  late List<Location> selectedLocations = [];
  late double delta =
      0.05; // Size of radius of pubs (^= more pubs but less performance)
  // User
  UserDB? _user;
  bool loading = false;

  Future<UserDB?> getUser() async {
    final user = await UserDB.getBySession(AuthenticationHelper().currentUser);
    setState(() {
      _user = user;
    });
    return user;
  }

  @override
  void initState() {
    super.initState();
    getUser();
    loading = true;
    locations = List.empty();
    selectedLocations = [];
    mapController = MapController();
    popupController = PopupController();
    panelController = PanelController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    crawlDetails = ModalRoute.of(context)!.settings.arguments as Crawl;

    fetchData(crawlDetails.city).then((value) {
      setState(() {
        locations = value;
        loading = false;
      });
    });
  }

  Future<List<Location>> fetchData(city) async {
    if (locations.isEmpty) {
      try {
        double latMin = city.latitude - delta;
        double lonMin = city.longitude - delta;
        double latMax = city.latitude + delta;
        double lonMax = city.longitude + delta;

        return await _overpassApi.queryAmenity(
            latMin, lonMin, latMax, lonMax, 'pub');
      } catch (e) {
        debugPrint('Error fetching data: $e');
        return List.empty();
      }
    }
    return locations;
  }

  void addSelectedLocation(Location location) {
    setState(() {
      selectedLocations.add(location);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location ${location.name} selected.'),
        duration: const Duration(seconds: 2),
      ),
    );
    popupController.hideAllPopups();
  }

  void removeSelectedLocation(Location location) {
    setState(() {
      selectedLocations.remove(location);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location ${location.name} deselected.'),
        duration: const Duration(seconds: 2),
      ),
    );
    popupController.hideAllPopups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SlidingUpPanel(
        controller: panelController,
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        panel: _user == null
            ? const Center(child: CircularProgressIndicator())
            : DrawerWidget(
                locations: locations,
                selectedLocations: selectedLocations,
                mapController: mapController,
                panelController: panelController,
                popupController: popupController,
                crawlDetails: crawlDetails), // Your custom drawer widget
        minHeight: 100, // Height of the collapsed panel
        maxHeight: MediaQuery.of(context).size.height *
            0.95, // Height of the expanded panel
        body: _user == null || loading == true
            ? const Center(child: CircularProgressIndicator())
            : MapWidget(
                popupController: popupController,
                mapController: mapController,
                tracking: false,
                latitude: crawlDetails.city.latitude,
                longitude: crawlDetails.city.longitude,
                zoom: 14,
                locations: locations,
                selectedLocations: selectedLocations,
                onLocationSelected: addSelectedLocation,
                onLocationDeselected: removeSelectedLocation,
                user: _user!,
              ), // Your map widget or main content
      ),
    );
  }
}
