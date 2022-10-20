import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../pages/material_issues_page/material_isssues_bloc.dart';
import '../../../pages/material_requisition_page/material_requisition_bloc.dart';
import '../../../pages/product_page/product_bloc.dart';
import '../../../pages/profile_page/profile_bloc.dart';
import '../../../utils/app_const.dart';
import '../menu/menu_list.dart';
import 'material_issues_detail.dart';

class MaterialIssuesList extends StatefulWidget {
  const MaterialIssuesList({Key? key}) : super(key: key);

  @override
  State<MaterialIssuesList> createState() => _MaterialIssuesListState();
}

class _MaterialIssuesListState extends State<MaterialIssuesList> {
  final profileBloc = ProfileBloc();
  final materialissuesBloc = MaterialIssuesBloc();
  final productBloc = ProductBloc();
  final mrBloc = MaterialRequisitionBloc();

  List<dynamic> profileList = [];
  String? userName = '';
  bool hasProfileData = false;

  List<dynamic> userList = [];
  bool hasUserData = false;

  List<dynamic> stockpickingList = [];
  bool hasStockPickingData = false;
  List<dynamic> stockpickingupdateList = [];

  List<dynamic> stockwarehouseList = [];
  bool hasStockWarehouseData = false;

  List<dynamic> mrList = [];
  bool hasMRData = false;
  List<dynamic> mrIdList = [];
  List<dynamic> prIdList = [];
  List<dynamic> prList = [];
  bool hasPRData = false;

