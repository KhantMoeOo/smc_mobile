import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../dbs/sharef.dart';
import '../../../../obs/response_ob.dart';
import '../../../../pages/logout_page/logout_page.dart';
import '../../../../pages/material_issues_page/material_isssues_bloc.dart';
import '../../../../pages/material_requisition_page/material_requisition_bloc.dart';
import '../../../../pages/product_page/product_bloc.dart';
import '../../../../pages/profile_page/profile_bloc.dart';
import '../../../../pages/sale_pricelist_page/sale_pricelist_type_page.dart';
import '../../../../pages/way_planning_page/way_planning_page.dart';
import '../../../../utils/app_const.dart';
import '../../../pages/material_isssues/material_issues_list.dart';
import '../../../pages/material_requisition/material_requisition_list.dart';
import '../customer_mb/customer_list_mb.dart';
import '../material_issues_mb/material_issues_list_mb.dart';
import '../material_requisition_mb/material_requisition_list_mb.dart';
import '../product_mb/product_list_mb.dart';
import '../profile_mb/profile_mb.dart';
import '../quotation_mb/quotation_list_mb.dart';
import '../sale_pricelist_mb/sale_pricelist_type_mb.dart';
import '../way_plan_mb/way_plan_list_mb.dart';

class MenuListMB extends StatefulWidget {
  const MenuListMB({Key? key}) : super(key: key);

  @override
  State<MenuListMB> createState() => _MenuListMBState();
}

class _MenuListMBState extends State<MenuListMB> {
  static PageController pageController = PageController();
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

  Timer? _timer;

