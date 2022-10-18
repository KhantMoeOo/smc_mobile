import 'package:flutter/material.dart';
import 'package:smc_mobile/pages/delivery_page/delivery_create_bloc.dart';
import 'package:smc_mobile/pages/quotation_page/sale_order_line_page/sale_order_line_bloc.dart';

import '../../../dbs/database_helper.dart';
import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../obs/stock_move_ob.dart';
import '../../../pages/delivery_page/delivery_bloc.dart';
import '../../../pages/material_issues_page/material_isssues_bloc.dart';
import '../../../utils/app_const.dart';
import 'material_issues_list.dart';

class MaterialIssuesDetail extends StatefulWidget {
  Map<String, dynamic> stockpicking;
  MaterialIssuesDetail({
    Key? key,
    required this.stockpicking,
  }) : super(key: key);

  @override
  State<MaterialIssuesDetail> createState() => _MaterialIssuesDetailState();
}

class _MaterialIssuesDetailState extends State<MaterialIssuesDetail> {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stockpickingBloc
        .getStockPickingData(['id', '=', widget.stockpicking['id']]);
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
      stockpickingBloc
          .getStockPickingData(['id', '=', widget.stockpicking['id']]);
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
      stockpickingBloc
          .getStockPickingData(['id', '=', widget.stockpicking['id']]);
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
        await databaseHelper.deleteAllStockMoveUpdate();
        Navigator.of(context).pop();
        return true;
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
                          backgroundColor:
                              const Color.fromARGB(255, 12, 41, 92),
                          elevation: 0.0,
                          title: Text('${stockpickingList[0]['name']}'),
                          actions: [],
                        ),
                        body: FutureBuilder<List<StockMoveOb>>(
                            future: databaseHelper.getStockMoveUpdateList(),
                            builder: (context, snapshot) {
                              stockmoveDBList = snapshot.data;
                              Widget saleOrderLineWidget = SliverToBoxAdapter(
                                child: Container(),
                              );
                              if (snapshot.hasData) {
                                saleOrderLineWidget = SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                  (context, i) {
                                    print(
                                        'SOLLength------------: ${stockmoveDBList?.length}');
                                    return Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          color: Colors.white,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          '${stockmoveDBList![i].productCodeName}}',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15))
                                                    ]),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          stockmoveDBList![i]
                                                              .description,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15))
                                                    ]),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          stockmoveDBList![i]
                                                              .demand,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15))
                                                    ]),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          stockmoveDBList![i]
                                                              .reserved!,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15))
                                                    ]),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          stockmoveDBList![i]
                                                              .done!,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15))
                                                    ]),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          stockmoveDBList![i]
                                                              .damageQty!,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15))
                                                    ]),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          stockmoveDBList![i]
                                                              .remainingstock!,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15))
                                                    ]),
                                              ),
                                              const SizedBox(
                                                width: 2,
                                              ),
                                              SizedBox(
                                                width: 80,
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                          stockmoveDBList![i]
                                                              .uomName,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15))
                                                    ]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                  childCount: stockmoveDBList!.length,
                                ));
                              } else {
                                saleOrderLineWidget = SliverToBoxAdapter(
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: CustomScrollView(
                                          slivers: [
                                            SliverPadding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                sliver: SliverToBoxAdapter(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    color: Colors.white,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Visibility(
                                                              visible: stockpickingList[
                                                                              0]
                                                                          [
                                                                          'state'] ==
                                                                      'issue_confirm'
                                                                  ? true
                                                                  : false,
                                                              child: TextButton(
                                                                  style: TextButton.styleFrom(
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .appBarColor),
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      isCallActionValidate =
                                                                          true;
                                                                    });
                                                                    await databaseHelper
                                                                        .deleteAllStockMoveUpdate();
                                                                    materialissuesBloc
                                                                        .callActionConfirm(
                                                                            widget.stockpicking['id']);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Validate',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  )),
                                                            ),
                                                            Visibility(
                                                              visible: stockpickingList[
                                                                              0]
                                                                          [
                                                                          'state'] ==
                                                                      'assigned'
                                                                  ? true
                                                                  : false,
                                                              child: TextButton(
                                                                  style: TextButton.styleFrom(
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .appBarColor),
                                                                  onPressed:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      isCallActionConfirm =
                                                                          true;
                                                                    });
                                                                    await databaseHelper
                                                                        .deleteAllStockMoveUpdate();
                                                                    materialissuesBloc
                                                                        .callActionConfirmIssues(
                                                                            widget.stockpicking['id']);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Confirm',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  )),
                                                            )
                                                          ],
                                                        ),
                                                        Row(children: [
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              height: 35,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: stockpickingList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'draft'
                                                                    ? AppColors
                                                                        .appBarColor
                                                                    : Colors.grey[
                                                                        200],
                                                              ),
                                                              child: Text(
                                                                  'Draft',
                                                                  style:
                                                                      TextStyle(
                                                                    color: stockpickingList[0]['state'] ==
                                                                            'draft'
                                                                        ? Colors
                                                                            .white
                                                                        : AppColors
                                                                            .appBarColor,
                                                                  ))),
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              height: 35,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: stockpickingList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'waiting'
                                                                    ? AppColors
                                                                        .appBarColor
                                                                    : Colors.grey[
                                                                        200],
                                                              ),
                                                              child: Text(
                                                                  'Waiting',
                                                                  style:
                                                                      TextStyle(
                                                                    color: stockpickingList[0]['state'] ==
                                                                            'waiting'
                                                                        ? Colors
                                                                            .white
                                                                        : AppColors
                                                                            .appBarColor,
                                                                  ))),
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              height: 35,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: stockpickingList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'assigned'
                                                                    ? AppColors
                                                                        .appBarColor
                                                                    : Colors.grey[
                                                                        200],
                                                              ),
                                                              child: Text(
                                                                  'Ready',
                                                                  style:
                                                                      TextStyle(
                                                                    color: stockpickingList[0]['state'] ==
                                                                            'assigned'
                                                                        ? Colors
                                                                            .white
                                                                        : AppColors
                                                                            .appBarColor,
                                                                  ))),
                                                          Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              height: 35,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: stockpickingList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'done'
                                                                    ? AppColors
                                                                        .appBarColor
                                                                    : Colors.grey[
                                                                        200],
                                                              ),
                                                              child: Text(
                                                                  'Done',
                                                                  style:
                                                                      TextStyle(
                                                                    color: stockpickingList[0]['state'] ==
                                                                            'done'
                                                                        ? Colors
                                                                            .white
                                                                        : AppColors
                                                                            .appBarColor,
                                                                  ))),
                                                          Visibility(
                                                            visible: stockpickingList[
                                                                            0][
                                                                        'state'] ==
                                                                    'issue_confirm'
                                                                ? true
                                                                : false,
                                                            child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                height: 35,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: stockpickingList[0]
                                                                              [
                                                                              'state'] ==
                                                                          'issue_confirm'
                                                                      ? AppColors
                                                                          .appBarColor
                                                                      : Colors.grey[
                                                                          200],
                                                                ),
                                                                child: Text(
                                                                    'Waiting For Related Manager',
                                                                    style:
                                                                        TextStyle(
                                                                      color: stockpickingList[0]['state'] ==
                                                                              'issue_confirm'
                                                                          ? Colors
                                                                              .white
                                                                          : AppColors
                                                                              .appBarColor,
                                                                    ))),
                                                          ),
                                                        ])
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                            SliverPadding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                sliver: SliverList(
                                                    delegate:
                                                        SliverChildBuilderDelegate(
                                                            (c, i) {
                                                  return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      color: Colors.white,
                                                      child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              stockpickingList[
                                                                  i]['name'],
                                                              style: const TextStyle(
                                                                  fontSize: 30,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            const SizedBox(
                                                              height: 30,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Expanded(
                                                                  child: Text(
                                                                    'Contact: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${stockpickingList[i]['partner_id'] == false ? '' : stockpickingList[i]['partner_id']}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                                const SizedBox(
                                                                    width: 10),
                                                                const Expanded(
                                                                  child: Text(
                                                                    'Scheduled Date: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${stockpickingList[i]['scheduled_date']}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Expanded(
                                                                  child: Text(
                                                                    'Ref No.: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          stockpickingList[i]
                                                                              [
                                                                              'ref_no'],
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                const Expanded(
                                                                  child: Text(
                                                                    'Source Document: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${stockpickingList[i]['origin'] == false ? '' : stockpickingList[i]['origin']}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Expanded(
                                                                  child: Text(
                                                                    'Operation Type: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${stockpickingList[i]['picking_type_id'] == false ? '' : stockpickingList[i]['picking_type_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                const Expanded(
                                                                  child:
                                                                      SizedBox(),
                                                                ),
                                                                const Expanded(
                                                                    child:
                                                                        SizedBox()),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Expanded(
                                                                  child: Text(
                                                                    'Source Location: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${stockpickingList[i]['location_id'] == false ? '' : stockpickingList[i]['location_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                                const Expanded(
                                                                    child:
                                                                        SizedBox()),
                                                                const Expanded(
                                                                    child:
                                                                        SizedBox()),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Expanded(
                                                                  child: Text(
                                                                    'Department: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${stockpickingList[i]['department_id'] == false ? '' : stockpickingList[i]['department_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                                const Expanded(
                                                                    child:
                                                                        SizedBox()),
                                                                const Expanded(
                                                                    child:
                                                                        SizedBox()),
                                                              ],
                                                            ),
                                                          ]));
                                                },
                                                            childCount:
                                                                stockpickingList
                                                                    .length))),
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
                                                  "Order Line",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20),
                                                ),
                                              )),
                                            ),
                                            SliverPadding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                sliver: SliverToBoxAdapter(
                                                  child: Container(
                                                    color: Colors.white,
                                                    padding:
                                                        const EdgeInsets.only(
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
                                                            width: 150,
                                                            child: Text(
                                                                'Product Code',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        Expanded(
                                                            child: Text(
                                                                'Description',
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        SizedBox(
                                                            width: 80,
                                                            child: Text(
                                                                'Damage',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        SizedBox(
                                                            width: 80,
                                                            child: Text(
                                                                'Reserved',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        SizedBox(
                                                            width: 80,
                                                            child: Text('Done',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        SizedBox(
                                                            width: 80,
                                                            child: Text(
                                                                'Damage Qty',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        SizedBox(
                                                            width: 80,
                                                            child: Text(
                                                                'Remaining Stock',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        SizedBox(
                                                            width: 80,
                                                            child: Text(
                                                                'Unit of Measures',
                                                                textAlign:
                                                                    TextAlign
                                                                        .end,
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                            SliverPadding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                sliver: saleOrderLineWidget),
                                            const SliverToBoxAdapter(
                                              child: SizedBox(height: 20),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
                      ),
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
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: Text("Error"),
                    ),
                  );
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
