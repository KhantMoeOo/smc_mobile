import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../../widgets/drawer_widget.dart';
import '../material_requisition_page/material_requisition_bloc.dart';
import '../product_page/product_bloc.dart';
import '../profile_page/profile_bloc.dart';
import 'material_isssues_bloc.dart';
import 'material_issues_detail_page.dart';

class MaterialIssuesPage extends StatefulWidget {
  const MaterialIssuesPage({Key? key}) : super(key: key);

  @override
  State<MaterialIssuesPage> createState() => _MaterialIssuesPageState();
}

class _MaterialIssuesPageState extends State<MaterialIssuesPage> {
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
    return SafeArea(
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
                      stream:
                          materialissuesBloc.getPurchaseRequisitionListStream(),
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
                                } else if (responseOb?.msgState ==
                                    MsgState.error) {
                                  return const Center(
                                    child: Text('Get User Error'),
                                  );
                                } else {
                                  return StreamBuilder<ResponseOb>(
                                      initialData: hasStockPickingData == true
                                          ? null
                                          : ResponseOb(
                                              msgState: MsgState.loading),
                                      stream: materialissuesBloc
                                          .getStockPickingStream(),
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
                                          return Scaffold(
                                            backgroundColor: Colors.grey[200],
                                            drawer: const DrawerWidget(),
                                            appBar: AppBar(
                                              backgroundColor:
                                                  AppColors.appBarColor,
                                              title:
                                                  const Text('Material Issues'),
                                            ),
                                            body: stockpickingupdateList.isEmpty
                                                ? Container()
                                                : ListView.builder(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    itemCount:
                                                        stockpickingupdateList
                                                            .length,
                                                    itemBuilder: (c, i) {
                                                      return Column(
                                                        children: [
                                                          Slidable(
                                                            controller:
                                                                slidableController,
                                                            actionPane:
                                                                const SlidableBehindActionPane(),
                                                            secondaryActions: [
                                                              IconSlideAction(
                                                                color: AppColors
                                                                    .appBarColor,
                                                                onTap: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .push(MaterialPageRoute(
                                                                          builder:
                                                                              (context) {
                                                                    return MaterialIssuesDetailPage(
                                                                        id: stockpickingupdateList[i]
                                                                            [
                                                                            'id']);
                                                                  })).then(
                                                                          (value) {
                                                                    profileBloc
                                                                        .getResUsersData();
                                                                    setState(
                                                                        () {
                                                                      stockpickingupdateList
                                                                          .clear();
                                                                    });
                                                                  });
                                                                },
                                                                iconWidget:
                                                                    Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .read_more,
                                                                      size: 25,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    Text(
                                                                      "View Details",
                                                                      style: TextStyle(
                                                                          fontSize: MediaQuery.of(context).size.width > 400.0
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
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              color:
                                                                  Colors.white,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Text(
                                                                          'Reference: ',
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                            Text(
                                                                              stockpickingupdateList[i]['name'],
                                                                              style: const TextStyle(color: Colors.black, fontSize: 13),
                                                                            )
                                                                          ])),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Text(
                                                                          'From: ',
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                            Text(
                                                                              stockpickingupdateList[i]['location_id'][1],
                                                                              style: const TextStyle(color: Colors.black, fontSize: 13),
                                                                            )
                                                                          ])),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Text(
                                                                          'To: ',
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                            Text(
                                                                              stockpickingupdateList[i]['location_dest_id'][1],
                                                                              style: const TextStyle(color: Colors.black, fontSize: 13),
                                                                            )
                                                                          ])),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Text(
                                                                          'Schedule Date: ',
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                            Text(
                                                                              stockpickingupdateList[i]['scheduled_date'].toString(),
                                                                              style: const TextStyle(color: Colors.black, fontSize: 13),
                                                                            )
                                                                          ])),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Text(
                                                                          'Source Doucument: ',
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                            Text(
                                                                              stockpickingupdateList[i]['origin'] == false ? '' : stockpickingupdateList[i]['origin'],
                                                                              style: const TextStyle(color: Colors.black, fontSize: 13),
                                                                            )
                                                                          ])),
                                                                    ],
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const SizedBox(
                                                                        width:
                                                                            200,
                                                                        child:
                                                                            Text(
                                                                          'Status: ',
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                            Text(
                                                                              stockpickingupdateList[i]['state'] == 'assigned' ? 'Ready' : 'Done',
                                                                              style: const TextStyle(color: Colors.black, fontSize: 13),
                                                                            )
                                                                          ])),
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
    ));
  }
}
