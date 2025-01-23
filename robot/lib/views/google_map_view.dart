import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapView extends StatefulWidget {
  const GoogleMapView({super.key});

  @override
  State<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends State<GoogleMapView> {

  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(43.1, -87.9), // 设置地图中心点
    zoom: 10.0, // 设置地图缩放级别
  );
  @override
  Widget build(BuildContext context) {
    GoogleMapController mapController;
    return Container(
      child: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
      ),
    );
  }
}

