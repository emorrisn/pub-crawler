import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/Challenge.dart';
import 'package:pub_hopper_app/models/database_models/CrawlDB.dart';
import 'package:pub_hopper_app/models/database_models/CrawlLocationChallengeDB.dart';
import 'package:pub_hopper_app/models/database_models/LocationDB.dart';
import '../../../models/database_models/ChallengeDB.dart';
import '../../../providers/groupChallengeProvider.dart';
import '../../../providers/individualChallengeProvider.dart';
import '../../../widgets/edit_crawl/ChallengeListItem.dart';

class editCrawlLocationChallengesScreen extends StatefulWidget {
  const editCrawlLocationChallengesScreen({super.key});

  @override
  State<editCrawlLocationChallengesScreen> createState() =>
      _EditLocationChallengesScreen();
}

class _EditLocationChallengesScreen
    extends State<editCrawlLocationChallengesScreen> {
  // Controllers
  final TextEditingController searchController = TextEditingController();

  // Providers
  GroupChallengeProvider groupChallengeProvider = GroupChallengeProvider();
  IndividualChallengeProvider individualChallengeProvider =
  IndividualChallengeProvider();

  LocationDB? location;
  List<ChallengeDB> challenges = [];
  late CrawlDB crawl;

  List<Challenge> groupChallenges = [];
  List<Challenge> individualChallenges = [];

  // Filter and Searching
  List<Challenge> filteredGroupChallenges = [];
  List<Challenge> filteredIndividualChallenges = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        location = args['location'];
        challenges = args['challenges'];
        crawl = args['crawl'];
      });
    }

    if (groupChallenges.isEmpty) {
      groupChallenges = await groupChallengeProvider.getChallenges();
      filteredGroupChallenges = List.from(groupChallenges);
      individualChallenges = await individualChallengeProvider.getChallenges();
      filteredIndividualChallenges = List.from(individualChallenges);
    }
  }

  void _toggleChallengeState(Challenge challenge, bool newValue) async {
    ChallengeDB? existingChallenge = challenges.where((c) => c.title == challenge.title).firstOrNull;
    if(existingChallenge == null)
      {
        // Case: Challenge does not exist in the list and we are setting challenge = true (so we need to add it)
        if (newValue == true) {
          // Insert the challenge into the database and add it to the list
          ChallengeDB newChallenge = ChallengeDB(
            id: 0,
            title: challenge.title,
            description: challenge.description,
            forfeit: challenge.forfeit,
            type: challenge.type,
          );

          int id = await newChallenge.insert();
          challenges.add(newChallenge);
          
          // Linking
          CrawlLocationChallengeDB newLink = CrawlLocationChallengeDB(
              id: 0,
              crawlId: crawl.id,
              locationId: location!.id,
              challengeId: id
          );
          newLink.insert();
        }
      } else {
      // Case: Challenge exists in the list and we
      if (newValue == false) {
        CrawlLocationChallengeDB? link = await CrawlLocationChallengeDB.getByChallengeID(existingChallenge.id);
        if(link != null)
          {
            await link.delete();
            challenges.remove(existingChallenge);
          }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Challenges'),
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
      body: FutureBuilder<void>(
        future: _loadChallenges(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && groupChallenges.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading challenges'),
            );
          } else {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(
                        text:
                        'Group (${challenges
                            .where((element) => element.type == 'group')
                            .length})',
                      ),
                      Tab(
                        text:
                        'Individual (${challenges
                            .where((element) => element.type == 'individual')
                            .length})',
                      ),
                    ],
                  ),
                  SearchBar(
                    shape: MaterialStateProperty.all(
                      const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
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
                            itemCount:
                            filteredGroupChallenges.length,
                            // Hardcoded number of items for testing
                            itemBuilder: (context, index) {
                              final Challenge challenge =
                              filteredGroupChallenges[index];

                              // Check if the challenge is in LocationChallenge
                              final isInChallenges = challenges
                                  .where((ch) => ch.title == challenge.title).isNotEmpty;

                              return ChallengeListItem(
                                challenge: challenge,
                                group: true,
                                isInChallenges: isInChallenges,
                                onUpdateChallenge: _toggleChallengeState,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: ListView.builder(
                            itemCount: filteredIndividualChallenges
                                .length,
                            // Hardcoded number of items for testing
                            itemBuilder: (context, index) {
                              final Challenge challenge =
                              filteredIndividualChallenges[index];

                              // Check if the challenge is in LocationChallenge.individualChallenges
                              final isInChallenges = challenges
                                  .where((ch) => ch.title == challenge.title).isNotEmpty;

                              return ChallengeListItem(
                                challenge: challenge,
                                group: false,
                                isInChallenges: isInChallenges,
                                onUpdateChallenge: _toggleChallengeState,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}