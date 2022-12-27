import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:smc_mobile/features/mobile_view/pages_mb/way_plan_mb/call-visit_mb/call_visit_list_mb.dart';
import 'package:smc_mobile/pages/profile_page/profile_bloc.dart';
import 'package:smc_mobile/utils/app_const.dart';

import '../../../../dbs/database_helper.dart';
import '../../../../dbs/sharef.dart';
import '../../../../obs/response_ob.dart';
import '../../../../pages/way_planning_page/way_planning_bloc.dart';
import '../../../../widgets/way_planning_widgets/way_planning_card_widget.dart';
import '../../../pages/menu/menu_list.dart';
import '../menu_mb/menu_list_mb.dart';

class WayPlanningListMB extends StatefulWidget {
  const WayPlanningListMB({Key? key}) : super(key: key);

  @override
  State<WayPlanningListMB> createState() => _WayPlanningListMBState();
}

class _WayPlanningListMBState extends State<WayPlanningListMB> {
  final wayplanningListBloc = WayPlanningBloc();
  final profileBloc = ProfileBloc();
  final databaseHelper = DatabaseHelper();
  List<dynamic> wayplanList = [];
  List<dynamic> userList = [];
  bool isScroll = false;
  final scrollController = ScrollController();
  final wayPlanSearchController = TextEditingController();
  bool searchDone = false;
  bool isSearch = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    deleteAllDatabase();
    // scrollController.addListener(scrollListener);
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      if (userList.isNotEmpty) {
        wayplanningListBloc.getWayPlanningListData(
            name: ['name', 'ilike', ''],
            filter: ['zone_id.id', '=', userList[0]['zone_id'][0]]);
      }
    }
  }

  void deleteAllDatabase() async {
    await databaseHelper.deleteAllHrEmployeeLine();
    await databaseHelper.deleteAllHrEmployeeLineUpdate();
    await databaseHelper.deleteAllSaleOrderLine();
    await databaseHelper.deleteAllSaleOrderLineUpdate();
    await databaseHelper.deleteAllTripPlanDelivery();
    await databaseHelper.deleteAllTripPlanDeliveryUpdate();
    await databaseHelper.deleteAllTripPlanSchedule();
    await databaseHelper.deleteAllTripPlanScheduleUpdate();
    await SharefCount.clearCount();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Do you want to exit?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          exit(0);
                        },
                        child: const Text('OK'))
                  ],
                );
              });
          return true;
        },
        child: SafeArea(
            child: StreamBuilder<ResponseOb>(
                initialData: userList.isNotEmpty
                    ? null
                    : ResponseOb(msgState: MsgState.loading),
                stream: profileBloc.getResUsersStream(),
                builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                  ResponseOb? responseOb = snapshot.data;
                  if (responseOb?.msgState == MsgState.error) {
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
                                  profileBloc.getResUsersData();
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
                                  profileBloc.getResUsersData();
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
                                  profileBloc.getResUsersData();
                                },
                                child: const Text('Try Again'))
                          ],
                        )),
                      );
                    }
                  } else if (responseOb?.msgState == MsgState.loading) {
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
                  } else {
                    return StreamBuilder<ResponseOb>(
                      initialData: ResponseOb(msgState: MsgState.loading),
                      stream: wayplanningListBloc.getWayPlanningListStream(),
                      builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                        ResponseOb? responseOb = snapshot.data;
                        if (responseOb?.msgState == MsgState.error) {
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
                                        profileBloc.getResUsersData();
                                      },
                                      child: const Text('Try Again'))
                                ],
                              )),
                            );
                          } else if (responseOb?.errState ==
                              ErrState.noConnection) {
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
                                        profileBloc.getResUsersData();
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
                                        profileBloc.getResUsersData();
                                      },
                                      child: const Text('Try Again'))
                                ],
                              )),
                            );
                          }
                        } else if (responseOb?.msgState == MsgState.data) {
                          wayplanList = responseOb!.data;
                          return Scaffold(
                              backgroundColor: Colors.grey[200],
                              appBar: AppBar(
                                leading: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return MenuListMB();
                                    }));
                                  },
                                  icon: const Icon(Icons.menu),
                                ),
                                backgroundColor: AppColors.appBarColor,
                                title: Text(
                                    "Way Planning (${userList[0]['zone_id'][1]})"),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return CallVisitListMB(userList: userList,);
                                        }));
                                      },
                                      child: const Text('Call-Visit',
                                          style:
                                              TextStyle(color: Colors.white)))
                                ],
                              ),
                              body: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
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
                                                  controller:
                                                      wayPlanSearchController,
                                                  decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      suffixIcon: IconButton(
                                                        onPressed: () {
                                                          if (searchDone ==
                                                              true) {
                                                            setState(() {
                                                              wayPlanSearchController
                                                                  .clear();
                                                              searchDone =
                                                                  false;
                                                              wayplanningListBloc
                                                                  .getWayPlanningListData(
                                                                      name: [
                                                                    'name',
                                                                    'ilike',
                                                                    ''
                                                                  ],
                                                                      filter: [
                                                                    'zone_id.id',
                                                                    '=',
                                                                    userList[0][
                                                                        'zone_id'][0]
                                                                  ]);
                                                            });
                                                          } else {
                                                            setState(() {
                                                              searchDone = true;
                                                              isSearch = false;
                                                              wayplanningListBloc
                                                                  .getWayPlanningListData(
                                                                      name: [
                                                                    'name',
                                                                    'ilike',
                                                                    wayPlanSearchController
                                                                        .text
                                                                  ],
                                                                      filter: [
                                                                    'zone_id.id',
                                                                    '=',
                                                                    userList[0][
                                                                        'zone_id'][0]
                                                                  ]);
                                                            });
                                                          }
                                                        },
                                                        icon: searchDone == true
                                                            ? const Icon(
                                                                Icons.close)
                                                            : const Icon(
                                                                Icons.search),
                                                      ),
                                                      border:
                                                          OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10))),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "Way Planning Total: " +
                                                  wayplanList.length.toString(),
                                              style:
                                                  const TextStyle(fontSize: 15),
                                            )),
                                      ],
                                    ),
                                  ),
                                  wayplanList.isEmpty
                                      ? const Center(
                                          child: Text("No Data"),
                                        )
                                      : Expanded(
                                          child: Stack(
                                            children: [
                                              ListView.builder(
                                                  controller: scrollController,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10,
                                                          left: 20,
                                                          right: 20),
                                                  itemCount: wayplanList.length,
                                                  itemBuilder: (context, i) {
                                                    return WayPlanningCardWidget(
                                                      wayplanid: wayplanList[i]
                                                          ['id'],
                                                      tripId: wayplanList[i]
                                                          ['trip_id'],
                                                      name: wayplanList[i]
                                                          ['name'],
                                                      zoneId: wayplanList[i]
                                                                  ['zone_id'] ==
                                                              false
                                                          ? []
                                                          : wayplanList[i]
                                                              ['zone_id'],
                                                      userId: wayplanList[i]
                                                                  ['user_id'] ==
                                                              false
                                                          ? []
                                                          : wayplanList[i]
                                                              ['user_id'],
                                                      fromDate: wayplanList[i]
                                                          ['from_date'],
                                                      toDate: wayplanList[i]
                                                          ['to_date'],
                                                      state: wayplanList[i]
                                                          ['state'],
                                                      leaderName: wayplanList[i]
                                                                  [
                                                                  'leader_id'] ==
                                                              false
                                                          ? []
                                                          : wayplanList[i]
                                                              ['leader_id'],
                                                      hremployeelineList: [],
                                                    );
                                                  }),
                                              // Visibility(
                                              //   visible: !isScroll,
                                              //   child: Positioned(
                                              //       bottom: 50,
                                              //       right: 30,
                                              //       child: FloatingActionButton(
                                              //           onPressed: () {

                                              //           },
                                              //           child: const Icon(Icons.add))
                                              //           ),
                                              // ),
                                              Visibility(
                                                visible: isSearch,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  margin: const EdgeInsets.only(
                                                      left: 15, right: 15),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
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
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        isSearch =
                                                                            false;
                                                                        searchDone =
                                                                            true;
                                                                        wayplanningListBloc
                                                                            .getWayPlanningListData(name: [
                                                                          'name',
                                                                          'ilike',
                                                                          wayPlanSearchController
                                                                              .text
                                                                        ], filter: [
                                                                          'zone_id.id',
                                                                          '=',
                                                                          userList[0]['zone_id']
                                                                              [
                                                                              0]
                                                                        ]);
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      height:
                                                                          50,
                                                                      child: RichText(
                                                                          text: TextSpan(children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Trip for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                wayPlanSearchController.text,
                                                                            style: const TextStyle(color: Colors.black))
                                                                      ])),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const Divider(
                                                              thickness: 1.5,
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        isSearch =
                                                                            false;
                                                                        searchDone =
                                                                            true;
                                                                        wayplanningListBloc
                                                                            .getWayPlanningListData(name: [
                                                                          'trip_id',
                                                                          'ilike',
                                                                          wayPlanSearchController
                                                                              .text
                                                                        ], filter: [
                                                                          'zone_id.id',
                                                                          '=',
                                                                          userList[0]['zone_id']
                                                                              [
                                                                              0]
                                                                        ]);
                                                                      });
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      height:
                                                                          50,
                                                                      child: RichText(
                                                                          text: TextSpan(children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Trip ID for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                wayPlanSearchController.text,
                                                                            style: const TextStyle(color: Colors.black))
                                                                      ])),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const Divider(
                                                              thickness: 1.5,
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      isSearch =
                                                                          false;
                                                                      searchDone =
                                                                          true;
                                                                      wayplanningListBloc
                                                                          .getWayPlanningListData(name: [
                                                                        'leader_id',
                                                                        'ilike',
                                                                        wayPlanSearchController
                                                                            .text
                                                                      ], filter: [
                                                                        'zone_id.id',
                                                                        '=',
                                                                        userList[0]
                                                                            [
                                                                            'zone_id'][0]
                                                                      ]);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      height:
                                                                          50,
                                                                      child: RichText(
                                                                          text: TextSpan(children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Leader for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                wayPlanSearchController.text,
                                                                            style: const TextStyle(color: Colors.black))
                                                                      ])),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
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
                              ));
                        } else {
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
                        }
                      },
                    );
                  }
                })));
  }
}
