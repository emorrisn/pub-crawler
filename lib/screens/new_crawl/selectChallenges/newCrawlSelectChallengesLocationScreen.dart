
import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/Challenge.dart';

import '../../../models/Crawl.dart';
import '../../../models/Location.dart';
import '../../../models/LocationChallenge.dart';
import '../../../providers/groupChallengeProvider.dart';
import '../../../providers/individualChallengeProvider.dart';
import '../../../widgets/new_crawl/ChallengeListItem.dart';

class newCrawlSelectChallengesLocationScreen extends StatefulWidget {
  const newCrawlSelectChallengesLocationScreen({super.key});

  @override
  State<newCrawlSelectChallengesLocationScreen> createState() =>
      _SelectChallengesLocationScreen();
}

class _SelectChallengesLocationScreen
    extends State<newCrawlSelectChallengesLocationScreen> {
  GroupChallengeProvider groupChallengeProvider = GroupChallengeProvider();
  IndividualChallengeProvider individualChallengeProvider =
      IndividualChallengeProvider();

  late List<LocationChallenge>? locationChallenges;
  late Location location;
  late LocationChallenge locationChallenge;
  late Crawl crawlDetails;
  final TextEditingController searchController = TextEditingController();

  List<Challenge> groupChallenges = [];
  List<Challenge> individualChallenges = [];

  List<Challenge> filteredGroupChallenges = [];
  List<Challenge> filteredIndividualChallenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  @override
  void didUpdateWidget(newCrawlSelectChallengesLocationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      location = args?['location'];
      locationChallenge = args?['locationChallenge'];
    });

    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    groupChallenges = await groupChallengeProvider.getChallenges();
    filteredGroupChallenges = List.from(groupChallenges);
    individualChallenges = await individualChallengeProvider.getChallenges();
    filteredIndividualChallenges = List.from(individualChallenges);

    setState(() {}); // Trigger a rebuild once cities are loaded
  }

  void updateGroupChallengesState(Challenge challenge, bool newValue) {
    setState(() {
      if (newValue) {
        // Add the challenge to groupChallenges
        locationChallenge.groupChallenges.add(challenge);
      } else {
        // Remove the challenge from groupChallenges
        locationChallenge.groupChallenges.remove(challenge);
      }
    });
  }

  void updateIndividualChallengesState(Challenge challenge, bool newValue) {
    setState(() {
      if (newValue) {
        // Add the challenge to groupChallenges
        locationChallenge.individualChallenges.add(challenge);
      } else {
        // Remove the challenge from groupChallenges
        locationChallenge.individualChallenges.remove(challenge);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    location = args?['location'];
    locationChallenge = args?['locationChallenge'];
    crawlDetails = args?['crawlDetails'];
    locationChallenges = args?['locationChallenges'];

    //
    // print(locationChallenge.groupChallenges.map((e) => '${e.title} - ${e.remain}'));
    // print(locationChallenge.individualChallenges.map((e) => e.title));

    return Scaffold(
        appBar: AppBar(
          title: Text('${location.name} Challenges'),
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: IconButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/new/select-challenges',
                  arguments: {
                    'location': location,
                    'locationChallenge': locationChallenge,
                    'crawlDetails': crawlDetails,
                    'locationChallenges': locationChallenges,
                  },
                );
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: 'Group (${locationChallenge.groupChallenges.length})'),
                  Tab(text: 'Individual (${locationChallenge.individualChallenges.length})'),
                ],
              ),
              SearchBar(
                shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero)),
                leading: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
                elevation: MaterialStateProperty.resolveWith<double?>(
                  (states) {
                    return 1; // Default elevation
                  },
                ),
                controller: searchController,
                hintText: "Search...",
                onChanged: (query) {
                  setState(() {
                    if (query.isNotEmpty) {
                      // Filter group challenges
                      filteredGroupChallenges = groupChallenges
                          .where((challenge) =>
                              challenge.title
                                  .toLowerCase()
                                  .contains(query.toLowerCase()) ||
                              challenge.description
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                          .toList();

                      // Filter individual challenges
                      filteredIndividualChallenges = individualChallenges
                          .where((challenge) =>
                              challenge.title
                                  .toLowerCase()
                                  .contains(query.toLowerCase()) ||
                              challenge.description
                                  .toLowerCase()
                                  .contains(query.toLowerCase()))
                          .toList();
                    } else {
                      // Reset filtered lists when query is empty
                      filteredGroupChallenges = List.from(groupChallenges);
                      filteredIndividualChallenges =
                          List.from(individualChallenges);
                    }
                  });
                },
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: ListView.builder(
                        itemCount: filteredGroupChallenges
                            .length, // Hardcoded number of items for testing
                        itemBuilder: (context, index) {
                          final Challenge challenge =
                              filteredGroupChallenges[index];

                          // Check if the challenge is in LocationChallenge.groupChallenges
                          final isInChallenges = locationChallenge
                              .groupChallenges
                              .contains(challenge);

                          return ChallengeListItem(
                            challenge: challenge,
                            group: true,
                            isInChallenges: isInChallenges,
                            locationChallenge: locationChallenge,
                            onUpdateGroupChallengesState: updateGroupChallengesState, // Pass the function to update the group challenges state
                            onUpdateIndividualChallengesState: updateIndividualChallengesState, // Pass the function to update the individual challenges state
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: ListView.builder(
                        itemCount: filteredIndividualChallenges
                            .length, // Hardcoded number of items for testing
                        itemBuilder: (context, index) {
                          final Challenge challenge =
                          filteredIndividualChallenges[index];

                          // Check if the challenge is in LocationChallenge.individualChallenges
                          final isInChallenges = locationChallenge
                              .individualChallenges
                              .contains(challenge);

                          return ChallengeListItem(
                            challenge: challenge,
                            group: false,
                            isInChallenges: isInChallenges,
                            locationChallenge: locationChallenge,
                            onUpdateGroupChallengesState: updateGroupChallengesState, // Pass the function to update the group challenges state
                            onUpdateIndividualChallengesState: updateIndividualChallengesState, // Pass the function to update the individual challenges state
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
