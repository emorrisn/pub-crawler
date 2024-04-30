import 'package:flutter/material.dart';

import '../../models/Crawl.dart';
import '../../models/Location.dart';
import '../../models/LocationChallenge.dart';

class newCrawlSelectChallengesScreen extends StatefulWidget {
  const newCrawlSelectChallengesScreen({super.key});

  @override
  State<newCrawlSelectChallengesScreen> createState() =>
      _SelectChallengesScreen();
}

class _SelectChallengesScreen extends State<newCrawlSelectChallengesScreen> {
  late List<Location> locations;
  late List<LocationChallenge> locationChallenges;
  bool _initCompleted = false;

  @override
  void initState() {
    super.initState();
    locations = [];
    locationChallenges = [];
    _initCompleted = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initCompleted) {
      // Now it's safe to access ModalRoute.of(context)
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        if (args['locationChallenges'] != null) {
          setState(() {
            locationChallenges = args['locationChallenges'];
          });
        }
        if (args['locationChallenge'] != null) {
          final locationChallenge =
              args['locationChallenge'] as LocationChallenge;
          setState(() {
            final index = locationChallenges.indexWhere(
                (lc) => lc.locationID == locationChallenge.locationID);
            if (index != -1) {
              // If the LocationChallenge already exists in the list, update it
              locationChallenges[index] = locationChallenge;
            } else {
              // Otherwise, add it to the list
              locationChallenges.add(locationChallenge);
            }
          });
        }
      }
    }
  }

  void findOrMakeLocationChallengeLink() {
    for (final location in locations) {
      final locationID = location.localID.toString();
      final LocationChallenge blankLocationChallenge = LocationChallenge(
        locationID: locationID,
        individualChallenges: [],
        groupChallenges: [],
      );

      bool addBlankChallenge = true;

      final existingLocationChallenge = locationChallenges.firstWhere(
        (challenge) {
          if (challenge.locationID == locationID) {
            addBlankChallenge = false;
            return true;
          }
          return false;
        },
        orElse: () => blankLocationChallenge,
      );

      if (addBlankChallenge) {
        locationChallenges.add(blankLocationChallenge);
      }
    }
  }

  void updateLocationChallengeState(
      Location location, LocationChallenge updatedChallenge) {
    setState(() {
      // Find the index of the location challenge in the list
      final index = locationChallenges.indexWhere(
          (challenge) => challenge.locationID == location.localID.toString());
      if (index != -1) {
        // Update the location challenge at the found index
        locationChallenges[index] = updatedChallenge;
      } else {
        // Add the updated challenge if not found
        locationChallenges.add(updatedChallenge);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      Crawl crawlDetails = args['crawlDetails'] as Crawl;

      locations = crawlDetails.locations;
      findOrMakeLocationChallengeLink();

      return Scaffold(
          appBar: AppBar(
            title: const Text('Set Challenges'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton.filledTonal(
                  onPressed: () {
                    Crawl crawl = Crawl(
                        name: crawlDetails.name,
                        description: crawlDetails.description,
                        city: crawlDetails.city,
                        individualChallenges: crawlDetails.individualChallenges,
                        groupChallenges: crawlDetails.groupChallenges,
                        locations: locations,
                        individualChallengeChance:
                            crawlDetails.individualChallengeChance,
                        challenges: locationChallenges);

                    Navigator.pushNamed(
                      context,
                      '/new/finalise',
                      arguments: {
                        'crawl': crawl,
                      },
                    );
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
          body: ListView.builder(
              itemCount: crawlDetails.locations.length,
              itemBuilder: (context, index) {
                int individualChallenges = 0;
                int groupChallenges = 0;

                // Find location challenges for the current location
                final currentLocationChallenges = locationChallenges
                    .where((challenge) =>
                        challenge.locationID ==
                        locations[index].localID.toString())
                    .toList();

                // Count individual and group challenges
                for (final challenge in currentLocationChallenges) {
                  if (challenge.individualChallenges.isNotEmpty) {
                    individualChallenges +=
                        challenge.individualChallenges.length;
                  }
                  if (challenge.groupChallenges.isNotEmpty) {
                    groupChallenges += challenge.groupChallenges.length;
                  }
                }

                return Column(
                  children: [
                    const Divider(),
                    ListTile(
                      onTap: () {
                        final selectedLocationID =
                            locations[index].localID.toString();
                        final LocationChallenge selectedLocationChallenge =
                            locationChallenges.firstWhere(
                          (challenge) =>
                              challenge.locationID == selectedLocationID,
                          orElse: () => LocationChallenge(
                            locationID: '0',
                            individualChallenges: [],
                            groupChallenges: [],
                          ),
                        );

                        if (selectedLocationChallenge.locationID == '0') {
                          debugPrint('error!');
                        } else {
                          Navigator.pushNamed(
                              context, '/new/select-challenges/location',
                              arguments: {
                                'locationChallenges': locationChallenges,
                                'location': locations[index],
                                'locationChallenge': selectedLocationChallenge,
                                'crawlDetails': crawlDetails,
                              });
                        }
                      },
                      leading: Text('#${locations[index].position + 1}'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      title: Text(
                        locations[index].name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          "$groupChallenges Group, $individualChallenges Individual"),
                    ),
                  ],
                );
              }
              )
      );
    }

    return const Center(
      child: Text("Error: Could not load crawl details!"),
    );
  }
}
