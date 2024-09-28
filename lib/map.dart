import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
// Removed unnecessary import of google_maps_flutter
import 'package:latlong2/latlong.dart' as l;

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<DocumentSnapshot>> getNotesWithinRadius(
  double centerLat,
  double centerLon,
  double radiusInMeters,
) async {
  // Earth's radius in meters
  const double earthRadius = 6378137.0;

  // Calculate offsets in degrees
  double latOffset = (radiusInMeters / earthRadius) * (180 / pi);
  double lonOffset = (radiusInMeters / earthRadius) * (180 / pi) / cos(centerLat * pi / 180);

  // Define the bounding box
  double minLat = centerLat - latOffset;
  double maxLat = centerLat + latOffset;
  double minLon = centerLon - lonOffset;
  double maxLon = centerLon + lonOffset;

  debugPrint("$minLat $maxLat, $minLon, $maxLon");

  // Build the query with range filters
  final d = await FirebaseFirestore.instance
      .collection('notes').get(); // Replace with your collection name
      // .where('note.latitude', isGreaterThanOrEqualTo: minLat)
      // .where('note.latitude', isLessThanOrEqualTo: maxLat)
      // .where('note.longitude', isGreaterThanOrEqualTo: minLon)
      // .where('note.longitude', isLessThanOrEqualTo: maxLon);


  for (QueryDocumentSnapshot docSnapshot in d.docs) {
    // Access each document's data
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    double lat = data["location"].latitude;
    double long = data["location"].longitude;
    debugPrint("$lat $long");
    if (lat >= minLat && lat <= maxLat && long >= minLon && long <= maxLon){
      debugPrint(data["title"]);
    }
  }

  // // Execute the query
  // QuerySnapshot querySnapshot = await query.get();

  // List<DocumentSnapshot> documentsWithinRadius = [];

  // // Iterate over the results and calculate distances
  // for (var doc in querySnapshot.docs) {
  //   GeoPoint noteLocation = doc['note'];
  //   double noteLat = noteLocation.latitude;
  //   double noteLon = noteLocation.longitude;

  //   double distanceInMeters = calculateDistance(centerLat, centerLon, noteLat, noteLon);

  //   // Include documents within the specified radius
  //   if (distanceInMeters <= radiusInMeters) {
  //     documentsWithinRadius.add(doc);
  //   }
  // }

  return [];
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


class _MainMapState extends State<MainMap> {
  Position? _currentPosition;
  String _locationStatus = 'Location not available';

  MapController mapController = MapController();
  l.LatLng _currentCenter = l.LatLng(51.509364, -0.128928); // Default center
  double _currentZoom = 9.2;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission().then((_) {
      debugPrint("LOCATION STATUS: $_locationStatus");
    });
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
            // Enable pinch-to-zoom and other gestures
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onMapEvent: (MapEvent mapEvent) {
              setState(() {
                // Update current center and zoom level
                _currentCenter = mapController.camera.center;
                _currentZoom = mapController.camera.zoom;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => debugPrint("HELLO WORLD!!"),
                ),
              ],
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
                    _currentZoom += 1;
                    mapController.move(_currentCenter, _currentZoom);
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
                    _currentZoom -= 1;
                    mapController.move(_currentCenter, _currentZoom);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _currentCenter = l.LatLng(position.latitude, position.longitude);
        mapController.move(_currentCenter, _currentZoom);
        _locationStatus =
            'Lat: ${position.latitude}, Long: ${position.longitude}';
      });

      debugPrint(
          'Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');

      final notes = await getNotesWithinRadius(position.latitude, position.longitude, 100000000);
      for (final note in notes){
        if (note.exists){
          debugPrint(note.get("title"));
        }
      }

    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = 'Location services are disabled.';
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
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationStatus = 'Location permissions are permanently denied.';
      });
      return;
    }

    // If permission is granted, get the current location
    await _getCurrentLocation();
  }
}
