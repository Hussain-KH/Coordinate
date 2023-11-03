/*
  Authors : initappz (Rahul Jograna)
  Website : https://initappz.com/
  App Name : Handy Service Full App Flutter V2
  This App Template Source code is licensed as per the
  terms found in the Website https://initappz.com/license
  Copyright and Good Faith Purchasers © 2023-present initappz.
*/
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../backend/model/point_model.dart';
import '../backend/parse/route_parse.dart';


class RouteController extends GetxController implements GetxService {
  final RouteParser parser;
  RouteController({required this.parser});

  List<Point> points = [];
  var pinnedLocationOnMap = Point().obs;
  var isPinMarkerVisible = false.obs;
  var isExpanded = false.obs;

  void addPoint(Point point) {
    points.add(point);
    update();
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
}
