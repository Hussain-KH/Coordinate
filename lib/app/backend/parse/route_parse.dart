import 'package:handyman/app/backend/api/api.dart';
import 'package:handyman/app/helper/shared_pref.dart';
import 'package:get/get.dart';
import 'package:handyman/app/util/constant.dart';

class RouteParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  RouteParser(
      {required this.sharedPreferencesManager, required this.apiService});

  Future<Response> getPlacesList(url) async {
    var response = await apiService.getOther(url);
    return response;
  }

  Future<Response> saveRoute(var body) async {
    var response = await apiService.postPrivate(AppConstants.saveRoute, body,
        sharedPreferencesManager.getString('token') ?? '');
    return response;
  }

  String getUID() {
    return sharedPreferencesManager.getString('uid') ?? '';
  }
}