import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/trip_plan_schedule_ob.dart';
import '../../../pages/way_planning_page/schedule_page/schedule_create_page.dart';
import '../../../utils/app_const.dart';

class ScheduleCreateWidget extends StatefulWidget {
  int neworedit;
  int tripId;
  ScheduleCreateWidget({
    Key? key,
    required this.neworedit,
    required this.tripId,
  }) : super(key: key);

  @override
  State<ScheduleCreateWidget> createState() => ScheduleCreateWidgetState();
}

class ScheduleCreateWidgetState extends State<ScheduleCreateWidget> {
  final databaseHelper = DatabaseHelper();
  final slidableController = SlidableController();
  static List<TripPlanScheduleOb>? tripplanscheduleList = [];
  static List<dynamic> tripplanscheduleInt = [];
  static List<TripPlanScheduleOb>? tripplanscheduleListUpdate = [];
  static List<dynamic> tripplanscheduleDeleteList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transferData();
  }

  Future<void> transferData() async {
    tripplanscheduleListUpdate =
        await databaseHelper.getTripPlanScheduleListUpdate();
    for (var element in tripplanscheduleListUpdate!) {
      tripplanscheduleInt.add(element.id);
      print('HrEmployeeLineListIDs: ${element.id}');
    }
    if (widget.neworedit == 1) {
      print('TransferData');
      print('TripPlanId: ${widget.tripId}');
      tripplanscheduleList =
          await databaseHelper.insertTable2TableTripPlanSchedule();
      print('TripplanscheduleListLength: ${tripplanscheduleList?.length}');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.appBarColor,
                  // boxShadow: const[
                  //   BoxShadow(
                  //     offset: Offset(0,0),
                  //     blurRadius: 2,
                  //   )
                  // ],
                  // borderRadius: BorderRadius.circular(10)
                ),
                width: 130,
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return ScheduleCreatePage(
                            newOrEdit: widget.neworedit,
                            neworeditTPS: 0,
                            tripId: 0,
                            tripplanscheduleId: 0,
                            fromDate: '',
                            toDate: '',
                            locationId: 0,
                            locationName: '',
                            remark: '');
                      })).then((value) {
                        setState(() {});
                      });
                    },
                    child: const Text(
                      "Add a Schedule",
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: FutureBuilder<List<TripPlanScheduleOb>>(
                  future: databaseHelper.getTripPlanScheduleList(),
                  builder: (context, snapshot) {
                    tripplanscheduleList = snapshot.data;
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: tripplanscheduleList!.length,
                          itemBuilder: (context, i) {
                            print(
                                "trippscheduleListlength______________: ${tripplanscheduleList!.length}");
                            print(
                                "trippscheduleID: ${tripplanscheduleList![i].id}");

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Slidable(
                                  controller: slidableController,
                                  actionPane: const SlidableBehindActionPane(),
                                  actions: [
                                    IconSlideAction(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return ScheduleCreatePage(
                                              newOrEdit: widget.neworedit,
                                              neworeditTPS: 1,
                                              tripId: widget.tripId,
                                              tripplanscheduleId:
                                                  tripplanscheduleList![i].id,
                                              fromDate: tripplanscheduleList![i]
                                                  .fromDate,
                                              toDate: tripplanscheduleList![i]
                                                  .toDate,
                                              locationId:
                                                  tripplanscheduleList![i]
                                                      .locationId,
                                              locationName:
                                                  tripplanscheduleList![i]
                                                      .locationName,
                                              remark: tripplanscheduleList![i]
                                                  .remark);
                                        })).then((value) {
                                          setState(() {});
                                        });
                                      },
                                      color: Colors.yellow,
                                      iconWidget: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.edit,
                                            size: 25,
                                          ),
                                          Text(
                                            "Edit",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  secondaryActions: [
                                    IconSlideAction(
                                      onTap: () async {
                                        await databaseHelper
                                            .deleteTripPlanScheduleManul(
                                                tripplanscheduleList![i].id);
                                        tripplanscheduleDeleteList
                                            .add(tripplanscheduleList![i].id);
                                        setState(() {});
                                      },
                                      color: Colors.red,
                                      iconWidget: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.delete,
                                            size: 25,
                                          ),
                                          Text(
                                            "Delete",
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      // borderRadius:
                                      //     BorderRadius.circular(10),
                                      // boxShadow: const [
                                      //   BoxShadow(
                                      //     color: Colors.black,
                                      //     offset: Offset(0, 0),
                                      //     blurRadius: 2,
                                      //   )
                                      // ]
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                            text: TextSpan(children: [
                                          const TextSpan(
                                            text: 'From Date: ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          TextSpan(
                                              text: tripplanscheduleList![i]
                                                  .fromDate,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18))
                                        ])),
                                        RichText(
                                            text: TextSpan(children: [
                                          const TextSpan(
                                            text: 'To Date: ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          TextSpan(
                                              text: tripplanscheduleList![i]
                                                  .toDate,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18))
                                        ])),
                                        RichText(
                                            text: TextSpan(children: [
                                          const TextSpan(
                                            text: 'location: ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          TextSpan(
                                              text: tripplanscheduleList![i]
                                                  .locationName,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18))
                                        ])),
                                        RichText(
                                            text: TextSpan(children: [
                                          const TextSpan(
                                            text: 'Remark: ',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          TextSpan(
                                              text: tripplanscheduleList![i]
                                                  .remark
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18))
                                        ])),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            );
                          });
                    } else {
                      print(snapshot.hasError.toString());
                      return Center(
                        child: Image.asset(
                          'assets/gifs/three_circle_loading.gif',
                          width: 150,
                          height: 150,
                        ),
                      );
                    }
                  }),
            )
          ],
        ));
  }
}
