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
        title: const Text('Minhas Rotas'),
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
              initialCameraPosition: const CameraPosition(
                target: LatLng(-23.5505, -46.6333),
                zoom: 12,
              ),
              polylines: controller.polylines,
              markers: controller.markers,
              onMapCreated:
                  (controller) => this.controller.mapController = controller,
              myLocationEnabled: true,
            ),
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator()),
            if (controller.coordenadas.isEmpty && !controller.isLoading.value)
              const Center(child: Text('Nenhuma rota registrada')),
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
