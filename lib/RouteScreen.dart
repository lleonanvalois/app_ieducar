import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_ieducar/controllers/map_controller.dart';

class RouteScreen extends GetView<MapController> {
  const RouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadRoute,
          ),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target:
                    controller.coordenadas.isNotEmpty
                        ? LatLng(
                          controller.coordenadas.first.latitude,
                          controller.coordenadas.first.longitude,
                        )
                        : const LatLng(-23.5505, -46.6333),
                zoom: 12,
              ),
              polylines: controller.polylines,
              markers: controller.markers,
              onMapCreated: (GoogleMapController googleMapController) {
                controller.mapController = googleMapController;

                // Acessa os argumentos após a criação do mapa
                final args = Get.arguments as Map<String, dynamic>?;

                if (args != null &&
                    args.containsKey('latitude') &&
                    args.containsKey('longitude')) {
                  final lat = args['latitude'] as double;
                  final lng = args['longitude'] as double;
                  final position = LatLng(lat, lng);
                  controller.addMarker(position);
                  controller.focusOnCoordinate(position);
                }
              },
              myLocationEnabled: true,
            ),
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
            // if (controller.coordenadas.isEmpty && !controller.isLoading.value)
            //   const Center(child: Text('Nenhuma rota registrada')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.zoomToRoute,
        child: const Icon(Icons.zoom_out_map),
      ),
    );
  }
}
