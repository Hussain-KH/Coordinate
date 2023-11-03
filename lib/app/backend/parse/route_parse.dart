import 'package:handyman/app/backend/api/api.dart';
import 'package:handyman/app/helper/shared_pref.dart';

class RouteParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  RouteParser(
      {required this.sharedPreferencesManager, required this.apiService});
}