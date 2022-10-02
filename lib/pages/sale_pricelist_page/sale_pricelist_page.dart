import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../../widgets/drawer_widget.dart';
import '../quotation_page/sale_order_line_page/sale_order_line_bloc.dart';

class SalePricelistPage extends StatefulWidget {
  int salepricelistId;
  int segmentId;
  SalePricelistPage({
    Key? key,
    required this.salepricelistId,
    required this.segmentId,
  }) : super(key: key);

  @override
  State<SalePricelistPage> createState() => _SalePricelistPageState();
}

class _SalePricelistPageState extends State<SalePricelistPage> {
  final saleorderlineBloc = SaleOrderLineBloc();
  List<dynamic> salepricelistList = [];
  List<dynamic> salepricelistproductlineList = [];
  List<dynamic> salepricelistproductlineUpdateList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saleorderlineBloc.getSalePricelistProductLineListDataWithFilter(
        ['pricelist_id', '=', widget.salepricelistId],
        ['segment_id.id', '=', widget.segmentId]);
    saleorderlineBloc
        .getSalePricelistProductLineListWithFilterStream()
        .listen(getSalePricelistProductLineListen);
  }

  void getSalePricelistProductLineListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salepricelistproductlineList = responseOb.data;
      salepricelistproductlineUpdateList = salepricelistproductlineList;
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
              initialData: ResponseOb(msgState: MsgState.loading),
              stream: saleorderlineBloc
                  .getSalePricelistProductLineListWithFilterStream(),
              builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                ResponseOb? responseOb = snapshot.data;
                if (responseOb?.msgState == MsgState.data) {
                  return Scaffold(
                      backgroundColor: Colors.grey[200],
                      appBar: AppBar(
                        backgroundColor: AppColors.appBarColor,
                        title: const Text('Sale Pricelist'),
                      ),
                      body: salepricelistproductlineList.isEmpty
                          ? const Center(
                              child: Text('No Data'),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Container(
                                    height: 40,
                                    color: Colors.white,
                                    child: TextField(
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          salepricelistproductlineUpdateList =
                                              salepricelistproductlineList;
                                        } else {
                                          final result =
                                              salepricelistproductlineList
                                                  .where((element) {
                                            final productNameResult =
                                                element['product_id'][1]
                                                    .toLowerCase();
                                            final input = value.toLowerCase();
                                            return productNameResult
                                                .contains(input);
                                          }).toList();
                                          setState(() =>
                                              salepricelistproductlineUpdateList =
                                                  result);
                                        }
                                      },
                                      decoration: const InputDecoration(
                                          hintText: 'Search Product',
                                          border: OutlineInputBorder()),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount:
                                            salepricelistproductlineUpdateList
                                                .length,
                                        itemBuilder: (c, i) {
                                          return Column(
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.all(10),
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
                                                          'Product',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      const Text(
                                                        ":  ",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  salepricelistproductlineUpdateList[
                                                                          i][
                                                                      'product_id'][1],
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
                                                          'Code  ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      const Text(
                                                        ":  ",
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  salepricelistproductlineUpdateList[
                                                                          i]
                                                                      ['code'],
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18),
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
                                                          Container(
                                                            width: 200,
                                                            child: const Text(
                                                              'Code  ',
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
                                                            ":  ",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      salepricelistproductlineUpdateList[
                                                                              i]
                                                                          [
                                                                          'code'],
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              18),
                                                                    )
                                                                  ]))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            child: const Text(
                                                              'UoM  ',
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
                                                            ":  ",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      salepricelistproductlineUpdateList[
                                                                              i]
                                                                          [
                                                                          'uom_id'][1],
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              18),
                                                                    )
                                                                  ]))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            child: const Text(
                                                              'Price  ',
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
                                                            ":  ",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      '${salepricelistproductlineUpdateList[i]['price']}',
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              18),
                                                                    )
                                                                  ]))
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            width: 200,
                                                            child: const Text(
                                                              'Formula  ',
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
                                                            ":  ",
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      salepricelistproductlineUpdateList[i]['formula'] ==
                                                                              false
                                                                          ? ''
                                                                          : salepricelistproductlineUpdateList[i]
                                                                              [
                                                                              'formula'],
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              18),
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
                                  ),
                                ],
                              ),
                            ));
                } else if (responseOb?.msgState == MsgState.error) {
                  return Container(
                    color: Colors.white,
                    child: const Center(
                      child: Text('Error'),
                    ),
                  );
                } else {
                  return Container(
                    color: Colors.white,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
              })),
    );
  }
}
