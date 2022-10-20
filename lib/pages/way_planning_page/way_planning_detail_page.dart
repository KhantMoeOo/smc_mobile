import 'dart:math';

import 'package:flutter/material.dart';
import '../../dbs/database_helper.dart';
import '../../dbs/sharef.dart';
import '../../obs/hr_employee_line_ob.dart';
import '../../obs/response_ob.dart';
import '../../obs/trip_plan_delivery_ob.dart';
import '../../obs/trip_plan_schedule_ob.dart';
import '../../widgets/drawer_widget.dart';
import '../../widgets/way_planning_widgets/delivery_widget/delivery_detail_widget.dart';
import '../../widgets/way_planning_widgets/sale_team_widget/sale_team_detail_widget.dart';
import '../../widgets/way_planning_widgets/schedule_widget/schedule_detail_widget.dart';
import '../home_page/home_page.dart';
import '../quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import 'delivery_page/delivery_bloc.dart';
import 'sale_team_page/sale_team_bloc.dart';
import 'schedule_page/schedule_bloc.dart';
import 'way_planning_create_page.dart';
import 'way_planning_delete_bloc.dart';
import 'way_planning_page.dart';

class WayPlanningDetailPage extends StatefulWidget {
  int wayplanid;
  String tripId;
  List<dynamic> name;
  List<dynamic> zoneId;
  List<dynamic> userId;
  String fromDate;
  String toDate;
  String state;
  List<dynamic> leaderName;
  WayPlanningDetailPage({
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
  }) : super(key: key);

  @override
  State<WayPlanningDetailPage> createState() => _WayPlanningDetailPageState();
}

