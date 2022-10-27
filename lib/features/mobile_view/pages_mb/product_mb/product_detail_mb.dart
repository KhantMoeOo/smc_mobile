import 'package:flutter/material.dart';

import '../../../../obs/response_ob.dart';
import '../../../../pages/product_page/product_bloc.dart';
import '../../../../pages/profile_page/profile_bloc.dart';
import '../../../../utils/app_const.dart';

class ProductDetailMB extends StatefulWidget {
  int productId;
  ProductDetailMB({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailMB> createState() => _ProductDetailMBState();
}

class _ProductDetailMBState extends State<ProductDetailMB> {
  final productListBloc = ProductBloc();
  final profileBloc = ProfileBloc();
  List<dynamic> productList = [];
  List<dynamic> userList = [];
  List<dynamic> stockwarehouseList = [];
  List<dynamic> stockquantList = [];
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
      getStockOnHand();
      // }
    }
  }

  void getStockQuantListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockquantList = responseOb.data;
      productListBloc.getProductListData(name: ['id', '=', widget.productId]);
    }
  }

  void getStockOnHand() {
    print('workgetStockOnHand');
    for (var stockquant in stockquantList) {
      print('loop stockquant________');
      if (widget.productId == stockquant['product_id'][0]) {
        print('StockonHand ${stockquant['detail_qty']}');
        print('StockproductId: ${stockquant['product_id']}');
        stockonhand = stockquant['detail_qty'];
      } else {
        print('NotSame productId');
        stockonhand = '';
      }
    }
  }

  // void getProductListListen(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     productList = responseOb.data;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<ResponseOb>(
          initialData: productList.isNotEmpty ? null: ResponseOb(msgState: MsgState.loading),
          stream: productListBloc.getProductListStream(),
          builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
            ResponseOb? responseOb = snapshot.data;
            if (responseOb?.msgState == MsgState.loading) {
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
            } else if (responseOb?.msgState == MsgState.error) {
              return Container(
                color: Colors.white,
                child: const Center(
                  child: Text("Error"),
                ),
              );
            } else {
              return Scaffold(
                backgroundColor: Colors.grey[200],
                appBar: AppBar(
                  backgroundColor: AppColors.appBarColor,
                  title: Text(productList[0]['name']),
                ),
                body: CustomScrollView(
                  slivers: [
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${productList[0]['name']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 30)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                      '${productList[0]['product_code'] == false ? '' : productList[0]['product_code']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 30)),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child: Text(
                                          'Can be Sold',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Text(
                                        ':  ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                            Icon(productList[0]['sale_ok'] ==
                                                    false
                                                ? Icons.check_box_outline_blank
                                                : Icons.check_box)
                                          ])),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child: Text(
                                          'Can be Sold',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Text(
                                        ':  ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                            Icon(productList[0]
                                                        ['purchase_ok'] ==
                                                    false
                                                ? Icons.check_box_outline_blank
                                                : Icons.check_box)
                                          ])),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child: Text(
                                          'Quantity Available',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Text(
                                        ':  ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                            Text(
                                                stockonhand,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18))
                                          ])),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        width: 200,
                                        child: Text(
                                          'Unit of Measure',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                      ),
                                      const Text(
                                        ':  ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                            Text(
                                                '${productList[0]['uom_id'][1]}',
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18))
                                          ])),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ]),
                          )
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
