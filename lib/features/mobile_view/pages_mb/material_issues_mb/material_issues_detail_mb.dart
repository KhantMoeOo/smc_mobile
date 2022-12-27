import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../../dbs/database_helper.dart';
import '../../../../dbs/sharef.dart';
import '../../../../obs/response_ob.dart';
import '../../../../obs/stock_move_ob.dart';
import '../../../../pages/delivery_page/delivery_bloc.dart';
import '../../../../pages/delivery_page/delivery_create_bloc.dart';
import '../../../../pages/material_issues_page/material_isssues_bloc.dart';
import '../../../../pages/quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import '../../../../utils/app_const.dart';
import 'material_issues_list_mb.dart';

class MaterialIssuesDetailMB extends StatefulWidget {
  int id;
  MaterialIssuesDetailMB({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<MaterialIssuesDetailMB> createState() => _MaterialIssuesDetailMBState();
}

class _MaterialIssuesDetailMBState extends State<MaterialIssuesDetailMB> {
  final stockpickingBloc = StockPickingBloc();
  final materialissuesBloc = MaterialIssuesBloc();
  final stockpickingcreateBloc = StockPickingCreateBloc();
  final saleorderlineBloc = SaleOrderLineBloc();
  final databaseHelper = DatabaseHelper();
  List<dynamic> stockpickingList = [];
  List<dynamic> stockmoveList = [];
  List<StockMoveOb>? stockmoveDBList = [];
  bool isCallActionValidate = false;
  bool isCallActionConfirm = false;
  bool isCallActionProcess = false;
  bool isUpdateQtyDone = false;
  final isDialOpen = ValueNotifier(false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stockpickingBloc.getStockPickingData(['id', '=', widget.id]);
    stockpickingBloc.getStockPickingStream().listen(getStockPickingListListen);
    stockpickingBloc.getStockMoveStream().listen(getStockMoveListListen);
    materialissuesBloc
        .getCallActionConfirmStream()
        .listen(callactionvalidateListen);
    stockpickingcreateBloc.getUpdateQtyDoneStream().listen(updateQtyDoneListen);
    materialissuesBloc
        .getCallActionConfirmIssueStream()
        .listen(callactionconfirmListen);
    saleorderlineBloc.waitingproductlineListStream().listen(waitingState);
  }

  Future<void> getproductlineListFromDB() async {
    print('Worked');
    for (var element in stockmoveList) {
      final stockmoveOb = StockMoveOb(
        isSelect: 1,
        pickigId: element['picking_id'][0],
        productCodeName: element['product_id'][1],
        productCodeId: element['product_id'][0],
        description: element['name'],
        fullName: '${element['product_id'][0]} ${element['name']}',
        demand: element['product_uom_qty'].toString(),
        reserved: element['product_uom_qty'].toString(),
        done: element['quantity_done'].toString(),
        remainingstock: element['remaining_qty'].toString(),
        damageQty: element['damage_qty'].toString(),
        uomName: element['product_uom'][1],
        uomId: element['product_uom'][0],
        locationDestId: element['location_dest_id'][0],
        locationDestName: element['location_dest_id'][1],
        locationId: element['location_id'][0],
        locationName: element['location_id'][1],
      );
      await databaseHelper.insertStockMoveUpdate(stockmoveOb);
    }

    setState(() {});
  }

  void getStockPickingListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockpickingList = responseOb.data;
      stockpickingBloc.getStockMoveData(stockpickingList[0]['id']);
    } else if (responseOb.msgState == MsgState.error) {
      print('No Stock Picking List');
    }
  }

