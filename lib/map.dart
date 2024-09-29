import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/animation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as l;
import 'package:shared_preferences/shared_preferences.dart';

Future<List> getNotesWithinRadius(
  double centerLat,
  double centerLon,
  double radiusInMeters,
) async {
  // Earth's radius in meters
  const double earthRadius = 6378137.0;

  // Calculate offsets in degrees
  double latOffset = (radiusInMeters / earthRadius) * (180 / pi);
  double lonOffset =
      (radiusInMeters / earthRadius) * (180 / pi) / cos(centerLat * pi / 180);

  // Define the bounding box
  double minLat = centerLat - latOffset;
  double maxLat = centerLat + latOffset;
  double minLon = centerLon - lonOffset;
  double maxLon = centerLon + lonOffset;

  debugPrint("$minLat $maxLat, $minLon, $maxLon");

  // Build the query with range filters
  final d = await FirebaseFirestore.instance
      .collection('notes')
      .get(); // Replace with your collection name

  final ans = [];

  for (QueryDocumentSnapshot docSnapshot in d.docs) {
    // Access each document's data
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    double lat = data["location"].latitude;
    double long = data["location"].longitude;
    debugPrint("$lat $long");
    if (lat >= minLat && lat <= maxLat && long >= minLon && long <= maxLon) {
      ans.add(data);
    }
  }

  return ans;
}

