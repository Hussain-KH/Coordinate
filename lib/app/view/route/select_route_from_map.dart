import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handyman/app/backend/model/point_model.dart';
import 'package:handyman/app/controller/route_controller.dart';
import 'package:handyman/app/util/theme.dart';
import 'package:handyman/app/widget/elevated_button.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SelectLocationFromMap extends StatefulWidget {
  const SelectLocationFromMap({super.key});

  @override
  State<SelectLocationFromMap> createState() => _SelectLocationFromMapState();
}

class _SelectLocationFromMapState extends State<SelectLocationFromMap> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? _newGoogleMapController;

  LocationPermission? _locationPermission;
  var geoLocator = Geolocator();
  Position? userCurrentPosition;
  static LatLng? _initialPosition;
  static CameraPosition? _cameraPosition;
  LatLng? onCameraMoveEndLatLng;
  Uint8List pickUpMarker = Uint8List.fromList([]);
  final placeTextEditor = TextEditingController();
  RouteController? routeController;
  //bool _isExpanded = false;
  final panelController = PanelController();
  double minHeight = 180;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);
    userCurrentPosition = position;
    pickUpMarker = await getMarker("location-pin");
    await pickOriginPositionOnMap(
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude));

    setState(() {
      _initialPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      onCameraMoveEndLatLng = _initialPosition;
      _cameraPosition =
          CameraPosition(target: _initialPosition as LatLng, zoom: 14.5);
      _newGoogleMapController
          ?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
    });
  }

  Future<Uint8List> getMarker(String fileName) async {
    ByteData byteData = await DefaultAssetBundle.of(context)
        .load("assets/images/$fileName.png");
    return byteData.buffer.asUint8List();
  }

  Future<void> pickOriginPositionOnMap(LatLng position) async {
    String placeName = "";
    String placeStreet = "";
    String locality = "";
    String subLocality = "";
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placeMarks.isNotEmpty) {
      locality = placeMarks[0].locality ?? "";
      subLocality = placeMarks[0].subLocality ?? "";
      placeStreet = placeMarks[0].street ?? "";

      placeName = '$locality - $subLocality';
    }
    Point userPickUpAddress = Point();
    userPickUpAddress.latitude = position.latitude;
    userPickUpAddress.longitude = position.longitude;
    userPickUpAddress.placeHeader = placeName;
    userPickUpAddress.placeDetails = placeStreet;
    routeController!.pinnedLocationOnMap.value = userPickUpAddress;
  }

  void _getPinnedAddress() async {
    routeController!.isPinMarkerVisible.value = false;
    await pickOriginPositionOnMap(onCameraMoveEndLatLng!);
  }

  @override
  void initState() {
    routeController = Get.find<RouteController>();
    checkIfLocationPermissionAllowed();
    _getUserLocation();

    super.initState();
  }

  @override
  void dispose() {
    _initialPosition = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _initialPosition == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: true,
                    initialCameraPosition: _cameraPosition!,
                    onCameraMove: (position) async {
                      routeController!.isPinMarkerVisible.value = true;
                      onCameraMoveEndLatLng = position.target;
                    },
                    onCameraIdle: _getPinnedAddress,
                    onMapCreated: (GoogleMapController controller) {
                      _controllerGoogleMap.complete(controller);
                      _newGoogleMapController = controller;
                    },
                  ),
                  Positioned(
                    bottom: minHeight + 10, // Adjust the top position as needed
                    right: 12.0, // Adjust the right position as needed
                    child: InkWell(
                      onTap: () {
                        _newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(_initialPosition!));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(2)),
                          color: Colors.white.withOpacity(0.7),
                        ),
                        height: 38,
                        width: 38,
                        child: Icon(
                          Icons.my_location,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(
                            milliseconds: 500), // Animation duration
                        child: routeController!.isPinMarkerVisible.value
                            ? Container(
                                width:
                                    8.0, // Adjust the size of the dot as needed
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors
                                      .black, // You can set the color you prefer
                                ),
                              )
                            : Image.memory(
                                pickUpMarker,
                                height: 60,
                                width: 60,
                                alignment: Alignment.center,
                                frameBuilder: (context, child, frame,
                                    wasSynchronouslyLoaded) {
                                  return Transform.translate(
                                    offset: const Offset(0, -25),
                                    child: child,
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                  SlidingUpPanel(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                          35.0), // Adjust the value as needed
                      topRight: Radius.circular(
                          35.0), // Adjust the value as needed
                      ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.transparent, // Transparent shadow color
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                    controller: panelController,
                    minHeight: minHeight, // Minimum panel height
                    maxHeight: MediaQuery.of(context).size.height,
                    onPanelSlide: (x) {
                      routeController!.widgetOpacity.value = x;
                    },
                    onPanelClosed: () {
                      routeController!.isExpanded.value = false;
                    },
                    onPanelOpened: () {
                      routeController!.isExpanded.value = true;
                    },
                    body: const Center(),
                    panel: Obx(
                      () => routeController!.widgetOpacity.value < 0.2
                          ? Opacity(
                              opacity: 1 - (routeController!.widgetOpacity.value * 4),
                              child: Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(
                                        35.0), // Adjust the value as needed
                                    topRight: Radius.circular(
                                        35.0), // Adjust the value as needed
                                  ),
                                  color: Colors.white,
                                ),
                                height: minHeight,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15.0, vertical: 10.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(35)),
                                          color: Colors.grey.shade300,
                                        ),
                                        height: 5,
                                        width: 70,
                                      ),
                                      const SizedBox(height: 15.0),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey
                                                  .withOpacity(0.15),
                                            ),
                                            child: const Padding(
                                              padding: EdgeInsets.all(11.0),
                                              child: Icon(
                                                Icons.search,
                                                color: ThemeProvider.appColor,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Obx(
                                            () => Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    routeController!
                                                        .pinnedLocationOnMap
                                                        .value
                                                        .placeHeader!
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    routeController!
                                                        .pinnedLocationOnMap
                                                        .value
                                                        .placeDetails!
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: minHeight - 150), // this expanded
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: MyElevatedButton(
                                          onPressed: () {
                                            routeController!.addPoint(
                                              Point(
                                                  placeHeader: routeController!
                                                      .pinnedLocationOnMap
                                                      .value
                                                      .placeHeader,
                                                  latitude: routeController!
                                                      .pinnedLocationOnMap
                                                      .value
                                                      .latitude,
                                                  longitude: routeController!
                                                      .pinnedLocationOnMap
                                                      .value
                                                      .longitude),
                                            );
                                            routeController!.onBack();
                                          },
                                          color: ThemeProvider.appColor,
                                          height: 45,
                                          width: double.infinity,
                                          child: Text(
                                            'Pick place on map'.tr,
                                            style: const TextStyle(
                                                letterSpacing: 1,
                                                fontSize: 16,
                                                color: ThemeProvider.whiteColor,
                                                fontFamily: 'bold'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Opacity(
                              opacity: routeController!.widgetOpacity.value,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.fromLTRB(25.0, 35, 0 ,0),
                                    child: Text(
                                      "Where to?",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            hintText: "Enter your destination",

                                            hintStyle: TextStyle(color: Colors.grey.shade500,),
                                            border: InputBorder.none,
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: Icon(
                                                Icons.search,
                                                size: 24,
                                                color: Colors.grey.shade500,
                                              )
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text(
                                                  "Suggestions",
                                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text(
                                                  "Airports",
                                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                                  ),
                                                ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text(
                                                  "DineOut",
                                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text(
                                                  "Malls",
                                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text(
                                                  "Attractions",
                                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                                                ),
                                              ),
                                              ]
                                            ),
                                        ),
                                        ),
                                    ),
                                    ),
                                  const Divider(
                                    height: 4,
                                    thickness: 4,
                                    color: Color(0xFFF8F8F8),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView( // or use ListView
                                      child: Column(
                                        children: List.generate(
                                          20,
                                              (index) => ListTile(
                                            title: Text('Item $index'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Obx(
                      () => Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 20, 0),
                      child: InkWell(
                        onTap: () {
                          routeController!.isExpanded.value ? panelController.close() : Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          height: 40,
                          width: 40,
                          child: Icon(
                            routeController!.isExpanded.value ? Icons.arrow_downward_rounded : Icons.close,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
