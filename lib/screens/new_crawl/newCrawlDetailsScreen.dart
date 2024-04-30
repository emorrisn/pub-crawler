import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/City.dart';

import '../../models/Crawl.dart';

class newCrawlDetailsScreen extends StatefulWidget {
  const newCrawlDetailsScreen({super.key});

  @override
  State<newCrawlDetailsScreen> createState() => _CrawlDetailsState();
}

class _CrawlDetailsState extends State<newCrawlDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form variables
  String _name = '';
  String _description = '';
  City? _city;
  bool _individualChallenges = true;
  bool _groupChallenges = true;
  double _individualChallengeChance = 5.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      setState(() {
        _name = args['name'] ?? '';
        _description = args['description'] ?? '';
        _individualChallenges = args['individualChallenges'] ?? true;
        _groupChallenges = args['groupChallenges'] ?? true;
        _city = args['city'] as City?;
        _individualChallengeChance = args['individualChallengeChance'] ?? 5.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Crawl'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // Validate form
                if (_formKey.currentState!.validate()) {
                  // Save form data into object
                  Crawl crawlDetails = Crawl(
                      name: _name,
                      description: _description,
                      city: _city!,
                      individualChallenges: _individualChallenges,
                      groupChallenges: _groupChallenges,
                      individualChallengeChance: _individualChallengeChance / 100);

                  // Navigate to the next page and pass the crawlDetails object
                  Navigator.pushNamed(context, '/new/select-locations',
                      arguments: crawlDetails);
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Form(
              // Your map or main content
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    autofocus: true,
                    decoration: const InputDecoration(
                        hintText: 'e.g. Best night out', label: Text('Name')),
                    maxLength: 25,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (value) => _name = value,
                    initialValue: _name,
                  ),
                  TextFormField(
                      canRequestFocus: false,
                      decoration: InputDecoration(
                        hintText: 'e.g. Sheffield',
                        label: const Text('City'),
                        suffix: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            Navigator.pushNamed(
                                context, '/new/details/select-city',
                                arguments: {
                                  'name': _name,
                                  'description': _description,
                                  'individualChallenges': _individualChallenges,
                                  'groupChallenges': _groupChallenges,
                                });
                          },
                        ),
                      ),
                      initialValue: _city?.name ?? '',
                      onTap: () {
                        Navigator.pushNamed(context, '/new/details/select-city',
                            arguments: {
                              'name': _name,
                              'description': _description,
                              'individualChallenges': _individualChallenges,
                              'groupChallenges': _groupChallenges,
                            });
                      },
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a city';
                        }
                        return null;
                      }),
                  TextFormField(
                    autofocus: false,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Sheffield only',
                      label: Text('Description'),
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _description = value;
                    },
                    initialValue: _description,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      children: [
                        Switch(
                          value: _individualChallenges,
                          onChanged: (value) {
                            setState(() {
                              _individualChallenges = value;
                            });
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Individual Challenges'),
                        ),
                      ],
                    ),
                  ),
                  _individualChallenges
                      ? Slider(
                          value: _individualChallengeChance,
                          max: 100.0,
                          divisions: 20,
                          min: 5.0,
                          label:
                              '${_individualChallengeChance.round().toString()}% Chance of challenge',
                          onChanged: (double value) {
                            setState(() {
                              _individualChallengeChance = value;
                            });
                          },
                        )
                      : const SizedBox(),
                  Row(
                    children: [
                      Switch(
                        value: _groupChallenges,
                        onChanged: (value) {
                          setState(() {
                            _groupChallenges = value;
                          });
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Group Challenges'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