  String dbName = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // SystemChrome.setPreferredOrientations(
    //     [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    profileBloc.getProfileStream().listen(getProfileDataListen);
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    mrBloc.getMaterialRequisitionListStream().listen(getMrList);
    materialissuesBloc
        .getPurchaseRequisitionListStream()
        .listen(getPurchaseRequisitionListen);
    materialissuesBloc.getStockPickingStream().listen(getStockPickingListen);
    productBloc.getStockWarehouseStream().listen(getStockWarehouseListen);
    Sharef.getOdooClientInstance().then((value) {
      setState(() {
        dbName = value['database'];
        print('Db Name: $dbName');
      });
    });
  }

  void getProfileDataListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        hasProfileData = true;
      });
      profileList = responseOb.data;
    } else if (responseOb.msgState == MsgState.error) {
      setState(() {
        hasProfileData = false;
      });
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
    } else if (responseOb.msgState == MsgState.error) {
      setState(() {
        hasUserData = false;
      });
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
    } else if (responseOb.msgState == MsgState.error) {
      setState(() {
        hasMRData = false;
      });
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
        ['assigned', 'issue_confirm']
      ]);
    } else if (responseOb.msgState == MsgState.error) {
      setState(() {
        hasStockWarehouseData = false;
      });
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
    } else if (responseOb.msgState == MsgState.error) {
      setState(() {
        hasPRData = false;
      });
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
    } else if (responseOb.msgState == MsgState.error) {
      setState(() {
        hasStockPickingData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResponseOb>(
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
                  const Text('No Internet Connection!'),
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
        } else {
          return StreamBuilder<ResponseOb>(
              initialData: hasMRData == true
                  ? null
                  : ResponseOb(msgState: MsgState.loading),
              stream: mrBloc.getMaterialRequisitionListStream(),
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
                                if (userList.isNotEmpty) {
                                  mrBloc.getMaterialRequisitionListData([
                                    'request_person.user_id.id',
                                    '=',
                                    userList[0]['id']
                                  ], [
                                    'id',
                                    'ilike',
                                    ''
                                  ]);
                                }
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
                          const Text('No Internet Connection!'),
                          const SizedBox(
                            height: 20,
                          ),
                          TextButton(
                              onPressed: () {
                                if (userList.isNotEmpty) {
                                  mrBloc.getMaterialRequisitionListData([
                                    'request_person.user_id.id',
                                    '=',
                                    userList[0]['id']
                                  ], [
                                    'id',
                                    'ilike',
                                    ''
                                  ]);
                                }
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
                                mrBloc.getMaterialRequisitionListData([
                                  'request_person.user_id.id',
                                  '=',
                                  userList[0]['id']
                                ], [
                                  'id',
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
                                        materialissuesBloc
                                            .getPurchaseRequisitionListData(
                                                mrIdList);
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
                                  const Text('No Internet Connection!'),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        materialissuesBloc
                                            .getPurchaseRequisitionListData(
                                                mrIdList);
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
                                        materialissuesBloc
                                            .getPurchaseRequisitionListData(
                                                mrIdList);
                                      },
                                      child: const Text('Try Again'))
                                ],
                              )),
                            );
                          }
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
                                  if (responseOb?.errState ==
                                      ErrState.severErr) {
                                    return Scaffold(
                                      body: Center(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('${responseOb?.data}'),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                productBloc
                                                    .getStockWarehouseData(
                                                        zoneId: userList[0]
                                                            ['zone_id'][0]);
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/imgs/no_internet_connection_icon.png',
                                            width: 100,
                                            height: 100,
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          const Text('No Internet Connection!'),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                productBloc
                                                    .getStockWarehouseData(
                                                        zoneId: userList[0]
                                                            ['zone_id'][0]);
                                              },
                                              child: const Text('Try Again'))
                                        ],
                                      )),
                                    );
                                  } else {
                                    return Scaffold(
                                      body: Center(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text('Unknown Error'),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                productBloc
                                                    .getStockWarehouseData(
                                                        zoneId: userList[0]
                                                            ['zone_id'][0]);
                                              },
                                              child: const Text('Try Again'))
                                        ],
                                      )),
                                    );
                                  }
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
                                          if (responseOb?.errState ==
                                              ErrState.severErr) {
                                            return Scaffold(
                                              body: Center(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text('${responseOb?.data}'),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        materialissuesBloc
                                                            .getStockPickingData(
                                                                [
                                                              'material_id',
                                                              'in',
                                                              prIdList
                                                            ],
                                                                [
                                                              'state',
                                                              'in',
                                                              ['assigned']
                                                            ]);
                                                      },
                                                      child: const Text(
                                                          'Try Again'))
                                                ],
                                              )),
                                            );
                                          } else if (responseOb?.errState ==
                                              ErrState.noConnection) {
                                            return Scaffold(
                                              body: Center(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/imgs/no_internet_connection_icon.png',
                                                    width: 100,
                                                    height: 100,
                                                  ),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  const Text(
                                                      'No Internet Connection!'),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        materialissuesBloc
                                                            .getStockPickingData(
                                                                [
                                                              'material_id',
                                                              'in',
                                                              prIdList
                                                            ],
                                                                [
                                                              'state',
                                                              'in',
                                                              ['assigned']
                                                            ]);
                                                      },
                                                      child: const Text(
                                                          'Try Again'))
                                                ],
                                              )),
                                            );
                                          } else {
                                            return Scaffold(
                                              body: Center(
                                                  child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text('Unknown Error'),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  TextButton(
                                                      onPressed: () {
                                                        materialissuesBloc
                                                            .getStockPickingData(
                                                                [
                                                              'material_id',
                                                              'in',
                                                              prIdList
                                                            ],
                                                                [
                                                              'state',
                                                              'in',
                                                              ['assigned']
                                                            ]);
                                                      },
                                                      child: const Text(
                                                          'Try Again'))
                                                ],
                                              )),
                                            );
                                          }
                                        } else {
                                          return SafeArea(
                                              child: Scaffold(
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  appBar: AppBar(
                                                    backgroundColor:
                                                        AppColors.appBarColor,
                                                    title:
                                                        Text('Menus ($dbName)'),
                                                    leading: IconButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      icon: const Icon(
                                                          Icons.menu),
                                                    ),
                                                    //title: Text('Menu'),
                                                  ),
                                                  body: Column(
                                                    children: [
                                                      Expanded(
                                                        child: GridView(
                                                          gridDelegate:
                                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 2,
                                                            childAspectRatio: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width /
                                                                (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height /
                                                                    2.5),
                                                            mainAxisSpacing:
                                                                50.0,
                                                            // crossAxisSpacing:
                                                            //     5.0,
                                                          ),
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return const QuotationListMB();
                                                                }),
                                                                    (route) =>
                                                                        false);
                                                              },
                                                              child: Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/imgs/quotation_icon.png',
                                                                        height:
                                                                            80,
                                                                        color: AppColors
                                                                            .appBarColor,
                                                                      ),
                                                                      const Text(
                                                                        "Quotation",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            // fontSize:
                                                                            //     20,
                                                                            color: AppColors.appBarColor),
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return const WayPlanningListMB();
                                                                }),
                                                                    (route) =>
                                                                        false);
                                                              },
                                                              child: Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/imgs/way_plan_icon.png',
                                                                        height:
                                                                            80,
                                                                        color: AppColors
                                                                            .appBarColor,
                                                                      ),
                                                                      const Text(
                                                                        "Way Planning",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            // fontSize:
                                                                            //     20,
                                                                            color: AppColors.appBarColor),
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return MaterialRequisitionListMB();
                                                                }),
                                                                    (route) =>
                                                                        false);
                                                              },
                                                              child: Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/imgs/material_requisition_icon.png',
                                                                        height:
                                                                            80,
                                                                        color: AppColors
                                                                            .appBarColor,
                                                                      ),
                                                                      const Text(
                                                                        "Material Requisition",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            // fontSize:
                                                                            //     20,
                                                                            color: AppColors.appBarColor),
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return MaterialIssuesListMB();
                                                                }),
                                                                    (route) =>
                                                                        false);
                                                              },
                                                              child: Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/imgs/material_requisition_icon.png',
                                                                        height:
                                                                            80,
                                                                        color: AppColors
                                                                            .appBarColor,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          const Text(
                                                                            "Material Issues",
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                // fontSize:
                                                                                //     20,
                                                                                color: AppColors.appBarColor),
                                                                          ),
                                                                          Visibility(
                                                                            visible: issuseCount > 0
                                                                                ? true
                                                                                : false,
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.all(5),
                                                                              decoration: const BoxDecoration(
                                                                                color: Colors.green,
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child: Text(
                                                                                '$issuseCount',
                                                                                style: const TextStyle(
                                                                                  // fontSize:
                                                                                  //     20,
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        ],
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return SalePricelistTypeMB();
                                                                }),
                                                                    (route) =>
                                                                        false);
                                                              },
                                                              child: Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/imgs/sale_pricelist_icon.png',
                                                                        height:
                                                                            80,
                                                                        color: AppColors
                                                                            .appBarColor,
                                                                      ),
                                                                      const Text(
                                                                        "Sale Pricelists",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            // fontSize:
                                                                            //     20,
                                                                            color: AppColors.appBarColor),
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return ProductListMB();
                                                                }),
                                                                    (route) =>
                                                                        false);
                                                              },
                                                              child: Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/imgs/product_icon.png',
                                                                        height:
                                                                            80,
                                                                        color: AppColors
                                                                            .appBarColor,
                                                                      ),
                                                                      const Text(
                                                                        "Products",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            // fontSize:
                                                                            //     20,
                                                                            color: AppColors.appBarColor),
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return const CustomerListMB();
                                                                }),
                                                                    (route) =>
                                                                        false);
                                                              },
                                                              child: Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/imgs/customer_icon.jpg',
                                                                        height:
                                                                            80,
                                                                        color: AppColors
                                                                            .appBarColor,
                                                                      ),
                                                                      const Text(
                                                                        "Customers",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            // fontSize:
                                                                            //     20,
                                                                            color: AppColors.appBarColor),
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.of(context).pushAndRemoveUntil(
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return ProfileMB();
                                                                }),
                                                                    (route) =>
                                                                        false);
                                                              },
                                                              child: Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'assets/imgs/person_icon.png',
                                                                        height:
                                                                            80,
                                                                        color: AppColors
                                                                            .appBarColor,
                                                                      ),
                                                                      const Text(
                                                                        "Profile",
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            // fontSize:
                                                                            //     20,
                                                                            color: AppColors.appBarColor),
                                                                      )
                                                                    ],
                                                                  )),
                                                            ),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              decoration: const BoxDecoration(
                                                                  // boxShadow: const [
                                                                  //   BoxShadow(
                                                                  //       color: Colors.black,
                                                                  //       offset: Offset(-2, 2),
                                                                  //       blurRadius: 2),
                                                                  // ],
                                                                  // borderRadius: BorderRadius.circular(10),
                                                                  // color: Colors.grey[200],
                                                                  // color: AppColors
                                                                  //     .appBarColor,
                                                                  ),
                                                              height: 60,
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                const Text("Do you want to Log Out?"),
                                                                            actions: [
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                  child: const Text('Cancel')),
                                                                              TextButton(
                                                                                  style: TextButton.styleFrom(
                                                                                    backgroundColor: Colors.purple,
                                                                                  ),
                                                                                  onPressed: () async {
                                                                                    var sessionId = await Sharef.clearSessionId();
                                                                                    await Sharef.logout();
                                                                                    if (sessionId == true) {
                                                                                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                                                                                        return const LogoutPage();
                                                                                      }), (route) => false);
                                                                                    }
                                                                                  },
                                                                                  child: const Text(
                                                                                    'Ok',
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ))
                                                                            ],
                                                                          );
                                                                        });
                                                                  },
                                                                  child: Column(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        "assets/imgs/logout_icon.png",
                                                                        color: AppColors
                                                                            .appBarColor,
                                                                        height:
                                                                            80,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      const Text(
                                                                        'Log Out',
                                                                        style:
                                                                            TextStyle(
                                                                          // fontSize:
                                                                          //     20,
                                                                          color:
                                                                              AppColors.appBarColor,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Text(version)
                                                    ],
                                                  )));
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
    );
  }
}
