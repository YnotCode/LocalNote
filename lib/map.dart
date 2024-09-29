import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/animation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as l;

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final ans = [];

  for (QueryDocumentSnapshot docSnapshot in d.docs) {
    // Access each document's data
    Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
    double lat = data["location"].latitude;
    double long = data["location"].longitude;
    debugPrint("$lat $long");
    if (lat >= minLat && lat <= maxLat && long >= minLon && long <= maxLon){
      ans.add(data);
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
  double _currentZoom = 9.2;
  final double _defaultZoom = 16.5; // Default zoom level when centering

  AnimationController? _mapAnimationController;
  Animation<l.LatLng>? _latLngAnimation;
  Animation<double>? _zoomAnimation;

  List<Marker> markers = [];

  @override
  void dispose() {
    _mapAnimationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkLocationPermission().then((_) {
      debugPrint("LOCATION STATUS: $_locationStatus");
      
      setState(() {
        markers = markers..add(
          Marker(
        point: l.LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
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
      )
        );
      });
    });
  }

  void _animateMapMovement(l.LatLng destCenter, double destZoom, {int duration = 700}) {
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

  // Animate the map movement
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
    // Create a list of markers
    // If the current position is available, add a marker at that location
    if (_currentPosition != null) {

      // markers.add(
      //   Marker(
      //     point: l.LatLng(
      //       37.786210,
      //       -122.402530
      //     ),
      //     width: 40.0,
      //     height: 40.0,
      //     child: Container(
      //       decoration: BoxDecoration(
      //         color: Colors.red.withOpacity(0.7),
      //         shape: BoxShape.circle,
      //       ),
      //       child: Center(
      //         child: Icon(
      //           Icons.my_location,
      //           color: Colors.white,
      //           size: 20.0,
      //         ),
      //       ),
      //     ),
      //   ),
      // );
    }

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
                // Optionally handle the case when the current position is not available
                debugPrint('Current position not available');
              }
            },
          ),
        ),
      ],
    );
  }

  bool closeEnough(double lat1, double lon1, double lat2, double lon2){
    final double minDistance = 0.001;
    return sqrt((lat1 - lat2) * (lat1 - lat2) + (lon1 - lon2) * (lon1 - lon2)) < minDistance;
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
        //_animateMapMovement(destCenter, destZoom);
        _currentCenter = destCenter;
        _currentZoom = destZoom;
        _locationStatus =
            'Lat: ${position.latitude}, Long: ${position.longitude}';
      });

      debugPrint('Location: ${position.latitude}, ${position.longitude}');

      final notes = await getNotesWithinRadius(position.latitude, position.longitude, 100000000);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? ph = prefs.getString("phone-number");

      for (final note in notes){
        try{
          debugPrint("Here!!");
          debugPrint("${note["location"].latitude} ${note["location"].longitude}");
          double clat = note["location"].latitude;
          double clon = note["location"].longitude;
          String name = "Unknown";
          if (closeEnough(clat, clon, position.latitude, position.longitude)){
            debugPrint("CLOSE: ${note["creator"]}");
            final d = await FirebaseFirestore.instance.collection("users").where("phoneNumber", isEqualTo: note["creator"]).get();
            if (d.docs.isNotEmpty){
              debugPrint("GG");
              name = d.docs[0].get("name");
            }
          }

          setState(() {
            markers = markers..insert(0,
            Marker(
                point: l.LatLng(
                  clat,
                  clon,
                ),
                width: 40.0,
                height: 40.0,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minSize: 0.0,
                  onPressed: (){
                    if (!closeEnough(clat, clon, position.latitude, position.longitude)){
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                          "Too far away"
                        ))
                      );
                      return;
                    }
                    showCupertinoModalPopup(context: context, builder: (context){
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.8,
                        color: Colors.white.withOpacity(0.8),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 10.0),
                                CupertinoButton(
                                  onPressed: ()=>Navigator.pop(context),
                                  child: Icon(CupertinoIcons.xmark)
                                ),
                                Expanded(child: Container())
                              ],
                            ),
                            Expanded(child: Container(),),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.normal, color: Colors.black, decoration: TextDecoration.none)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),
                            Text(note["title"], style: const TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold, color: Colors.black, decoration: TextDecoration.none)),
                            const SizedBox(height: 10),
                            Text(note["note"], style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: Colors.black, decoration: TextDecoration.none)),
                            Expanded(child: Container(),),
                            Expanded(child: Container(),)
                          ]
                        )
                      );
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: note["creator"] == ph ? Colors.blue.withOpacity(0.8)  : Colors.purple.withOpacity(0.7),
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
                ),
              ),
            );
          });
        }
        catch(e){
          debugPrint("Failed to load note: $e");
        }
      }
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
        _currentPosition = null; // Ensure current position is null
        // Move to default position if location can't be found
        _animateMapMovement(_defaultCenter, _defaultZoom);
        _currentCenter = _defaultCenter;
        _currentZoom = _defaultZoom;
      });
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    // Check if location services are enabled
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = 'Location services are disabled.';
        _currentPosition = null;
        // Move to default position
        _animateMapMovement(_defaultCenter, _defaultZoom);
        _currentCenter = _defaultCenter;
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
          // Move to default position
          _animateMapMovement(_defaultCenter, _defaultZoom);
          _currentCenter = _defaultCenter;
          _currentZoom = _defaultZoom;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationStatus = 'Location permissions are permanently denied.';
        _currentPosition = null;
        // Move to default position
        _animateMapMovement(_defaultCenter, _defaultZoom);
        _currentCenter = _defaultCenter;
        _currentZoom = _defaultZoom;
      });
      return;
    }

    // If permission is granted, get the current location
    await _getCurrentLocation();
  }
}
