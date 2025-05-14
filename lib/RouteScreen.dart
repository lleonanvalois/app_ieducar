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

              // onTap:
              //     controller.isEditing.value
              //         ? (position) {
              //           // Remove marcadores temporários antes de adicionar
              //           controller.markers.removeWhere(
              //             (m) => m.markerId.value.startsWith('temp_ponto'),
              //           );
              //           controller.addMarker(
              //             position,
              //             markerId: 'temp_ponto', // ID fixo para rascunho
              //           );
              //         }
              //         : null,
              myLocationEnabled: true,
            ),

            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
            // if (controller.coordenadas.isEmpty && !controller.isLoading.value)
            //   const Center(child: Text('Nenhuma rota registrada')),
          ],
        ),
      ),
    );
  }
}
