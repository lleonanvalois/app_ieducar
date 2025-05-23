import 'dart:async';
import 'package:app_ieducar/database/db.dart';
import 'package:app_ieducar/models/coordenada.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _timer;
  Position? _lastPosition;

  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviço de localização desativado');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização permanentemente negada');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> getLocationUpdates({
    required Function(Position) onLocationUpdate,
    int distanceFilter = 10,
    Duration? timeInterval = const Duration(seconds: 10),
    required Function(Position) onLocationSaved,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) async {
    await getCurrentLocation();

    if (distanceFilter > 0) {
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter,
        ),
      ).listen((Position position) {
        _lastPosition = position;
        onLocationUpdate(position);
      });
    }
    if (timeInterval != null) {
      _timer = Timer.periodic(timeInterval, (_) async {
        try {
          final position = await Geolocator.getCurrentPosition();
          _lastPosition = position;
          onLocationUpdate(position);
        } catch (e) {
          print('Erro ao atulizar por tempo: $e');
        }
      });
    }
  }

  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    _positionStreamSubscription = null;
    _timer = null;
  }

  void dispose() {
    stopLocationUpdates();
  }

  Position? get lastPosition => _lastPosition;

  Future<void> _savedLocation(Position position) async {
    try {
      await DatabaseHelper().insertPontoRota(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print('Erro ao salvar localização: $e');
    }
  }

  Future<List<Coordenada>> getCoordenadas() async {
    final dados = await DatabaseHelper().getRotas();
    return dados.map((c) => Coordenada.fromMap(c)).toList();
  }
}
