import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRoute {
  int? id;
  List<LatLng>? routePoints;
  List<bool>? selectedDays;
  int? startingTimeHour;
  int? startingTimeMinute;
  String? selectedVehicle;

  MapRoute({
    this.id,
    required this.routePoints,
    required this.selectedDays,
    required this.startingTimeHour,
    required this.startingTimeMinute,
    required this.selectedVehicle,
  });

  MapRoute.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    routePoints = (json['routeMarkers'] as List<dynamic>)
        .map((latLngJson) => LatLng(
      latLngJson['latitude'],
      latLngJson['longitude'],
    ))
        .toList();
    selectedDays = (json['selectedDays'] as List<dynamic>).cast<bool>().toList();
    startingTimeHour = json['startingTimeHour'];
    startingTimeMinute = json['startingTimeMinute'];
    selectedVehicle = json['selectedVehicle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['routeMarkers'] = routePoints!.map((latLng) => {
      'latitude': latLng.latitude,
      'longitude': latLng.longitude,
    }).toList();
    data['selectedDays'] = selectedDays!.toList();
    data['startingTimeHour'] = startingTimeHour;
    data['startingTimeMinute'] = startingTimeMinute;
    data['selectedVehicle'] = selectedVehicle;

    return data;
  }
}
