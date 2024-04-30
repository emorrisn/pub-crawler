import 'package:flutter/material.dart';
import '../../../models/City.dart';
import '../../../models/database_models/CrawlDB.dart';

class editCrawlDetails extends StatefulWidget {
  final CrawlDB crawl;
  final Function onUpdateDetails;

  const editCrawlDetails({
    Key? key,
    required this.crawl,
    required this.onUpdateDetails,
  }) : super(key: key);

  @override
  State<editCrawlDetails> createState() => _CrawlDetailsState();
}

class _CrawlDetailsState extends State<editCrawlDetails> {
  late Map<String, dynamic> detailsForm;
  TextEditingController textCityController = TextEditingController();


  @override
  void initState() {
    super.initState();
    detailsForm = {
      'name': widget.crawl.name,
      'city': widget.crawl.city,
      'description': widget.crawl.description,
      'individualChallenges': widget.crawl.individualChallenges,
      'groupChallenges': widget.crawl.groupChallenges,
      'individualChallengeChance': widget.crawl.individualChallengeChance * 100,
    };
    textCityController.text = widget.crawl.city;
  }

  void _changeValue(String key, dynamic value) {
    setState(() {
      detailsForm[key] = value;
    });
    widget.onUpdateDetails(detailsForm);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24),
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'e.g. Best night out this year',
                  labelText: 'Name',
                ),
                maxLength: 25,
                onChanged: (value) => _changeValue('name', value),
                initialValue: detailsForm['name'],
              ),
              TextFormField(
                controller: textCityController,
                decoration: InputDecoration(
                  hintText: 'e.g. Sheffield',
                  labelText: 'City',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      Navigator.pushNamed(context, '/crawl/edit/select-city',
                          arguments: {'form': detailsForm}).then((result) {
                        if (result != null && result is Map<String, dynamic>) {
                          City city = result['city'];
                          _changeValue('city', city.name);
                          textCityController.text = city.name;
                        }
                      });
                    },
                  ),
                ),
                canRequestFocus: false,
                onTap: () {
                  Navigator.pushNamed(context, '/crawl/edit/select-city',
                      arguments: {'form': detailsForm}).then((result) {
                    if (result != null && result is Map<String, dynamic>) {
                      City city = result['city'];
                      _changeValue('city', city.name);
                      textCityController.text = city.name;
                    }
                  });
                },
              ),
              TextFormField(
                minLines: 3,
                maxLines: 5,
                maxLength: 150,
                decoration: const InputDecoration(
                  hintText: 'e.g. Sheffield only',
                  labelText: 'Description',
                ),
                onChanged: (value) => _changeValue('description', value),
                initialValue: detailsForm['description'],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Switch(
                      value: detailsForm['individualChallenges'],
                      onChanged: (value) =>
                          _changeValue('individualChallenges', value),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Individual Challenges'),
                    ),
                  ],
                ),
              ),
              detailsForm['individualChallenges']
                  ? Slider(
                      value: detailsForm['individualChallengeChance'],
                      max: 100.0,
                      divisions: 20,
                      min: 5.0,
                      label:
                          '${detailsForm['individualChallengeChance'].round().toString()}% Chance of challenge',
                      onChanged: (double value) =>
                          _changeValue('individualChallengeChance', value),
                    )
                  : const SizedBox(),
              Row(
                children: [
                  Switch(
                    value: detailsForm['groupChallenges'],
                    onChanged: (value) =>
                        _changeValue('groupChallenges', value),
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
    );
  }
}
