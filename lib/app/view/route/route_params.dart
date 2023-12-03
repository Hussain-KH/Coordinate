import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handyman/app/controller/route_controller.dart';

import '../../util/theme.dart';
import '../../widget/elevated_button.dart';

class RouteParams extends StatefulWidget {
  const RouteParams({super.key});

  @override
  State<RouteParams> createState() => _RouteParamsState();
}

class _RouteParamsState extends State<RouteParams> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeProvider.appColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Text(
          'Route Config'.tr,
          style: ThemeProvider.titleStyle,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ThemeProvider.whiteColor,
          ),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: const SelectDaysWidget(),
    );
  }
}

class SelectDaysWidget extends StatefulWidget {
  const SelectDaysWidget({super.key});

  @override
  State<SelectDaysWidget> createState() => _SelectDaysWidgetState();
}

class _SelectDaysWidgetState extends State<SelectDaysWidget> {
  List<String> daysList = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  RouteController? routeController;

  @override
  void initState() {
    routeController = Get.find<RouteController>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Select Days'.tr,
                          style: const TextStyle(
                              letterSpacing: 1, fontSize: 16, fontFamily: 'bold'),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          7,
                              (index) => GestureDetector(
                            onTap: () {
                              routeController!.selectDays(index);
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: routeController!.selectedDays[index]
                                    ? ThemeProvider.appColor
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  daysList[index],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Select Time'.tr,
                          style: const TextStyle(
                              letterSpacing: 1, fontSize: 16, fontFamily: 'bold'),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                routeController!.selectStartTime(context),
                            child: routeController!.startingTime.value == null
                                ? const Text(
                              'Start Time',
                              style: TextStyle(
                                  color: ThemeProvider.appColor,
                                  fontWeight: FontWeight.bold),
                            )
                                : Text(
                              'Start: ${routeController!.startingTime.value!.format(context)}',
                              style: const TextStyle(
                                  color: ThemeProvider.appColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Select Vehicle'.tr,
                          style: const TextStyle(
                              letterSpacing: 1, fontSize: 16, fontFamily: 'bold'),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              routeController!.selectedVehicle.value = 'Car';
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 48,
                                  color: routeController!.selectedVehicle.value ==
                                      'Car'
                                      ? ThemeProvider.appColor
                                      : Colors.black,
                                ),
                                const SizedBox(height: 4),
                                const Text('Car'),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              routeController!.selectedVehicle.value = 'Bus';
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.directions_bus,
                                  size: 48,
                                  color: routeController!.selectedVehicle.value ==
                                      'Bus'
                                      ? ThemeProvider.appColor
                                      : Colors.black,
                                ),
                                const SizedBox(height: 4),
                                const Text('Bus'),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              routeController!.selectedVehicle.value = 'Public';
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.bus_alert_outlined,
                                  size: 48,
                                  color: routeController!.selectedVehicle.value ==
                                      'Public'
                                      ? ThemeProvider.appColor
                                      : Colors.black,
                                ),
                                const SizedBox(height: 4),
                                const Text('Public'),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              routeController!.selectedVehicle.value = 'Walking';
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.directions_walk,
                                  size: 48,
                                  color: routeController!.selectedVehicle.value ==
                                      'Walking'
                                      ? ThemeProvider.appColor
                                      : Colors.black,
                                ),
                                const SizedBox(height: 4),
                                const Text('Walking'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: MyElevatedButton(
                    onPressed: () {
                      routeController!.saveRoute();
                    },
                    color: ThemeProvider.appColor,
                    height: 45,
                    width: double.infinity,
                    child: Text(
                      'Save'.tr,
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
    );
  }
}
