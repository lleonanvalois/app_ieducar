import 'package:app_ieducar/database/db.dart';
import 'package:app_ieducar/models/coordenada.dart';
import 'package:app_ieducar/models/ponto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController extends GetxController {
  final RxList<Coordenada> coordenadas = <Coordenada>[].obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxBool isLoading = true.obs;
  late GoogleMapController mapController;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>?;

    if (args != null &&
        args.containsKey('latitude') &&
        args.containsKey('longitude')) {
      final lat = args['latitude'] as double;
      final lng = args['longitude'] as double;
      final position = LatLng(lat, lng);
      addMarker(position);
      focusOnCoordinate(position);
    }

    loadRoute();
  }

  Future<void> loadRoute() async {
    try {
      isLoading.value = true;
      final data = await DatabaseHelper().getRotas();
      coordenadas.assignAll(data.map((e) => Coordenada.fromMap(e)));
      _createRoute();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar as rotas: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _createRoute() {
    polylines.clear();
    markers.clear();

    if (coordenadas.length > 1) {
      final points =
          coordenadas.map((c) => LatLng(c.latitude, c.longitude)).toList();

      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 4,
          points: points,
        ),
      );

      markers.addAll({
        Marker(
          markerId: const MarkerId('start'),
          position: points.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: const MarkerId('end'),
          position: points.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      });
    }
  }

  void zoomToRoute() {
    if (coordenadas.isNotEmpty) {
      final bounds = _calculateBounds();
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  LatLngBounds _calculateBounds() {
    double? west, south, east, north;

    for (var coord in coordenadas) {
      west =
          west != null
              ? (coord.longitude < west ? coord.longitude : west)
              : coord.longitude;
      east =
          east != null
              ? (coord.longitude > east ? coord.longitude : east)
              : coord.longitude;
      south =
          south != null
              ? (coord.latitude < south ? coord.latitude : south)
              : coord.latitude;
      north =
          north != null
              ? (coord.latitude > north ? coord.latitude : north)
              : coord.latitude;
    }

    return LatLngBounds(
      southwest: LatLng(south ?? 0, west ?? 0),
      northeast: LatLng(north ?? 0, east ?? 0),
    );
  }

  void focusOnCoordinate(LatLng position) {
    mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
  }

  void addMarker(LatLng position, {String? title}) {
    markers.add(
      Marker(
        markerId: MarkerId('selected_${DateTime.now().millisecondsSinceEpoch}'),
        position: position,
        infoWindow: InfoWindow(title: title ?? 'Localização Selecionada'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }
}
