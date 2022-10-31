import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../obs/response_ob.dart';
import '../../../../pages/product_page/product_bloc.dart';
import '../../../../pages/profile_page/profile_bloc.dart';
import '../../../../utils/app_const.dart';
import '../../../../widgets/product_widgets/product_card_widget.dart';
import '../menu_mb/menu_list_mb.dart';

class ProductListMB extends StatefulWidget {
  const ProductListMB({Key? key}) : super(key: key);

  @override
  State<ProductListMB> createState() => _ProductListMBState();
}

class _ProductListMBState extends State<ProductListMB> {
  final productListBloc = ProductBloc();
  final profileBloc = ProfileBloc();
  List<dynamic> productList = [];
  List<dynamic> userList = [];
  List<dynamic> stockwarehouseList = [];
  List<dynamic> stockquantList = [];
  ScrollController scrollController = ScrollController();
  bool isScroll = false;
  final productSearchController = TextEditingController();
  bool searchDone = false;
  bool isSearch = false;
  String stockonhand = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    productListBloc.getStockWarehouseStream().listen(getStockWarehouseListen);
    productListBloc.getStockQuantStream().listen(getStockQuantListen);
    productListBloc.getProductListStream().listen(getProductListListen);
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      if (userList.isNotEmpty) {
        productListBloc.getStockWarehouseData(
            zoneId: userList[0]['zone_id'][0]);
      }
    }
  }

  void getStockWarehouseListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockwarehouseList = responseOb.data;
      productListBloc.getStockQuantData(
          locationId: stockwarehouseList[0]['lot_stock_id'][0]);
    }
  }

  void getProductListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productList = responseOb.data;
      // if (productList.isNotEmpty && stockwarehouseList.isNotEmpty) {

      // }
    }
  }

  void getStockQuantListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockquantList = responseOb.data;
      productListBloc.getProductListData(name: ['name', 'ilike', '']);
    }
  }

  getStockOnHand(int i) {
    print('workgetStockOnHand');
    for (var stockquant in stockquantList) {
      // print('loop stockquant________');
      if (productList[i]['id'] == stockquant['product_id'][0]) {
        print('StockonHand ${stockquant['detail_qty']}');
        print('StockproductId: ${stockquant['product_id']}');
        productList[i]['detail_qty'] = stockquant['detail_qty'];
        print('stockonhand: ${productList[i]['detail_qty']}');
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    productListBloc.dispose();
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
          initialData: productList.isNotEmpty
              ? null
              : ResponseOb(msgState: MsgState.loading),
          stream: productListBloc.getProductListStream(),
          builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
            ResponseOb? responseOb = snapshot.data;
            if (responseOb?.msgState == MsgState.error) {
              return const Center(
                child: Text('Error'),
              );
            } else if (responseOb?.msgState == MsgState.data) {
              productList = responseOb!.data;
              return Scaffold(
                  backgroundColor: Colors.grey[200],
                  appBar: AppBar(
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const MenuListMB();
                        }));
                      },
                      icon: const Icon(Icons.menu),
                    ),
                    backgroundColor: AppColors.appBarColor,
                    title: const Text("Products"),
                  ),
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: SizedBox(
                          height: 50,
                          child: TextField(
                            controller: productSearchController,
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
                                        productSearchController.clear();
                                        searchDone = false;
                                        productListBloc.getProductListData(
                                            name: ['name', 'ilike', '']);
                                      });
                                    } else {
                                      setState(() {
                                        searchDone = true;
                                        isSearch = false;
                                        productListBloc.getProductListData(
                                            name: [
                                              'name',
                                              'ilike',
                                              productSearchController.text
                                            ]);
                                      });
                                    }
                                  },
                                  icon: searchDone == true
                                      ? const Icon(Icons.close)
                                      : const Icon(Icons.search),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
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
                                  productList.length.toString(),
                              style: const TextStyle(fontSize: 15),
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      productList.isEmpty
                          ? const Center(
                              child: Text('No Data'),
                            )
                          : Expanded(
                              child: Stack(
                                children: [
                                  ListView.builder(
                                      controller: scrollController,
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      itemCount: productList.length,
                                      itemBuilder: (context, i) {
                                        getStockOnHand(i);
                                        return ProductCardWidget(
                                          productid: productList[i]['id'],
                                          productName: productList[i]['name'],
                                          productCode: productList[i]
                                                      ['product_code'] ==
                                                  false
                                              ? ''
                                              : productList[i]['product_code'],
                                          saleOk: productList[i]['sale_ok'],
                                          purchaseOk: productList[i]
                                              ['purchase_ok'],
                                          listPrice: productList[i]
                                                      ['list_price'] ==
                                                  false
                                              ? 0.0
                                              : productList[i]['list_price'],
                                          qtyAvailable: productList[i]
                                              ['detail_qty'],
                                          uomId:
                                              productList[i]['uom_id'] == false
                                                  ? []
                                                  : productList[i]['uom_id'],
                                        );
                                      }),
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
                                            child: ListView(
                                              shrinkWrap: true,
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
                                                            productListBloc
                                                                .getProductListData(
                                                                    name: [
                                                                  'name',
                                                                  'ilike',
                                                                  productSearchController
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
                                                                    text: productSearchController
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
                                                            productListBloc
                                                                .getProductListData(
                                                                    name: [
                                                                  'product_code',
                                                                  'ilike',
                                                                  productSearchController
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
                                                                    text: productSearchController
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
                                                          productListBloc
                                                              .getProductListData(
                                                                  name: [
                                                                'categ_id',
                                                                'ilike',
                                                                productSearchController
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
                                                                        "Search Product Category for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: productSearchController
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
                                                          productListBloc
                                                              .getProductListData(
                                                                  name: [
                                                                'main_category_id',
                                                                'ilike',
                                                                productSearchController
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
                                                                        "Search Main Category for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: productSearchController
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
                                                          productListBloc
                                                              .getProductListData(
                                                                  name: [
                                                                'list_price',
                                                                'ilike',
                                                                productSearchController
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
                                                                        "Search Pricelist for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: productSearchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
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
                  ));
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
        ),
      ),
    );
  }
}
