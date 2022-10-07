import 'package:flutter/material.dart';

import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../../widgets/drawer_widget.dart';
import '../profile_page/profile_bloc.dart';
import '../quotation_page/quotation_bloc.dart';
import '../quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import 'sale_pricelist_page.dart';

class RegionTypePage extends StatefulWidget {
  const RegionTypePage({Key? key}) : super(key: key);

  @override
  State<RegionTypePage> createState() => _RegionTypePageState();
}

class _RegionTypePageState extends State<RegionTypePage> {
  final quotationBloc = QuotationBloc();
  final saleorderlineBloc = SaleOrderLineBloc();
  final profileBloc = ProfileBloc();
  final searchController = TextEditingController();
  List<dynamic> userList = [];
  List<dynamic> salepricelistproductlineList = [];
  List<dynamic> salepricelistList = [];
  List<dynamic> segmentList = [];

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
        saleorderlineBloc.getSalePricelistData(
            ['zone_id.id', '=', userList[0]['zone_id'][0]]);
        saleorderlineBloc.getSalePricelistProductLineListByRegion(
            zoneId: ['pricelist_id.zone_id', '=', userList[0]['zone_id'][0]],
            type: ['pricelist_id.pricelist_type', '=', 'region'],
            filter: ['id', 'ilike', '']);
      }
    }
  }

  void getSalePricelistListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salepricelistList = responseOb.data;
      // for (var salepricelist in salepricelistList) {
      //   if (userList[0]['zone_id'][0] == salepricelist['zone_id'][0]) {
      //     salepricelistId = salepricelist['id'];
      //     print('Sale Pricelist Id: $salepricelistId');
      //   }
      // }
      //quotationBloc.getSegmenListData();
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
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else if (responseOb?.msgState == MsgState.error) {
                return Container(
                  color: Colors.white,
                  child: const Center(child: CircularProgressIndicator()),
                );
              } else {
                return StreamBuilder<ResponseOb>(
                    initialData: salepricelistList.isNotEmpty
                        ? null
                        : ResponseOb(msgState: MsgState.loading),
                    stream: saleorderlineBloc.getSalePricelistListStream(),
                    builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                      ResponseOb? responseOb = snapshot.data;
                      if (responseOb?.msgState == MsgState.loading) {
                        return Container(
                          color: Colors.white,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      } else if (responseOb?.msgState == MsgState.error) {
                        return Container(
                          color: Colors.white,
                          child:
                              const Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return StreamBuilder<ResponseOb>(
                          initialData: salepricelistproductlineList.isNotEmpty
                              ? null
                              : ResponseOb(msgState: MsgState.loading),
                          stream: saleorderlineBloc
                              .getSalePricelistProductLineListByRegionStream(),
                          builder:
                              (context, AsyncSnapshot<ResponseOb> snapshot) {
                            ResponseOb? responseOb = snapshot.data;
                            if (responseOb?.msgState == MsgState.loading) {
                              return Container(
                                color: Colors.white,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            } else if (responseOb?.msgState == MsgState.error) {
                              return Container(
                                color: Colors.white,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            } else {
                              return Scaffold(
                                backgroundColor: Colors.grey[200],
                                appBar: AppBar(
                                  backgroundColor: AppColors.appBarColor,
                                  title: Text(
                                      'Sale Pricelist (${userList[0]['zone_id'][1]}) By Region'),
                                ),
                                body: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 10,
                                          bottom: 10),
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
                                                            userList[0]
                                                                ['zone_id'][0]
                                                          ],
                                                              type: [
                                                            'pricelist_id.pricelist_type',
                                                            '=',
                                                            'region'
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
                                                            userList[0]
                                                                ['zone_id'][0]
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
                                                  }
                                                },
                                                icon: searchDone == true
                                                    ? const Icon(Icons.close)
                                                    : const Icon(Icons.search),
                                              ),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
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
                                                salepricelistproductlineList
                                                    .length
                                                    .toString(),
                                            style:
                                                const TextStyle(fontSize: 15),
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
                                                padding:
                                                    const EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        width: 250,
                                                        child: const Text(
                                                          'Product Code',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        )),
                                                    Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        width: 100,
                                                        child: const Text(
                                                          'UOM',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        )),
                                                    Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        width: 100,
                                                        child: const Text(
                                                          'Unit Price',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        )),
                                                    Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        width: 100,
                                                        child: const Text(
                                                          'Formula',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              salepricelistproductlineList
                                                      .isEmpty
                                                  ? const Center(
                                                      child: Text('No Data'),
                                                    )
                                                  : Expanded(
                                                      child: ListView.builder(
                                                          itemCount:
                                                              salepricelistproductlineList
                                                                  .length,
                                                          itemBuilder: (c, i) {
                                                            return Column(
                                                              children: [
                                                                Container(
                                                                  color: Colors
                                                                      .white,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(8),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                          padding: const EdgeInsets.all(
                                                                              8),
                                                                          width:
                                                                              250,
                                                                          child:
                                                                              Text(
                                                                            '${salepricelistproductlineList[i]['product_id'][1]} ${salepricelistproductlineList[i]['code']}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15,
                                                                            ),
                                                                          )),
                                                                      Container(
                                                                          padding: const EdgeInsets.all(
                                                                              8),
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            '${salepricelistproductlineList[i]['uom_id'][1]}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15,
                                                                            ),
                                                                          )),
                                                                      Container(
                                                                          padding: const EdgeInsets.all(
                                                                              8),
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            '${salepricelistproductlineList[i]['price']}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15,
                                                                            ),
                                                                          )),
                                                                      Container(
                                                                          padding: const EdgeInsets.all(
                                                                              8),
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              Text(
                                                                            '${salepricelistproductlineList[i]['formula'] == false ? '' : salepricelistproductlineList[i]['formula']}',
                                                                            style:
                                                                                const TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 15,
                                                                            ),
                                                                          ))
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
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    isSearch =
                                                                        false;
                                                                    searchDone =
                                                                        true;
                                                                    saleorderlineBloc
                                                                        .getSalePricelistProductLineListByRegion(zoneId: [
                                                                      'pricelist_id.zone_id',
                                                                      '=',
                                                                      userList[
                                                                              0]
                                                                          [
                                                                          'zone_id'][0]
                                                                    ], type: [
                                                                      'pricelist_id.pricelist_type',
                                                                      '=',
                                                                      'region'
                                                                    ], filter: [
                                                                      'product_id',
                                                                      'ilike',
                                                                      searchController
                                                                          .text
                                                                    ]);
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  height: 50,
                                                                  child:
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Product for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                searchController.text,
                                                                            style: const TextStyle(color: Colors.black))
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
                                                                    isSearch =
                                                                        false;
                                                                    searchDone =
                                                                        true;
                                                                    saleorderlineBloc
                                                                        .getSalePricelistProductLineListByRegion(zoneId: [
                                                                      'pricelist_id.zone_id',
                                                                      '=',
                                                                      userList[
                                                                              0]
                                                                          [
                                                                          'zone_id'][0]
                                                                    ], type: [
                                                                      'pricelist_id.pricelist_type',
                                                                      '=',
                                                                      'region'
                                                                    ], filter: [
                                                                      'code',
                                                                      'ilike',
                                                                      searchController
                                                                          .text
                                                                    ]);
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  height: 50,
                                                                  child:
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Code for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                searchController.text,
                                                                            style: const TextStyle(color: Colors.black))
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
                                                                  isSearch =
                                                                      false;
                                                                  searchDone =
                                                                      true;
                                                                  saleorderlineBloc
                                                                      .getSalePricelistProductLineListByRegion(
                                                                          zoneId: [
                                                                        'pricelist_id.zone_id',
                                                                        '=',
                                                                        userList[0]
                                                                            [
                                                                            'zone_id'][0]
                                                                      ],
                                                                          type: [
                                                                        'pricelist_id.pricelist_type',
                                                                        '=',
                                                                        'region'
                                                                      ],
                                                                          filter: [
                                                                        'pricelist_id.region_ids',
                                                                        'ilike',
                                                                        searchController
                                                                            .text
                                                                      ]);
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  height: 50,
                                                                  child:
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Region for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                searchController.text,
                                                                            style: const TextStyle(color: Colors.black))
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
                    });
              }
            }));
  }
}
