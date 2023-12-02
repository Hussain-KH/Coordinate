import 'dart:async';

import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:handyman/app/backend/model/point_model.dart';
import 'package:handyman/app/controller/route_controller.dart';
import 'package:handyman/app/util/theme.dart';
import 'package:handyman/app/view/route/route_params.dart';
import 'package:handyman/app/widget/elevated_button.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
//import 'package:shimmer/shimmer.dart';

class SelectLocationFromMap extends StatefulWidget{
  const SelectLocationFromMap({super.key});

  @override
  State<SelectLocationFromMap> createState() => _SelectLocationFromMapState();
}

class _SelectLocationFromMapState extends State<SelectLocationFromMap> {

  GoogleMapController? _newGoogleMapController;
  LocationPermission? _locationPermission;
  var geoLocator = Geolocator();
  Position? userCurrentPosition;
  static LatLng? _initialPosition;
  static CameraPosition? _cameraPosition;
  CameraPosition? onCameraMoveEndLatLng;
  Uint8List pickUpMarker = Uint8List.fromList([]);
  final placeTextEditor = TextEditingController();
  RouteController? routeController;
  final panelController = PanelController();
  double minHeight = 210;
  LatLng? lastSelectedLatLng;

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
      onCameraMoveEndLatLng = CameraPosition(target: _initialPosition!);
      lastSelectedLatLng = _initialPosition;
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
    await pickOriginPositionOnMap(onCameraMoveEndLatLng!.target);
    routeController!.isCameraMoving.value = false;
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
    _newGoogleMapController!.dispose();
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
              child: Obx(
                    () {
                      //remove this code to go to initial position on each point selected
                      _cameraPosition =
                          CameraPosition(target: lastSelectedLatLng as LatLng, zoom: 14.5);
                      _newGoogleMapController
                          ?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
                      //

                      return CustomGoogleMapMarkerBuilder(
                      // ignore: invalid_use_of_protected_member
                        customMarkers: routeController!.markers.value,
                        builder: (BuildContext context, Set<Marker>? markers) {
                          if (markers == null) {
                          return const Center(child: CircularProgressIndicator());
                        }
                          return Stack(
                          children: [
                            GoogleMap(
                              mapType: MapType.normal,
                              myLocationButtonEnabled: false,
                              myLocationEnabled: true,
                              zoomGesturesEnabled: true,
                              zoomControlsEnabled: false,
                              markers: markers,
                              // ignore: invalid_use_of_protected_member
                              circles: routeController!.circles.value.toSet(),
                              initialCameraPosition: _cameraPosition!,
                              onCameraMoveStarted: () {
                                routeController!.isCameraMoving.value = true;
                                routeController!.isPinMarkerVisible.value = true;
                                routeController!.isMarkerAdded.value = false;
                              },
                              onCameraMove: (position) async {
                                onCameraMoveEndLatLng = position;
                              },
                              onCameraIdle: _getPinnedAddress,
                              onMapCreated: (GoogleMapController controller) {
                                _newGoogleMapController = controller;
                              },
                            ),
                            Positioned(
                              bottom: minHeight + 10,
                              right: 12.0,
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
                            Center(
                              child: Container(
                                width:
                                8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors
                                      .black, // You can set the color you prefer
                                ),
                              ),
                            ),
                            Obx(
                              () => Center(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                  opacity: !(routeController!.isPinMarkerVisible.value
                                  || routeController!.isMarkerAdded.value
                                  || routeController!.isMarkerSelected.value) ? 1 : 0,
                                  child: Image.memory(
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
                              )
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
                              panel: Obx(() => routeController!.widgetOpacity.value < 0.2
                                  ? Opacity(
                                opacity: 1 - (routeController!.widgetOpacity.value * 4),
                                child: routeController!.isCameraMoving.value
                                    ? Container(
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(35.0),
                                      topRight: Radius.circular(35.0),
                                    ),
                                    color: Colors.white,
                                  ),
                                  height: minHeight,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
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
                                                    color: Colors.grey.withOpacity(0.15),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(11.0),
                                                    child: Icon(
                                                      Icons.search,
                                                      color: ThemeProvider.appColor.withOpacity(0.3),
                                                      size: 30,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(right: (MediaQuery.of(context).size.width * 0.2)),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(right: (MediaQuery.of(context).size.width * 0.25)),
                                                          child: Container(
                                                            height: 20,
                                                            decoration: BoxDecoration(
                                                              color: Colors.grey.shade300,
                                                              borderRadius: BorderRadius.circular(7.5), // Adjust the radius as needed
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Container(
                                                          height: 15,
                                                          decoration: BoxDecoration(
                                                            color: Colors.grey.shade300,
                                                            borderRadius: BorderRadius.circular(7.5), // Adjust the radius as needed
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: minHeight - 185),
                                            if(!routeController!.isMarkerSelected.value)
                                              Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: MyElevatedButton(
                                                    onPressed: () {},
                                                    color: Colors.grey.shade300,
                                                    height: 40,
                                                    width: double.infinity,
                                                    child: const Text(
                                                      ''
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                  child: MyElevatedButton(
                                                    onPressed: () {},
                                                    color: Colors.grey.shade300,
                                                    height: 40,
                                                    width: double.infinity,
                                                    child: const Text(
                                                      '',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if(routeController!.isMarkerSelected.value)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                routeController!.removeMarkerSelection();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 0.5,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue,
                                                ),
                                                height: 70,
                                                width: 70,
                                                child: const Icon(
                                                  Icons.arrow_back,
                                                  size: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                routeController!.deletePoint();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 0.5,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  color: Colors.red,
                                                ),
                                                height: 70,
                                                width: 70,
                                                child: const Icon(
                                                  Icons.delete_forever,
                                                  size: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                                onTap: null,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey.shade300,
                                                      width: 0.5,
                                                    ),
                                                    shape: BoxShape.circle,
                                                    color: Colors.green.withOpacity(0.3),
                                                  ),
                                                  height: 70,
                                                  width: 70,
                                                  child: const Icon(
                                                    Icons.check,
                                                    size: 32,
                                                    color: Colors.white,
                                                  ),
                                                )
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                                    : Container(
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
                                          width: (MediaQuery.of(context).size.width * 0.2),
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
                                            Expanded(
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
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black,
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Text(
                                                    routeController!
                                                        .pinnedLocationOnMap.value.placeDetails!
                                                        .toString(),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: minHeight - 185),
                                        routeController!.isMarkerSelected.value
                                            ? Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                routeController!.removeMarkerSelection();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 0.5,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  color: Colors.blue,
                                                ),
                                                height: 70,
                                                width: 70,
                                                child: const Icon(
                                                  Icons.arrow_back,
                                                  size: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                routeController!.deletePoint();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 0.5,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  color: Colors.red,
                                                ),
                                                height: 70,
                                                width: 70,
                                                child: const Icon(
                                                  Icons.delete_forever,
                                                  size: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                lastSelectedLatLng =
                                                    LatLng(routeController!
                                                        .pinnedLocationOnMap
                                                        .value
                                                        .latitude!, routeController!
                                                        .pinnedLocationOnMap
                                                        .value
                                                        .longitude!);

                                                routeController!.updatePoint(lastSelectedLatLng!);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 0.5,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  color: Colors.green,
                                                ),
                                                height: 70,
                                                width: 70,
                                                child: const Icon(
                                                  Icons.check,
                                                  size: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                            : Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: MyElevatedButton(
                                                onPressed: () {
                                                  lastSelectedLatLng =
                                                      LatLng(routeController!
                                                          .pinnedLocationOnMap
                                                          .value
                                                          .latitude!, routeController!
                                                          .pinnedLocationOnMap
                                                          .value
                                                          .longitude!);

                                                  routeController!.addPoint(
                                                      Point(
                                                        id: routeController!.markers.length + 1,
                                                        placeHeader: routeController!
                                                            .pinnedLocationOnMap
                                                            .value
                                                            .placeHeader,
                                                        latitude: lastSelectedLatLng!.latitude,
                                                        longitude: lastSelectedLatLng!.longitude,
                                                      ), context
                                                  );
                                                  //routeController!.onBack();
                                                },
                                                color: Colors.blue,
                                                height: 40,
                                                width: double.infinity,
                                                child: Text(
                                                  routeController!.markers.isEmpty
                                                    ? 'Add first point'
                                                    : routeController!.markers.length < 2
                                                      ? 'Add second point'
                                                      : 'Add point number: ${routeController!.markers.length + 1}',

                                                  style: const TextStyle(
                                                      letterSpacing: 1,
                                                      fontSize: 16,
                                                      color: ThemeProvider.whiteColor,
                                                      fontFamily: 'bold'),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5,),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              child: MyElevatedButton(
                                                onPressed: routeController!.markers.length >= 2 ? () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => const RouteParams()),
                                                  );
                                                } : null,
                                                color: ThemeProvider.appColor,
                                                height: 40,
                                                width: double.infinity,
                                                child: Text(
                                                  routeController!.markers.length >= 2 ? 'Next'.tr : 'Add at least two points'.tr,
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
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Icon(
                                                Icons.search,
                                                size: 24,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                            Expanded(
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  hintText: "Enter your destination",
                                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                                  border: InputBorder.none,

                                                ),
                                                onChanged: (content) {
                                                  routeController!.onSearchChanged(content);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
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
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(
                                      height: 4,
                                      thickness: 4,
                                      color: Color(0xFFF8F8F8),
                                    ),
                                    routeController!.getList.isNotEmpty
                                        ? Container(
                                      decoration:
                                      const BoxDecoration(color: ThemeProvider.whiteColor),
                                      child: Column(
                                        children: [
                                          for (var item in routeController!.getList)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 15, vertical: 15),
                                              child: InkWell(
                                                onTap: () async {
                                                  panelController.close();
                                                  _newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(await routeController!.getLatLngFromAddress(
                                                      item.description.toString())));
                                                },
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.my_location,
                                                      size: 22,
                                                      color: Colors.black.withOpacity(0.6),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        item.description!,
                                                        style: const TextStyle(
                                                          fontSize: 17,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                    )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),)

                            ),
                            Positioned(
                              right: 0,
                              child: Obx(
                                    () => Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 30, 20, 0),
                                  child: InkWell(
                                    onTap: () {
                                      routeController!.isExpanded.value
                                          ? panelController.close()
                                          : routeController!.isMarkerSelected.value
                                            ? routeController!.removeMarkerSelection()
                                            : Navigator.pop(context);
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
                            ),
                          ],
                        );
                      },
                    );
                  },
              ),
            ),
    );
  }
}