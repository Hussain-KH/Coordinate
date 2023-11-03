import 'package:get/get.dart';
import '../../controller/route_controller.dart';

class RouteBinding extends Bindings {
  @override
  void dependencies() async {
    Get.lazyPut(
          () => RouteController(parser: Get.find()),
    );
  }
}