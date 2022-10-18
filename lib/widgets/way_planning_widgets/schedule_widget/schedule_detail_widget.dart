import 'package:flutter/material.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/trip_plan_schedule_ob.dart';

class TripPlanScheduleDetailWidget extends StatefulWidget {
  int wayplanId;
  List<dynamic> tirpplanscheduleList;
  TripPlanScheduleDetailWidget({
    Key? key,
    required this.wayplanId,
    required this.tirpplanscheduleList,
  }) : super(key: key);

  @override
  State<TripPlanScheduleDetailWidget> createState() =>
      _TripPlanScheduleDetailWidgetState();
}

class _TripPlanScheduleDetailWidgetState
    extends State<TripPlanScheduleDetailWidget> {
  final _databaseHelper = DatabaseHelper();
  List<TripPlanScheduleOb>? tripplanscheduleDB = [];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<List<TripPlanScheduleOb>>(
          future: _databaseHelper.getTripPlanScheduleListUpdate(),
          builder: (context, snapshot) {
            Widget scheduleWidget = const SliverToBoxAdapter();
            if (snapshot.hasData) {
              tripplanscheduleDB = snapshot.data;
              scheduleWidget = SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    print('TriplineId: ${tripplanscheduleDB!.length}');
                    print('TripLine: ${tripplanscheduleDB![i].tripId}');
                    return tripplanscheduleDB![i].tripId != widget.wayplanId
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  // borderRadius: BorderRadius.circular(10),
                                  // boxShadow: const [
                                  //   BoxShadow(
                                  //     color: Colors.black,
                                  //     offset: Offset(0, 0),
                                  //     blurRadius: 2,
                                  //   )
                                  // ]
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          text: tripplanscheduleDB![i].fromDate,
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
                                          text: tripplanscheduleDB![i].toDate,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18))
                                    ])),
                                    RichText(
                                        text: TextSpan(children: [
                                      const TextSpan(
                                        text: 'Location: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      TextSpan(
                                          text: tripplanscheduleDB![i]
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
                                          text: tripplanscheduleDB![i].remark,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18))
                                    ])),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                  },
                  childCount: tripplanscheduleDB!.length,
                ),
              );
            } else {
              scheduleWidget = SliverToBoxAdapter(
                child: Center(
                  child: Image.asset(
                    'assets/gifs/three_circle_loading.gif',
                    width: 150,
                    height: 150,
                  ),
                ),
              );
            }
            return CustomScrollView(
              slivers: [
                scheduleWidget,
                const SliverToBoxAdapter(
                    child: SizedBox(
                  height: 100,
                ))
              ],
            );
          }),
    );
  }
}
