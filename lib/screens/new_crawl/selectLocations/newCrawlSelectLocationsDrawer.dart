import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../models/Crawl.dart';
import '../../../models/Location.dart';
import '../../../widgets/new_crawl/LocationListItem.dart';

class DrawerWidget extends StatefulWidget {
  final List<Location> locations;
  final List<Location> selectedLocations;

  final MapController mapController; // Map control
  final PanelController panelController; // Slide-up panel control
  final PopupController popupController; // Map pop-up control

  final Crawl crawlDetails;

  const DrawerWidget({
    super.key,
    required this.locations,
    required this.mapController,
    required this.panelController,
    required this.popupController,
    required this.selectedLocations,
    required this.crawlDetails,
  });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  // Tabs
  late List<Widget> _tabViews;
  late TabController _tabController;
  // Controllers
  late MapController mapController;
  late PanelController panelController;
  late PopupController popupController;
  // Locations
  late List<Location> locations;
  late List<Location> filteredLocations;
  // Selected Locations
  late List<Location> selectedLocations;
  late List<Location> filterSelectedLocations;
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
    filteredLocations = locations;
    panelController = widget.panelController;
    selectedLocations = widget.selectedLocations;
    filterSelectedLocations = selectedLocations;
    crawlDetails = widget.crawlDetails;

    _tabController = TabController(length: 2, vsync: this);
    _tabViews = [
      _buildLocationsTab(), // Function to build the 'Locations' tab
      _buildSelectedTab(), // Function to build the 'Selected' tab
    ];
  }

  @override
  void didUpdateWidget(DrawerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (locations != widget.locations) {
      setState(() {
        locations = widget.locations;
      });
    }
    if (filteredLocations.isEmpty) {
      setState(() {
        filteredLocations = locations;
      });
    }

    if (filterSelectedLocations.isEmpty &&
        filterSelectedLocations.length != selectedLocations.length) {
      filterSelectedLocations = selectedLocations;
    }

    // Update the tab views when locations change
    _tabViews = [
      _buildLocationsTab(), // Function to build the 'Locations' tab
      _buildSelectedTab(), // Function to build the 'Selected' tab
    ];
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
              "Select Locations",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton.filledTonal(
                  onPressed: () {
                    if (selectedLocations.isNotEmpty &&
                        selectedLocations.length > 1) {
                      // Create a copy of selectedLocations
                      final List<Location> selectedLocationsCopy =
                          List.from(selectedLocations);

                      // Update crawlDetails with the copy (optional)
                      crawlDetails.locations = selectedLocationsCopy;

                      // Navigate to the next page and pass the crawlDetails object
                      Navigator.pushNamed(context, '/new/order-locations',
                          arguments: crawlDetails);
                    } else {
                      // Notify user of impossible action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Select two or more locations to continue.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check),
                ),
              ),
            ],
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/new');
                },
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ),
          SearchBar(
            shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
            leading: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
            ),
            trailing: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.mic),
              ),
            ],
            elevation: MaterialStateProperty.resolveWith<double?>(
              (states) {
                return 1; // Default elevation
              },
            ),
            controller: searchController,
            hintText: "Search...",
            onChanged: (value) {
              setState(() {
                filteredLocations = locations
                    .where((location) => location.name
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
                filterSelectedLocations = selectedLocations
                    .where((location) => location.name
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
              });
            },
          ),
          PreferredSize(
            preferredSize: const Size.fromHeight(48.0),
            child: TabBar(
              controller: _tabController,
              tabs: [
                const Tab(
                  text: 'Locations',
                ),
                (selectedLocations.isEmpty)
                    ? const Tab(
                        text: 'Selected',
                      )
                    : Tab(
                        text: '${selectedLocations.length} Selected',
                      ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabViews,
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the 'Locations' tab view
  Widget _buildLocationsTab() {
    if (filteredLocations.isEmpty) {
      return const Center(
        child: Text('No locations found'),
      );
    }

    return ListView.builder(
      itemCount: filteredLocations.length,
      itemBuilder: (context, index) {
        if (index >= filteredLocations.length) {
          return const SizedBox(); // Return an empty SizedBox if index is out of bounds
        }
        // Fix: If we can't find the location in the filtered location using the index, then we just use the index.
        if (!locations.contains(filteredLocations[index])) {
          return Column(
            children: [
              LocationListItem(
                id: index,
                location: filteredLocations[index],
                mapController: mapController,
                panelController: panelController,
                popupController: popupController,
              ),
              const Divider(),
            ],
          );
        }

        return Column(
          children: [
            LocationListItem(
              id: locations.indexOf(filteredLocations[index]),
              location: filteredLocations[index],
              mapController: mapController,
              panelController: panelController,
              popupController: popupController,
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  // Function to build the 'Selected' tab view
  Widget _buildSelectedTab() {
    if (selectedLocations.isEmpty) {
      return const Center(
        child: Text('No locations selected'),
      );
    }
    // Add your implementation for the 'Selected' tab view here
    return ListView.builder(
      itemCount: filterSelectedLocations.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            LocationListItem(
              id: locations.indexOf(filterSelectedLocations[index]),
              location: filterSelectedLocations[index],
              mapController: mapController,
              panelController: panelController,
              popupController: popupController,
            ),
            const Divider(),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
