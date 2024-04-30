import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/database_models/ChallengeDB.dart';
import '../../../models/database_models/CrawlDB.dart';
import '../../../models/database_models/LocationDB.dart';

class editCrawlChallenges extends StatefulWidget {
  final List<LocationDB> locations;
  final CrawlDB crawl;

  const editCrawlChallenges({
    Key? key,
    required this.locations,
    required this.crawl,
  }) : super(key: key);

  @override
  State<editCrawlChallenges> createState() => _CrawlChallengesState();
}

class _CrawlChallengesState extends State<editCrawlChallenges> {
  late List<LocationDB> locations;
  late Map<int, List<ChallengeDB>> challenges;

  @override
  void initState() {
    super.initState();
    locations = [];
    challenges = {};
  }

  Future<void> _setup() async {
    locations = widget.locations;
    for(LocationDB location in locations)
    {
      challenges[location.id] = await location.getAllChallenges();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(editCrawlChallenges oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setup();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          int individualChallenges = 0;
          int groupChallenges = 0;

          // Count individual and group challenges
          List<ChallengeDB>? locationChallenges = challenges[locations[index].id];

          if(locationChallenges != null)
            {
              for (final challenge in locationChallenges) {
                if (challenge.type == 'individual') {
                  individualChallenges += 1;
                }
                if (challenge.type == 'group') {
                  groupChallenges += 1;
                }
              }
            }

          return Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.pushNamed(
                      context, '/crawl/edit/location/challenges',
                      arguments: {
                        'location': locations[index],
                        'challenges': challenges[locations[index].id],
                        'crawl': widget.crawl,
                      }).then((result) {
                        _setup();
                  });
                },
                leading: Text('#${locations[index].orderPos + 1}'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded),
                title: Text(
                  locations[index].name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                    "$groupChallenges Group, $individualChallenges Individual"),
              ),
              const Divider(),
            ],
          );
        }
        );
  }
}
