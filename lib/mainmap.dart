import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MainMap extends StatefulWidget {
  const MainMap({Key? key}) : super(key: key);

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  // Initialize MapController, center position, and zoom level
  final MapController _mapController = MapController();
  LatLng _currentCenter = LatLng(51.509364, -0.128928); // Center over London
  double _currentZoom = 9.2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentCenter,
            initialZoom: _currentZoom,
            // Enable pinch-to-zoom and other gestures
            interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onMapEvent: (MapEvent mapEvent) {
              setState(() {
                // Access current center and zoom via the camera property
                _currentCenter = _mapController.camera.center;
                _currentZoom = _mapController.camera.zoom;
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
                    _mapController.move(_currentCenter, _currentZoom);
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
                    _mapController.move(_currentCenter, _currentZoom);
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
