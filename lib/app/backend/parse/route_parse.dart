import 'package:handyman/app/backend/api/api.dart';
import 'package:handyman/app/helper/shared_pref.dart';
import 'package:get/get.dart';

class RouteParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  RouteParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> getPlacesList(url) async {
    var response = await apiService.getOther(url);
    return response;
  }
}