/*
  Authors : initappz (Rahul Jograna)
  Website : https://initappz.com/
  App Name : Handy Service Full App Flutter V2
  This App Template Source code is licensed as per the
  terms found in the Website https://initappz.com/license
  Copyright and Good Faith Purchasers © 2023-present initappz.
*/
import 'package:get/get.dart';
import 'package:handyman/app/controller/add_card_controller.dart';

class AddCardBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
      () => AddCardController(parser: Get.find()),
    );
  }
}
