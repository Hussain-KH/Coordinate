import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

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
      body: SelectDaysWidget(),
    );
  }
}

class SelectDaysWidget extends StatefulWidget {
  const SelectDaysWidget({super.key});

  @override
  _SelectDaysWidgetState createState() => _SelectDaysWidgetState();
}

class _SelectDaysWidgetState extends State<SelectDaysWidget> {
  List<bool> selectedDays = [false, false, false, false, false, false, false];
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String selectedVehicle = '';


  Future<void> _selectStartTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != startTime) {
      setState(() {
        startTime = pickedTime;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && pickedTime != endTime) {
      setState(() {
        endTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  setState(() {
                    selectedDays[index] = !selectedDays[index];
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selectedDays[index] ? ThemeProvider.appColor : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      getDayAbbreviation(index),
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
            children: [
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _selectStartTime(context),
                  child: startTime == null
                      ? const Text(
                          'Start Time',
                          style: TextStyle(color: ThemeProvider.appColor, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          'Start: ${startTime!.format(context)}',
                          style: const TextStyle(color: ThemeProvider.appColor, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _selectEndTime(context),
                  child: endTime == null
                      ? const Text(
                          'End Time',
                          style: TextStyle(color: ThemeProvider.appColor, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          'End: ${endTime!.format(context)}',
                          style: const TextStyle(color: ThemeProvider.appColor, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(
                width: 15,
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
                  setState(() {
                    selectedVehicle = 'Car';
                  });
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_car,
                      size: 48,
                      color: selectedVehicle == 'Car' ? ThemeProvider.appColor : Colors.black,
                    ),
                    const SizedBox(height: 4),
                    const Text('Car'),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    selectedVehicle = 'Bus';
                  });
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.directions_bus,
                      size: 48,
                      color: selectedVehicle == 'Bus' ? ThemeProvider.appColor : Colors.black,
                    ),
                    const SizedBox(height: 4),
                    const Text('Bus'),
                  ],
                ),
              ),

            ],
          ),

          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: MyElevatedButton(
              onPressed: () {

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

  String getDayAbbreviation(int index) {
    switch (index) {
      case 0:
        return 'M';
      case 1:
        return 'T';
      case 2:
        return 'W';
      case 3:
        return 'T';
      case 4:
        return 'F';
      case 5:
        return 'S';
      case 6:
        return 'S';
      default:
        return '';
    }
  }
}
