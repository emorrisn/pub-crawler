import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/database_models/LocationDB.dart';
import '../../../widgets/new_crawl/ReorderableListItem.dart';

class editCrawlLocations extends StatefulWidget {
  final List<LocationDB> locations;
  final Function onUpdateLocations;

  const editCrawlLocations({
    Key? key,
    required this.locations,
    required this.onUpdateLocations,
  }) : super(key: key);

  @override
  State<editCrawlLocations> createState() => _CrawlLocationsState();
}

class _CrawlLocationsState extends State<editCrawlLocations> {
  late List<LocationDB> virtualLocations;

  @override
  void initState() {
    super.initState();
    virtualLocations = widget.locations;
  }

  @override
  void didUpdateWidget(editCrawlLocations oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      virtualLocations = widget.locations;
    });

  }

  void _processLocations()
  {
    List<Map<int, LocationDB>> mappedLocations = [];
    for (int index = 0; index < virtualLocations.length; index++) {
      mappedLocations.add({
        index: virtualLocations[index]
      });
    }
    widget.onUpdateLocations(mappedLocations);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      children: <Widget>[
        for (int index = 0; index < virtualLocations.length; index++)
          ReorderableLocationListItem(
            position: index,
            location: virtualLocations[index],
            key: Key('${virtualLocations[index].id}'),
          ),
      ],
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final LocationDB item = virtualLocations.removeAt(oldIndex);
          virtualLocations.insert(newIndex, item);
          // _updateLocation(oldIndex, newIndex);
          _processLocations();
        });
      },
    );
  }
}
