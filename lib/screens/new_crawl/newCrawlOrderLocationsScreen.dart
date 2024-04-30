import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../helpers/authenticationHelper.dart';
import '../../models/Crawl.dart';
import '../../models/Location.dart';
import '../../models/database_models/UserDB.dart';
import '../../widgets/mapWidget.dart';
import 'orderLocations/newCrawlOrderLocationsDrawer.dart';


class newCrawlOrderLocationsScreen extends StatefulWidget {
  const newCrawlOrderLocationsScreen({super.key});

  @override
  State<newCrawlOrderLocationsScreen> createState() => _OrderLocationsScreen();
}

class _OrderLocationsScreen extends State<newCrawlOrderLocationsScreen> {
  // Controllers
  late MapController mapController;
  late PopupController popupController;
  late PanelController panelController;
  // Crawl
  late Crawl crawlDetails;
  late List<Location> locations;

  // User
  UserDB? _user;

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
    locations = List.empty();
    mapController = MapController();
    popupController = PopupController();
    panelController = PanelController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      crawlDetails = ModalRoute.of(context)!.settings.arguments as Crawl;
      List<Location> updatedLocations = List.from(crawlDetails.locations);
      for (int i = 0; i < updatedLocations.length; i++) {
        updatedLocations[i].position = i;
      }

      locations = updatedLocations;
    });
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
        panel: DrawerWidget(
            locations: locations,
            mapController: mapController,
            panelController: panelController,
            popupController: popupController,
            crawlDetails: crawlDetails
        ), // Your custom drawer widget
        minHeight: 100, // Height of the collapsed panel
        maxHeight: MediaQuery.of(context).size.height *
            0.95, // Height of the expanded panel
        body: _user == null ? const Center(child: CircularProgressIndicator()) : MapWidget(
          popupController: popupController,
          mapController: mapController,
          tracking: false,
          latitude: crawlDetails.city.latitude,
          longitude: crawlDetails.city.longitude,
          zoom: 14,
          locations: locations,
          locationPositions: true,
          locationPopUpButtons: false,
          locationLines: true,
          locationMarkerClustering: false,
          locationCameraFit: true,
          user: _user!,
        ), // Your map widget or main content
      ),
    );
  }
}
