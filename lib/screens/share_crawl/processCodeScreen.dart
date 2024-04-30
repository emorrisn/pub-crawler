import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/City.dart';

import '../../models/Challenge.dart';
import '../../models/Crawl.dart';
import '../../models/Location.dart';
import '../../models/LocationChallenge.dart';
import '../../providers/groupChallengeProvider.dart';
import '../../providers/individualChallengeProvider.dart';

class processCodeScreen extends StatefulWidget {
  const processCodeScreen({super.key});

  @override
  State<processCodeScreen> createState() => _ProcessCode();
}

class _ProcessCode extends State<processCodeScreen> {
  final _audioPlayer = AudioPlayer();

  // Providers
  GroupChallengeProvider groupChallengeProvider = GroupChallengeProvider();
  IndividualChallengeProvider individualChallengeProvider =
      IndividualChallengeProvider();

  // Raw data
  String rawDetails = "";
  String rawLocations = "";
  String rawChallenges = "";
  String rawLocationChallenges = "";

  // Json Challenges
  List<Challenge> individualChallenges = [];
  List<Challenge> groupChallenges = [];

  // Converted/Processed Data
  Map<String, String> details = {};
  List<Location> locations = [];
  List<LocationChallenge> locationChallenges = [];
  bool dataProcessed = false;

  // Generated Crawl
  Crawl? crawl;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadChallenges() async {
    groupChallenges = await groupChallengeProvider.getChallenges();
    individualChallenges = await individualChallengeProvider.getChallenges();

    setState(() {}); // Trigger a rebuild once cities are loaded
  }

  void _loadData(args) {
    if (args != null) {
      for (Map<String, String?> item in args) {
        String key = item.keys.first;
        String? data = item.values.first;
        if (data != null) {
          if (key == 'Challenges') {
            rawChallenges = data;
          } else if (key == 'Locations') {
            rawLocations = data;
          } else if (key == 'Location Challenges') {
            rawLocationChallenges = data;
          } else if (key == 'Details') {
            rawDetails = data;
          }
        }
      }
    }
  }

  void _processData() {
    if (dataProcessed == false) {
      _loadChallenges().then((_) {
        _processDetailsData();
        _processLocationsData();
        _processChallengesData();
      }).then((value) => _createCrawl());
    }
    dataProcessed = true;
    setState(() {});
  }

  void _createCrawl() {
    crawl = Crawl(
      name: details['name'] ?? '',
      description: details['description'] ?? '',
      city: City(
          name: details['city'] ?? '',
          country: '',
          latitude: 0.0,
          longitude: 0.0),
      individualChallenges: details['individualChallenges'] == 'true',
      groupChallenges: details['groupChallenges'] == 'true',
      individualChallengeChance:
          double.tryParse(details['individualChallengeChance'] ?? '') ?? 0.0,
      locations: locations,
      challenges: locationChallenges,
    );
    setState(() {});
  }

  void _processDetailsData() {
    List<String> detailsList = rawDetails.split(':');

    details = {
      'name': Uri.decodeComponent(detailsList[0]),
      'city': detailsList[1],
      'description': Uri.decodeComponent(detailsList[2]),
      'individualChallengeChance': (int.parse(detailsList[3]) / 100).toString(),
      'individualChallenges': detailsList[4],
      'groupChallenges': detailsList[5],
    };
  }

  void _processLocationsData() {
    List<String> locationsList = rawLocations.split(',');
    List<Location> localLocations = [];

    for (String loc in locationsList) {
      List<String> l = loc.split(':');
      Location location = Location(
        apiID: int.parse(l[0]),
        localID: int.parse(l[0]),
        name: Uri.decodeComponent(l[1]),
        position: int.parse(l[4]),
        longitude: double.parse(l[2]),
        latitude: double.parse(l[3]),
      );

      localLocations.add(location);
    }

    locations.addAll(localLocations);
  }

  void _processChallengesData() {
    Map<int, List<Challenge>> locationChallengesMap = {};

    for (String locationChallenge in rawLocationChallenges.split(',')) {
      List<String> listLocationChallenge = locationChallenge.split(':');
      int locationId = int.parse(listLocationChallenge[0]);
      int challengeId = int.parse(listLocationChallenge[1]);

      if (!locationChallengesMap.containsKey(locationId)) {
        locationChallengesMap[locationId] = [];
      }

      bool group = false;

      // Go through challenges list and find if's a group challenge or not.
      List<String> listChallenges = rawChallenges.split(',');
      for (String challengeItem in listChallenges) {
        List<String> splitChallengeItem = challengeItem.split(':');
        if (splitChallengeItem[0].toString() == challengeId.toString() &&
            splitChallengeItem[1].toString() == '1') {
          group = true;
        }
      }

      Challenge? foundChallenge = Challenge.fromPos(
          challengeId, group, individualChallenges, groupChallenges);

      locationChallengesMap[locationId]!.add(foundChallenge);
        }

    // Debug: Check what challenges have been found
    // locationChallengesMap.forEach((locationId, challenges) {
    //   print('Location ID: $locationId');
    //   print('Challenges:');
    //   for (var challenge in challenges) {
    //     print('| ${challenge.title} _ ${challenge.type}');
    //   }
    // });

    locationChallengesMap.forEach((locationId, challenges) {
      locationChallenges.add(LocationChallenge(
        locationID: locationId.toString(),
        individualChallenges:
            challenges.where((challenge) => challenge.type != 'group').toList(),
        groupChallenges:
            challenges.where((challenge) => challenge.type == 'group').toList(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments
        as List<Map<String, String?>>?;

    _loadData(args);
    _processData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Joining Crawl...'),
      ),
      body: crawl == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        const Text(
                          'Crawl Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text('Name: ${crawl!.name}'),
                        Text('Description: ${crawl!.description}'),
                        Text('City: ${crawl!.city.name}'),
                        Text(
                            'Individual Challenges: ${crawl!.individualChallenges}'),
                        Text('Group Challenges: ${crawl!.groupChallenges}'),
                        Text(
                            'Individual Challenge Chance: ${crawl!.individualChallengeChance}'),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _audioPlayer.play(AssetSource("audio/ta-da.wav"));
                        await crawl!.saveToDatabase();

                        if(mounted)
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Crawl saved"),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                      },
                      child: const Text('Accept & Save Crawl'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}
