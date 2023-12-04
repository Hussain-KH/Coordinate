import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:handyman/app/backend/model/route_model.dart';
import 'package:handyman/app/util/toast.dart';
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

  //List<Point> points = [];
  Rx<Point> pinnedLocationOnMap = Point().obs;
  Rx<bool> isPinMarkerVisible = false.obs;
  Rx<bool> isExpanded = false.obs;
  Rx<bool> isCameraMoving = false.obs;
  RxDouble widgetOpacity = 0.0.obs;
  RxList<GooglePlacesModel> getList = <GooglePlacesModel>[].obs;
  RxList<Circle> circles = <Circle>[].obs;
  Rx<bool> isMarkerAdded = false.obs;
  Rx<bool> isMarkerSelected = false.obs;
  int selectedMarkerIndex = -1;
  String intersectCircleId = '';

  RxList<MarkerData> markers = <MarkerData>[].obs;
  RxList<bool> selectedDays = [false, false, false, false, false, false, false].obs;
  Rx<TimeOfDay?> startingTime = Rx<TimeOfDay?>(null);
  Rx<String> selectedVehicle = ''.obs;

  void addPoint(Point point, BuildContext? context) {
    if(checkIfMarkerInsideCircle(LatLng(point.latitude!, point.longitude!))){
      isMarkerAdded.value = true;
      markers.add(
        MarkerData(
          marker: Marker(
            onTap: () {
              isMarkerSelected.value = true;
              selectedMarkerIndex = point.id!;
            },
            markerId: MarkerId(point.id!.toString()),
            position: LatLng(point.latitude!, point.longitude!),

          ),
          child: Stack(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 50,
              ),
              Positioned(
                left: 15,
                top: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(point.id!.toString())),
                ),
              ),
            ],
          ),
        ),
      );

      circles.add(
        Circle(
          circleId: CircleId(point.id.toString()),
          center: LatLng(point.latitude!, point.longitude!),
          radius: 700,
          strokeWidth: 0,
          fillColor: Colors.blue
              .withOpacity(0.12),
        ),
      );
    } else {
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Text('Too close to point number: $intersectCircleId'),
          duration: const Duration(milliseconds: 1350),
          behavior: SnackBarBehavior.floating, // Use SnackBarBehavior.fixed for a fixed position
        ),
      );
    }
  }

  void updatePoint(LatLng lastSelectedLatLng) {
    markers.removeWhere((marker) => marker.marker.markerId == MarkerId(selectedMarkerIndex.toString()));
    circles.removeWhere((circle) => circle.circleId == CircleId(selectedMarkerIndex.toString()));
    Point point = Point(id: selectedMarkerIndex, latitude: lastSelectedLatLng.latitude, longitude: lastSelectedLatLng.longitude);
    markers.insert(
      selectedMarkerIndex - 1,
      MarkerData(
        marker: Marker(
          onTap: () {
            isMarkerSelected.value = true;
            selectedMarkerIndex = point.id!;
          },
          markerId: MarkerId(point.id!.toString()),
          position: LatLng(point.latitude!, point.longitude!),

        ),
        child: Stack(
          children: [
            const Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 50,
            ),
            Positioned(
              left: 15,
              top: 8,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(point.id!.toString())),
              ),
            ),
          ],
        ),
      ),
    );

    circles.insert(
      selectedMarkerIndex - 1,
      Circle(
        circleId: CircleId(point.id.toString()),
        center: LatLng(point.latitude!, point.longitude!),
        radius: 700,
        strokeWidth: 0,
        fillColor: Colors.blue
            .withOpacity(0.12),
      ),
    );

    removeMarkerSelection();
    isMarkerAdded.value = true;
  }

  void deletePoint() {
    List<MarkerData> remainingMarkers = markers.sublist(selectedMarkerIndex);
    markers.value = markers.sublist(0, selectedMarkerIndex - 1);
    // ignore: invalid_use_of_protected_member
    circles.value = circles.sublist(0, selectedMarkerIndex - 1);

    for(int i = 0; i < remainingMarkers.length; i++){
      LatLng oldMarker = remainingMarkers[i].marker.position;
      Point point = Point(id: i + selectedMarkerIndex, latitude: oldMarker.latitude, longitude: oldMarker.longitude);
      addPoint(point, null);
    }

    removeMarkerSelection();
  }

  bool checkIfMarkerInsideCircle(LatLng newMarker) {

    for (Circle circle in circles) {
      LatLng circleCenter = circle.center;
      double circleRadius = circle.radius;

      double distance = Geolocator.distanceBetween(
        circleCenter.latitude,
        circleCenter.longitude,
        newMarker.latitude,
        newMarker.longitude,
      );

      if (distance <= circleRadius) {
        intersectCircleId = circle.circleId.value;
        return false;
      }
    }
    return true;
  }

  void removeMarkerSelection() {
    isMarkerSelected.value = false;
    selectedMarkerIndex = -1;
  }

  Future<void> selectStartTime(BuildContext context) async {
    startingTime.value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  void selectDays(int index) {
    selectedDays[index] = !selectedDays[index];
  }

  Future<void> saveRoute() async {
    List<LatLng> routePoints = markers.map((element) => element.marker.position).toList();

    MapRoute route = MapRoute(
        routePoints: routePoints,
        selectedDays: selectedDays,
        startingTimeHour: startingTime.value!.hour,
        startingTimeMinute: startingTime.value!.minute,
        selectedVehicle: selectedVehicle.value
    );

    var body = {
      "uid": parser.getUID(),
      "route": route.toJson(),
      "status": 1
    };

    var response = await parser.saveRoute(body);
    //Get.back();

    debugPrint('sdsdsd');
    debugPrint(response.bodyString);

    if (response.statusCode == 200) {
      //debugPrint(response.bodyString);
      successToast('Successfully Added'.tr);
      //onBack();
    } else {
      ApiChecker.checkApi(response);
    }
    // update();
  }

  // void reorderRoutes(oldIndex, newIndex) {
  //   final Point point = points.removeAt(oldIndex);
  //   points.insert(newIndex, point);
  //   update();
  // }

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