class _WayPlanningDetailPageState extends State<WayPlanningDetailPage>
    with SingleTickerProviderStateMixin {
  final saleteamBloc = SaleTeamBloc();
  final deliveryBloc = DeliveryBloc();
  final scheduleBloc = ScheduleBloc();
  final saleorderlineBloc = SaleOrderLineBloc();
  final wayplanDeleteBloc = DeleteWayPlanBloc();
  final databaseHelper = DatabaseHelper();
  late TabController _tabController;
  List<dynamic> hremployeelineList = [];
  List<dynamic> hremployeelineListUpdate = [];

  List<dynamic> tripplandeliveryList = [];

  List<dynamic> tripplanscheduleList = [];

  bool isDelete = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('WayPlanId: ${widget.wayplanid}');
    _tabController = TabController(length: 3, vsync: this);
    saleteamBloc.getSaleTeamListData();
    saleteamBloc.getSaleTeamListStream().listen(getHrEmployeeLineListListen);
    deliveryBloc.getDeliveryListData();
    deliveryBloc.getDeliveryListStream().listen(getTipPlanDeliveryListListen);
    scheduleBloc.getScheduleListData();
    scheduleBloc.getScheduleListStream().listen(getTipPlanScheduleListListen);
    wayplanDeleteBloc.deleteWayPlanStream().listen(deleteRecordListen);
    wayplanDeleteBloc
        .deleteHrEmployeeLineStream()
        .listen(deleteHrEmployeeLineListen);
    saleorderlineBloc
        .waitingproductlineListStream()
        .listen(waitingDeleteOrNotListen);
  }

  @override
  void dispose() {
    super.dispose();
    saleorderlineBloc.dispose();
    saleteamBloc.dispose();
    deliveryBloc.dispose();
    scheduleBloc.dispose();
    wayplanDeleteBloc.dispose();
  }

  Future<void> getHrEmployeeLineListFromDB() async {
    print('Worked');
    for (var element in hremployeelineList) {
      if (element['trip_line'] != false) {
        if (element['trip_line'][0] == widget.wayplanid) {
          print('FoundHEL: ${element['id']}');
          hremployeelineListUpdate.add(element['id']);
          final hremployeelineOb = HrEmployeeLineOb(
              id: element['id'],
              tripLine:
                  element['trip_line'] == false ? -1 : element['trip_line'][0],
              empName: element['emp_name'][1],
              empId: element['emp_name'][0],
              departmentId: element['department_id'] == false
                  ? 0
                  : element['department_id'][0],
              departmentName: element['department_id'] == false
                  ? ''
                  : element['department_id'][1],
              jobId: element['job_id'] == false ? 0 : element['job_id'][0],
              jobName: element['job_id'] == false ? '' : element['job_id'][1],
              responsible: element['mr_responsible'] == false ? 0 : 1);
          await databaseHelper.insertHrEmployeeLineUpdate(hremployeelineOb);
        }
      }
    }
    setState(() {});
  }

  Future<void> getTripPlanDeliveryListFromDB() async {
    print('Worked');
    for (var element in tripplandeliveryList) {
      if (element['trip_id'] != false) {
        if (element['trip_id'][0] == widget.wayplanid) {
          print('FoundTPD: ${element['id']}');
          final tripplandeliveryOb = TripPlanDeliveryOb(
              id: element['id'],
              tripline:
                  element['trip_id'] == false ? -1 : element['trip_id'][0],
              teamId: element['team_id'] == false ? 0 : element['team_id'][0],
              teamName:
                  element['team_id'] == false ? '' : element['team_id'][1],
              assignPersonId: element['assign_person'] == false
                  ? 0
                  : element['assign_person'][0],
              assignPerson: element['assign_person'] == false
                  ? ''
                  : element['assign_person'][1],
              zoneId: element['zone_id'] == false ? 0 : element['zone_id'][0],
              zoneName:
                  element['zone_id'] == false ? '' : element['zone_id'][1],
              invoiceId:
                  element['invoice_id'] == false ? 0 : element['invoice_id'][0],
              invoiceName: element['invoice_id'] == false
                  ? ''
                  : element['invoice_id'][1],
              orderId:
                  element['order_id'] == false ? 0 : element['order_id'][0],
              orderName:
                  element['order_id'] == false ? '' : element['order_id'][1],
              state: element['state'] == false ? '' : element['state'],
              invoiceStatus: element['invoice_status'] == false
                  ? ''
                  : element['invoice_status'],
              remark: element['remark'] == false ? '' : element['remark']);
          await databaseHelper.insertTripPlanDeliveryUpdate(tripplandeliveryOb);
        }
      }
    }
    setState(() {});
  }

  Future<void> getTripPlanScheduleListFromDB() async {
    print('Worked');
    for (var element in tripplanscheduleList) {
      if (element['trip_id'] != false) {
        if (element['trip_id'][0] == widget.wayplanid) {
          print('FoundTPS: ${element['id']}');
          final tripplanscheduleOb = TripPlanScheduleOb(
              id: element['id'],
              tripId: element['trip_id'] == false ? -1 : element['trip_id'][0],
              fromDate:
                  element['from_date'] == false ? '' : element['from_date'],
              toDate: element['to_date'] == false ? '' : element['to_date'],
              locationId: element['location_id'] == false
                  ? 0
                  : element['location_id'][0],
              locationName: element['location_id'] == false
                  ? ''
                  : element['location_id'][1],
              remark: element['remark'] == false ? '' : element['remark']);
          await databaseHelper.insertTripPlanScheduleUpdate(tripplanscheduleOb);
        }
      }
    }
    setState(() {});
  }

  void getHrEmployeeLineListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      hremployeelineList = responseOb.data;
      print("Herrrrrrrrrrr: ${hremployeelineList.length}");
      getHrEmployeeLineListFromDB();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoHrEmployeeLineList");
    }
  } // listen to get HrEmployeeLine List

  void getTipPlanDeliveryListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      tripplandeliveryList = responseOb.data;
      print("TripPlanDeliveryLength: ${tripplandeliveryList.length}");
      getTripPlanDeliveryListFromDB();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoTripPlanDeliveryList");
    }
  } // listen to get TripPlanDelivery List

  void getTipPlanScheduleListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      tripplanscheduleList = responseOb.data;
      print("TripPlanScheduleLength: ${tripplanscheduleList.length}");
      getTripPlanScheduleListFromDB();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoTripPlanScheduleList");
    }
  } // listen to get TripPlanSchedule List

  void deleteRecord() async {
    setState(() {
      isDelete = true;
    });
    Navigator.of(context).pop();
    await wayplanDeleteBloc.deleteWayPlanData(widget.wayplanid);
  }

  void deleteRecordListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      if (hremployeelineList.isNotEmpty) {
        for (var element in hremployeelineList) {
          if (element['trip_line'] != false) {
            if (element['trip_line'][0] == widget.wayplanid) {
              print('HELID: ${element['id']}');
              wayplanDeleteBloc.deleteHrEmployeeLineData(element['id']);
            }
          }
        }
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return WayPlanningListPage();
      }), (route) => false);
      await databaseHelper.deleteAllHrEmployeeLine();
      await databaseHelper.deleteAllHrEmployeeLineUpdate();
      await databaseHelper.deleteAllSaleOrderLine();
      await databaseHelper.deleteAllSaleOrderLineUpdate();
      await databaseHelper.deleteAllTripPlanDelivery();
      await databaseHelper.deleteAllTripPlanDeliveryUpdate();
      await databaseHelper.deleteAllTripPlanSchedule();
      await databaseHelper.deleteAllTripPlanScheduleUpdate();
      await SharefCount.clearCount();
    } else {
      print('Error in Delete Record');
    }
  }

  void deleteHrEmployeeLineListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Success Sale Team Delete');
    } else {
      print('error in Sale Team Delete');
    }
  }

  void waitingDeleteOrNotListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return WayPlanningListPage();
      }), (route) => false);
    } else {
      print('Error in waiting Delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResponseOb>(
        stream: saleteamBloc.getSaleTeamListStream(),
        initialData: ResponseOb(msgState: MsgState.loading),
        builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
          ResponseOb? responseOb = snapshot.data;
          if (responseOb?.msgState == MsgState.loading) {
            return Container(
                color: Colors.white,
                child: Center(
                  child: Image.asset(
                    'assets/gifs/loading.gif',
                    width: 100,
                    height: 100,
                  ),
                ));
          } else if (responseOb?.msgState == MsgState.error) {
            return const Center(child: Text('Error'));
          } else {
            return Stack(
              children: [
                WillPopScope(
                  onWillPop: () async {
                    await databaseHelper.deleteAllHrEmployeeLineUpdate();
                    await databaseHelper.deleteAllTripPlanDeliveryUpdate();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) {
                      return WayPlanningListPage();
                    }), (route) => false);
                    // DrawerWidgetState.pageController.jumpToPage(1);
                    return true;
                  },
                  child: Scaffold(
                    backgroundColor: Colors.grey[200],
                    appBar: AppBar(
                      backgroundColor: Color.fromARGB(255, 12, 41, 92),
                      title: Text(widget.tripId),
                    ),
                    body: Stack(
                      children: [
                        CustomScrollView(slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(8),
                            sliver: SliverList(
                                delegate: SliverChildListDelegate([
                              Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.tripId,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 200,
                                            child: Text(
                                              'Trip ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          const Text(
                                            ':  ',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.name[1],
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black),
                                                    )
                                                  ]))
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 200,
                                            child: Text(
                                              'Zone ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          const Text(
                                            ':  ',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.zoneId.isEmpty
                                                          ? ''
                                                          : widget.zoneId[1],
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black),
                                                    )
                                                  ]))
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 200,
                                            child: Text(
                                              'From Date ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          const Text(
                                            ':  ',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.fromDate,
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black),
                                                    )
                                                  ]))
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            width: 200,
                                            child: Text(
                                              'To Date ',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          const Text(
                                            ':  ',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      widget.toDate,
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black),
                                                    )
                                                  ]))
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ))
                            ])),
                          ),
                          SliverFillRemaining(
                              child: Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: TabBar(
                                    unselectedLabelColor: Colors.black,
                                    indicator: const BoxDecoration(
                                      color: Color.fromARGB(255, 12, 41, 92),
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    labelColor: Colors.white,
                                    controller: _tabController,
                                    tabs: const [
                                      Tab(
                                        height: 50,
                                        child: Text("Sale Team"),
                                      ),
                                      Tab(
                                        height: 50,
                                        child: Text("Schedule"),
                                      ),
                                      Tab(
                                        height: 50,
                                        child: Text("Delivery"),
                                      ),
                                    ]),
                              ),
                              Expanded(
                                child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      SaleTeamDetailWidget(
                                          wayplanId: widget.wayplanid,
                                          leaderName: widget.leaderName.isEmpty
                                              ? '-'
                                              : widget.leaderName[1],
                                          hremployeelineList:
                                              hremployeelineList),
                                      TripPlanScheduleDetailWidget(
                                          wayplanId: widget.wayplanid,
                                          tirpplanscheduleList:
                                              tripplanscheduleList),
                                      DeliveryDetailWidget(
                                          wayplanId: widget.wayplanid,
                                          tripplandeliveryList:
                                              tripplandeliveryList)
                                    ]),
                              ),
                            ],
                          )),
                        ]),
                        // Positioned(
                        //     bottom: 20,
                        //     left: MediaQuery.of(context).size.width/5,
                        //             right: MediaQuery.of(context).size.width/5,
                        //     child: Container(
                        //       padding: const EdgeInsets.only(top: 5, bottom:5),
                        //         decoration: BoxDecoration(
                        //           boxShadow: const [
                        //             BoxShadow(
                        //                 color: Colors.grey,
                        //                 blurRadius: 4,
                        //                 offset: Offset(0, 2))
                        //           ],
                        //           borderRadius: BorderRadius.circular(20),
                        //           color: Colors.white,
                        //         ),
                        //         height: 70,
                        //         child: Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceAround,
                        //           children: [
                        //             TextButton(
                        //               onPressed: () {
                        //                 Navigator.of(context).push(
                        //                     MaterialPageRoute(
                        //                         builder: ((context) {
                        //                   return WayPlanningCreatePage(
                        //                     neworedit: 1,
                        //                     tripId: widget.wayplanid,
                        //                     tripSeq: widget.tripId,
                        //                     tripconfigList: widget.name,
                        //                     zoneList: widget.zoneId,
                        //                     userList: widget.userId,
                        //                     fromDate: widget.fromDate,
                        //                     toDate: widget.toDate,
                        //                     leaderId: widget.leaderName,
                        //                     hremployeelineList:
                        //                         hremployeelineList,
                        //                   );
                        //                 })));
                        //               },
                        //               child: Column(children: const [
                        //                 Icon(Icons.edit, color: Colors.yellow,),Text("Edit",style: TextStyle(color: Colors.black),)
                        //               ]),
                        //             ),
                        //             TextButton(
                        //                 onPressed: () {
                        //                   Navigator.of(context).push(
                        //                       MaterialPageRoute(
                        //                           builder: (context) {
                        //                     return WayPlanningCreatePage(
                        //                         neworedit: 0,
                        //                         tripId: 0,
                        //                         tripSeq: '',
                        //                         tripconfigList: [],
                        //                         zoneList: [],
                        //                         userList: [],
                        //                         fromDate: '',
                        //                         toDate: '',
                        //                         leaderId: [],
                        //                         hremployeelineList: []);
                        //                   }));
                        //                 },
                        //                 child: Column(children: const [
                        //                 Icon(Icons.add, color: Colors.green,),Text("Create",style: TextStyle(color: Colors.black),)
                        //               ]),),
                        //             TextButton(
                        //               onPressed: () {
                        //                 showDialog(
                        //                     context: context,
                        //                     builder: (context) {
                        //                       return AlertDialog(
                        //                         title: const Text(
                        //                             "Are you sure you want to Delete?"),
                        //                         actions: [
                        //                           TextButton(
                        //                               onPressed: () {
                        //                                 Navigator.of(context)
                        //                                     .pop();
                        //                               },
                        //                               child:
                        //                                   const Text("Cancel")),
                        //                           TextButton(
                        //                               style:
                        //                                   TextButton.styleFrom(
                        //                                 backgroundColor:
                        //                                     Colors.red,
                        //                               ),
                        //                               onPressed: deleteRecord,
                        //                               child: const Text(
                        //                                 "Delete",
                        //                                 style: TextStyle(
                        //                                     color:
                        //                                         Colors.white),
                        //                               ))
                        //                         ],
                        //                       );
                        //                     }).then((value) {
                        //                   setState(() {});
                        //                 });
                        //               },
                        //               child: Column(children: const [
                        //                 Icon(Icons.delete, color: Colors.red,),Text("Delete",style: TextStyle(color: Colors.black),)
                        //               ]),
                        //             )
                        //           ],
                        //         )))
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: isDelete,
                  child: Positioned(
                      child: StreamBuilder<ResponseOb>(
                    initialData: ResponseOb(msgState: MsgState.loading),
                    stream: saleorderlineBloc.waitingproductlineListStream(),
                    builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                      ResponseOb? responseOb = snapshot.data;
                      if (responseOb?.msgState == MsgState.loading) {
                        return Container(
                            color: Colors.white,
                            child: Center(
                              child: Image.asset(
                                'assets/gifs/loading.gif',
                                width: 100,
                                height: 100,
                              ),
                            ));
                      }
                      return Container();
                    },
                  )),
                )
              ],
            );
          }
        });
  }
}
