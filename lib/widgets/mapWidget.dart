import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pub_hopper_app/models/database_models/UserDB.dart';

import '../models/Location.dart';

class MapWidget extends StatefulWidget {
  final MapController mapController;
  final PopupController? popupController;
  final bool tracking;
  final double latitude;
  final double longitude;
  final double zoom;
  final List<Location>? locations;
  final List<Location>? selectedLocations;
  final Function(Location)? onLocationSelected;
  final Function(Location)? onLocationDeselected;
  final bool? locationPositions;
  final bool? locationPopUpButtons;
  final bool? locationLines;
  final bool? locationMarkerClustering;
  final bool? locationCameraFit;
  final UserDB user;
  final bool? isDrawerOpen;

  const MapWidget({super.key, 
    required this.mapController,
    this.popupController,
    required this.tracking,
    this.latitude = 0,
    this.longitude = 0,
    this.zoom = 16.0,
    this.locations,
    this.selectedLocations,
    this.onLocationSelected,
    this.onLocationDeselected,
    this.locationPositions,
    this.locationPopUpButtons,
    this.locationLines,
    this.locationMarkerClustering,
    this.locationCameraFit,
    this.isDrawerOpen,
    required this.user,
  });

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool _setup = false;
  late LatLng currentLocation;
  late List<Location> selectedLocations = [];
  late List<Location> locations = [];
  late double zoom = 0;
  late bool locationPositions;
  late bool locationPopUpButtons;
  late bool locationLines = false;
  late bool locationMarkerClustering = true;
  late bool locationCameraFit = false;
  StreamSubscription<Position>? positionStreamSubscription;
  bool showCenterButton = false;

  late PopupController _popupController = PopupController();

  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  List<LatLng> _camfitCoords = [];

  @override
  void initState() {
    super.initState();
    _polylines = [];
    _camfitCoords = [];
    _setup = false;
    setup();
  }

