import 'package:flutter/material.dart';

class ReorderableLocationListItem extends StatelessWidget {
  final dynamic location;
  final Key key;
  final int position;

  const ReorderableLocationListItem({
    required this.key,
    required this.location,
    required this.position,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          key: key,
          leading: position != -1 ? Text('#${position+1}') : Text('#${location.position+1}'),
          trailing: const Icon(
            Icons.menu
          ),
          title: Text(
            location.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("${ (location.houseNumber != '?') ? location.houseNumber + ', ' : '' }${location.street}"),
        ),
        const Divider(),
      ],
    );
  }
}