import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../features/mobile_view/pages_mb/way_plan_mb/way_plan_detail_mb.dart';
import '../../pages/way_planning_page/way_planning_bloc.dart';
import '../../pages/way_planning_page/way_planning_detail_page.dart';
import '../../utils/app_const.dart';

class WayPlanningCardWidget extends StatefulWidget {
  int wayplanid;
  String tripId;
  List<dynamic> name;
  List<dynamic> zoneId;
  List<dynamic> userId;
  String fromDate;
  String toDate;
  String state;
  List<dynamic> leaderName;
  List<dynamic> hremployeelineList;
  WayPlanningCardWidget({
    Key? key,
    required this.wayplanid,
    required this.tripId,
    required this.name,
    required this.zoneId,
    required this.userId,
    required this.fromDate,
    required this.toDate,
    required this.state,
    required this.leaderName,
    required this.hremployeelineList,
  }) : super(key: key);

  @override
  State<WayPlanningCardWidget> createState() => _WayPlanningCardWidgetState();
}

class _WayPlanningCardWidgetState extends State<WayPlanningCardWidget> {
  final wayplanningBloc = WayPlanningBloc();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Slidable(
        actionPane: const SlidableBehindActionPane(),
        secondaryActions: [
          IconSlideAction(
            color: AppColors.appBarColor,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return WayPlanningDetailMB(
                  wayplanid: widget.wayplanid,
                  tripId: widget.tripId,
                  name: widget.name,
                  zoneId: widget.zoneId,
                  userId: widget.userId,
                  fromDate: widget.fromDate,
                  toDate: widget.toDate,
                  state: widget.state,
                  leaderName: widget.leaderName,
                );
              })).then((value) {
                setState(() {
                  wayplanningBloc
                      .getWayPlanningListData(name: ['name', 'ilike', '']);
                });
              });
            },
            iconWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.read_more,
                  size: 25,
                  color: Colors.white,
                ),
                Text(
                  "View Details",
                  style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 400.0 ? 18 : 12,
                      color: Colors.white),
                ),
              ],
            ),
          )
        ],
        child: Container(
          padding: const EdgeInsets.all(8),
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
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.tripId,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 200,
                          child: Text(
                            'Trip ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        const Text(
                          ':  ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.name[1],
                                    style: const TextStyle(color: Colors.black),
                                  )
                                ]))
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 200,
                          child: Text(
                            'Zone ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        const Text(
                          ':  ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.zoneId.isEmpty
                                        ? ''
                                        : widget.zoneId[1],
                                    style: const TextStyle(color: Colors.black),
                                  )
                                ]))
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 200,
                          child: Text(
                            'From Date ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        const Text(
                          ':  ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.fromDate,
                                    style: const TextStyle(color: Colors.black),
                                  )
                                ]))
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 200,
                          child: Text(
                            'To Date ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        const Text(
                          ':  ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.toDate,
                                    style: const TextStyle(color: Colors.black),
                                  )
                                ]))
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 200,
                          child: Text(
                            'Status ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        const Text(
                          ':  ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        Expanded(
                            flex: 2,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.state == 'draft'
                                        ? 'Draft'
                                        : widget.state == 'confirm'
                                            ? 'Confirmed'
                                            : 'Approved',
                                    style: const TextStyle(color: Colors.black),
                                  )
                                ]))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