  Future<void> setup() async {
    if (_setup == false) {

      currentLocation = LatLng(widget.latitude, widget.longitude);
      zoom = widget.zoom;

      if (widget.latitude == 0 && widget.longitude == 0) {
        await Geolocator.getCurrentPosition().then((pos) {
          setState(() {
            currentLocation = LatLng(pos.latitude, pos.longitude);
          });
        });
      }

      if (widget.tracking) {
        getLocationUpdates();
      }
      if (widget.popupController != null) {
        _popupController = widget.popupController!;
      }

      if (widget.locationPositions != null) {
        locationPositions = widget.locationPositions!;
      } else {
        locationPositions = false;
      }

      if (widget.locationPopUpButtons != null) {
        locationPopUpButtons = widget.locationPopUpButtons!;
      } else {
        locationPopUpButtons = true;
      }

      if (widget.locationLines != null) {
        locationLines = widget.locationLines!;
      }

      if (widget.locationMarkerClustering != null) {
        locationMarkerClustering = widget.locationMarkerClustering!;
      }

      if (widget.locationCameraFit != null) {
        locationCameraFit = widget.locationCameraFit!;
      }

      if (widget.locations != null) {
        locations = (widget.locations!
              ..sort((a, b) => a.position.compareTo(b.position)))
            .toList();
      }
      setState(() {
        _setup = true;
      });

      updateMapValues();
    }
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    try {
      if (widget.tracking) {
        positionStreamSubscription?.cancel();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
    _setup = false;
    super.dispose();
  }

  void getLocationUpdates() async {
    positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
          // Update the current location and move the map to the new location
          if (!showCenterButton && _setup == true) {
            setState(() {
              currentLocation = LatLng(position.latitude, position.longitude);
              widget.mapController.move(currentLocation, zoom);
            });
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateMapValues();
  }

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateMapValues();
  }

  void updateMapValues()
  {
    updatePolylines();
    updateLocations();
    updateMarkers();
    updateCamfit();
  }

  void updateCamfit()
  {
    if(locations.length > 1)
    {
      _camfitCoords = locations
          .map((location) =>
          LatLng(location.latitude, location.longitude))
          .toList();
    } else {
      if(locations.length == 1)
      {
        _camfitCoords = [
          currentLocation,
          LatLng(widget.locations![0].latitude,
              widget.locations![0].longitude),
        ];
      }
    }
  }

  void updateLocations()
  {
    if (_setup == true) {
      if (widget.selectedLocations != null && widget.selectedLocations != []) {
        selectedLocations = widget.selectedLocations!;
      } else {
        selectedLocations = [];
      }
      if (widget.locations != null) {
        locations = (widget.locations!
          ..sort((a, b) => a.position.compareTo(b.position)))
            .toList();
      }
    }
  }

  void toggleCenterButtonVisibility() {
    if (_setup == true) {
      setState(() {
        showCenterButton = !showCenterButton;
      });
    }
  }

  void updateZoom(double newZoom) {
    if (_setup == true) {
      setState(() {
        zoom = newZoom; // Update stored zoom level
      });
    }
  }

  // Location Markers
  void updateMarkers() {

    if (locations != [] && _setup == true) {
      // print("map: Updating markers!");

      List<Marker> localOldMarkers = _markers;
      _markers = [];

      if(locations.length > 1)
        {
          _markers = locations
              .asMap()
              .map((index, location) => MapEntry(
            index,
            Marker(
              key: ValueKey<int>(index), // Use the index as the key
              width: 25.0,
              height: 25.0,
              point: LatLng(location.latitude, location.longitude),
              child: Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: selectedLocations.contains(locations[index])
                      ? Colors.green
                      : Colors.red,
                ),
                child: Icon(
                  (locationPositions &&
                      location.position == locations.length - 1)
                      ? Icons.flag
                      : Icons.sports_bar,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
            ),
          ))
              .values
              .toList();
        } else {
        if(locations.length == 1)
          {
            _markers = [
              Marker(
                key: const ValueKey<int>(0), // Use the index as the key
                width: 25.0,
                height: 25.0,
                point: LatLng(locations[0].latitude, widget.locations![0].longitude),
                child: Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.red,
                  ),
                  child: const Icon(Icons.flag,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ),
            ];
          }
      }

      if(localOldMarkers != _markers)
        {
          setState(() {});
        }
    }
  }

  void updatePolylines()
  {
    if(widget.locationLines == true && _setup == true)
      {
        List<Polyline> localOldPolylines = _polylines;

        if(locations.length > 1)
        {
          _polylines = [];
          for (int i = 0;
          i < locations.length - 1;
          i++)
          {
            Location l = locations[i];
            Location nl = locations[i + 1];

            _polylines.add(
                Polyline(
                  points: [
                    LatLng(l.latitude, l.longitude),
                    LatLng(nl.latitude, nl.longitude),
                  ],
                  color: Colors.blueAccent,
                  borderColor: Colors.blue,
                  borderStrokeWidth: 1,
                  isDotted: true,
                  strokeWidth: 5,
                )
            );
          }
        } else {
          if(locations.length == 1)
          {
            _polylines = [
              Polyline(
                points: [
                  currentLocation,
                  LatLng(widget.locations![0].latitude,
                      widget.locations![0].longitude),
                ],
                color: Colors.blueAccent,
                borderColor: Colors.blue,
                borderStrokeWidth: 1,
                isDotted: true,
                strokeWidth: 5,
              ),
            ];
          }
        }

        if(localOldPolylines != _polylines)
          {
            setState(() {});
          }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      PopupScope(
        popupController: _popupController,
        child: _setup == false ? const Center(child: CircularProgressIndicator()) : FlutterMap(
          options: MapOptions(
              initialCenter: currentLocation,
              initialZoom: zoom,
              initialCameraFit: locationCameraFit
                  ? CameraFit.coordinates(
                      coordinates: _camfitCoords,
                      padding: const EdgeInsets.all(100.0))
                  : null,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
              ),
              onPositionChanged: (MapPosition pos, bool gesture) {
                if (!showCenterButton) {
                  setState(() {
                    showCenterButton = true;
                  });
                }
              },
              onMapEvent: (MapEvent event) {
                // Update zoom
                setState(() {
                  zoom = event.camera.zoom;
                });
              },
              onTap: (_, __) => _popupController.hideAllPopups()),
          mapController: widget.mapController,
          children: [
            TileLayer(
              retinaMode: true,
              urlTemplate: '${widget.user.map_layer}${widget.user.map_api_key}',
            ),
            MarkerLayer(
              markers: [
                if (widget.tracking == true)
                  Marker(
                    width: 20.0,
                    height: 20.0,
                    point: currentLocation,
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white),
                      child: const Icon(
                        Icons.fiber_manual_record,
                        color: Colors.blue,
                        size: 20.0,
                      ),
                    ),
                  ),
              ],
            ),
            PolylineLayer(
                polylines: _polylines
            ),
            MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
              disableClusteringAtZoom: locationMarkerClustering ? 20 : 0,
              size: const Size(25, 25),
              markers: _markers,
              alignment: Alignment.center,
              popupOptions: PopupOptions(
                  popupSnap: PopupSnap.markerTop,
                  popupController: _popupController,
                  popupBuilder: (context, marker) => SingleChildScrollView(
                        child: SizedBox(
                          width: 300,
                          height: 136,
                          child: Center(
                            child: Card(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(Icons.sports_bar),
                                    title: Text(
                                      (widget.locations != null &&
                                              widget.locations!.isNotEmpty)
                                          ? widget
                                              .locations![
                                                  (marker.key as ValueKey<int>)
                                                      .value]
                                              .name
                                          : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ), // widget.locations![(marker.key as ValueKey<int>).value].name
                                    subtitle: Text(
                                      (widget.locations != null &&
                                              widget.locations!.isNotEmpty)
                                          ? widget
                                              .locations![
                                                  (marker.key as ValueKey<int>)
                                                      .value]
                                              .street
                                          : '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  locationPopUpButtons == false
                                      ? const SizedBox()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            selectedLocations.contains(widget
                                                    .locations?[(marker.key
                                                        as ValueKey<int>)
                                                    .value])
                                                ? TextButton(
                                                    child:
                                                        const Text('DESELECT'),
                                                    onPressed: () {
                                                      widget
                                                          .onLocationDeselected
                                                          ?.call(widget
                                                              .locations![(marker
                                                                      .key
                                                                  as ValueKey<
                                                                      int>)
                                                              .value]);
                                                    },
                                                  )
                                                : TextButton(
                                                    child: const Text('SELECT'),
                                                    onPressed: () {
                                                      widget.onLocationSelected
                                                          ?.call(widget
                                                              .locations![(marker
                                                                      .key
                                                                  as ValueKey<
                                                                      int>)
                                                              .value]);
                                                    },
                                                  ),
                                            const SizedBox(width: 8),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
              builder: (context, markers) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.redAccent,
                  ),
                  child: Center(
                    child: Text(
                      markers.length.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            )
            ),
          ],
        ),
      ),
      (widget.tracking == true)
          ? const Positioned(
              top: 20.0,
              right: 20.0,
              child: Image(
                image: AssetImage('assets/images/logos/icon-dark.png'),
                semanticLabel: "Pub Crawler",
              ),
            )
          : const SizedBox(),
      AnimatedPositioned(
        bottom: 150.0,
        right: widget.isDrawerOpen != null ? (widget.isDrawerOpen! ? -100.0 : 15.0) : 15.0,
        duration: const Duration(milliseconds: 300),
        child: (widget.tracking == true)
            ? FloatingActionButton(
                heroTag: 'nav_btn',
                shape: const CircleBorder(),
                onPressed: () {
                    widget.mapController.move(currentLocation, zoom);
                    toggleCenterButtonVisibility();
                                  },
                child: showCenterButton == true
                    ? const Icon(Icons.near_me_outlined)
                    : const Icon(Icons.near_me),
              )
            : const SizedBox(),
      ),
      AnimatedPositioned(
          bottom: 75.0,
          right: widget.isDrawerOpen != null ? (widget.isDrawerOpen! ? -100.0 : 15.0) : 15.0,
          duration: const Duration(milliseconds: 300),
          child: FloatingActionButton(
            heroTag: 'settings_btn',
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
            shape: const CircleBorder(),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: const Icon(Icons.settings),
          )),
    ]);
  }
}
