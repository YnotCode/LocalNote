import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
// Removed unnecessary import of google_maps_flutter
import 'package:latlong2/latlong.dart' as l;

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