// Haversine formula to calculate the great-circle distance between two points
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // in meters

  double dLat = _degreesToRadians(lat2 - lat1);
  double dLon = _degreesToRadians(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreesToRadians(lat1)) *
          cos(_degreesToRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

// Helper function to convert degrees to radians
double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with TickerProviderStateMixin {
  Position? _currentPosition;
  String _locationStatus = 'Location not available';

  final MapController mapController = MapController();
  l.LatLng _currentCenter = const l.LatLng(51.509364, -0.128929);
  double _currentZoom = 20.0;
  final double _defaultZoom = 20; // Default zoom level when centering

  AnimationController? _mapAnimationController;
  List<Marker> markers = [];

  @override
  void dispose() {
    _mapAnimationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    final coll = FirebaseFirestore.instance.collection("notes");
    coll.snapshots().listen((event) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String ph = prefs.getString("phone-number") ?? "";

      for (int i = 0; i < event.docChanges.length; ++i) {
        try {
          final n = event.docChanges[i].doc.data() ?? {};
          double clat = n["location"].latitude;
          double clon = n["location"].longitude;
          String name = "Unknown";

          if (closeEnough(clat, clon, _currentPosition?.latitude ?? 0,
              _currentPosition?.longitude ?? 0)) {
            debugPrint("CLOSE: ${n["creator"]}");
            final d = await FirebaseFirestore.instance
                .collection("users")
                .where("phoneNumber", isEqualTo: n["creator"])
                .get();
            if (d.docs.isNotEmpty) {
              debugPrint("GG");
              name = d.docs[0].get("name");
            }
          }

          setState(() {
            markers = markers
              ..insert(
                0,
                Marker(
                  point: l.LatLng(n?["location"].latitude, n?["location"].longitude),
                  width: 40.0,
                  height: 40.0,
                  child: _notePopup(n?["location"].latitude,
                      n?["location"].longitude, _currentPosition!, name, n, ph),
                ),
              );
          });
        } catch (e) {
          debugPrint("Failed to listen to note: $e");
        }
      }
    });

    _checkLocationPermission().then((_) {
      debugPrint("LOCATION STATUS: $_locationStatus");

      setState(() {
        markers = markers
          ..add(
            Marker(
              point: l.LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
              width: 20.0,
              height: 20.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.my_location,
                    color: Colors.white,
                    size: 20.0,
                  ),
                ),
              ),
            ),
          );
      });
    });
  }

  void _animateMapMovement(l.LatLng destCenter, double destZoom,
      {int duration = 700}) {
    // Dispose of any previous animation controller
    _mapAnimationController?.dispose();

    final latTween = Tween<double>(
      begin: _currentCenter.latitude,
      end: destCenter.latitude,
    );

    final lngTween = Tween<double>(
      begin: _currentCenter.longitude,
      end: destCenter.longitude,
    );

    final zoomTween = Tween<double>(
      begin: _currentZoom,
      end: destZoom,
    );

    _mapAnimationController = AnimationController(
      duration: Duration(milliseconds: duration),
      vsync: this,
    );

    _mapAnimationController!.addListener(() {
      final lat = latTween.evaluate(_mapAnimationController!);
      final lng = lngTween.evaluate(_mapAnimationController!);
      final zoom = zoomTween.evaluate(_mapAnimationController!);

      mapController.move(
        l.LatLng(lat, lng),
        zoom,
      );
    });

    _mapAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _mapAnimationController?.dispose();
        _mapAnimationController = null;
      }
    });

    _mapAnimationController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: _currentCenter,
            initialZoom: _currentZoom,
            crs: const Epsg3857(),
            onMapEvent: (MapEvent mapEvent) {
              setState(() {
                // Update current center and zoom from mapEvent
                _currentCenter = mapEvent.camera.center;
                _currentZoom = mapEvent.camera.zoom;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            if (markers.isNotEmpty)
              MarkerLayer(
                markers: markers,
              ),
          ],
        ),
        // Zoom controls at the bottom left corner
        Positioned(
          bottom: 20,
          left: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                mini: true,
                heroTag: "zoomIn",
                child: Icon(Icons.zoom_in),
                onPressed: () {
                  setState(() {
                    final destZoom = _currentZoom + 1;
                    _animateMapMovement(_currentCenter, destZoom, duration: 500);
                    _currentZoom = destZoom;
                  });
                },
              ),
              SizedBox(height: 10),
              FloatingActionButton(
                mini: true,
                heroTag: "zoomOut",
                child: Icon(Icons.zoom_out),
                onPressed: () {
                  setState(() {
                    final destZoom = _currentZoom - 1;
                    _animateMapMovement(_currentCenter, destZoom, duration: 500);
                    _currentZoom = destZoom;
                  });
                },
              ),
            ],
          ),
        ),
        // Center button at the bottom middle
        Positioned(
          bottom: 20,
          left: MediaQuery.of(context).size.width / 2 - 25, // Adjust position
          child: FloatingActionButton(
            mini: true,
            heroTag: "centerMap",
            child: Icon(Icons.my_location),
            onPressed: () {
              if (_currentPosition != null) {
                final destCenter = l.LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                );
                setState(() {
                  _animateMapMovement(destCenter, _defaultZoom);
                  _currentCenter = destCenter;
                  _currentZoom = _defaultZoom;
                });
              } else {
                debugPrint('Current position not available');
              }
            },
          ),
        ),
      ],
    );
  }

  bool closeEnough(double lat1, double lon1, double lat2, double lon2) {
    final double minDistance = 0.001;
    return sqrt((lat1 - lat2) * (lat1 - lat2) + (lon1 - lon2) * (lon1 - lon2)) <
        minDistance;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final destCenter = l.LatLng(position.latitude, position.longitude);
      final destZoom = _defaultZoom;

      setState(() {
        _currentPosition = position;
        _currentCenter = destCenter;
        _currentZoom = destZoom;
        _locationStatus =
            'Lat: ${position.latitude}, Long: ${position.longitude}';
      });

      debugPrint('Location: ${position.latitude}, ${position.longitude}');

      final notes = await getNotesWithinRadius(
          position.latitude, position.longitude, 100000000);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ph = prefs.getString("phone-number");

      for (final note in notes) {
        try {
          debugPrint("Here!!");
          debugPrint("${note["location"].latitude} ${note["location"].longitude}");
          double clat = note["location"].latitude;
          double clon = note["location"].longitude;
          String name = "Unknown";
          if (closeEnough(clat, clon, position.latitude, position.longitude)) {
            debugPrint("CLOSE: ${note["creator"]}");
            final d = await FirebaseFirestore.instance
                .collection("users")
                .where("phoneNumber", isEqualTo: note["creator"])
                .get();
            if (d.docs.isNotEmpty) {
              debugPrint("GG");
              name = d.docs[0].get("name");
            }
          }

          setState(() {
            markers = markers
              ..insert(
                0,
                Marker(
                  point: l.LatLng(clat, clon),
                  width: 40.0,
                  height: 40.0,
                  child: _notePopup(clat, clon, position, name, note, ph),
                ),
              );
          });
        } catch (e) {
          debugPrint("Failed to load note: $e");
        }
      }
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
      });
    }
  }

  CupertinoButton _notePopup(double clat, double clon, Position position,
      String name, note, String? ph) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0.0,
      onPressed: () {
        if (!closeEnough(clat, clon, position.latitude, position.longitude)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Too far away")),
          );
          return;
        }
        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Close Icon Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 10.0),
                      CupertinoButton(
                        onPressed: () => Navigator.pop(context),
                        child: Icon(
                          CupertinoIcons.xmark,
                          size: 30.0,
                          color: Colors.black54,
                        ),
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Profile or Name Section - Centered
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'from $name',
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Note Title Section - Centered
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      note["title"],
                      style: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Note Body Section - Centered
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      note["note"],
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        decoration: TextDecoration.none,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Center(
                      child: Container(
                        height: 5.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: note["creator"] == ph
              ? Colors.blue.withOpacity(0.8)
              : Colors.purple.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.edit_document,
            color: Colors.white,
            size: 20.0,
          ),
        ),
      ),
    );
  }

  Future<void> _checkLocationPermission() async {
    // Check if location services are enabled
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    final destCenter = l.LatLng(
      _currentPosition?.latitude ?? 0,
      _currentPosition?.longitude ?? 0,
    );

    if (!serviceEnabled) {
      setState(() {
        _locationStatus = 'Location services are disabled.';
        _currentPosition = null;
        _animateMapMovement(destCenter, _defaultZoom);
        _currentZoom = _defaultZoom;
      });
      return;
    }

    // Check for location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationStatus = 'Location permission denied';
          _currentPosition = null;
          _animateMapMovement(destCenter, _defaultZoom);
          _currentZoom = _defaultZoom;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationStatus = 'Location permissions are permanently denied.';
        _currentPosition = null;
        _animateMapMovement(destCenter, _defaultZoom);
        _currentZoom = _defaultZoom;
      });
      return;
    }

    // If permission is granted, get the current location
    await _getCurrentLocation();
  }
}
