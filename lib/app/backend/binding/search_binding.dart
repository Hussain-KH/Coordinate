/*
  Authors : initappz (Rahul Jograna)
  Website : https://initappz.com/
  App Name : Handy Service Full App Flutter V2
  This App Template Source code is licensed as per the
  terms found in the Website https://initappz.com/license
  Copyright and Good Faith Purchasers © 2023-present initappz.
*/
import 'package:get/get.dart';
import 'package:handyman/app/controller/search_controller.dart';

class SearchBindings extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => AppSearchController(parser: Get.find()),
    );
  }
}
