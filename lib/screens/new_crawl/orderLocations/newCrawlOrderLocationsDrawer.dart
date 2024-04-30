import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../models/Crawl.dart';
import '../../../models/Location.dart';
import '../../../widgets/new_crawl/ReorderableListItem.dart';

class DrawerWidget extends StatefulWidget {
  final List<Location> locations;

  final MapController mapController; // Map control
  final PanelController panelController; // Slide-up panel control
  final PopupController popupController; // Map pop-up control

  final Crawl crawlDetails;

  const DrawerWidget(
      {super.key,
      required this.locations,
      required this.mapController,
      required this.panelController,
      required this.popupController,
      required this.crawlDetails});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  // Controllers
  late MapController mapController;
  late PanelController panelController;
  late PopupController popupController;
  // Locations
  late List<Location> locations;
  late List<Location> virtualLocations;
  // Search
  final TextEditingController searchController = TextEditingController();
  // Crawl
  late Crawl crawlDetails;

  @override
  void initState() {
    super.initState();
    locations = widget.locations;
    mapController = widget.mapController;
    popupController = widget.popupController;
    panelController = widget.panelController;
    crawlDetails = widget.crawlDetails;
    virtualLocations = locations;
  }

  @override
  void didUpdateWidget(DrawerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (locations != widget.locations) {
      setState(() {
        locations = widget.locations;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
          ),
          AppBar(
            title: const Text(
              "Order Locations",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton.filledTonal(
                  onPressed: () {
                    // Create a copy of selectedLocations
                    final List<Location> selectedLocationsCopy =
                        List.from(locations);

                    // Update crawlDetails with the copy (optional)
                    crawlDetails.locations = selectedLocationsCopy;

                    // Navigate to the next page and pass the crawlDetails object
                    Navigator.pushNamed(context, '/new/select-challenges',
                        arguments: {'crawlDetails': crawlDetails});
                  },
                  icon: const Icon(Icons.check),
                ),
              ),
            ],
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          const Divider(),
          Expanded(
              child: ReorderableListView(
            children: <Widget>[
              for (var location
                  in locations.toList()
                    ..sort((a, b) => a.position.compareTo(b.position)))
                ReorderableLocationListItem(
                  position: -1,
                  location: location,
                  key: Key('${location.position}'),
                ),
            ],
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = virtualLocations.removeAt(oldIndex);
                virtualLocations.insert(newIndex, item);
              });

              setState(() {
                // Update positions for all locations
                for (int i = 0; i < locations.length; i++) {
                  int virtualIndex = virtualLocations
                      .indexWhere((loc) => loc.apiID == locations[i].apiID);
                  locations[i].position = virtualIndex;
                }
              });
            },
          )),
        ],
      ),
    );
  }
}
