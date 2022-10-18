import 'package:flutter/material.dart';

import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../../widgets/drawer_widget.dart';
import '../profile_page/profile_bloc.dart';
import '../quotation_page/quotation_bloc.dart';
import '../quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import 'sale_pricelist_page.dart';

class CustomerTypePage extends StatefulWidget {
  const CustomerTypePage({Key? key}) : super(key: key);

  @override
  State<CustomerTypePage> createState() => _CustomerTypePageState();
}

class _CustomerTypePageState extends State<CustomerTypePage> {
  final quotationBloc = QuotationBloc();
  final saleorderlineBloc = SaleOrderLineBloc();
  final profileBloc = ProfileBloc();
  final searchController = TextEditingController();
  List<dynamic> userList = [];
  List<dynamic> salepricelistproductlineList = [];
  List<dynamic> salepricelistList = [];
  List<dynamic> segmentList = [];
  List<dynamic> currencyList = [];
  String currencysymbol = '';

  bool isSearch = false;
  bool searchDone = false;

  int salepricelistId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saleorderlineBloc
        .getSalePricelistProductLineListByRegionStream()
        .listen(getSalePricelistProductLineListen);
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    saleorderlineBloc
        .getSalePricelistListStream()
        .listen(getSalePricelistListen);
    quotationBloc.getSegmentListStream().listen(getSegmentListListen);
    quotationBloc.getCurrencyStream().listen(getCurrencyListen);
  }

  void getSalePricelistProductLineListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salepricelistproductlineList = responseOb.data;
    }
  }

  void getSegmentListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      segmentList = responseOb.data;
    }
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      if (userList.isNotEmpty) {
        quotationBloc.getCurrencyList();
        saleorderlineBloc.getSalePricelistProductLineListByRegion(
            zoneId: ['pricelist_id.zone_id', '=', userList[0]['zone_id'][0]],
            type: ['pricelist_id.pricelist_type', '=', 'customer'],
            filter: ['id', 'ilike', '']);
      }
    }
  }

  void getSalePricelistListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salepricelistList = responseOb.data;
      for (var salepricelist in salepricelistList) {
        if (userList[0]['zone_id'][0] == salepricelist['zone_id'][0]) {
          salepricelistId = salepricelist['id'];
          print('Sale Pricelist Id: $salepricelistId');
        }
      }
      quotationBloc.getSegmenListData();
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
        currencysymbol = currency['symbol'];
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    quotationBloc.dipose();
    saleorderlineBloc.dispose();
    profileBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: StreamBuilder<ResponseOb>(
            initialData: userList.isNotEmpty
                ? null
                : ResponseOb(msgState: MsgState.loading),
            stream: profileBloc.getResUsersStream(),
            builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
              ResponseOb? responseOb = snapshot.data;
              if (responseOb?.msgState == MsgState.loading) {
                return Container(
                  color: Colors.white,
                  child: Center(
                    child: Image.asset(
                      'assets/gifs/three_circle_loading.gif',
                      width: 150,
                      height: 150,
                    ),
                  ),
                );
              } else if (responseOb?.msgState == MsgState.error) {
                return Container(
                  color: Colors.white,
                  child: const Center(child: Text('Error')),
                );
              } else {
                return StreamBuilder<ResponseOb>(
                  initialData: salepricelistproductlineList.isNotEmpty
                      ? null
                      : ResponseOb(msgState: MsgState.loading),
                  stream: saleorderlineBloc
                      .getSalePricelistProductLineListByRegionStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return Container(
                        color: Colors.white,
                        child: Center(
                          child: Image.asset(
                            'assets/gifs/three_circle_loading.gif',
                            width: 150,
                            height: 150,
                          ),
                        ),
                      );
                    } else if (responseOb?.msgState == MsgState.error) {
                      return Container(
                        color: Colors.white,
                        child: const Center(child: Text('Error')),
                      );
                    } else {
                      return Scaffold(
                        backgroundColor: Colors.grey[200],
                        appBar: AppBar(
                          backgroundColor: AppColors.appBarColor,
                          title: Text(
                              'Sale Pricelist (${userList[0]['zone_id'][1]}) By Customer'),
                        ),
                        body: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 10, bottom: 10),
                              child: SizedBox(
                                height: 50,
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
                                              saleorderlineBloc
                                                  .getSalePricelistProductLineListByRegion(
                                                      zoneId: [
                                                    'pricelist_id.zone_id',
                                                    '=',
                                                    userList[0]['zone_id'][0]
                                                  ],
                                                      type: [
                                                    'pricelist_id.pricelist_type',
                                                    '=',
                                                    'customer'
                                                  ],
                                                      filter: [
                                                    'id',
                                                    'ilike',
                                                    ''
                                                  ]);
                                            });
                                          } else {
                                            setState(() {
                                              searchDone = true;
                                              isSearch = false;
                                              saleorderlineBloc
                                                  .getSalePricelistProductLineListByRegion(
                                                      zoneId: [
                                                    'pricelist_id.zone_id',
                                                    '=',
                                                    userList[0]['zone_id'][0]
                                                  ],
                                                      type: [
                                                    'pricelist_id.pricelist_type',
                                                    '=',
                                                    'customer'
                                                  ],
                                                      filter: [
                                                    'product_id',
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
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Total Products: " +
                                        salepricelistproductlineList.length
                                            .toString(),
                                    style: const TextStyle(fontSize: 15),
                                  )),
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                width: 150,
                                                child: const Text(
                                                  'Product',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                )),
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                width: 80,
                                                child: const Text(
                                                  'Unit Price (ctn)',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                )),
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                width: 80,
                                                child: const Text(
                                                  'Unit Price',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                )),
                                            Expanded(
                                              child: Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: const Text(
                                                    'Formula',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                  )),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      salepricelistproductlineList.isEmpty
                                          ? const Center(
                                              child: Text('No Data'),
                                            )
                                          : Expanded(
                                              child: ListView.builder(
                                                  itemCount:
                                                      salepricelistproductlineList
                                                          .length,
                                                  itemBuilder: (c, i) {
                                                    getCurrencySymbol(i);
                                                    return Column(
                                                      children: [
                                                        Container(
                                                          color: Colors.white,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  width: 150,
                                                                  child: Text(
                                                                    '${salepricelistproductlineList[i]['product_id'][1]} ${salepricelistproductlineList[i]['code']}',
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  )),
                                                              Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  width: 80,
                                                                  child: Text(
                                                                    '${salepricelistproductlineList[i]['custom_price']} $currencysymbol',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  )),
                                                              Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  width: 80,
                                                                  child: Text(
                                                                    '${salepricelistproductlineList[i]['ctn_price']} $currencysymbol',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  )),
                                                              Expanded(
                                                                child:
                                                                    Container(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                8),
                                                                        child:
                                                                            Text(
                                                                          '${salepricelistproductlineList[i]['formula'] == false ? '' : salepricelistproductlineList[i]['formula']}',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            fontSize:
                                                                                13,
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
                                                            saleorderlineBloc
                                                                .getSalePricelistProductLineListByRegion(
                                                                    zoneId: [
                                                                  'pricelist_id.zone_id',
                                                                  '=',
                                                                  userList[0][
                                                                      'zone_id'][0]
                                                                ],
                                                                    type: [
                                                                  'pricelist_id.pricelist_type',
                                                                  '=',
                                                                  'region'
                                                                ],
                                                                    filter: [
                                                                  'product_id',
                                                                  'ilike',
                                                                  searchController
                                                                      .text
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
                                                                        "Search Product for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: searchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
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
                                                            saleorderlineBloc
                                                                .getSalePricelistProductLineListByRegion(
                                                                    zoneId: [
                                                                  'pricelist_id.zone_id',
                                                                  '=',
                                                                  userList[0][
                                                                      'zone_id'][0]
                                                                ],
                                                                    type: [
                                                                  'pricelist_id.pricelist_type',
                                                                  '=',
                                                                  'region'
                                                                ],
                                                                    filter: [
                                                                  'code',
                                                                  'ilike',
                                                                  searchController
                                                                      .text
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
                                                                        "Search Code for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: searchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
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
                                                          saleorderlineBloc
                                                              .getSalePricelistProductLineListByRegion(
                                                                  zoneId: [
                                                                'pricelist_id.zone_id',
                                                                '=',
                                                                userList[0][
                                                                    'zone_id'][0]
                                                              ],
                                                                  type: [
                                                                'pricelist_id.pricelist_type',
                                                                '=',
                                                                'customer'
                                                              ],
                                                                  filter: [
                                                                'pricelist_id.customer_ids',
                                                                'ilike',
                                                                searchController
                                                                    .text
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
                                                                        "Search Customer for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: searchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
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
                      );
                    }
                  },
                );
              }
            }));
  }
}
