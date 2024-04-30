import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/database_models/LocationDB.dart';
import 'package:pub_hopper_app/screens/edit_crawl/challenges/editCrawlChallengesScreen.dart';
import 'package:pub_hopper_app/screens/edit_crawl/details/editCrawlDetailsScreen.dart';
import 'package:pub_hopper_app/screens/edit_crawl/locations/editCrawlLocationsScreen.dart';
import '../../models/database_models/CrawlDB.dart';

class editCrawlScreen extends StatefulWidget {
  const editCrawlScreen({super.key});

  @override
  State<editCrawlScreen> createState() => _EditDetail();
}

class _EditDetail extends State<editCrawlScreen> {
  late CrawlDB crawl;
  int currentTab = 0;

  late bool hasChanges;
  bool loading = false;

  // Details

  late Map<String, dynamic> detailsForm;

  void updateDetails(Map<String, dynamic> details) {
    setState(() {
      if (detailsForm != details) {
        hasChanges = true;
      }
      detailsForm = details;
    });
  }

  void _initializeCrawl() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      crawl = args['crawl'] as CrawlDB;
    }

    _initializeLocations();
  }

  // Locations
  late List<LocationDB> locations;
  late List<LocationDB> dirtyLocations;

  void updateLocations(List<Map<int, LocationDB>> locations) {
    dirtyLocations = [];

    for (Map<int, LocationDB> mappedLocations in locations) {
      int key = mappedLocations.keys.first;
      LocationDB oldLocation = mappedLocations.values.first;

      LocationDB newLocation = LocationDB(
        id: oldLocation.id,
        orderPos: key,
        name: oldLocation.name,
        description: oldLocation.description,
        city: oldLocation.city,
        country: oldLocation.country,
        postcode: oldLocation.postcode,
        street: oldLocation.street,
        houseNumber: oldLocation.houseNumber,
        website: oldLocation.website,
        amenity: oldLocation.amenity,
        openingHours: oldLocation.openingHours,
        phone: oldLocation.phone,
        outdoorSeating: oldLocation.outdoorSeating,
        longitude: oldLocation.longitude,
        latitude: oldLocation.latitude,
      );

      dirtyLocations.add(newLocation);
    }

    if (locations.map((locationMap) => locationMap.values.first).toList() != dirtyLocations) {
      setState(() {
        hasChanges = true;
      });
    }
  }
  // Committing changes

  void _commitDetailsChanges() {
    // Todo: Check currently selected tab!

    setState(() {
      loading = true;
    });

    // Committing changes for locations
    if (currentTab == 1) {
      for (LocationDB location in dirtyLocations) {
        location.update();
      }
      locations = dirtyLocations;
      dirtyLocations = [];
    }

    // Committing changes for details
    if (currentTab == 0) {
      CrawlDB newCrawl = CrawlDB(
        name: detailsForm['name'],
        id: crawl.id,
        city: detailsForm['city'],
        description: detailsForm['description'],
        individualChallenges: detailsForm['individualChallenges'],
        groupChallenges: detailsForm['groupChallenges'],
        individualChallengeChance:
            detailsForm['individualChallengeChance'] / 100,
      );

      newCrawl.update();
      crawl = newCrawl;
    }

    setState(() {
      loading = false;
      hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Crawl updated"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _initializeLocations() async {
    try {
      // Get locations
      locations = await crawl.getAllLocations();
    } catch (error) {
      // Handle error
      debugPrint('Error fetching locations: $error');
      // Set loading to false in case of error
    }
  }

  @override
  void initState() {
    super.initState();
    hasChanges = false;
    locations = [];
    detailsForm = {
      'name': '',
      'city': '',
      'description': '',
      'individualChallenges': false,
      'groupChallenges': false,
      'individualChallengeChance': 5.0,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCrawl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Crawl'),
        actions: [
          hasChanges == true
              ? Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: IconButton.filledTonal(
                    onPressed: () => _commitDetailsChanges(),
                    icon: const Icon(Icons.check),
                  ),
                )
              : const SizedBox(),
        ],
      ),
      body: DefaultTabController(
        length: 3, // Number of tabs
        child: Column(
          children: [
            TabBar(
              onTap: (index) {
                setState(() {
                  currentTab = index;
                  hasChanges = false;
                });
              },
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Locations'),
                Tab(text: 'Challenges'),
              ],
            ),
            Expanded(
              child: loading == true
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : TabBarView(
                      children: [
                        editCrawlDetails(
                          crawl: crawl,
                          onUpdateDetails: updateDetails,
                        ),
                        editCrawlLocations(
                          locations: locations,
                          onUpdateLocations: updateLocations,
                        ),
                        editCrawlChallenges(
                            locations: locations,
                            crawl: crawl,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
