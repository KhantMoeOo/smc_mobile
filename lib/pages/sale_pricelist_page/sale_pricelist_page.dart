import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../../widgets/drawer_widget.dart';
import '../quotation_page/quotation_bloc.dart';
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
  final quotationBloc = QuotationBloc();
  List<dynamic> salepricelistList = [];
  List<dynamic> salepricelistproductlineList = [];
  List<dynamic> salepricelistproductlineUpdateList = [];
  List<dynamic> currencyList = [];
  String currencysymbol = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quotationBloc.getCurrencyList();
    saleorderlineBloc.getSalePricelistProductLineListDataWithFilter(
        ['pricelist_id', '=', widget.salepricelistId],
        ['segment_id.id', '=', widget.segmentId]);
    saleorderlineBloc
        .getSalePricelistProductLineListWithFilterStream()
        .listen(getSalePricelistProductLineListen);
    quotationBloc.getCurrencyStream().listen(getCurrencyListen);
  }

  void getSalePricelistProductLineListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salepricelistproductlineList = responseOb.data;
      salepricelistproductlineUpdateList = salepricelistproductlineList;
    }
  }

  void getCurrencyListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      currencyList = responseOb.data;
    }
  }

  void getCurrencySymbol(int i) {
    print('work');
    for (var currency in currencyList) {
      print('loop');
      if (salepricelistproductlineList[i]['currency_id'][0] == currency['id']) {
        print('same');
        salepricelistproductlineList[i]['symbol'] = currency['symbol'];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                                              '${element['product_id'][1]} ${element['code']}'
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(8),
                                          width: 100,
                                          child: const Text(
                                            'Product',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          )),
                                      Container(
                                          padding: const EdgeInsets.all(8),
                                          width: 80,
                                          child: const Text(
                                            'Unit Price',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          )),
                                      Container(
                                          padding: const EdgeInsets.all(8),
                                          width: 80,
                                          child: const Text(
                                            'Unit Price (ctn)',
                                            //textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          )),
                                      Expanded(
                                        child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: const Text(
                                              'Formula',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            )),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount:
                                          salepricelistproductlineUpdateList
                                              .length,
                                      itemBuilder: (c, i) {
                                        getCurrencySymbol(i);
                                        return Column(
                                          children: [
                                            Container(
                                              color: Colors.white,
                                              padding: const EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      width: 100,
                                                      child: Text(
                                                        '${salepricelistproductlineUpdateList[i]['product_id'][1]} ${salepricelistproductlineUpdateList[i]['code']}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      )),
                                                  Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      width: 80,
                                                      child: Text(
                                                        '${salepricelistproductlineUpdateList[i]['custom_price']} ${salepricelistproductlineList[i]['symbol']}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      )),
                                                  Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      width: 80,
                                                      child: Text(
                                                        '${salepricelistproductlineUpdateList[i]['ctn_price']} ${salepricelistproductlineList[i]['symbol']}',
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      )),
                                                  Expanded(
                                                    child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          '${salepricelistproductlineUpdateList[i]['formula'] == false ? '' : salepricelistproductlineUpdateList[i]['formula']}',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                        )),
                                                  )
                                                ],
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
                  child: Center(
                    child: Image.asset(
                      'assets/gifs/loading.gif',
                      width: 100,
                      height: 100,
                    ),
                  ),
                );
              }
            }));
  }
}
