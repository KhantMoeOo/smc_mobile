import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import '../../../../dbs/database_helper.dart';
import '../../../../dbs/sharef.dart';
import '../../../../obs/response_ob.dart';
import '../../../../pages/profile_page/profile_bloc.dart';
import '../../../../pages/quotation_page/quotation_bloc.dart';
import '../../../../pages/quotation_page/quotation_create_page.dart';
import '../../../../utils/app_const.dart';
import '../../../../widgets/quotation_widgets/quotation_card_widget.dart';
import '../menu_mb/menu_list_mb.dart';
import 'quotation_create_mb.dart';

class QuotationListMB extends StatefulWidget {
  const QuotationListMB({Key? key}) : super(key: key);

  @override
  State<QuotationListMB> createState() => _QuotationListMBState();
}

class _QuotationListMBState extends State<QuotationListMB> {
  final quotationBloc = QuotationBloc();
  final profileBloc = ProfileBloc();
  List<dynamic> quotationList = [];
  List<dynamic> userList = [];

  ScrollController scrollController = ScrollController();
  final searchController = TextEditingController();
  final databaseHelper = DatabaseHelper();
  bool isScroll = false;
  bool isSearch = false;
  bool searchDone = false;
  bool closeFilter = true;
  String filterName = '';
  String totalDraft = '';
  String totalSale = '';
  String totalCancel = '';

  late double screenHeight;
  late double screenWidth;
  late var listener;

  bool isConnection = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // screenHeight = MediaQuery.of(context).size.height;
    // screenWidth = MediaQuery.of(context).size.width;

