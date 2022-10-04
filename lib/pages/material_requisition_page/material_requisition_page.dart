import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../dbs/database_helper.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../../widgets/drawer_widget.dart';
import '../profile_page/profile_bloc.dart';
import '../quotation_page/quotation_detail_page.dart';
import 'material_requisition_bloc.dart';
import 'material_requisition_create_page.dart';
import 'material_requisition_detail_page.dart';

class MaterialRequisitionPage extends StatefulWidget {
  const MaterialRequisitionPage({Key? key}) : super(key: key);

  @override
  State<MaterialRequisitionPage> createState() =>
      _MaterialRequisitionPageState();
}

class _MaterialRequisitionPageState extends State<MaterialRequisitionPage> {
  final materialRequisitionBloc = MaterialRequisitionBloc();
  final profileBloc = ProfileBloc();
  final databaseHelper = DatabaseHelper();
  final searchController = TextEditingController();
  List<dynamic> userList = [];
  List<dynamic> materialrequisitionList = [];
  final slidableController = SlidableController();

  bool isSearch = false;
  bool searchDone = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    deleteDatabases();
    materialRequisitionBloc
        .getMaterialRequisitionListStream()
        .listen(getMaterialRequisitionListen);
  }

  void deleteDatabases() async {
    await databaseHelper.deleteAllMaterialProductLine();
    await SharefCount.clearCount();
  }

  void getMaterialRequisitionListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      materialrequisitionList = responseOb.data;
    }
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      print('User Zone Id: ${userList[0]['zone_id']}');
      materialRequisitionBloc.getMaterialRequisitionListData(
          ['zone_id.id', '=', userList[0]['zone_id'][0]], ['id', 'ilike', '']);
    }
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
            initialData: materialrequisitionList.isNotEmpty
                ? null
                : ResponseOb(msgState: MsgState.loading),
            stream: materialRequisitionBloc.getMaterialRequisitionListStream(),
            builder: (context, snapshot) {
              ResponseOb? responseOb = snapshot.data;
              if (responseOb?.msgState == MsgState.error) {
                return Container(
                    color: Colors.white,
                    child: const Center(
                      child: Text('Error'),
                    ));
              } else if (responseOb?.msgState == MsgState.loading) {
                return Container(
                    color: Colors.white,
                    child: const Center(child: CircularProgressIndicator()));
              } else {
                return Scaffold(
                    backgroundColor: Colors.grey[200],
                    drawer: const DrawerWidget(),
                    appBar: AppBar(
                        backgroundColor: AppColors.appBarColor,
                        title: const Text('Material Requisition')),
                    body: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchController,
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
                                  readOnly: searchDone,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          if (searchDone == true) {
                                            setState(() {
                                              searchController.clear();
                                              searchDone = false;
                                              materialRequisitionBloc
                                                  .getMaterialRequisitionListData(
                                                      [
                                                    'zone_id.id',
                                                    '=',
                                                    userList[0]['zone_id'][0]
                                                  ],
                                                      [
                                                    'id',
                                                    'ilike',
                                                    ''
                                                  ]);
                                            });
                                          } else {
                                            setState(() {
                                              searchDone = true;
                                              isSearch = false;
                                              materialRequisitionBloc
                                                  .getMaterialRequisitionListData(
                                                      [
                                                    'zone_id.id',
                                                    '=',
                                                    userList[0]['zone_id'][0]
                                                  ],
                                                      [
                                                    'request_person',
                                                    'ilike',
                                                    searchController.text
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
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.green,
                                  ),
                                  width: 60,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return MaterialRequisitionCreatePage(
                                          name: '',
                                          neworedit: 0,
                                          userId: userList[0]['zone_id'][0],
                                        );
                                      })).then((value) {
                                        setState(() {
                                          materialRequisitionBloc
                                              .getMaterialRequisitionListData([
                                            'zone_id.id',
                                            '=',
                                            userList[0]['zone_id'][0]
                                          ], [
                                            'id',
                                            'ilike',
                                            ''
                                          ]);
                                        });
                                      });
                                    },
                                    child: const Text("Create",
                                        style: TextStyle(
                                          color: Colors.white,
                                        )),
                                  )),
                            ],
                          ),
                        ),
                        materialrequisitionList.isEmpty
                            ? Container(
                                child: const Center(child: Text('No Data')),
                              )
                            : Expanded(
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                        padding: const EdgeInsets.all(8),
                                        itemCount:
                                            materialrequisitionList.length,
                                        itemBuilder: (c, i) {
                                          return Column(
                                            children: [
                                              Slidable(
                                                controller: slidableController,
                                                actionPane:
                                                    const SlidableBehindActionPane(),
                                                secondaryActions: [
                                                  IconSlideAction(
                                                    color:
                                                        AppColors.appBarColor,
                                                    onTap: () {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                        return MaterialRequisitionDetailPage(
                                                          id: materialrequisitionList[
                                                              i]['id'],
                                                          userId: userList[0]
                                                              ['zone_id'][0],
                                                        );
                                                      })).then((value) {
                                                        setState(() {
                                                          profileBloc
                                                              .getResUsersData();
                                                        });
                                                      });
                                                    },
                                                    iconWidget: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons.read_more,
                                                          size: 25,
                                                          color: Colors.white,
                                                        ),
                                                        Text(
                                                          "View Details",
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width >
                                                                      400.0
                                                                  ? 18
                                                                  : 12,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        materialrequisitionList[
                                                            i]['name'],
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            child: const Text(
                                                              'Requested Person: ',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      materialrequisitionList[
                                                                              i]
                                                                          [
                                                                          'request_person'][1],
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12),
                                                                    )
                                                                  ]))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            child: const Text(
                                                              'Department: ',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      materialrequisitionList[i]['department_id'] ==
                                                                              false
                                                                          ? ''
                                                                          : materialrequisitionList[i]['department_id']
                                                                              [
                                                                              1],
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12),
                                                                    )
                                                                  ]))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            child: const Text(
                                                              'Order Date: ',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      materialrequisitionList[
                                                                              i]
                                                                          [
                                                                          'order_date'],
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12),
                                                                    )
                                                                  ]))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            child: const Text(
                                                              'Scheduled Date: ',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      materialrequisitionList[
                                                                              i]
                                                                          [
                                                                          'scheduled_date'],
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12),
                                                                    )
                                                                  ]))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            child: const Text(
                                                              'Description: ',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      materialrequisitionList[
                                                                              i]
                                                                          [
                                                                          'desc'],
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              12),
                                                                    )
                                                                  ]))
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
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
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
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
                                                              materialRequisitionBloc
                                                                  .getMaterialRequisitionListData(
                                                                      [
                                                                    'zone_id.id',
                                                                    '=',
                                                                    userList[0][
                                                                        'zone_id'][0]
                                                                  ],
                                                                      [
                                                                    'request_person',
                                                                    'ilike',
                                                                    searchController
                                                                        .text,
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
                                                                          "Search Requested Person for: ",
                                                                      style: TextStyle(
                                                                          fontStyle: FontStyle
                                                                              .italic,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  TextSpan(
                                                                      text: searchController
                                                                          .text,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.black))
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
                                                              materialRequisitionBloc
                                                                  .getMaterialRequisitionListData(
                                                                      [
                                                                    'zone_id.id',
                                                                    '=',
                                                                    userList[0][
                                                                        'zone_id'][0]
                                                                  ],
                                                                      [
                                                                    'department_id',
                                                                    'ilike',
                                                                    searchController
                                                                        .text,
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
                                                                          "Search Department for: ",
                                                                      style: TextStyle(
                                                                          fontStyle: FontStyle
                                                                              .italic,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  TextSpan(
                                                                      text: searchController
                                                                          .text,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.black))
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
                                                            materialRequisitionBloc
                                                                .getMaterialRequisitionListData(
                                                                    [
                                                                  'zone_id.id',
                                                                  '=',
                                                                  userList[0][
                                                                      'zone_id'][0]
                                                                ],
                                                                    [
                                                                  'desc',
                                                                  'ilike',
                                                                  searchController
                                                                      .text,
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
                                                                          "Search Description for: ",
                                                                      style: TextStyle(
                                                                          fontStyle: FontStyle
                                                                              .italic,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  TextSpan(
                                                                      text: searchController
                                                                          .text,
                                                                      style: const TextStyle(
                                                                          color:
                                                                              Colors.black))
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
                    ));
              }
            }),
      ),
    );
  }
}
