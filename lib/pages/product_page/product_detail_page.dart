import 'package:flutter/material.dart';

import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import 'product_bloc.dart';

class ProductDetailPage extends StatefulWidget {
  int productId;
  ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final productBloc = ProductBloc();

  List<dynamic> productList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productBloc.getProductListData(name: ['id', '=', widget.productId]);
    productBloc.getProductListStream().listen(getProductListListen);
  }

  void getProductListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productList = responseOb.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<ResponseOb>(
          initialData: ResponseOb(msgState: MsgState.loading),
          stream: productBloc.getProductListStream(),
          builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
            ResponseOb? responseOb = snapshot.data;
            if (responseOb?.msgState == MsgState.loading) {
              return Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(),
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
                                                '${productList[0]['qty_available']}',
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