    deleteAllDatabase();
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      print('listen');
      switch (status) {
        case InternetConnectionStatus.connected:
          print('Data connection is 1 available.');
          setState(() {
            isConnection = true;
            print('isConnection: $isConnection');
          });
          // quotationBloc.getQuotationData(
          //     name: ['name', 'ilike', ''], state: ['id', 'ilike', '']);
          break;
        case InternetConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          setState(() {
            isConnection = false;
            print('isConnection: $isConnection');
          });
          // Navigator.of(context).pushAndRemoveUntil(
          //     MaterialPageRoute(builder: (context) {
          //   return NoInternetConnectionMB();
          // }), (route) => false);
          break;
      }
    });
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);

    quotationBloc.getQuotationStream().listen(getQuotationListListen);

    // scrollController.addListener(scrollListener);
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      if (userList.isNotEmpty) {
        quotationBloc.getQuotationData(
            name: ['name', 'ilike', ''],
            state: ['id', 'ilike', ''],
            zoneId: userList[0]['zone_id'][0]);
      }
    }
  }

  void deleteAllDatabase() async {
    await databaseHelper.deleteAllHrEmployeeLine();
    await databaseHelper.deleteAllHrEmployeeLineUpdate();
    await databaseHelper.deleteAllSaleOrderLine();
    await databaseHelper.deleteAllSaleOrderLineUpdate();
    await databaseHelper.deleteAllMaterialProductLine();
    await databaseHelper.deleteAllMaterialProductLineUpdate();
    await databaseHelper.deleteAllProductLineMultiSelect();
    await databaseHelper.deleteAllStockMove();
    await databaseHelper.deleteAllStockMoveUpdate();
    await databaseHelper.deleteAllSaleOrderLineMultiSelect();
    await databaseHelper.deleteAllTripPlanDelivery();
    await databaseHelper.deleteAllTripPlanDeliveryUpdate();
    await databaseHelper.deleteAllTripPlanSchedule();
    await databaseHelper.deleteAllTripPlanScheduleUpdate();
    await databaseHelper.deleteAllAccountMoveLine();
    await databaseHelper.deleteAllAccountMoveLineUpdate();
    await databaseHelper.deleteAllTaxIds();
    await SharefCount.clearCount();
  }

  void getQuotationListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      quotationList = responseOb.data;
      totalDraft = quotationList
          .where((element) => element['state'] == 'draft')
          .length
          .toString();
      totalSale = quotationList
          .where((element) => element['state'] == 'sale')
          .length
          .toString();
      totalCancel = quotationList
          .where((element) => element['state'] == 'cancel')
          .length
          .toString();
      print(
          'Draft: ${quotationList.where((element) => element['state'] == 'draft').length}');
      print(
          'Sale Order: ${quotationList.where((element) => element['state'] == 'sale').length}');
      print(
          'Cancel: ${quotationList.where((element) => element['state'] == 'cancel').length}');
      // hasAccountTaxesData = true;
    } else if (responseOb.msgState == MsgState.error) {
      print("NoaccounttaxsList");
    }
  } // listen to get Account Taxes List

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    listener.cancel();
    scrollController.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ScreenHeight: ${MediaQuery.of(context).size.height}');
    print('ScreenWidth: ${MediaQuery.of(context).size.width}');
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
              builder: (context, AsyncSnapshot snapshot) {
                ResponseOb responseOb = snapshot.data;
                if (responseOb.msgState == MsgState.error) {
                  if (responseOb.errState == ErrState.severErr) {
                    return Scaffold(
                      body: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${responseOb.data}'),
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
                  } else if (responseOb.errState == ErrState.noConnection) {
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
                              body: Center(child: Column(
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
                } else if (responseOb.msgState == MsgState.loading) {
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
                    initialData: quotationList.isNotEmpty
                        ? null
                        : ResponseOb(msgState: MsgState.loading),
                    stream: quotationBloc.getQuotationStream(),
                    builder: (context, AsyncSnapshot snapshot) {
                      ResponseOb responseOb = snapshot.data;
                      if (responseOb.msgState == MsgState.data) {
                        quotationList = responseOb.data;
                        return Stack(
                          children: [
                            Scaffold(
                              backgroundColor: Colors.grey[200],
                              appBar: AppBar(
                                elevation: 0.0,
                                backgroundColor: AppColors.appBarColor,
                                leading: IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return const MenuListMB();
                                    }));
                                  },
                                  icon: const Icon(Icons.menu),
                                ),
                                // backgroundColor: Color.fromARGB(255, 12, 41, 92),
                                title: Text(
                                    "Quotation (${userList[0]['zone_id'][1]})"),
                                actions: [
                                  Visibility(
                                      visible:
                                          MediaQuery.of(context).size.width >
                                                  400.0
                                              ? false
                                              : true,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return QuotationCreateMB(
                                              quotationId: 0,
                                              name: '',
                                              userid: [],
                                              customerId: [],
                                              dateOrder: '',
                                              validityDate: '',
                                              currencyId: [],
                                              exchangeRate: '',
                                              pricelistId: [],
                                              paymentTermId: [],
                                              zoneId: [],
                                              segmentId: [],
                                              regionId: [],
                                              newOrEdit: 2,
                                              productlineList: [],
                                              filter: '',
                                              zoneFilterId: 0,
                                              segmentFilterId: 0,
                                              userzoneId: userList[0]['zone_id'],
                                            );
                                          })).then((value) {
                                            setState(() {
                                              quotationBloc.getQuotationData(
                                                  name: ['name', 'ilike', ''],
                                                  state: ['id', 'ilike', ''],
                                                  zoneId: userList[0]['zone_id']
                                                      [0]);
                                            });
                                          });
                                        },
                                        child: const Text("Create",
                                            style: TextStyle(
                                              color: Colors.white,
                                            )),
                                      ))
                                ],
                              ),
                              body: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
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
                                                          searchController,
                                                      decoration:
                                                          InputDecoration(
                                                              prefix: closeFilter ==
                                                                      true
                                                                  ? const Text(
                                                                      '')
                                                                  : Directionality(
                                                                      textDirection:
                                                                          TextDirection
                                                                              .rtl,
                                                                      child: TextButton.icon(
                                                                          onPressed: () {
                                                                            setState(() {
                                                                              closeFilter = true;
                                                                              filterName = '';
                                                                            });
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'name',
                                                                              'ilike',
                                                                              ''
                                                                            ], state: [
                                                                              'id',
                                                                              'ilike',
                                                                              ''
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          },
                                                                          label: Text(filterName == 'draft'
                                                                              ? 'Quotation'
                                                                              : filterName == 'sale'
                                                                                  ? 'Sale Order'
                                                                                  : 'Cancelled'),
                                                                          icon: const Icon(Icons.close)),
                                                                    ),
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              suffixIcon:
                                                                  IconButton(
                                                                onPressed: () {
                                                                  if (searchDone ==
                                                                      true) {
                                                                    setState(
                                                                        () {
                                                                      searchController
                                                                          .clear();
                                                                      searchDone =
                                                                          false;
                                                                      closeFilter =
                                                                          true;
                                                                      filterName =
                                                                          '';
                                                                      quotationBloc.getQuotationData(
                                                                          name: [
                                                                            'name',
                                                                            'ilike',
                                                                            ''
                                                                          ],
                                                                          state: [
                                                                            'id',
                                                                            'ilike',
                                                                            ''
                                                                          ],
                                                                          zoneId:
                                                                              userList[0]['zone_id'][0]);
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      searchDone =
                                                                          true;
                                                                      isSearch =
                                                                          false;
                                                                      quotationBloc.getQuotationData(
                                                                          name: [
                                                                            'name',
                                                                            'ilike',
                                                                            searchController.text
                                                                          ],
                                                                          state: [
                                                                            'id',
                                                                            'ilike',
                                                                            ''
                                                                          ],
                                                                          zoneId:
                                                                              userList[0]['zone_id'][0]);
                                                                    });
                                                                  }
                                                                },
                                                                icon: searchDone ==
                                                                        true
                                                                    ? const Icon(
                                                                        Icons
                                                                            .close)
                                                                    : const Icon(
                                                                        Icons
                                                                            .search),
                                                              ),
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10))),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Visibility(
                                                    visible:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                400.0
                                                            ? true
                                                            : false,
                                                    child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: Colors.green,
                                                        ),
                                                        width: 60,
                                                        child: TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .push(MaterialPageRoute(
                                                                    builder:
                                                                        (context) {
                                                              return QuotationCreateMB(
                                                                quotationId: 0,
                                                                name: '',
                                                                userid: [],
                                                                customerId: [],
                                                                dateOrder: '',
                                                                validityDate:
                                                                    '',
                                                                currencyId: [],
                                                                exchangeRate:
                                                                    '',
                                                                pricelistId: [],
                                                                paymentTermId: [],
                                                                zoneId: [],
                                                                segmentId: [],
                                                                regionId: [],
                                                                newOrEdit: 2,
                                                                productlineList: [],
                                                                filter: '',
                                                                zoneFilterId: 0,
                                                                segmentFilterId:
                                                                    0,
                                                                    userzoneId: userList[0]['zone_id']
                                                              );
                                                            })).then((value) {
                                                              setState(() {
                                                                quotationBloc.getQuotationData(
                                                                    name: [
                                                                      'name',
                                                                      'ilike',
                                                                      ''
                                                                    ],
                                                                    state: [
                                                                      'id',
                                                                      'ilike',
                                                                      ''
                                                                    ],
                                                                    zoneId: userList[
                                                                            0][
                                                                        'zone_id'][0]);
                                                              });
                                                            });
                                                          },
                                                          child: const Text(
                                                              "Create",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              )),
                                                        )),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  "Quotation Total: " +
                                                      quotationList.length
                                                          .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                )),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.yellow,
                                                  ),
                                                  child: TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          closeFilter = false;
                                                          filterName = 'draft';
                                                        });
                                                        quotationBloc
                                                            .getQuotationData(
                                                                name: [
                                                              'name',
                                                              'ilike',
                                                              ''
                                                            ],
                                                                state: [
                                                              'state',
                                                              'ilike',
                                                              'draft'
                                                            ],
                                                                zoneId: userList[
                                                                            0][
                                                                        'zone_id']
                                                                    [0]);
                                                      },
                                                      child: Text(
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                400.0
                                                            ? 'Total Draft: ($totalDraft)'
                                                            : 'Total Draft:\n ($totalDraft)',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      )),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.green,
                                                  ),
                                                  child: TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          closeFilter = false;
                                                          filterName = 'sale';
                                                        });
                                                        quotationBloc
                                                            .getQuotationData(
                                                                name: [
                                                              'name',
                                                              'ilike',
                                                              ''
                                                            ],
                                                                state: [
                                                              'state',
                                                              'ilike',
                                                              'sale'
                                                            ],
                                                                zoneId: userList[
                                                                            0][
                                                                        'zone_id']
                                                                    [0]);
                                                      },
                                                      child: Text(
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                400.0
                                                            ? 'Total Sale: ($totalSale)'
                                                            : 'Total Sale:\n ($totalSale)',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      )),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.red,
                                                  ),
                                                  child: TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          closeFilter = false;
                                                          filterName = 'cancel';
                                                        });
                                                        quotationBloc
                                                            .getQuotationData(
                                                                name: [
                                                              'name',
                                                              'ilike',
                                                              ''
                                                            ],
                                                                state: [
                                                              'state',
                                                              'ilike',
                                                              'cancel'
                                                            ],
                                                                zoneId: userList[
                                                                            0][
                                                                        'zone_id']
                                                                    [0]);
                                                      },
                                                      child: Text(
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                400.0
                                                            ? 'Total Cancelled: ($totalCancel)'
                                                            : 'Total Cancelled:\n ($totalCancel)',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.black),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      quotationList.isEmpty
                                          ? const Center(
                                              child: Text("No Data"),
                                            )
                                          : Expanded(
                                              child: Stack(
                                                children: [
                                                  ListView.builder(
                                                      controller:
                                                          scrollController,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              right: 10,
                                                              top: 10),
                                                      itemCount:
                                                          quotationList.length,
                                                      itemBuilder:
                                                          (context, i) {
                                                        return QuotationCardWidget(
                                                          quotationId:
                                                              quotationList[i]
                                                                  ['id'],
                                                          name: quotationList[i]
                                                              ['name'],
                                                          userid: quotationList[
                                                                  i]['user_id'],
                                                          customerId:
                                                              quotationList[i][
                                                                  'partner_id'],
                                                          amountTotal:
                                                              quotationList[i][
                                                                      'amount_total']
                                                                  .toString(),
                                                          state:
                                                              quotationList[i]
                                                                      ['state']
                                                                  .toString(),
                                                          createTime:
                                                              quotationList[i][
                                                                  'create_date'],
                                                          expectedDate:
                                                              quotationList[i][
                                                                      'expected_date']
                                                                  .toString(),
                                                          dateOrder:
                                                              quotationList[i][
                                                                  'date_order'],
                                                          validityDate:
                                                              quotationList[i][
                                                                      'validity_date']
                                                                  .toString(),
                                                          currencyId: quotationList[
                                                                          i][
                                                                      'currency_id'] ==
                                                                  false
                                                              ? []
                                                              : quotationList[i]
                                                                  [
                                                                  'currency_id'],
                                                          exchangeRate:
                                                              quotationList[i][
                                                                      'exchange_rate']
                                                                  .toString(),
                                                          pricelistId:
                                                              quotationList[i][
                                                                  'pricelist_id'],
                                                          paymentTermId: quotationList[
                                                                          i][
                                                                      'payment_term_id'] ==
                                                                  false
                                                              ? []
                                                              : quotationList[i]
                                                                  [
                                                                  'pricelist_id'],
                                                          zoneId: quotationList[
                                                                          i][
                                                                      'zone_id'] ==
                                                                  false
                                                              ? []
                                                              : quotationList[i]
                                                                  ['zone_id'],
                                                          segmentId: quotationList[
                                                                          i][
                                                                      'segment_id'] ==
                                                                  false
                                                              ? []
                                                              : quotationList[i]
                                                                  [
                                                                  'segment_id'],
                                                          regionId: quotationList[
                                                                          i][
                                                                      'region_id'] ==
                                                                  false
                                                              ? []
                                                              : quotationList[i]
                                                                  ['region_id'],
                                                          filterBy: quotationList[
                                                                          i][
                                                                      'customer_filter'] ==
                                                                  false
                                                              ? ''
                                                              : quotationList[i]
                                                                  [
                                                                  'customer_filter'],
                                                          zoneFilterId: quotationList[
                                                                          i][
                                                                      'zone_filter_id'] ==
                                                                  false
                                                              ? []
                                                              : quotationList[i]
                                                                  [
                                                                  'zone_filter_id'],
                                                          segmentFilterId: quotationList[
                                                                          i][
                                                                      'seg_filter_id'] ==
                                                                  false
                                                              ? []
                                                              : quotationList[i]
                                                                  [
                                                                  'seg_filter_id'],
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
                                                  //           child: const Icon(Icons.add))),
                                                  // ),
                                                  Visibility(
                                                    visible: isSearch,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              5),
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 15,
                                                              right: 15),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color:
                                                              Colors.grey[200],
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.black,
                                                              blurRadius: 2,
                                                              offset:
                                                                  Offset(0, 0),
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
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            isSearch =
                                                                                false;
                                                                            searchDone =
                                                                                true;
                                                                            // quotationBloc
                                                                            //       .getQuotationData(
                                                                            //           name: [
                                                                            //         'name',
                                                                            //         'ilike',
                                                                            //         searchController
                                                                            //             .text
                                                                            //       ],
                                                                            //           state: [
                                                                            //         'state',
                                                                            //         'ilike',
                                                                            //         'draft'
                                                                            //       ]);
                                                                            if (filterName ==
                                                                                'draft') {
                                                                              quotationBloc.getQuotationData(name: [
                                                                                'name',
                                                                                'ilike',
                                                                                searchController.text
                                                                              ], state: [
                                                                                'state',
                                                                                '=',
                                                                                'draft'
                                                                              ], zoneId: userList[0]['zone_id'][0]);
                                                                            } else if (filterName ==
                                                                                'sale') {
                                                                              quotationBloc.getQuotationData(name: [
                                                                                'name',
                                                                                'ilike',
                                                                                searchController.text
                                                                              ], state: [
                                                                                'state',
                                                                                '=',
                                                                                'sale'
                                                                              ], zoneId: userList[0]['zone_id'][0]);
                                                                            } else if (filterName ==
                                                                                'cancel') {
                                                                              quotationBloc.getQuotationData(name: [
                                                                                'name',
                                                                                'ilike',
                                                                                searchController.text
                                                                              ], state: [
                                                                                'state',
                                                                                '=',
                                                                                'cancel'
                                                                              ], zoneId: userList[0]['zone_id'][0]);
                                                                            } else {
                                                                              quotationBloc.getQuotationData(name: [
                                                                                'name',
                                                                                'ilike',
                                                                                searchController.text
                                                                              ], state: [
                                                                                'id',
                                                                                'ilike',
                                                                                ''
                                                                              ], zoneId: userList[0]['zone_id'][0]);
                                                                            }
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          height:
                                                                              50,
                                                                          child: RichText(
                                                                              text: TextSpan(children: [
                                                                            const TextSpan(
                                                                                text: "Search Order for: ",
                                                                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
                                                                            TextSpan(
                                                                                text: searchController.text,
                                                                                style: const TextStyle(fontSize: 15, color: Colors.black))
                                                                          ])),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const Divider(
                                                                  thickness:
                                                                      1.5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            isSearch =
                                                                                false;
                                                                            searchDone =
                                                                                true;
                                                                            if (filterName ==
                                                                                'draft') {
                                                                              quotationBloc.getQuotationData(name: [
                                                                                'partner_id',
                                                                                'ilike',
                                                                                searchController.text
                                                                              ], state: [
                                                                                'state',
                                                                                '=',
                                                                                'draft'
                                                                              ], zoneId: userList[0]['zone_id'][0]);
                                                                            } else if (filterName ==
                                                                                'sale') {
                                                                              quotationBloc.getQuotationData(name: [
                                                                                'partner_id',
                                                                                'ilike',
                                                                                searchController.text
                                                                              ], state: [
                                                                                'state',
                                                                                '=',
                                                                                'sale'
                                                                              ], zoneId: userList[0]['zone_id'][0]);
                                                                            } else if (filterName ==
                                                                                'cancel') {
                                                                              quotationBloc.getQuotationData(name: [
                                                                                'partner_id',
                                                                                'ilike',
                                                                                searchController.text
                                                                              ], state: [
                                                                                'state',
                                                                                '=',
                                                                                'cancel'
                                                                              ], zoneId: userList[0]['zone_id'][0]);
                                                                            } else {
                                                                              quotationBloc.getQuotationData(name: [
                                                                                'name',
                                                                                'ilike',
                                                                                searchController.text
                                                                              ], state: [
                                                                                'id',
                                                                                'ilike',
                                                                                ''
                                                                              ], zoneId: userList[0]['zone_id'][0]);
                                                                            }
                                                                          });
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          height:
                                                                              50,
                                                                          child: RichText(
                                                                              text: TextSpan(children: [
                                                                            const TextSpan(
                                                                                text: "Search Customer for: ",
                                                                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                            TextSpan(
                                                                                text: searchController.text,
                                                                                style: const TextStyle(color: Colors.black))
                                                                          ])),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const Divider(
                                                                  thickness:
                                                                      1.5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          isSearch =
                                                                              false;
                                                                          searchDone =
                                                                              true;
                                                                          if (filterName ==
                                                                              'draft') {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'user_id',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'state',
                                                                              '=',
                                                                              'draft'
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          } else if (filterName ==
                                                                              'sale') {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'user_id',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'state',
                                                                              '=',
                                                                              'sale'
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          } else if (filterName ==
                                                                              'cancel') {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'user_id',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'state',
                                                                              '=',
                                                                              'cancel'
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          } else {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'name',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'id',
                                                                              'ilike',
                                                                              ''
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          height:
                                                                              50,
                                                                          child: RichText(
                                                                              text: TextSpan(children: [
                                                                            const TextSpan(
                                                                                text: "Search Saleperson for: ",
                                                                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                            TextSpan(
                                                                                text: searchController.text,
                                                                                style: const TextStyle(color: Colors.black))
                                                                          ])),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const Divider(
                                                                  thickness:
                                                                      1.5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          isSearch =
                                                                              false;
                                                                          searchDone =
                                                                              true;
                                                                          if (filterName ==
                                                                              'draft') {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'order_line.product_id',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'state',
                                                                              '=',
                                                                              'draft'
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          } else if (filterName ==
                                                                              'sale') {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'order_line.product_id',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'state',
                                                                              '=',
                                                                              'sale'
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          } else if (filterName ==
                                                                              'cancel') {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'order_line.product_id',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'state',
                                                                              '=',
                                                                              'cancel'
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          } else {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'name',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'id',
                                                                              'ilike',
                                                                              ''
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          height:
                                                                              50,
                                                                          child: RichText(
                                                                              text: TextSpan(children: [
                                                                            const TextSpan(
                                                                                text: "Search Product Code for: ",
                                                                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                            TextSpan(
                                                                                text: searchController.text,
                                                                                style: const TextStyle(color: Colors.black))
                                                                          ])),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const Divider(
                                                                  thickness:
                                                                      1.5,
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          InkWell(
                                                                        onTap:
                                                                            () {
                                                                          isSearch =
                                                                              false;
                                                                          searchDone =
                                                                              true;
                                                                          if (filterName ==
                                                                              'draft') {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'order_line.product_name',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'state',
                                                                              '=',
                                                                              'draft'
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          } else if (filterName ==
                                                                              'sale') {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'order_line.product_name',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'state',
                                                                              '=',
                                                                              'sale'
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          } else if (filterName ==
                                                                              'cancel') {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'order_line.product_name',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'state',
                                                                              '=',
                                                                              'cancel'
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          } else {
                                                                            quotationBloc.getQuotationData(name: [
                                                                              'name',
                                                                              'ilike',
                                                                              searchController.text
                                                                            ], state: [
                                                                              'id',
                                                                              'ilike',
                                                                              ''
                                                                            ], zoneId: userList[0]['zone_id'][0]);
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          height:
                                                                              50,
                                                                          child: RichText(
                                                                              text: TextSpan(children: [
                                                                            const TextSpan(
                                                                                text: "Search Product Name for: ",
                                                                                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black, fontWeight: FontWeight.bold)),
                                                                            TextSpan(
                                                                                text: searchController.text,
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else if (responseOb.msgState == MsgState.error) {
                        if (responseOb.errState == ErrState.severErr) {
                          return Scaffold(
                            body: Center(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${responseOb.data}'),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextButton(
                                    onPressed: () {
                                      if (userList.isNotEmpty) {
                                        quotationBloc.getQuotationData(
                                            name: ['name', 'ilike', ''],
                                            state: ['id', 'ilike', ''],
                                            zoneId: userList[0]['zone_id'][0]);
                                      }
                                    },
                                    child: const Text('Try Again'))
                              ],
                            )),
                          );
                        } else if (responseOb.errState ==
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
                                      if (userList.isNotEmpty) {
                                        quotationBloc.getQuotationData(
                                            name: ['name', 'ilike', ''],
                                            state: ['id', 'ilike', ''],
                                            zoneId: userList[0]['zone_id'][0]);
                                      }
                                    },
                                    child: const Text('Try Again'))
                              ],
                            )),
                          );
                        } else {
                          return Scaffold(
                              body: Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Unknown Error'),
                            const SizedBox(
                              height: 20,
                            ),
                            TextButton(
                                onPressed: () {
                                  quotationBloc.getQuotationData(
                                            name: ['name', 'ilike', ''],
                                            state: ['id', 'ilike', ''],
                                            zoneId: userList[0]['zone_id'][0]);
                                },
                                child: const Text('Try Again'))
                          ],
                        )),
                            );
                        }
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
              })),
    );
  }
}
