import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handyman/app/controller/route_controller.dart';
import 'package:handyman/app/view/route/select_route_from_map.dart';

import '../../util/theme.dart';

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({Key? key}) : super(key: key);

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RouteController>(builder: (value) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: ThemeProvider.appColor,
          elevation: 0,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: Text(
            'Add Route'.tr,
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
        body: Container(
          padding: const EdgeInsets.all(12),
          // child: Column(
          //   children: [
          //     Expanded(
          //       child: ReorderableListView(
          //         proxyDecorator: (Widget child, int index, Animation<double> animation) {
          //           return Material(
          //             elevation: 3.0,
          //             shadowColor: ThemeProvider.appColor,
          //             borderRadius: BorderRadius.circular(15),
          //             child: SizeTransition(
          //               sizeFactor: animation,
          //               child: child,
          //             ),
          //           );
          //         },
          //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //         onReorder: (oldIndex, newIndex) {
          //           int targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
          //           value.reorderRoutes(oldIndex, targetIndex);
          //         },
          //         children: [
          //           for (int index = 0; index < value.points.length; index++)
          //           Card(
          //             key: ValueKey(value.points[index]),
          //             child: ListTile(
          //               onTap: () {},
          //               visualDensity: const VisualDensity(vertical: -3),
          //               leading: const Icon(Icons.location_on_outlined),
          //               minLeadingWidth: 0,
          //               title: heading4(value.points[index].placeHeader),
          //               trailing: const Icon(Icons.drag_handle),
          //             ),
          //           )
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SelectLocationFromMap()),
            );
          },
          shape: const CircleBorder(),
          backgroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    });
  }
}
