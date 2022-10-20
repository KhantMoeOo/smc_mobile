import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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
  final databaseHelper = DatabaseHelper();
  List<dynamic> wayplanList = [];
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
    wayplanningListBloc.getWayPlanningListData(name: ['name', 'ilike', '']);
    deleteAllDatabase();
    // scrollController.addListener(scrollListener);
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

  // void scrollListener() {
  //   if (scrollController.position.userScrollDirection ==
  //       ScrollDirection.reverse) {
  //     setState(() {
  //       isScroll = true;
  //       isSearch = false;
  //       wayPlanSearchController.text = '';
  //     });
  //   }
  //   if (scrollController.position.userScrollDirection ==
  //       ScrollDirection.forward) {
  //     setState(() {
  //       isScroll = false;
  //     });
  //   }
  // } // listen to Control show or hide of floating button and search bar from way planning list page

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
          initialData: ResponseOb(msgState: MsgState.loading),
          stream: wayplanningListBloc.getWayPlanningListStream(),
          builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
            ResponseOb? responseOb = snapshot.data;
            if (responseOb?.msgState == MsgState.error) {
              return const Center(
                child: Text('Error'),
              );
            } else if (responseOb?.msgState == MsgState.data) {
              wayplanList = responseOb!.data;
              return Scaffold(
                  backgroundColor: Colors.grey[200],
                  appBar: AppBar(
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return MenuListMB();
                        }));
                      },
                      icon: const Icon(Icons.menu),
                    ),
                    backgroundColor: Color.fromARGB(255, 12, 41, 92),
                    title: const Text("Way Planning"),
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
                                      controller: wayPlanSearchController,
                                      decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              if (searchDone == true) {
                                                setState(() {
                                                  wayPlanSearchController
                                                      .clear();
                                                  searchDone = false;
                                                  wayplanningListBloc
                                                      .getWayPlanningListData(
                                                          name: [
                                                        'name',
                                                        'ilike',
                                                        ''
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
                                  // Container(
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(10),
                                  //     color: Colors.green,
                                  //   ),
                                  //   width: 60,
                                  //   child: TextButton(
                                  //       onPressed: () {
                                  //         Navigator.of(context).push(
                                  //             MaterialPageRoute(builder: (context) {
                                  //           return WayPlanningCreatePage(
                                  //               neworedit: 0,
                                  //               tripId: 0,
                                  //               tripSeq: '',
                                  //               tripconfigList: [],
                                  //               zoneList: [],
                                  //               userList: [],
                                  //               fromDate: '',
                                  //               toDate: '',
                                  //               leaderId: [],
                                  //               hremployeelineList: []);
                                  //         })).then((value) {
                                  //           setState(() {
                                  //             wayplanningListBloc
                                  //                 .getWayPlanningListData('', '', '');
                                  //           });
                                  //         });
                                  //       },
                                  //       child: const Icon(
                                  //         Icons.add,
                                  //         color: Colors.white,
                                  //       )),
                                  // )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Way Planning Total: " +
                                      wayplanList.length.toString(),
                                  style: const TextStyle(fontSize: 15),
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
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 20, right: 20),
                                      itemCount: wayplanList.length,
                                      itemBuilder: (context, i) {
                                        return WayPlanningCardWidget(
                                          wayplanid: wayplanList[i]['id'],
                                          tripId: wayplanList[i]['trip_id'],
                                          name: wayplanList[i]['name'],
                                          zoneId:
                                              wayplanList[i]['zone_id'] == false
                                                  ? []
                                                  : wayplanList[i]['zone_id'],
                                          userId:
                                              wayplanList[i]['user_id'] == false
                                                  ? []
                                                  : wayplanList[i]['user_id'],
                                          fromDate: wayplanList[i]['from_date'],
                                          toDate: wayplanList[i]['to_date'],
                                          state: wayplanList[i]['state'],
                                          leaderName: wayplanList[i]
                                                      ['leader_id'] ==
                                                  false
                                              ? []
                                              : wayplanList[i]['leader_id'],
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
                                                            wayplanningListBloc
                                                                .getWayPlanningListData(
                                                                    name: [
                                                                  'name',
                                                                  'ilike',
                                                                  wayPlanSearchController
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
                                                                        "Search Trip for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: wayPlanSearchController
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
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            isSearch = false;
                                                            searchDone = true;
                                                            wayplanningListBloc
                                                                .getWayPlanningListData(
                                                                    name: [
                                                                  'trip_id',
                                                                  'ilike',
                                                                  wayPlanSearchController
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
                                                                        "Search Trip ID for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: wayPlanSearchController
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
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          isSearch = false;
                                                          searchDone = true;
                                                          wayplanningListBloc
                                                              .getWayPlanningListData(
                                                                  name: [
                                                                'leader_id',
                                                                'ilike',
                                                                wayPlanSearchController
                                                                    .text
                                                              ]);
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
                                                                        "Search Leader for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: wayPlanSearchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
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
        ),
      ),
    );
  }
}