  void getStockMoveListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockmoveList = responseOb.data;
      if (stockmoveList.isNotEmpty) {
        getproductlineListFromDB();
      }
    }
  }

  void callactionvalidateListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isCallActionValidate = false;
      });
      stockpickingBloc.getStockPickingData(['id', '=', widget.id]);
    }
  }

  void callactionconfirmListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isCallActionConfirm = false;
        isUpdateQtyDone = true;
      });
      for (var stockmove in stockmoveList) {
        stockpickingcreateBloc.updateQtyDoneData(
            stockmove['id'], stockmove['product_uom_qty']);
      }
    }
  }

  void updateQtyDoneListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      // setState(() {
      //   isUpdateQtyDone = false;
      // });
      SharefCount.setTotal(stockmoveList.length);
      saleorderlineBloc.waitingSaleOrderLineData();
    }
  }

  void waitingState(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isUpdateQtyDone = false;
      });
      stockpickingBloc.getStockPickingData(['id', '=', widget.id]);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    materialissuesBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
          await databaseHelper.deleteAllStockMoveUpdate();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return MaterialIssuesListMB();
          }), (route) => false);
          return true;
        }
      },
      child: SafeArea(
          child: StreamBuilder<ResponseOb>(
              initialData: ResponseOb(msgState: MsgState.loading),
              stream: stockpickingBloc.getStockPickingStream(),
              builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                ResponseOb? responseOb = snapshot.data;
                if (responseOb?.msgState == MsgState.data) {
                  return Stack(
                    children: [
                      Scaffold(
                          backgroundColor: Colors.grey[200],
                          appBar: AppBar(
                            backgroundColor: AppColors.appBarColor,
                            title: Text(
                              stockpickingList[0]['name'],
                            ),
                            // actions: [
                            //   // Visibility(
                            //   //   visible:
                            //   //       stockpickingList[0]['state'] == 'assigned'
                            //   //           ? true
                            //   //           : false,
                            //   //   child: TextButton(
                            //   //       onPressed: () async {
                            //   //         await databaseHelper
                            //   //             .deleteAllStockMoveUpdate();
                            //   //         materialissuesBloc
                            //   //             .callActionConfirm(widget.id);
                            //   //       },
                            //   //       child: const Text('Confirm')),
                            //   // )
                            // ],
                          ),
                          body: FutureBuilder<List<StockMoveOb>>(
                              future: databaseHelper.getStockMoveUpdateList(),
                              builder: (context, snapshot) {
                                stockmoveDBList = snapshot.data;
                                Widget stockmoveWidget = SliverToBoxAdapter(
                                  child: Container(),
                                );
                                if (snapshot.hasData) {
                                  stockmoveWidget = SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                    (context, i) {
                                      print(
                                          'SOLLength------------: ${stockmoveDBList?.length}');
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(10),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                // borderRadius:
                                                //     BorderRadius.circular(10),
                                                // boxShadow: const [
                                                //   BoxShadow(
                                                //     color: Colors.black,
                                                //     offset: Offset(0, 0),
                                                //     blurRadius: 2,
                                                //   )
                                                // ]
                                              ),
                                              child: ExpandablePanel(
                                                  header: Row(
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        child: const Text(
                                                          'Product: ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
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
                                                                  stockmoveDBList![
                                                                          i]
                                                                      .productCodeName,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18),
                                                                )
                                                              ]))
                                                    ],
                                                  ),
                                                  collapsed: Row(
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        child: const Text(
                                                          'Description: ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                            Text(
                                                              stockmoveDBList![
                                                                      i]
                                                                  .description,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 18),
                                                            )
                                                          ]))
                                                    ],
                                                  ),
                                                  expanded: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Description: ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  Text(
                                                                    stockmoveDBList![
                                                                            i]
                                                                        .description,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                ])),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'From: ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  Text(
                                                                    stockmoveDBList![
                                                                            i]
                                                                        .locationName!,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                ])),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'From: ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  Text(
                                                                    stockmoveDBList![
                                                                            i]
                                                                        .locationDestName!,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                ])),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Reserved: ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  Text(
                                                                    stockmoveDBList![
                                                                            i]
                                                                        .reserved!,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                ])),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Done: ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  Text(
                                                                    stockmoveDBList![
                                                                            i]
                                                                        .done!,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                ])),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'UOM: ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  Text(
                                                                    stockmoveDBList![
                                                                            i]
                                                                        .uomName,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                ])),
                                                          ],
                                                        ),
                                                        // Row(
                                                        //   children: [
                                                        //     const SizedBox(
                                                        //       width: 200,
                                                        //       child: Text(
                                                        //         'Remaining Stock: ',
                                                        //         style: TextStyle(
                                                        //             fontSize: 20,
                                                        //             fontWeight:
                                                        //                 FontWeight
                                                        //                     .bold,
                                                        //             color:
                                                        //                 Colors.black),
                                                        //       ),
                                                        //     ),
                                                        //     Expanded(
                                                        //         child: Column(
                                                        //             crossAxisAlignment:
                                                        //                 CrossAxisAlignment
                                                        //                     .start,
                                                        //             children: [
                                                        //           Text(
                                                        //             stockmoveDBList![
                                                        //                     i]
                                                        //                 .remainingstock!,
                                                        //             style: const TextStyle(
                                                        //                 color: Colors
                                                        //                     .black,
                                                        //                 fontSize: 18),
                                                        //           )
                                                        //         ])),
                                                        //   ],
                                                        // ),
                                                      ]))),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      );
                                    },
                                    childCount: stockmoveDBList!.length,
                                  ));
                                } else {
                                  stockmoveWidget = SliverToBoxAdapter(
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/loading.gif',
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  );
                                }
                                return Stack(
                                  children: [
                                    CustomScrollView(slivers: [
                                      SliverPadding(
                                        padding: const EdgeInsets.all(8),
                                        sliver: SliverList(
                                          delegate: SliverChildListDelegate([
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 50,
                                                    ),
                                                    Text(
                                                        '${stockpickingList[0]['name']}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                            fontSize: 30)),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Delivery Address',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        const Text(
                                                          ':  ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                  '${stockpickingList[0]['partner_id'] == false ? '' : stockpickingList[0]['partner_id'][1]}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18))
                                                            ])),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Ref No.',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        const Text(
                                                          ':  ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                  '${stockpickingList[0]['ref_no'] == false ? '' : stockpickingList[0]['ref_no']}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18))
                                                            ])),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Operation Type',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        const Text(
                                                          ':  ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                  '${stockpickingList[0]['picking_type_id'][1]}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18))
                                                            ])),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Source Location',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        const Text(
                                                          ':  ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                  '${stockpickingList[0]['location_id'][1]}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18))
                                                            ])),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Destination Location',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        const Text(
                                                          ':  ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                  '${stockpickingList[0]['location_dest_id'][1]}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18))
                                                            ])),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Scheduled Date',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        const Text(
                                                          ':  ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                  '${stockpickingList[0]['scheduled_date']}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18))
                                                            ])),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Source Document',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        const Text(
                                                          ':  ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Text(
                                                                  '${stockpickingList[0]['origin'] == false ? '' : stockpickingList[0]['origin']}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18))
                                                            ])),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          width: 200,
                                                          child: Text(
                                                            'Included NCR',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        const Text(
                                                          ':  ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        Expanded(
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                              Icon(stockpickingList[
                                                                              0]
                                                                          [
                                                                          'is_ncr_complaint'] ==
                                                                      false
                                                                  ? Icons
                                                                      .check_box_outline_blank
                                                                  : Icons
                                                                      .check_box)
                                                            ])),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                  ]),
                                            )
                                          ]),
                                        ),
                                      ),
                                      SliverPadding(
                                        padding: const EdgeInsets.all(8),
                                        sliver: SliverToBoxAdapter(
                                            child: Container(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10),
                                          height: 50,
                                          width: 20,
                                          color: Colors.white,
                                          child: const Text(
                                            "Operations",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        )),
                                      ),
                                      SliverPadding(
                                        padding: const EdgeInsets.all(8),
                                        sliver: stockmoveWidget,
                                      ),
                                      const SliverToBoxAdapter(
                                        child: SizedBox(height: 20),
                                      ),
                                    ]),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, right: 10),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          // width: 100,
                                          // height: 60,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            // color: AppColors.appBarColor,
                                          ),
                                          child:
                                              //MediaQuery.of(context).size.width > 400.0
                                              //     ? SpeedDial(
                                              //         buttonSize: 80,
                                              //         childrenButtonSize: 100,
                                              //         backgroundColor: Colors.transparent,
                                              //         elevation: 0.0,
                                              //         activeChild: const Icon(
                                              //           Icons.close,
                                              //           color: AppColors.appBarColor,
                                              //         ),
                                              //         child: stockpickingList[0]['state'] ==
                                              //                 'draft'
                                              //             ? Container(
                                              //                 width: 80,
                                              //                 height: 40,
                                              //                 decoration: BoxDecoration(
                                              //                   color: AppColors.appBarColor,
                                              //                   borderRadius:
                                              //                       BorderRadius.circular(10),
                                              //                 ),
                                              //                 child: const Center(
                                              //                   child: Text('Draft',
                                              //                       textAlign: TextAlign.center,
                                              //                       style: TextStyle(
                                              //                           fontSize: 10)),
                                              //                 ),
                                              //               )
                                              //             : stockpickingList[0]['state'] ==
                                              //                     'confirmed'
                                              //                 ? Container(
                                              //                     width: 80,
                                              //                     height: 40,
                                              //                     decoration: BoxDecoration(
                                              //                       color:
                                              //                           AppColors.appBarColor,
                                              //                       borderRadius:
                                              //                           BorderRadius.circular(
                                              //                               10),
                                              //                     ),
                                              //                     child: const Center(
                                              //                       child: Text('Waiting',
                                              //                           textAlign:
                                              //                               TextAlign.center,
                                              //                           style: TextStyle(
                                              //                               fontSize: 10)),
                                              //                     ),
                                              //                   )
                                              //                 : stockpickingList[0]['state'] ==
                                              //                         'assigned'
                                              //                     ? Container(
                                              //                         width: 80,
                                              //                         height: 40,
                                              //                         decoration: BoxDecoration(
                                              //                           color: AppColors
                                              //                               .appBarColor,
                                              //                           borderRadius:
                                              //                               BorderRadius
                                              //                                   .circular(10),
                                              //                         ),
                                              //                         child: const Center(
                                              //                           child: Text('Ready',
                                              //                               textAlign: TextAlign
                                              //                                   .center,
                                              //                               style: TextStyle(
                                              //                                   fontSize: 10)),
                                              //                         ),
                                              //                       )
                                              //                     : stockpickingList[0]
                                              //                                 ['state'] ==
                                              //                             'done'
                                              //                         ? Container(
                                              //                             width: 80,
                                              //                             height: 40,
                                              //                             decoration:
                                              //                                 BoxDecoration(
                                              //                               color: AppColors
                                              //                                   .appBarColor,
                                              //                               borderRadius:
                                              //                                   BorderRadius
                                              //                                       .circular(
                                              //                                           10),
                                              //                             ),
                                              //                             child: const Center(
                                              //                               child: Text('Done',
                                              //                                   textAlign:
                                              //                                       TextAlign
                                              //                                           .center,
                                              //                                   style: TextStyle(
                                              //                                       fontSize:
                                              //                                           10)),
                                              //                             ),
                                              //                           )
                                              //                         : Container(
                                              //                             width: 80,
                                              //                             height: 40,
                                              //                             decoration:
                                              //                                 BoxDecoration(
                                              //                               color: AppColors
                                              //                                   .appBarColor,
                                              //                               borderRadius:
                                              //                                   BorderRadius
                                              //                                       .circular(
                                              //                                           10),
                                              //                             ),
                                              //                             child: const Center(
                                              //                               child: Text(
                                              //                                   'Cancelled',
                                              //                                   textAlign:
                                              //                                       TextAlign
                                              //                                           .center,
                                              //                                   style: TextStyle(
                                              //                                       fontSize:
                                              //                                           10)),
                                              //                             ),
                                              //                           ),
                                              //         spaceBetweenChildren: 5,
                                              //         direction: SpeedDialDirection.left,
                                              //         renderOverlay: false,
                                              //         children: [
                                              //             SpeedDialChild(
                                              //               backgroundColor: Colors.transparent,
                                              //               elevation: 0.0,
                                              //               child: Container(
                                              //                 height: 40,
                                              //                 width: 80,
                                              //                 decoration: BoxDecoration(
                                              //                     border: Border.all(width: 1),
                                              //                     borderRadius:
                                              //                         BorderRadius.circular(10),
                                              //                     color: stockpickingList[0]
                                              //                                 ['state'] ==
                                              //                             'cancel'
                                              //                         ? AppColors.appBarColor
                                              //                         : Colors.white),
                                              //                 child: Center(
                                              //                   child: Text(
                                              //                     "Cancelled",
                                              //                     style: TextStyle(
                                              //                         color: stockpickingList[0]
                                              //                                     ['state'] ==
                                              //                                 'cancel'
                                              //                             ? Colors.white
                                              //                             : Colors.grey,
                                              //                         fontSize: 15),
                                              //                   ),
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //             SpeedDialChild(
                                              //               backgroundColor: Colors.transparent,
                                              //               elevation: 0.0,
                                              //               child: Container(
                                              //                 height: 40,
                                              //                 width: 80,
                                              //                 decoration: BoxDecoration(
                                              //                     border: Border.all(width: 1),
                                              //                     borderRadius:
                                              //                         BorderRadius.circular(10),
                                              //                     color: stockpickingList[0]
                                              //                                 ['state'] ==
                                              //                             'done'
                                              //                         ? AppColors.appBarColor
                                              //                         : Colors.white),
                                              //                 child: Center(
                                              //                   child: Text(
                                              //                     "Sale Order",
                                              //                     textAlign: TextAlign.center,
                                              //                     style: TextStyle(
                                              //                         color: stockpickingList[0]
                                              //                                     ['state'] ==
                                              //                                 'Done'
                                              //                             ? Colors.white
                                              //                             : Colors.grey,
                                              //                         fontSize: 15),
                                              //                   ),
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //             SpeedDialChild(
                                              //               backgroundColor: Colors.transparent,
                                              //               elevation: 0.0,
                                              //               child: Container(
                                              //                 height: 40,
                                              //                 width: 80,
                                              //                 decoration: BoxDecoration(
                                              //                     border: Border.all(width: 1),
                                              //                     borderRadius:
                                              //                         BorderRadius.circular(10),
                                              //                     color: stockpickingList[0]
                                              //                                 ['state'] ==
                                              //                             'assigned'
                                              //                         ? AppColors.appBarColor
                                              //                         : Colors.white),
                                              //                 child: Center(
                                              //                   child: Text(
                                              //                     "Quotation Sent",
                                              //                     textAlign: TextAlign.center,
                                              //                     style: TextStyle(
                                              //                         color: stockpickingList[0]
                                              //                                     ['state'] ==
                                              //                                 'Ready'
                                              //                             ? Colors.white
                                              //                             : Colors.grey,
                                              //                         fontSize: 15),
                                              //                   ),
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //             SpeedDialChild(
                                              //               backgroundColor: Colors.transparent,
                                              //               elevation: 0.0,
                                              //               child: Container(
                                              //                 height: 40,
                                              //                 width: 80,
                                              //                 decoration: BoxDecoration(
                                              //                     border: Border.all(width: 1),
                                              //                     borderRadius:
                                              //                         BorderRadius.circular(10),
                                              //                     color: stockpickingList[0]
                                              //                                 ['state'] ==
                                              //                             'confirmed'
                                              //                         ? AppColors.appBarColor
                                              //                         : Colors.white),
                                              //                 child: Center(
                                              //                   child: Text(
                                              //                     "Quotation",
                                              //                     style: TextStyle(
                                              //                         color: stockpickingList[0]
                                              //                                     ['state'] ==
                                              //                                 'Waiting'
                                              //                             ? Colors.white
                                              //                             : Colors.grey,
                                              //                         fontSize: 15),
                                              //                   ),
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //             SpeedDialChild(
                                              //               backgroundColor: Colors.transparent,
                                              //               elevation: 0.0,
                                              //               child: Container(
                                              //                 height: 40,
                                              //                 width: 80,
                                              //                 decoration: BoxDecoration(
                                              //                     border: Border.all(width: 1),
                                              //                     borderRadius:
                                              //                         BorderRadius.circular(10),
                                              //                     color: stockpickingList[0]
                                              //                                 ['state'] ==
                                              //                             'draft'
                                              //                         ? AppColors.appBarColor
                                              //                         : Colors.white),
                                              //                 child: Center(
                                              //                   child: Text(
                                              //                     "Quotation",
                                              //                     style: TextStyle(
                                              //                         color: stockpickingList[0]
                                              //                                     ['state'] ==
                                              //                                 'Draft'
                                              //                             ? Colors.white
                                              //                             : Colors.grey,
                                              //                         fontSize: 15),
                                              //                   ),
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //           ])
                                              //:
                                              Container(
                                            child: stockpickingList[0]
                                                        ['state'] ==
                                                    'draft'
                                                ? Container(
                                                    width: 80,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          AppColors.appBarColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: const Center(
                                                      child: Text('Draft',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  )
                                                : stockpickingList[0]
                                                            ['state'] ==
                                                        'waiting'
                                                    ? Container(
                                                        width: 80,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: AppColors
                                                              .appBarColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: const Center(
                                                          child: Text('Waiting',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                      )
                                                    : stockpickingList[0]
                                                                ['state'] ==
                                                            'assigned'
                                                        ? Container(
                                                            width: 80,
                                                            height: 40,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppColors
                                                                  .appBarColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                            child: const Center(
                                                              child: Text(
                                                                  'Ready',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          15,
                                                                      color: Colors
                                                                          .white)),
                                                            ),
                                                          )
                                                        : stockpickingList[0]
                                                                    ['state'] ==
                                                                'done'
                                                            ? Container(
                                                                width: 80,
                                                                height: 40,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColors
                                                                      .appBarColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                child:
                                                                    const Center(
                                                                  child: Text(
                                                                      'Done',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              )
                                                            : Container(
                                                                width: 80,
                                                                height: 40,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: AppColors
                                                                      .appBarColor,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                child:
                                                                    const Center(
                                                                  child: Text(
                                                                      'Waiting For Related Manager',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          floatingActionButton: SpeedDial(
                              visible: stockpickingList[0]['state'] ==
                                          'issue_confirm' ||
                                      stockpickingList[0]['state'] == 'done'
                                  ? false
                                  : true,
                              backgroundColor: AppColors.appBarColor,
                              buttonSize: 80,
                              childrenButtonSize: 75,
                              animationSpeed: 80,
                              openCloseDial: isDialOpen,
                              animatedIcon: AnimatedIcons.menu_close,
                              overlayColor: Colors.black,
                              overlayOpacity: 0.5,
                              children: [
                                // SpeedDialChild(
                                //   visible: stockpickingList[0]['state'] ==
                                //           'issue_confirm'
                                //       ? true
                                //       : false,
                                //   onTap: () async {
                                //     setState(() {
                                //       isCallActionValidate = true;
                                //     });
                                //     await databaseHelper
                                //         .deleteAllStockMoveUpdate();
                                //     materialissuesBloc
                                //         .callActionConfirm(widget.id);
                                //   },
                                //   child: const Icon(Icons.check),
                                //   label: 'Validate',
                                // ),
                                SpeedDialChild(
                                  visible:
                                      stockpickingList[0]['state'] == 'assigned'
                                          ? true
                                          : false,
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text(
                                                'Issue Confirmation!'),
                                            content: const Text(
                                                'Do you want to Issue Confirm?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('No')),
                                              TextButton(
                                                  style: TextButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.appBarColor,
                                                  ),
                                                  onPressed: () async {
                                                    setState(() {
                                                      isCallActionConfirm =
                                                          true;
                                                    });
                                                    Navigator.of(context).pop();
                                                    await databaseHelper
                                                        .deleteAllStockMoveUpdate();
                                                    materialissuesBloc
                                                        .callActionConfirmIssues(
                                                            widget.id);
                                                  },
                                                  child: const Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ))
                                            ],
                                          );
                                        });
                                  },
                                  child: Image.asset(
                                    'assets/imgs/order_confirm_icon.png',
                                    color: Colors.black,
                                    width: 30,
                                    height: 30,
                                  ),
                                  label: 'Order Confirm',
                                )
                              ])),
                      isCallActionConfirm == true
                          ? StreamBuilder<ResponseOb>(
                              initialData:
                                  ResponseOb(msgState: MsgState.loading),
                              stream: materialissuesBloc
                                  .getCallActionConfirmIssueStream(),
                              builder: (context,
                                  AsyncSnapshot<ResponseOb> snapshot) {
                                ResponseOb? responseOb = snapshot.data;
                                if (responseOb?.msgState == MsgState.loading) {
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/loading.gif',
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  );
                                } else if (responseOb?.msgState ==
                                    MsgState.data) {}
                                return Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/gifs/loading.gif',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                );
                              })
                          : Container(),
                      isCallActionValidate == true
                          ? StreamBuilder<ResponseOb>(
                              initialData:
                                  ResponseOb(msgState: MsgState.loading),
                              stream: materialissuesBloc
                                  .getCallActionConfirmStream(),
                              builder: (context,
                                  AsyncSnapshot<ResponseOb> snapshot) {
                                ResponseOb? responseOb = snapshot.data;
                                if (responseOb?.msgState == MsgState.loading) {
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/loading.gif',
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  );
                                } else if (responseOb?.msgState ==
                                    MsgState.data) {}
                                return Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/gifs/loading.gif',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                );
                              })
                          : Container(),
                      isUpdateQtyDone == true
                          ? StreamBuilder<ResponseOb>(
                              initialData:
                                  ResponseOb(msgState: MsgState.loading),
                              stream: saleorderlineBloc
                                  .waitingproductlineListStream(),
                              builder: (context,
                                  AsyncSnapshot<ResponseOb> snapshot) {
                                ResponseOb? responseOb = snapshot.data;
                                if (responseOb?.msgState == MsgState.loading) {
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/loading.gif',
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                  );
                                } else if (responseOb?.msgState ==
                                    MsgState.data) {}
                                return Container(
                                  color: Colors.black.withOpacity(0.5),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/gifs/loading.gif',
                                      width: 100,
                                      height: 100,
                                    ),
                                  ),
                                );
                              })
                          : Container(),
                    ],
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
                        stockpickingBloc.getStockPickingData(['id', '=', widget.id]);
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
                        stockpickingBloc.getStockPickingData(['id', '=', widget.id]);
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
                                  stockpickingBloc.getStockPickingData(['id', '=', widget.id]);
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
              })),
    );
  }
}
