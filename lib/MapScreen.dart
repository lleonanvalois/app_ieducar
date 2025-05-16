import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_ieducar/controllers/map_controller.dart';

class Mapscreen extends GetView<MapController> {
  const Mapscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        actions: [
          Obx(
            () =>
                controller.isEditing.value
                    ? Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: controller.confirmAndSave,
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: controller.exitEditMode,
                        ),
                      ],
                    )
                    : IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: controller.enterEditMode,
                    ),
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
              mapType: controller.mapType.value,
              polylines: controller.polylines,
              markers: controller.markers.toSet(),
              onMapCreated: (GoogleMapController googleMapController) {
                controller.mapController = googleMapController;

                final args = Get.arguments as Map<String, dynamic>?;
                if (args != null && args.containsKey('editarPontoId')) {
                  final markerId = args['editarPontoId'] as int;
                  final lat = args['latitude'] as double;
                  final lng = args['longitude'] as double;
                  final position = LatLng(lat, lng);
                  controller.addMarker(position, markerId: 'ponto_$markerId');
                  controller.focusOnCoordinate(position);
                }
              },

              myLocationEnabled: true,
            ),

            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
            Positioned(
              top: 16.0,
              left: 16.0,
              child: FloatingActionButton(
                onPressed: controller.showMapType,
                child: const Icon(Icons.map),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
