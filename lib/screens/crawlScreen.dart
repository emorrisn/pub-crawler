import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pub_hopper_app/models/database_models/ChallengeDB.dart';
import 'package:pub_hopper_app/models/database_models/CrawlDB.dart';
import 'package:pub_hopper_app/models/database_models/LocationDB.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../helpers/authenticationHelper.dart';
import '../models/Location.dart';
import '../models/database_models/UserDB.dart';
import '../widgets/mapWidget.dart';

class crawlScreen extends StatefulWidget {
  const crawlScreen({super.key});

  @override
  State<crawlScreen> createState() => _Crawl();
}

class _Crawl extends State<crawlScreen> {
  late MapController mapController;
  late PanelController panelController;

  late CrawlDB crawl;
  late int position;
  late List<LocationDB> locations;
  late List<ChallengeDB> challenges;

  ChallengeDB? personalChallenge;
  Location? selectedMapLocation;
  LocationDB? selectedLocation;

  bool challengeRolled = false;
  bool loading = true;
  UserDB? _user;

  final _audioPlayer = AudioPlayer();

  Future<UserDB?> getUser() async {
    final user = await UserDB.getBySession(AuthenticationHelper().currentUser);
    setState(() {
      _user = user;
    });
    return user;
  }

  Future<List<LocationDB>> getLocations() async {
    final localLocations = await crawl.getAllLocations();
    setState(() {
      locations = localLocations;
    });

    if (selectedLocation == null) {
      updateSelectedLocation(position);
    }

    return locations;
  }

  void updateSelectedLocation(int newPosition) {
    if (locations.isNotEmpty && newPosition != locations.length) {
      setState(() {
        personalChallenge = null;
        challengeRolled = false;
        selectedLocation =
            locations.where((element) => element.orderPos == newPosition).first;
        position = newPosition;
        selectedMapLocation = Location(
            apiID: selectedLocation!.id,
            localID: selectedLocation!.id,
            name: selectedLocation!.name,
            position: position,
            longitude: selectedLocation!.longitude,
            latitude: selectedLocation!.latitude);
      });
      getChallenges();
    }
  }

  Future<List<ChallengeDB>> getChallenges() async {
    if (crawl != null && selectedLocation != null) {
      final localChallenges = await selectedLocation!.getAllChallenges();
      setState(() {
        challenges = localChallenges;
      });
    }

    return challenges;
  }

  Future<void> rollChallenge() async {
    if (challenges.isNotEmpty) {

      List<ChallengeDB> iChallenges = challenges.where((element) => element.type == 'individual').toList();
      double chance = crawl.individualChallengeChance;
      ChallengeDB? lastChallenge;

      for(ChallengeDB iC in iChallenges)
        {
          double roll = Random().nextDouble();

          if (roll < chance) {
            // If the roll is less than the chance, set it as personal challenge
            lastChallenge = iC;
          }
        }

      if(lastChallenge != null)
        {
          await _audioPlayer.play(AssetSource("audio/new-challenge.wav"));
          if(mounted)
            {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("You have received a challenge!"),
                  duration: Duration(seconds: 2),
                ),
              ); 
            }
        }

      setState(() {
        if(lastChallenge != null)
        {
          personalChallenge = lastChallenge;
        }
        challengeRolled = true;
      });

    }
  }

  @override
  void initState() {
    super.initState();
    locations = [];
    challenges = [];
    personalChallenge = null;
    mapController = MapController();
    panelController = PanelController();
    getUser();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      crawl = args['crawl'] as CrawlDB;
      position = args['position'];
    }

    getLocations();

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null ||
        loading == true ||
        selectedMapLocation == null ||
        selectedLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
          crawl: crawl,
          user: _user!,
          position: position,
          challenges: challenges,
          locations: locations,
          selectedLocation: selectedLocation,
          personalChallenge: personalChallenge,
          challengeRolled: challengeRolled,
          onUpdateSelectedLocation: updateSelectedLocation,
          onRollChallenge: rollChallenge,
        ), // Your custom drawer widget
        minHeight: 125, // Height of the collapsed panel
        maxHeight: MediaQuery.of(context).size.height *
            0.95, // Height of the expanded panel
        body: MapWidget(
          mapController: mapController,
          tracking: true,
          locations: [selectedMapLocation as Location],
          locationPositions: true,
          locationPopUpButtons: false,
          locationLines: true,
          locationCameraFit: true,
          user: _user!,
        ), // Your map widget or main content
      ),
    );
  }
}

class DrawerWidget extends StatefulWidget {
  final UserDB user;
  final CrawlDB crawl;
  final int position;
  final LocationDB? selectedLocation;
  final List<ChallengeDB> challenges;
  final List<LocationDB> locations;
  final Function(int newPosition) onUpdateSelectedLocation;
  final Function() onRollChallenge;

  final ChallengeDB? personalChallenge;
  final bool challengeRolled;

  const DrawerWidget(
      {super.key, required this.crawl,
      required this.user,
      required this.position,
      required this.locations,
      required this.challenges,
      required this.selectedLocation,
      required this.onUpdateSelectedLocation,
      this.personalChallenge,
      required this.challengeRolled,
      required this.onRollChallenge});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int tabsCount = 0;

    if (widget.crawl.groupChallenges == true) {
      tabsCount += 1;
    }