  int issuseCount = 0;
  final slidableController = SlidableController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileBloc.getProfileStream().listen(getProfileDataListen);
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    mrBloc.getMaterialRequisitionListStream().listen(getMrList);
    materialissuesBloc
        .getPurchaseRequisitionListStream()
        .listen(getPurchaseRequisitionListen);
    materialissuesBloc.getStockPickingStream().listen(getStockPickingListen);
    productBloc.getStockWarehouseStream().listen(getStockWarehouseListen);
    SharefCount.clearCount();
  }

  void getProfileDataListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        hasProfileData = true;
      });
      profileList = responseOb.data;
    }
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      setState(() {
        hasUserData = true;
      });
      if (userList.isNotEmpty) {
        mrBloc.getMaterialRequisitionListData(
            ['request_person.user_id.id', '=', userList[0]['id']],
            ['id', 'ilike', '']);
      }
    }
  }

  void getMrList(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      mrList = responseOb.data;
      setState(() {
        hasMRData = true;
      });
      if (mrList.isNotEmpty) {
        for (var mr in mrList) {
          mrIdList.add(mr['id']);
        }
      }
      print('MrIdList $mrIdList');
      materialissuesBloc.getPurchaseRequisitionListData(mrIdList);
    }
  }

  void getStockWarehouseListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockwarehouseList = responseOb.data;
      setState(() {
        hasStockWarehouseData = true;
      });
      materialissuesBloc.getStockPickingData([
        'material_id',
        'in',
        prIdList
      ], [
        'state',
        'in',
        ['assigned', 'done']
      ]);
    }
  }

  void getPurchaseRequisitionListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      prList = responseOb.data;
      setState(() {
        hasPRData = true;
      });
      if (prList.isNotEmpty) {
        for (var pr in prList) {
          prIdList.add(pr['id']);
        }
      }
      print('Pr id List : $prIdList');
      productBloc.getStockWarehouseData(zoneId: userList[0]['zone_id'][0]);
    }
  }

  void getStockPickingListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockpickingList = responseOb.data;
      profileBloc.getProfileData();
      setState(() {
        hasStockPickingData = true;
      });
      if (stockpickingList.isNotEmpty) {
        print('StockPickingLength: ${stockpickingList.length}');
        for (var stockpicking in stockpickingList) {
          if (stockpicking['location_id'][0] ==
                  stockwarehouseList[0]['lot_stock_id'][0] ||
              stockpicking['location_dest_id'][0] ==
                  stockwarehouseList[0]['lot_stock_id'][0]) {
            print('Stock Picking Name: ${stockpicking['name']}');
            stockpickingupdateList.add(stockpicking);
          }
        }
      }
      print('Stock Picking Update Length: ${stockpickingupdateList.length}');
      print('StockPickingUpdateList : $stockpickingupdateList');
      if (stockpickingupdateList.isNotEmpty) {
        setState(() {
          issuseCount = stockpickingupdateList.length;
        });
      }
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
          initialData: hasUserData == true
              ? null
              : ResponseOb(
                  msgState: MsgState.loading,
                ),
          stream: profileBloc.getResUsersStream(),
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
              return const Center(
                child: Text('Get User Error'),
              );
            } else {
              return StreamBuilder<ResponseOb>(
                  initialData: hasMRData == true
                      ? null
                      : ResponseOb(msgState: MsgState.loading),
                  stream: hasMRData == true
                      ? null
                      : mrBloc.getMaterialRequisitionListStream(),
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
                      return const Center(
                        child: Text('Get User Error'),
                      );
                    } else {
                      return StreamBuilder<ResponseOb>(
                          initialData: hasPRData == true
                              ? null
                              : ResponseOb(msgState: MsgState.loading),
                          stream: materialissuesBloc
                              .getPurchaseRequisitionListStream(),
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
                              return const Center(
                                child: Text('Get User Error'),
                              );
                            } else {
                              return StreamBuilder<ResponseOb>(
                                  initialData: hasStockWarehouseData == true
                                      ? null
                                      : ResponseOb(msgState: MsgState.loading),
                                  stream: productBloc.getStockWarehouseStream(),
                                  builder: (context, snapshot) {
                                    ResponseOb? responseOb = snapshot.data;
                                    if (responseOb?.msgState ==
                                        MsgState.loading) {
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
                                    } else if (responseOb?.msgState ==
                                        MsgState.error) {
                                      return const Center(
                                        child: Text('Get User Error'),
                                      );
                                    } else {
                                      return StreamBuilder<ResponseOb>(
                                          initialData: hasStockPickingData ==
                                                  true
                                              ? null
                                              : ResponseOb(
                                                  msgState: MsgState.loading),
                                          stream: materialissuesBloc
                                              .getStockPickingStream(),
                                          builder: (context, snapshot) {
                                            ResponseOb? responseOb =
                                                snapshot.data;
                                            if (responseOb?.msgState ==
                                                MsgState.loading) {
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
                                            } else if (responseOb?.msgState ==
                                                MsgState.error) {
                                              return const Center(
                                                child: Text('Get User Error'),
                                              );
                                            } else {
                                              return Scaffold(
                                                backgroundColor:
                                                    Colors.grey[200],
                                                appBar: AppBar(
                                                  backgroundColor:
                                                      AppColors.appBarColor,
                                                  leading: IconButton(
                                                    onPressed: () {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                        return MenuList();
                                                      }));
                                                    },
                                                    icon:
                                                        const Icon(Icons.menu),
                                                  ),
                                                  title: const Text(
                                                      'Material Requisition'),
                                                ),
                                                body: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        color: Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 5,
                                                                bottom: 5,
                                                                left: 8,
                                                                right: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: const [
                                                            SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                    'Reference',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold))),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                    'From',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold))),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                    'To',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold))),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                    'Contact',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold))),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                    'Scheduled Date',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold))),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Expanded(
                                                                child: Text(
                                                                    'Source Document',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold))),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            SizedBox(
                                                                width: 100,
                                                                child: Text(
                                                                    'Status',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold))),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Expanded(
                                                        child: ListView.builder(
                                                          itemCount:
                                                              stockpickingupdateList
                                                                  .length,
                                                          itemBuilder: (c, i) {
                                                            return Column(
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(context).push(MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                      return MaterialIssuesDetail(
                                                                        stockpicking:
                                                                            stockpickingupdateList[i],
                                                                      );
                                                                    })).then(
                                                                        (value) {
                                                                      // setState(
                                                                      //     () {

                                                                      // });
                                                                      profileBloc
                                                                          .getResUsersData();
                                                                      stockpickingupdateList
                                                                          .clear();
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(8),
                                                                    color: Colors
                                                                        .white,
                                                                    child: Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text('${stockpickingupdateList[i]['name']}', style: const TextStyle(color: Colors.black, fontSize: 15))
                                                                              ]),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text('${stockpickingupdateList[i]['location_id'][1]}', style: const TextStyle(color: Colors.black, fontSize: 15))
                                                                              ]),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text('${stockpickingupdateList[i]['location_dest_id'][1]}', style: const TextStyle(color: Colors.black, fontSize: 15))
                                                                              ]),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text('${stockpickingupdateList[i]['partner_id'] == false ? '' : stockpickingupdateList[i]['partner_id'][1]}', style: const TextStyle(color: Colors.black, fontSize: 15))
                                                                              ]),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text('${stockpickingupdateList[i]['scheduled_date']}', style: const TextStyle(color: Colors.black, fontSize: 15))
                                                                              ]),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        Expanded(
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text('${stockpickingupdateList[i]['origin'] == false ? '' : stockpickingupdateList[i]['origin']}', style: const TextStyle(color: Colors.black, fontSize: 15))
                                                                              ]),
                                                                        ),
                                                                        const SizedBox(
                                                                          width:
                                                                              2,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              100,
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text(stockpickingupdateList[i]['state'] == 'assigned' ? 'Ready' : 'Done', style: const TextStyle(color: Colors.black, fontSize: 15))
                                                                              ]),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 10),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }
                                          });
                                    }
                                  });
                            }
                          });
                    }
                  });
            }
          },
        )));
  }
}
