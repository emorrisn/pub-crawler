import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:pub_hopper_app/models/Location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class LocationListItem extends StatefulWidget {
  final int id;
  final Location location;
  final MapController mapController;
  final PanelController panelController;
  final PopupController popupController;

  const LocationListItem(
      {Key? key,
      required this.id,
      required this.location,
      required this.mapController,
      required this.panelController,
      required this.popupController})
      : super(key: key);

  @override
  State<LocationListItem> createState() => _LocationListItemState();
}

class _LocationListItemState extends State<LocationListItem> {
  void locationSelected() {
    Marker marker = Marker(
      key: ValueKey<int>(widget.id), // Use the index as the key
      width: 25.0,
      height: 25.0,
      point: LatLng(widget.location.latitude, widget.location.longitude),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.red,
        ),
        child: const Icon(
          Icons.sports_bar,
          color: Colors.white,
          size: 20.0,
        ),
      ),
    );

    widget.popupController.hideAllPopups();
    widget.panelController.close();
    widget.popupController.togglePopup(marker);
    widget.mapController
        .move(LatLng(widget.location.latitude, widget.location.longitude), 18);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      color: Colors.transparent, // Transparent background for swipe action
      child: ListTile(
        onTap: () => locationSelected(),
        leading: Text(widget.location.amenity),
        trailing: Text(widget.location.country),
        title: Text(
          widget.location.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            "${(widget.location.houseNumber != '?') ? '${widget.location.houseNumber}, ' : ''}${widget.location.street}"),
      ),
    );
  }
}