    if (widget.crawl.individualChallenges == true) {
      tabsCount += 1;
    }

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Stack(
        children: [
          Column(children: [
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
            NavigationBar(
              onDestinationSelected: (int index) {
                if (index == 0) {
                  widget.onUpdateSelectedLocation(widget.position - 1);
                }
                if (index == 2) {
                  widget.onUpdateSelectedLocation(widget.position + 1);
                }
              },
              elevation: 0,
              selectedIndex: 1,
              destinations: [
                NavigationDestination(
                  enabled: widget.position > 0,
                  icon: const Icon(Icons.arrow_back),
                  label: 'Previous',
                ),
                NavigationDestination(
                  selectedIcon: const Icon(Icons.home),
                  icon: const Icon(Icons.home_outlined),
                  label: '${widget.selectedLocation?.name}',
                ),
                NavigationDestination(
                  enabled: widget.position != widget.locations.length - 1,
                  icon: const Icon(Icons.arrow_forward),
                  label: 'Next',
                ),
              ],
            ),
            const Divider(),
            tabsCount < 1
                ? const Center(child: Text('No challenges enabled.'))
                : DefaultTabController(
                    length: tabsCount,
                    child: Column(children: [
                      TabBar(
                        tabs: [
                          widget.crawl.groupChallenges == true
                              ? const Tab(text: 'Group Challenges')
                              : const SizedBox(),
                          widget.crawl.individualChallenges == true
                              ? const Tab(text: 'Your Challenges')
                              : const SizedBox(),
                        ],
                      ),
                      SingleChildScrollView(
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height - 250,
                            child: TabBarView(
                              children: [
                                widget.challenges
                                            .where((element) =>
                                                element.type == 'group')
                                            .toList().isNotEmpty
                                    ? Container(
                                        child:
                                            widget.crawl.groupChallenges == true
                                                ? ListView.builder(
                                                  itemCount: widget
                                                      .challenges
                                                      .where((element) =>
                                                          element.type ==
                                                          'group')
                                                      .length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final challenges = widget
                                                        .challenges
                                                        .where((element) =>
                                                            element.type ==
                                                            'group')
                                                        .toList();
                                                    final challenge =
                                                        challenges[index];
                                                
                                                    return Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0),
                                                          child: Column(
                                                            children: [
                                                              ListTile(
                                                                leading:
                                                                    Text(
                                                                  '#${index + 1}',
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                  ),
                                                                ),
                                                                title: Text(
                                                                  challenge
                                                                      .title,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                  ),
                                                                ),
                                                                subtitle: Text(
                                                                    challenge
                                                                        .description),
                                                                isThreeLine:
                                                                    false,
                                                              ),
                                                              ListTile(
                                                                leading:
                                                                    Text(
                                                                  '#${index + 1}',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Theme.of(context)
                                                                        .colorScheme
                                                                        .background,
                                                                    fontWeight:
                                                                        FontWeight.bold,
                                                                  ),
                                                                ),
                                                                title:
                                                                    const Text(
                                                                  'Forfeit',
                                                                  style: TextStyle(
                                                                      fontWeight: FontWeight
                                                                          .bold,
                                                                      color:
                                                                          Colors.redAccent),
                                                                ),
                                                                subtitle:
                                                                    Text(
                                                                  challenge
                                                                      .forfeit,
                                                                  style: const TextStyle(
                                                                      color:
                                                                          Colors.redAccent),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const Divider()
                                                      ],
                                                    );
                                                  },
                                                )
                                                : const SizedBox(),
                                      )
                                    : const Center(
                                        child: Text(
                                            'No group challenges to display')),
                                widget.challenges
                                            .where((element) =>
                                                element.type == 'individual')
                                            .toList().isNotEmpty
                                    ? Container(
                                        child:
                                            widget.crawl.individualChallenges ==
                                                    true
                                                ? Container(
                                                    child: widget
                                                                .personalChallenge ==
                                                            null
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(24.0),
                                                            child: Column(
                                                              children: [
                                                                Card(
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            12.0),
                                                                    child: widget.challengeRolled ==
                                                                            false
                                                                        ? const Text(
                                                                            "You don't have a challenge set, press the button to roll the dice and see if you get one.")
                                                                        : const Text(
                                                                            "You have already rolled and didn't get a challenge!"),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 12,
                                                                ),
                                                                widget.challengeRolled ==
                                                                        false
                                                                    ? FloatingActionButton(
                                                                        heroTag:
                                                                            'give_challenge',
                                                                        onPressed:
                                                                            () =>
                                                                                widget.onRollChallenge(),
                                                                        child: const Icon(
                                                                            Icons.casino),
                                                                      )
                                                                    : const SizedBox(),
                                                              ],
                                                            ))
                                                        : ListView(
                                                      children: [
                                                        Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 8.0),
                                                              child: Column(
                                                                children: [
                                                                  ListTile(
                                                                    leading:
                                                                    const Icon(Icons.access_alarm),
                                                                    title: Text(
                                                                      widget.personalChallenge!.title,
                                                                      style:
                                                                      const TextStyle(
                                                                        fontWeight:
                                                                        FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    subtitle: Text(
                                                                        widget.personalChallenge!.description),
                                                                    isThreeLine:
                                                                    false,
                                                                  ),
                                                                  ListTile(
                                                                    leading: Icon(Icons.access_alarm,  color: Theme.of(context).colorScheme.background,),
                                                                    title: const Text(
                                                                      'Forfeit',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                          Colors.redAccent),
                                                                    ),
                                                                    subtitle:
                                                                    Text(
                                                                      widget.personalChallenge!.forfeit,
                                                                      style: const TextStyle(
                                                                          color:
                                                                          Colors.redAccent),
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            const Divider()
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                      )
                                    : const Center(
                                        child: Text(
                                            'No Individual challenges to display'))
                              ],
                            )),
                      ),
                    ])),
          ]),
          Positioned(
              bottom: 25.0,
              right: 25,
              child: FloatingActionButton(
                heroTag: 'stop_crawl',
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: const CircleBorder(),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                child: const Icon(Icons.done_all),
              )),
        ],
      ),
    );
  }
}
