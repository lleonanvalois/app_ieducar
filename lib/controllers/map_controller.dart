import 'package:app_ieducar/database/db.dart';
import 'package:app_ieducar/models/coordenada.dart';
import 'package:app_ieducar/models/ponto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_ieducar/globals.dart' as globals;
import 'package:app_ieducar/extensions.dart';

class MapController extends GetxController {
  final RxList<Coordenada> coordenadas = <Coordenada>[].obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxBool isLoading = true.obs;
  final RxBool isEditing = false.obs;
  final RxString selectedPontoId = ''.obs;
  final RxList<Ponto> pontos = <Ponto>[].obs;
  GoogleMapController? mapController;

  late List<LatLng> originalRouteCoordinates;

  @override
  void onInit() async {
    super.onInit();
    await loadPontos();
    await loadRoute();
    _processarArgumentos();

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null &&
        args.containsKey('latitude') &&
        args.containsKey('longitude')) {
      final lat = args['latitude'] as double;
      final lng = args['longitude'] as double;
      final position = LatLng(lat, lng);
      addMarker(position, markerId: 'marcador_temporario');
    }
  }

  Future<void> loadPontosFromDatabase() async {
    try {
      final data = await DatabaseHelper().getPontos();
      pontos.assignAll(data.map((e) => Ponto.fromMap(e)));
      markers.clear();

      for (var ponto in pontos) {
        addMarker(
          LatLng(ponto.nuLatitude, ponto.nuLongitude),
          markerId: 'ponto_${ponto.id}',
          ponto: ponto,
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar pontos: ${e.toString()}');
    }
  }

  Future<void> loadRoute() async {
    try {
      isLoading.value = true;
      final data = await DatabaseHelper().getRotas();
      coordenadas.assignAll(data.map((e) => Coordenada.fromMap(e)));
      _createRoute();
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar rotas: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _createRoute() {
    polylines.clear();

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
      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
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
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
  }

  void addMarker(LatLng position, {required String markerId, Ponto? ponto}) {
    markers.removeWhere((m) => m.markerId.value == markerId);

    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        draggable: isEditing.value,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          selectedPontoId.value == markerId
              ? BitmapDescriptor.hueAzure
              : BitmapDescriptor.hueRed,
        ),
        onTap: () => selectedPontoId.value = markerId,
        onDragEnd: (newPosition) {
          markers.removeWhere((m) => m.markerId.value == markerId);
          addMarker(newPosition, markerId: markerId, ponto: ponto);
        },
      ),
    );
  }

  void refreshMap() {
    _createRoute();
    update();
  }

  void _processarArgumentos() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('editarPontoId')) {
      final pontoId = args['editarPontoId'] as int;
      final ponto = pontos.firstWhereOrNull((p) => p.id == pontoId);

      if (ponto != null) {
        addMarker(
          LatLng(ponto.nuLatitude, ponto.nuLongitude),
          markerId: 'ponto_${ponto.id}',
          ponto: ponto,
        );
        selectedPontoId.value = 'ponto_${ponto.id}';
      } else {
        Get.snackbar('Erro', 'Ponto não encontrado');
      }
    }
  }

  void enterEditMode() {
    isEditing.value = true;

    final updatedMarkers =
        markers.map((marker) {
          return marker.copyWith(draggableParam: true);
        }).toSet();

    markers.clear();
    markers.addAll(updatedMarkers);
  }

  void exitEditMode() {
    isEditing.value = false;

    final updatedMarkers =
        markers.map((marker) {
          return marker.copyWith(draggableParam: false);
        }).toSet();

    markers.clear();
    markers.addAll(updatedMarkers);
  }

  Future<void> confirmAndSave() async {
    if (selectedPontoId.isEmpty) {
      Get.snackbar('Aviso', 'Nenhum ponto selecionado para editar');
      return;
    }

    if (!selectedPontoId.value.startsWith('ponto_')) {
      Get.snackbar('Erro', 'ID do marcador inválido');
      return;
    }

    final parts = selectedPontoId.value.split('_');
    if (parts.length != 2) {
      Get.snackbar('Erro', 'Formato do ID incorreto');
      return;
    }

    final pontoId = int.tryParse(parts[1]);
    if (pontoId == null) {
      Get.snackbar('Erro', 'ID não é numérico');
      return;
    }

    final confirmed = await Get.dialog(
      AlertDialog(
        title: const Text('Confirmar alterações'),
        content: const Text('Deseja salvar as alterações feitas no mapa?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Salvar', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirmed) {
      try {
        final marker = markers.firstWhereOrNull(
          (m) => m.markerId.value == selectedPontoId.value,
        );

        if (marker == null) {
          Get.snackbar('Erro', 'Marcador não encontrado');
          return;
        }

        final ponto = pontos.firstWhere(
          (p) => p.id == pontoId,
          orElse: () => throw Exception('Ponto não encontrado no banco'),
        );

        await DatabaseHelper().updatePonto(ponto.id!, {
          'nu_latitude': marker.position.latitude,
          'nu_longitude': marker.position.longitude,
          'dh_ponto': DateTime.now().toIso8601String(),
        });

        Get.snackbar('Sucesso', 'Ponto atualizado!');
        //refreshMap();
      } on Exception catch (e) {
        Get.snackbar('Erro', e.toString());
      }
    }
  }

  Future<void> loadPontos() async {
    try {
      final data = await DatabaseHelper().getPontos();
      pontos.assignAll(data.map((e) => Ponto.fromMap(e)));
      markers.clear();

      for (var ponto in pontos) {
        addMarker(
          LatLng(ponto.nuLatitude, ponto.nuLongitude),
          markerId: 'ponto_${ponto.id}',
          ponto: ponto,
        );
      }
    } catch (e) {
      Get.snackbar('Erro', 'Falha ao carregar pontos: ${e.toString()}');
    }
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }
}
