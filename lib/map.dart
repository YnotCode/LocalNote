import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_map/flutter_map.dart';
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

  @override
  initState(){
    _checkLocationPermission().then((_) => {
      debugPrint("LOCATION STATUS: ${_locationStatus}")
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: l.LatLng(_currentPosition?.latitude ?? 51.509364, _currentPosition?.longitude ?? -0.128928), // Center the map over London
        initialZoom: 9.2,
      ),
      children: [
        TileLayer( // Display map tiles from any source
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
          userAgentPackageName: 'com.example.app',
          // And many more recommended properties!
        ),
        RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () => debugPrint("HELLO WORLD!!") // (external)
            ),
            // Also add images...
          ],
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
        mapController.move(l.LatLng(position.latitude, position.longitude), 9.2);
        _locationStatus =
            'Lat: ${position.latitude}, Long: ${position.longitude}';
      });

      debugPrint('Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      
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