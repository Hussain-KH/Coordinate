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
  bool _isExpanded = false;
  final panelController = PanelController();

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    userCurrentPosition = position;
    pickUpMarker = await getMarker("location-pin");
    await pickOriginPositionOnMap(LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude));

    setState(() {
      _initialPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      onCameraMoveEndLatLng = _initialPosition;
      _cameraPosition = CameraPosition(target: _initialPosition as LatLng, zoom: 14.5);
      _newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition!));
    });
  }

  Future<Uint8List> getMarker(String fileName) async {
    ByteData byteData = await DefaultAssetBundle.of(context).load("assets/images/$fileName.png");
    return byteData.buffer.asUint8List();
  }

  Future<void> pickOriginPositionOnMap(LatLng position) async {
    String placeName = "";
    String placeStreet = "";
    String locality = "";
    String subLocality = "";
    List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    if(placeMarks.isNotEmpty) {
      print(placeMarks[1]);
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
                myLocationButtonEnabled: true,
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
              Obx(
                () => Center(
                  child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500), // Animation duration
                  child: routeController!.isPinMarkerVisible.value
                    ? Container(
                      width: 8.0, // Adjust the size of the dot as needed
                      height: 8.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black, // You can set the color you prefer
                      ),
                    )
                    : Image.memory(
                        pickUpMarker,
                        height: 60,
                        width: 60,
                        alignment: Alignment.center,
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          return Transform.translate(offset: const Offset(0, -25), child: child,);
                        },
                      ),
                  ),
                ),
              ),
              // Positioned(
              //   bottom: 0.0,
              //   right: 0.0,
              //   left: 0.0,
              //   child: Container(
              //     decoration: const BoxDecoration(
              //       borderRadius: BorderRadius.only(
              //         topLeft: Radius.circular(35.0), // Adjust the value as needed
              //         topRight: Radius.circular(35.0), // Adjust the value as needed
              //       ),
              //       color: Colors.white,
              //     ),
              //     height: 155,
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              //       child: Column(
              //         mainAxisSize: MainAxisSize.max,
              //         children: [
              //           const SizedBox(height: 4.0),
              //           InkWell(
              //             onTap: () {
              //               setState(() {
              //                 _isExpanded = !_isExpanded;
              //               });
              //             },
              //             child: Row(
              //               children: [
              //                 Container(
              //                   decoration: BoxDecoration(
              //                     shape: BoxShape.circle,
              //                     color: Colors.grey.withOpacity(0.15),
              //                   ),
              //                   child: const Padding(
              //                     padding: EdgeInsets.all(11.0),
              //                     child: Icon(Icons.search, color: ThemeProvider.appColor, size: 30,),
              //                   ),
              //                 ),
              //                 const SizedBox(width: 10.0,),
              //                 Obx(
              //                       () => Expanded(
              //                     child: Column(
              //                       crossAxisAlignment: CrossAxisAlignment.start,
              //                       children: [
              //                         Text(
              //                           routeController!.pinnedLocationOnMap.value.placeHeader!.toString(),
              //                           overflow: TextOverflow.ellipsis,
              //                           style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
              //                         ),
              //                         Text(
              //                           routeController!.pinnedLocationOnMap.value.placeDetails!.toString(),
              //                           overflow: TextOverflow.ellipsis,
              //                           maxLines: 2,
              //                           style: const TextStyle(fontSize: 14, color: Colors.grey),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           const Expanded(child: SizedBox()),
              //           Padding(
              //             padding: const EdgeInsets.symmetric(horizontal: 8.0),
              //             child: MyElevatedButton(
              //               onPressed: () {
              //                 routeController!.addPoint(
              //                   Point(
              //                       placeHeader: routeController!.pinnedLocationOnMap.value.placeHeader,
              //                       latitude: routeController!.pinnedLocationOnMap.value.latitude,
              //                       longitude: routeController!.pinnedLocationOnMap.value.longitude
              //                   ),
              //                 );
              //                 routeController!.onBack();
              //               },
              //               color: ThemeProvider.appColor,
              //               height: 45,
              //               width: double.infinity,
              //               child: Text(
              //                 'Pick place on map'.tr,
              //                 style: const TextStyle(
              //                     letterSpacing: 1,
              //                     fontSize: 16,
              //                     color: ThemeProvider.whiteColor,
              //                     fontFamily: 'bold'),
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              SlidingUpPanel(
                controller: panelController,
                minHeight: 200.0, // Minimum panel height
                maxHeight: MediaQuery.of(context).size.height,
                onPanelSlide: (x) {
                  print(x);
                    routeController!.isExpanded.value = true;
                },
                onPanelClosed: () {
                  routeController!.isExpanded.value = false;
                },
                body: const Center(),
                panel: Obx(
                        () => routeController!.isExpanded.value
                            ? Text('dsdsd')
                            : Text('data'),
                ),
              ),
              Positioned(
                bottom: 15.0,
                right: 10.0,
                left: 10.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: MyElevatedButton(
                    onPressed: () {
                      routeController!.addPoint(
                        Point(
                            placeHeader: routeController!.pinnedLocationOnMap.value.placeHeader,
                            latitude: routeController!.pinnedLocationOnMap.value.latitude,
                            longitude: routeController!.pinnedLocationOnMap.value.longitude
                        ),
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
              ),
            ],
          ),
        ),
      );
  }
}

