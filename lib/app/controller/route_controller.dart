import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../backend/model/point_model.dart';
import '../backend/parse/route_parse.dart';
import 'package:handyman/app/backend/api/handler.dart';
import 'package:handyman/app/backend/model/google_places_model.dart';
import 'package:handyman/app/env.dart';
import 'package:handyman/app/helper/uid_generate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';


class RouteController extends GetxController implements GetxService {
  final RouteParser parser;
  RouteController({required this.parser});

  List<Point> points = [];
  Rx<Point> pinnedLocationOnMap = Point().obs;
  Rx<bool> isPinMarkerVisible = false.obs;
  Rx<bool> isExpanded = false.obs;
  Rx<bool> isCameraMoving = false.obs;
  RxDouble widgetOpacity = 0.0.obs;
  RxList<GooglePlacesModel> getList = <GooglePlacesModel>[].obs;
  RxSet<Marker> markers = <Marker>{}.obs;

  void addPoint(Point point, String markerId) async {
    markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: LatLng(point.latitude!, point.longitude!),
      ),
    );
  }

  void reorderPoints(oldIndex, newIndex) {
    final Point point = points.removeAt(oldIndex);
    points.insert(newIndex, point);
    update();
  }

  void onBack() {
    var context = Get.context as BuildContext;
    Navigator.of(context).pop(true);
  }

  void onSearchChanged(String value) {
    if (value.isNotEmpty) {
      getPlacesList(value);
    }
  }

  Future<void> getPlacesList(String value) async {
    String googleURL =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    var sessionToken = Uuid().generateV4();
    var googleKey = Environments.googleMapsKey;
    String request =
        '$googleURL?input=$value&key=$googleKey&sessiontoken=$sessionToken&components=country:AE';

    Response response = await parser.getPlacesList(request);
    if (response.statusCode == 200) {
      Map<String, dynamic> myMap = Map<String, dynamic>.from(response.body);
      var body = myMap['predictions'];
      getList.value = [];
      body.forEach((data) {
        GooglePlacesModel placeData = GooglePlacesModel.fromJson(data);
        getList.add(placeData);
      });

      getList.refresh();
    } else {
      ApiChecker.checkApi(response);
    }
  }

  Future<LatLng> getLatLngFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      getList.value = [];
      return LatLng(locations[0].latitude, locations[0].longitude);
    }
    return LatLng(pinnedLocationOnMap.value.latitude!, pinnedLocationOnMap.value.longitude!);
  }
}
