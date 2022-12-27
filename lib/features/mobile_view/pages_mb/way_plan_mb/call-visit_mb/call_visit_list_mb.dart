import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:smc_mobile/features/mobile_view/pages_mb/way_plan_mb/call-visit_mb/call_visit_create_mb.dart';
import 'package:smc_mobile/features/mobile_view/pages_mb/way_plan_mb/way_plan_list_mb.dart';
import 'package:smc_mobile/obs/response_ob.dart';
import 'package:smc_mobile/utils/app_const.dart';

import '../../../../../pages/way_planning_page/way_planning_bloc.dart';
import 'call_visit_detail_mb.dart';

class CallVisitListMB extends StatefulWidget {
  List<dynamic> userList;
  CallVisitListMB({
    Key? key,
    required this.userList,
  }) : super(key: key);

  @override
  State<CallVisitListMB> createState() => _CallVisitListMBState();
}

class _CallVisitListMBState extends State<CallVisitListMB> {
  final wayplanBloc = WayPlanningBloc();
  final callvisitSearchController = TextEditingController();
  List<dynamic> callvisitList = [];
  bool hasCallVisitData = false;
  bool isSearch = false;
  bool searchDone = false;

  final interfaceFormat = DateFormat('hh:mm a');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    wayplanBloc.getCallVisitList(
        zone: ['zone_id', '=', widget.userList[0]['zone_id'][1]],
        filter: ['name', 'ilike', '']);
    wayplanBloc.getCallVisitListStream().listen(getCallVisitListListen);
  }

  void getCallVisitListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        hasCallVisitData = true;
      });
      callvisitList = responseOb.data;
    }
  }

  String getTimeStringFromDouble(double value) {
    if (value < 0) return 'Invalid Value';
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);

    return '$hourValue:$minuteString';
  }

  String getMinuteString(double decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return WayPlanningListMB();
        }), (route) => false);
        return true;
      },
      child: SafeArea(
        child: StreamBuilder<ResponseOb>(
            initialData: hasCallVisitData == true
                ? null
                : ResponseOb(msgState: MsgState.loading),
            stream: wayplanBloc.getCallVisitListStream(),
            builder: (context, snapshot) {
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
                  ),
                );
              } else if (responseOb?.msgState == MsgState.error) {
                if (responseOb?.errState == ErrState.severErr) {
                  return Scaffold(
                    body: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${responseOb?.data}'),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                            onPressed: () {
                              wayplanBloc.getCallVisitList(zone: [
                                'zone_id',
                                '=',
                                widget.userList[0]['zone_id'][1]
                              ], filter: [
                                'name',
                                'ilike',
                                ''
                              ]);
                            },
                            child: const Text('Try Again'))
                      ],
                    )),
                  );
                } else if (responseOb?.errState == ErrState.noConnection) {
                  return Scaffold(
                    body: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/imgs/no_internet_connection_icon.png',
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('No Internet Connection'),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                            onPressed: () {
                              wayplanBloc.getCallVisitList(zone: [
                                'zone_id',
                                '=',
                                widget.userList[0]['zone_id'][1]
                              ], filter: [
                                'name',
                                'ilike',
                                ''
                              ]);
                            },
                            child: const Text('Try Again'))
                      ],
                    )),
                  );
                } else {
                  return Scaffold(
                    body: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Unknown Error'),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                            onPressed: () {
                              wayplanBloc.getCallVisitList(zone: [
                                'zone_id',
                                '=',
                                widget.userList[0]['zone_id'][1]
                              ], filter: [
                                'name',
                                'ilike',
                                ''
                              ]);
                            },
                            child: const Text('Try Again'))
                      ],
                    )),
                  );
                }
              } else {
                return Scaffold(
                  backgroundColor: Colors.grey[200],
                  appBar: AppBar(
                    backgroundColor: AppColors.appBarColor,
                    title: const Text('Call-Visit'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return CallVisitCreateMB(isNew: true,
                                          callvisitList: {},);
                            }));
                          },
                          child: const Text('Create',
                              style: TextStyle(color: Colors.white)))
                    ],
                  ),
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      readOnly: searchDone,
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            isSearch = true;
                                          });
                                        } else {
                                          setState(() {
                                            isSearch = false;
                                          });
                                        }
                                      },
                                      controller: callvisitSearchController,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              if (searchDone == true) {
                                                setState(() {
                                                  callvisitSearchController
                                                      .clear();
                                                  searchDone = false;
                                                  wayplanBloc.getCallVisitList(
                                                      zone: [
                                                        'zone_id',
                                                        '=',
                                                        widget.userList[0]
                                                            ['zone_id'][1]
                                                      ],
                                                      filter: [
                                                        'name',
                                                        'ilike',
                                                        ''
                                                      ]);
                                                });
                                              } else {
                                                setState(() {
                                                  searchDone = true;
                                                  isSearch = false;
                                                  wayplanBloc.getCallVisitList(
                                                      zone: [
                                                        'zone_id',
                                                        '=',
                                                        widget.userList[0]
                                                            ['zone_id'][1]
                                                      ],
                                                      filter: [
                                                        'name',
                                                        'ilike',
                                                        ''
                                                      ]);
                                                });
                                              }
                                            },
                                            icon: searchDone == true
                                                ? const Icon(Icons.close)
                                                : const Icon(Icons.search),
                                          ),
                                          border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Call-Visit Total: " +
                                      callvisitList.length.toString(),
                                  style: const TextStyle(fontSize: 15),
                                )),
                          ],
                        ),
                      ),
                      callvisitList.isEmpty
                          ? const Center(
                              child: Text('No Data'),
                            )
                          : Expanded(
                              child: Stack(
                                children: [
                                  ListView.builder(
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount: callvisitList.length,
                                      itemBuilder: (c, i) {
                                        return Column(
                                          children: [
                                            Slidable(
                                              actionPane: const SlidableBehindActionPane(),
        secondaryActions: [
          IconSlideAction(
            color: AppColors.appBarColor,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return CallVisitDetailMB(callvisitList: callvisitList[i],);
              })).then((value) {
                setState(() {
                  wayplanBloc.getCallVisitList(
        zone: ['zone_id', '=', widget.userList[0]['zone_id'][1]],
        filter: ['name', 'ilike', '']);
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
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  color: Colors.white,
                                                  child: Column(children: [
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Customer',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.black),
                                                          ),
                                                        ),
                                                        const Text(':  '),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                '${callvisitList[i]['customer_id'][1]}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Zone',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.black),
                                                          ),
                                                        ),
                                                        const Text(':  '),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                '${callvisitList[i]['zone_id'][1]}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Arrival Time',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.black),
                                                          ),
                                                        ),
                                                        const Text(':  '),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                getTimeStringFromDouble(
                                                                    callvisitList[
                                                                            i][
                                                                        'arl_time']),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Departure Time',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.black),
                                                          ),
                                                        ),
                                                        const Text(':  '),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                getTimeStringFromDouble(
                                                                    callvisitList[
                                                                            i][
                                                                        'dept_time']),
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Vehicle',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.black),
                                                          ),
                                                        ),
                                                        const Text(':  '),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                '${callvisitList[i]['fleet_id'] == false ? '' : callvisitList[i]['fleet_id'][1]}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Driver',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.black),
                                                          ),
                                                        ),
                                                        const Text(':  '),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                '${callvisitList[i]['driver_id'] == false ? '' : callvisitList[i]['driver_id'][1]}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Remark',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.black),
                                                          ),
                                                        ),
                                                        const Text(':  '),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                '${callvisitList[i]['remark'] == false ? '' : callvisitList[i]['remark']}',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'State',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.black),
                                                          ),
                                                        ),
                                                        const Text(':  '),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                callvisitList[i][
                                                                            'state'] ==
                                                                        'draft'
                                                                    ? 'Draft'
                                                                    : callvisitList[i]
                                                                                [
                                                                                'state'] ==
                                                                            'confirm'
                                                                        ? 'Confirmed'
                                                                        : 'Approved',
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black),
                                                              )
                                                            ])),
                                                      ],
                                                    ),
                                                  ])),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        );
                                      }),
                                  Visibility(
                                    visible: isSearch,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      margin: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey[200],
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 2,
                                              offset: Offset(0, 0),
                                            )
                                          ]),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ListView(
                                              shrinkWrap: true,
                                              // mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            isSearch = false;
                                                            searchDone = true;
                                                            wayplanBloc
                                                                .getCallVisitList(
                                                                    zone: [
                                                                  'zone_id',
                                                                  '=',
                                                                  widget.userList[
                                                                          0][
                                                                      'zone_id'][1]
                                                                ],
                                                                    filter: [
                                                                  'customer_id',
                                                                  'ilike',
                                                                  callvisitSearchController
                                                                      .text
                                                                ]);
                                                          });
                                                        },
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          height: 50,
                                                          child: RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                const TextSpan(
                                                                    text:
                                                                        "Search Customer for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: callvisitSearchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
                                                              ])),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  thickness: 1.5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}
