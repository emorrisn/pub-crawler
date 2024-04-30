import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/database_models/CrawlDB.dart';
import 'package:pub_hopper_app/models/database_models/LocationDB.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/Challenge.dart';
import '../../models/database_models/ChallengeDB.dart';
import '../../models/database_models/CrawlLocationChallengeDB.dart';
import '../../providers/groupChallengeProvider.dart';
import '../../providers/individualChallengeProvider.dart';

class shareCrawlScreen extends StatefulWidget {
  const shareCrawlScreen({super.key});

  @override
  State<shareCrawlScreen> createState() => CrawlScreen();
}

class CrawlScreen extends State<shareCrawlScreen> {
  late CrawlDB crawl;
  late List<LocationDB> locations;
  late List<ChallengeDB> challenges;
  late List<CrawlLocationChallengeDB> locationChallenges;

  // QR Code data
  late String qrDetails = "";
  late String qrLocations = "";
  late String qrChallenges = "";
  late String qrChallengeLocations = "";


  // Raw challenge data
  GroupChallengeProvider groupChallengeProvider = GroupChallengeProvider();
  IndividualChallengeProvider individualChallengeProvider = IndividualChallengeProvider();
  List<Challenge> groupChallenges = [];
  List<Challenge> individualChallenges = [];

  bool _dataFetched = false;

  void _getInfo() async {
    // Check if crawl is not null (same as above)
    locations = await crawl.getAllLocations();
    locationChallenges = await crawl.getLinkedChallenges();
    challenges = await crawl.getChallenges(locationChallenges);
      _dataFetched = true;
    _convertInfo();
  }

  Future<void> _loadChallenges() async {
    groupChallenges = await groupChallengeProvider.getChallenges();
    individualChallenges = await individualChallengeProvider.getChallenges();

    setState(() {}); // Trigger a rebuild once cities are loaded
  }

  void _convertInfo() {
    if (_dataFetched == true) {
      // Details
      // E.g."d Lad's+night+out!:1,1,1";
      int individualChallengeChance =
          (crawl.individualChallengeChance * 100).toInt();
      String qrDetails =
          "d=${Uri.encodeComponent(crawl.name)}:${Uri.encodeComponent(crawl.city)}:${Uri.encodeComponent(crawl.description)}:${(individualChallengeChance).toString()}:${crawl.groupChallenges}:${crawl.individualChallenges}";

      // Locations
      String qrLocations = "l=";
      for (int i = 0; i < locations.length; i++) {
        final location = locations[i];
        final locationId = location.id;
        final locationName = Uri.encodeComponent(location.name);
        final latitude = location.latitude.toString();
        final longitude = location.longitude.toString();
        final position = location.orderPos.toString();
        qrLocations += "$locationId:$locationName:$latitude:$longitude:$position";
        if (i < locations.length - 1) {
          qrLocations += ',';
        }
      }

      // Challenges
      // Format: ChallengeID(pos in json):group?
      if(groupChallenges.isEmpty || individualChallenges.isEmpty)
        {
          _loadChallenges();
        }

      // Get challenges and locations&challenge ready.

      List<Map<String, dynamic>> challengesMap = [];

      for (int i = 0; i < challenges.length; i++) {
        final challenge = challenges[i];
        Map<int, bool> challengePosition = challenge.toPos(individualChallenges, groupChallenges);

        // Challenge ch = Challenge.fromPos(challengePosition.keys.first, challengePosition.values.first, individualChallenges, groupChallenges);
        // if(ch.title != challenge.title)
        //   {
        //     throw Exception('Challenges no match!');
        //   }

        challengesMap.add(
          {
            'id': challenge.id,
            'pos': challengePosition.keys.first,
            'group': challengePosition.values.first
          }
        );
      }

      List<Map<String, dynamic>> locationChallengesMap = [];

      for (int i = 0; i < locationChallenges.length; i++) {
        final locationChallenge = locationChallenges[i];
        for(Map<String, dynamic> cMapObj in challengesMap)
          {
            if(cMapObj['id'] == locationChallenge.challengeId)
              {
                locationChallengesMap.add(
                  {
                    'location_id': locationChallenge.locationId,
                    'challenge_pos_id': cMapObj['pos'],
                  }
                );
              }
          }
      }

      // Now we convert to correct format

      String qrChallenges = "ch=";

      for (int i = 0; i < challengesMap.length; i++) {
        Map<String, dynamic> cMapObj = challengesMap[i];
        qrChallenges += "${cMapObj['pos']}:${cMapObj['group'] == true ? 1 : 0}";
        if(i != challengesMap.length - 1)
          {
            qrChallenges += ',';
          }
      }

      String qrChallengeLocations = "cl=";
      for (int i = 0; i < locationChallengesMap.length; i++) {
        Map<String, dynamic> lMapObj = locationChallengesMap[i];
        qrChallengeLocations += "${lMapObj['location_id']}:${lMapObj['challenge_pos_id']}";
        if(i != locationChallengesMap.length - 1)
        {
          qrChallengeLocations += ',';
        }
      }

      setState(() {
        qrDetails = qrDetails;
        qrLocations = qrLocations;
        qrChallenges = qrChallenges;
        qrChallengeLocations = qrChallengeLocations;
      });
    }
  }

  void share() {
    Share.share('$qrDetails|$qrLocations|$qrChallenges|$qrChallengeLocations', subject: 'Copy the following text: ');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      crawl = args['crawl'] as CrawlDB;
      _getInfo();
    }
    _convertInfo();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      crawl = args['crawl'] as CrawlDB;
    }
    _loadChallenges();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Crawl'),
      ),
      body: Center(
        child: crawl == null
            ? const Text('Loading...')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please use every QR code when sharing a crawl'),
                  const SizedBox(height: 20),
                  qrLocations == ""
                      ? const CircularProgressIndicator()
                      : CarouselSlider(
                    options: CarouselOptions(
                        initialPage: 0,
                        enableInfiniteScroll: false,

                        height: 400.0
                    ),
                    items: [
                      {'Details': qrDetails},
                      {'Challenges': qrChallenges},
                      {'Locations': qrLocations},
                      {'Location Challenges': qrChallengeLocations}
                          ].map((i) {
                      var key = i.keys.first;
                      var data = i.values.first;

                      return Builder(
                        builder: (BuildContext context) {
                          return Column(
                            children: [
                              QrImageView(
                                data: data,
                                version: QrVersions.auto,
                                size: 300.0,
                                dataModuleStyle: const QrDataModuleStyle(
                                    color: Colors.white,
                                    dataModuleShape: QrDataModuleShape.square),
                                eyeStyle: const QrEyeStyle(
                                    color: Colors.white, eyeShape: QrEyeShape.square),
                              ),
                              Text('QR: $key')
                            ],
                          );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => share(),
                    child: const Text('Share code instead'),
                  ),
                ],
              ),
      ),
    );
  }
}
