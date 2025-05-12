import 'package:google_maps_flutter/google_maps_flutter.dart';

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

extension MarkerCopyWith on Marker {
  Marker copyWith({
    bool? draggableParam,
    LatLng? position,
    BitmapDescriptor? iconParam,
    void Function()? onTapParam,
    void Function(LatLng)? onDragEndParam,
  }) {
    return Marker(
      markerId: markerId,
      position: position ?? this.position,
      draggable: draggableParam ?? draggable,
      icon: iconParam ?? icon,
      onTap: onTapParam ?? onTap,
      onDragEnd: onDragEndParam ?? onDragEnd,
    );
  }
}
