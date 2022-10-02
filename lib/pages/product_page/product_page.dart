import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../../widgets/drawer_widget.dart';
import '../../widgets/product_widgets/product_card_widget.dart';
import 'product_bloc.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final productListBloc = ProductBloc();
  List<dynamic> productList = [];
  ScrollController scrollController = ScrollController();
  bool isScroll = false;
  final productSearchController = TextEditingController();
  bool searchDone = false;
  bool isSearch = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productListBloc.getProductListData(name: ['name', 'ilike', '']);
  }

  // void _scrollListener() {
  //   if (scrollController.position.userScrollDirection ==
  //       ScrollDirection.reverse) {
  //     setState(() {
  //       isScroll = true;
  //     });
  //   }
  //   if (scrollController.position.userScrollDirection ==
  //       ScrollDirection.forward) {
  //     setState(() {
  //       isScroll = false;
  //     });
  //   }
  // } // listen to Control show or hide of search bar from product list page

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
                  drawer: const DrawerWidget(),
                  appBar: AppBar(
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
                                                      ['qty_available'] ==
                                                  false
                                              ? 0.0
                                              : productList[i]['qty_available'],
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
                                                            ],
                                                          );
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
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
