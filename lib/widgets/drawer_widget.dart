import 'dart:async';

import 'package:flutter/material.dart';
import '../dbs/sharef.dart';
import '../obs/response_ob.dart';
import '../pages/customer_page/customer_page.dart';
import '../pages/logout_page/logout_page.dart';
import '../pages/material_issues_page/material_isssues_bloc.dart';
import '../pages/material_issues_page/material_issues_page.dart';
import '../pages/material_requisition_page/material_requisition_bloc.dart';
import '../pages/material_requisition_page/material_requisition_page.dart';
import '../pages/product_page/product_bloc.dart';
import '../pages/product_page/product_page.dart';
import '../pages/profile_page/profile_bloc.dart';
import '../pages/profile_page/profile_page.dart';
import '../pages/quotation_page/quotation_page.dart';
import '../pages/sale_pricelist_page/sale_pricelist_type_page.dart';
import '../pages/sale_pricelist_page/segment_type_page.dart';
import '../pages/way_planning_page/way_planning_page.dart';
import '../utils/app_const.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<DrawerWidget> {
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
        ['assigned']
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
      child: SizedBox(
        width: 300,
        child: Drawer(
            elevation: 0.0,
            backgroundColor: Colors.white,
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
                  return Center(
                    child: Image.asset(
                      'assets/gifs/loading.gif',
                      width: 100,
                      height: 100,
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
                      stream: mrBloc.getMaterialRequisitionListStream(),
                      builder: (context, snapshot) {
                        ResponseOb? responseOb = snapshot.data;
                        if (responseOb?.msgState == MsgState.loading) {
                          return Center(
                            child: Image.asset(
                              'assets/gifs/loading.gif',
                              width: 100,
                              height: 100,
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
                                  return Center(
                                    child: Image.asset(
                                      'assets/gifs/loading.gif',
                                      width: 100,
                                      height: 100,
                                    ),
                                  );
                                } else if (responseOb?.msgState ==
                                    MsgState.error) {
                                  return const Center(
                                    child: Text('Get User Error'),
                                  );
                                } else {
                                  return StreamBuilder<ResponseOb>(
                                      initialData: hasStockWarehouseData == true
                                          ? null
                                          : ResponseOb(
                                              msgState: MsgState.loading),
                                      stream:
                                          productBloc.getStockWarehouseStream(),
                                      builder: (context, snapshot) {
                                        ResponseOb? responseOb = snapshot.data;
                                        if (responseOb?.msgState ==
                                            MsgState.loading) {
                                          return Center(
                                            child: Image.asset(
                                              'assets/gifs/loading.gif',
                                              width: 100,
                                              height: 100,
                                            ),
                                          );
                                        } else if (responseOb?.msgState ==
                                            MsgState.error) {
                                          return const Center(
                                            child: Text('Get User Error'),
                                          );
                                        } else {
                                          return StreamBuilder<ResponseOb>(
                                              initialData:
                                                  hasStockPickingData == true
                                                      ? null
                                                      : ResponseOb(
                                                          msgState:
                                                              MsgState.loading),
                                              stream: materialissuesBloc
                                                  .getStockPickingStream(),
                                              builder: (context, snapshot) {
                                                ResponseOb? responseOb =
                                                    snapshot.data;
                                                if (responseOb?.msgState ==
                                                    MsgState.loading) {
                                                  return Center(
                                                    child: Image.asset(
                                                      'assets/gifs/loading.gif',
                                                      width: 100,
                                                      height: 100,
                                                    ),
                                                  );
                                                } else if (responseOb
                                                        ?.msgState ==
                                                    MsgState.error) {
                                                  return const Center(
                                                    child:
                                                        Text('Get User Error'),
                                                  );
                                                } else {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              color: Colors
                                                                  .grey[200],
                                                              child: Column(
                                                                children: [
                                                                  Container(
                                                                      margin: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              60,
                                                                          right:
                                                                              60),
                                                                      decoration: BoxDecoration(
                                                                          shape: BoxShape
                                                                              .circle,
                                                                          border: Border.all(
                                                                              width:
                                                                                  2,
                                                                              color: Colors
                                                                                  .black)),
                                                                      child: ClipOval(
                                                                          clipBehavior: Clip
                                                                              .antiAlias,
                                                                          child:
                                                                              Image.asset('assets/imgs/smc_logo.jpg'))),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  StreamBuilder<
                                                                          ResponseOb>(
                                                                      initialData: profileList
                                                                              .isNotEmpty
                                                                          ? null
                                                                          : ResponseOb(
                                                                              msgState: MsgState
                                                                                  .loading),
                                                                      stream: profileBloc
                                                                          .getProfileStream(),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        ResponseOb?
                                                                            responseOb =
                                                                            snapshot.data;
                                                                        if (responseOb?.msgState ==
                                                                            MsgState.data) {
                                                                          return Text(
                                                                            profileList.isEmpty
                                                                                ? '-'
                                                                                : profileList[0]['name'],
                                                                            style: const TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold),
                                                                          );
                                                                        } else if (responseOb?.msgState ==
                                                                            MsgState.error) {
                                                                          return const Text(
                                                                            'Something Went Wrong!',
                                                                            style: TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold),
                                                                          );
                                                                        } else {
                                                                          print(
                                                                              'Else');
                                                                          return Center(
                                                                            child:
                                                                                Image.asset(
                                                                              'assets/gifs/loading.gif',
                                                                              width: 100,
                                                                              height: 100,
                                                                            ),
                                                                          );
                                                                        }
                                                                      }),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            Expanded(
                                                              child: ListView(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10),
                                                                children: [
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // boxShadow: const [
                                                                      //   BoxShadow(
                                                                      //       color: Colors.black,
                                                                      //       offset: Offset(-2, 2),
                                                                      //       blurRadius: 2),
                                                                      // ],
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      // color: Colors.grey[200],
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                    ),
                                                                    height: 60,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return QuotationListPage();
                                                                          }), (route) => false);
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Image.asset(
                                                                              'assets/imgs/quotation_icon.png',
                                                                              color: Colors.white,
                                                                              width: 25,
                                                                              height: 25,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            const Text(
                                                                              'Quotations',
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        2,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      // boxShadow: const [
                                                                      //   BoxShadow(
                                                                      //       color: Colors.black,
                                                                      //       offset: Offset(-2, 2),
                                                                      //       blurRadius: 2),
                                                                      // ],
                                                                      // color: Colors.grey[200],
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                    ),
                                                                    height: 60,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return WayPlanningListPage();
                                                                          }), (route) => false);
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/imgs/way_plan_icon.png",
                                                                              color: Colors.white,
                                                                              width: 25,
                                                                              height: 25,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            const Text(
                                                                              'Way Planning',
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        2,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      // boxShadow: const [
                                                                      //   BoxShadow(
                                                                      //       color: Colors.black,
                                                                      //       offset: Offset(-2, 2),
                                                                      //       blurRadius: 2),
                                                                      // ],
                                                                      // color: Colors.grey[200],
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                    ),
                                                                    height: 60,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return MaterialRequisitionPage();
                                                                          }), (route) => false);
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/imgs/material_requisition_icon.png",
                                                                              color: Colors.white,
                                                                              width: 25,
                                                                              height: 25,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            const Text(
                                                                              'Material Requisition',
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        2,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      // boxShadow: const [
                                                                      //   BoxShadow(
                                                                      //       color: Colors.black,
                                                                      //       offset: Offset(-2, 2),
                                                                      //       blurRadius: 2),
                                                                      // ],
                                                                      // color: Colors.grey[200],
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                    ),
                                                                    height: 60,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return MaterialIssuesPage();
                                                                          }), (route) => false);
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/imgs/material_requisition_icon.png",
                                                                              color: Colors.white,
                                                                              width: 25,
                                                                              height: 25,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                const Text(
                                                                                  'Material Issues',
                                                                                  style: TextStyle(
                                                                                    fontSize: 20,
                                                                                    color: Colors.white,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Container(
                                                                                  padding: const EdgeInsets.all(5),
                                                                                  decoration: const BoxDecoration(
                                                                                    color: Colors.green,
                                                                                    shape: BoxShape.circle,
                                                                                  ),
                                                                                  child: Text(
                                                                                    '$issuseCount',
                                                                                    style: const TextStyle(
                                                                                      fontSize: 20,
                                                                                      color: Colors.white,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            )
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        2,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // boxShadow: const [
                                                                      //   BoxShadow(
                                                                      //       color: Colors.black,
                                                                      //       offset: Offset(-2, 2),
                                                                      //       blurRadius: 2),
                                                                      // ],
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      // color: Colors.grey[200],
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                    ),
                                                                    height: 60,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return ProductListPage();
                                                                          }), (route) => false);
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/imgs/product_icon.png",
                                                                              color: Colors.white,
                                                                              width: 25,
                                                                              height: 25,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            const Text(
                                                                              'Product',
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        2,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // boxShadow: const [
                                                                      //   BoxShadow(
                                                                      //       color: Colors.black,
                                                                      //       offset: Offset(-2, 2),
                                                                      //       blurRadius: 2),
                                                                      // ],
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      // color: Colors.grey[200],
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                    ),
                                                                    height: 60,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return SalePricelistTypePage();
                                                                          }), (route) => false);
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/imgs/sale_pricelist_icon.png",
                                                                              color: Colors.white,
                                                                              width: 25,
                                                                              height: 25,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            const Text(
                                                                              'Sale Pricelist',
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        2,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // boxShadow: const [
                                                                      //   BoxShadow(
                                                                      //       color: Colors.black,
                                                                      //       offset: Offset(-2, 2),
                                                                      //       blurRadius: 2),
                                                                      // ],
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      // color: Colors.grey[200],
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                    ),
                                                                    height: 60,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return CustomerListPage();
                                                                          }), (route) => false);
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/imgs/customer_icon.jpg",
                                                                              color: Colors.white,
                                                                              width: 25,
                                                                              height: 25,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            const Text(
                                                                              'Customers',
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        2,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // boxShadow: const [
                                                                      //   BoxShadow(
                                                                      //       color: Colors.black,
                                                                      //       offset: Offset(-2, 2),
                                                                      //       blurRadius: 2),
                                                                      // ],
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      // color: Colors.grey[200],
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                    ),
                                                                    height: 60,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:
                                                                              (context) {
                                                                            return ProfilePage();
                                                                          }), (route) => false);
                                                                        },
                                                                        child: Row(
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/imgs/profile_icon.png",
                                                                              color: Colors.white,
                                                                              width: 25,
                                                                              height: 25,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            const Text(
                                                                              'Profile',
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                  const Divider(
                                                                    thickness:
                                                                        2,
                                                                  ),
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.all(
                                                                            10),
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      // boxShadow: const [
                                                                      //   BoxShadow(
                                                                      //       color: Colors.black,
                                                                      //       offset: Offset(-2, 2),
                                                                      //       blurRadius: 2),
                                                                      // ],
                                                                      // borderRadius: BorderRadius.circular(10),
                                                                      // color: Colors.grey[200],
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                    ),
                                                                    height: 60,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return AlertDialog(
                                                                                  title: const Text("Do you want to Log Out?"),
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
                                                                                              return LogoutPage();
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
                                                                        child: Row(
                                                                          children: [
                                                                            Image.asset(
                                                                              "assets/imgs/logout_icon.png",
                                                                              color: Colors.white,
                                                                              width: 25,
                                                                              height: 25,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            const Text(
                                                                              'Log Out',
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      const Text("Version: 1.0")
                                                    ],
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
            )),
      ),
    );
  }
}
