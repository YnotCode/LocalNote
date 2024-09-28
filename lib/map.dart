import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/animation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as l;

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  @override
  State<MainMap> createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> with TickerProviderStateMixin {
  Position? _currentPosition;
  String _locationStatus = 'Location not available';

  final MapController mapController = MapController();
  l.LatLng _currentCenter = l.LatLng(51.509364, -0.128928); // Default center
  double _currentZoom = 9.2;
  final double _defaultZoom = 12.0; // Default zoom level when centering

  AnimationController? _mapAnimationController;
  Animation<l.LatLng>? _latLngAnimation;
  Animation<double>? _zoomAnimation;

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

  @override
  Widget build(BuildContext context) {
    // Create a list of markers
    final List<Marker> markers = [];

    // If the current position is available, add a marker at that location
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: l.LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 40.0,
          height: 40.0,
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
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => debugPrint("Attribution tapped!"),
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

  Future<void> _getCurrentLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final destCenter = l.LatLng(position.latitude, position.longitude);
      final destZoom = _defaultZoom;

      setState(() {
        _currentPosition = position;
        _animateMapMovement(destCenter, destZoom);
        _currentCenter = destCenter;
        _currentZoom = destZoom;
        _locationStatus =
            'Lat: ${position.latitude}, Long: ${position.longitude}';
      });

      debugPrint('Location: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
      });
    }
  }

  Future<void> _checkLocationPermission() async {
    // ... (rest of the method remains the same)
  }
}
