import 'package:app_ieducar/PontoScreen.dart';
import 'package:app_ieducar/database/db.dart';
import 'package:app_ieducar/models/coordenada.dart';
import 'package:app_ieducar/models/ponto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_ieducar/extensions.dart';

class MapController extends GetxController {
  // --- Propriedades ---
  final RxList<Coordenada> coordenadas = <Coordenada>[].obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxList<Ponto> pontos = <Ponto>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isEditing = false.obs;
  final RxBool isFirstDrag = true.obs;

  final RxString selectedPontoId = ''.obs;
  final RxString tempMarkerId = ''.obs;
  final Rx<MapType> mapType = MapType.normal.obs;

  GoogleMapController? mapController;
  late List<LatLng> originalRouteCoordinates;
  // Mapeia os IDs dos marcadores para suas posições originais
  final Map<String, LatLng> originalMarkerPositions = {};

  // --- Inicialização ---
  @override
  void onInit() async {
    super.onInit();
    await loadPontos();
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      isLoading.value = true;
      await loadPontos();
      await loadRoute();
      _processarArgumentos();
    } finally {
      isLoading.value = false;
    }
  }

  // --- Métodos de Carregamento de Dados ---

  Future<void> loadPontos() async {
    try {
      final data = await DatabaseHelper().getPontos();
      pontos.assignAll(data.map((e) => Ponto.fromMap(e)));
      _updateMarkers();
    } catch (e) {
      _showErrorSnackbar('Falha ao carregar pontos: ${e.toString()}');
    }
  }

  Future<void> loadRoute() async {
    try {
      final data = await DatabaseHelper().getRotas();
      coordenadas.assignAll(data.map((e) => Coordenada.fromMap(e)));
      _createRoute();
    } catch (e) {
      _showErrorSnackbar('Falha ao carregar rotas: ${e.toString()}');
    }
  }

  // --- Métodos de Manipulação do Mapa ---

  void addMarker(LatLng position, {required String markerId, Ponto? ponto}) {
    markers.removeWhere((m) => m.markerId.value == markerId);
    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        draggable: isEditing.value,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        onDragStart: (_) => _onDragStart(markerId),
        onDragEnd: (newPosition) => _onDragEnd(markerId, newPosition),
      ),
    );

    // Armazena a posição original do marcador

    originalMarkerPositions[markerId] = position;
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
          markerId: MarkerId('start'),
          position: LatLng(40.7128, -74.0060),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
        Marker(
          markerId: MarkerId('end'),
          position: LatLng(34.0522, -118.2437),
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
          west == null
              ? coord.longitude
              : coord.longitude < west
              ? coord.longitude
              : west;
      east =
          east == null
              ? coord.longitude
              : coord.longitude > east
              ? coord.longitude
              : east;
      south =
          south == null
              ? coord.latitude
              : coord.latitude < south
              ? coord.latitude
              : south;
      north =
          north == null
              ? coord.latitude
              : coord.latitude > north
              ? coord.latitude
              : north;
    }

    return LatLngBounds(
      southwest: LatLng(south ?? 0, west ?? 0),
      northeast: LatLng(north ?? 0, east ?? 0),
    );
  }

  void focusOnCoordinate(LatLng position) {
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
  }

  // --- Métodos de Edição ---

  void enterEditMode() {
    isEditing.value = true;
    final updatedMarkers =
        markers.map((m) {
          if (!originalMarkerPositions.containsKey(m.markerId.value)) {
            originalMarkerPositions[m.markerId.value] = m.position;
          }
          return m.copyWith(draggableParam: true, positionParam: m.position);
        }).toSet();

    markers
      ..clear()
      ..addAll(updatedMarkers);
  }

  void exitEditMode() {
    isEditing.value = false;

    _restoreOriginalMarkerPositions();
    _updateMarkerDraggableState(false);
    _resetTempMarkerColor();
    _resetDragState();
  }

  void _updateMarkerDraggableState(bool draggable) {
    final updatedMarkers =
        markers.map((m) {
          return m.copyWith(
            draggableParam: draggable,
            positionParam: m.position,
          );
        }).toSet();

    markers
      ..clear()
      ..addAll(updatedMarkers);
    update();
  }

  void _onDragStart(String markerId) {
    if (isFirstDrag.value) {
      tempMarkerId.value = markerId;
      _updateMarkerColor(markerId, BitmapDescriptor.hueAzure);
      isFirstDrag.value = false;
    }
  }

  void _onDragEnd(String markerId, LatLng newPosition) {
    final marker = markers.firstWhereOrNull(
      (m) => m.markerId.value == markerId,
    );
    if (marker != null) {
      markers.remove(marker);
      markers.add(marker.copyWith(positionParam: newPosition));
      update();
    }
  }

  Future<void> confirmAndSave() async {
    try {
      // Salva todos os marcadores modificados
      for (var m in markers) {
        final markerId = m.markerId.value;
        if (markerId.startsWith('ponto_')) {
          final parts = markerId.split('_');
          if (parts.length != 2) continue;
          final idPonto = int.tryParse(parts[1]);
          if (idPonto == null) continue;

          print(
            'Atualizando ponto $idPonto com Lat: ${m.position.latitude}, Lng: ${m.position.longitude}',
          );

          await DatabaseHelper().updatePonto(idPonto, {
            'nu_latitude': m.position.latitude,
            'nu_longitude': m.position.longitude,
            'dh_ponto': DateTime.now().toIso8601String(),
          });
        }
        originalMarkerPositions[markerId] = m.position;
      }
      if (Get.isRegistered<PontosController>()) {
        // Verifica se o controller está registrado
        final PontosController pontosCtrl = Get.find<PontosController>();
        await pontosCtrl.carregarPontos();
      }

      Get.snackbar(
        'Sucesso',
        'Alterações salvas!',
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: Colors.green,
      );
      _resetTempMarkerColor();
      _resetDragState();
      isEditing.value = false;
    } catch (e) {
      _showErrorSnackbar('Falha ao salvar alterações: ${e.toString()}');
    }
  }

  void _resetDragState() {
    isFirstDrag.value = true;
    tempMarkerId.value = '';
  }

  void _resetTempMarkerColor() {
    _updateMarkerColor(tempMarkerId.value, BitmapDescriptor.hueRed);
  }

  void _updateMarkerColor(String markerId, double color) {
    final marker = markers.firstWhereOrNull(
      (m) => m.markerId.value == markerId,
    );
    if (marker != null) {
      markers.remove(marker);
      markers.add(
        marker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(color),
        ),
      );
      update();
    }
  }

  void _restoreOriginalMarkerPositions() {
    final restoredMarkers =
        markers.map((m) {
          if (originalMarkerPositions.containsKey(m.markerId.value)) {
            return m.copyWith(
              positionParam: originalMarkerPositions[m.markerId.value]!,
            );
          } else {
            return m;
          }
        }).toSet();

    markers
      ..clear()
      ..addAll(restoredMarkers);

    originalMarkerPositions.clear(); // Limpa o mapa após restaurar
  }

  void _updateMarkers() {
    markers.clear();
    for (final ponto in pontos) {
      addMarker(
        LatLng(ponto.nuLatitude, ponto.nuLongitude),
        markerId: 'ponto_${ponto.id}',
        ponto: ponto,
      );
    }
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
        _showErrorSnackbar('Ponto não encontrado');
      }
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar('Erro', message);
  }

  void showMapType() {
    Get.bottomSheet(
      Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Selecionar Tipo de Mapa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                RadioListTile<MapType>(
                  title: const Text('Normal'),
                  value: MapType.normal,
                  groupValue: mapType.value,
                  onChanged: (MapType? value) {
                    if (value != null) {
                      mapType.value = value;
                      Get.back(); // Fecha o BottomSheet
                    }
                  },
                ),
                RadioListTile<MapType>(
                  title: const Text('Satélite'),
                  value: MapType.satellite,
                  groupValue: mapType.value,
                  onChanged: (MapType? value) {
                    if (value != null) {
                      mapType.value = value;
                      Get.back();
                    }
                  },
                ),
                RadioListTile<MapType>(
                  title: const Text('Híbrido'),
                  value: MapType.hybrid,
                  groupValue: mapType.value,
                  onChanged: (MapType? value) {
                    if (value != null) {
                      mapType.value = value;
                      Get.back();
                    }
                  },
                ),
                RadioListTile<MapType>(
                  title: const Text('Terreno'),
                  value: MapType.terrain,
                  groupValue: mapType.value,
                  onChanged: (MapType? value) {
                    if (value != null) {
                      mapType.value = value;
                      Get.back();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );

    // --- Limpeza ---

    @override
    void onClose() {
      mapController?.dispose();
      super.onClose();
    }
  }
}
