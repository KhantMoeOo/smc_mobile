import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../../dbs/database_helper.dart';
import '../../../../dbs/sharef.dart';
import '../../../../obs/product_line_ob.dart';
import '../../../../obs/response_ob.dart';
import '../../../../pages/material_requisition_page/material_product_line_page/material_product_line_bloc.dart';
import '../../../../pages/material_requisition_page/material_requisition_bloc.dart';
import '../../../../pages/material_requisition_page/material_requisition_create_bloc.dart';
import '../../../../pages/material_requisition_page/material_requisition_create_page.dart';
import '../../../../pages/material_requisition_page/purchase_requisition_bloc.dart';
import '../../../../pages/quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import '../../../../utils/app_const.dart';
import 'material_requisition_list_mb.dart';

class MaterialRequisitionDetailMB extends StatefulWidget {
  int id;
  int userId;
  MaterialRequisitionDetailMB({
    Key? key,
    required this.id,
    required this.userId,
  }) : super(key: key);

  @override
  State<MaterialRequisitionDetailMB> createState() =>
      _MaterialRequisitionDetailMBState();
}

class _MaterialRequisitionDetailMBState
    extends State<MaterialRequisitionDetailMB> {
  final materialRequisitionBloc = MaterialRequisitionBloc();
  final materialproductlineBloc = MaterialProductLineBloc();
  final materialrequisitioncreateBloc = MaterialRequisitionCreateBloc();
  final purchaserequisitionBloc = PurchaseRequisitionBloc();
  final saleorderlineBloc = SaleOrderLineBloc();
  final databaseHelper = DatabaseHelper();
  List<dynamic> materialRequisitionList = [];
  List<dynamic> productlineList = [];
  List<dynamic> productproductList = [];
  List<dynamic> productcategoryList = [];
  List<ProductLineOb>? materialproductlineDBList = [];
  final isDialOpen = ValueNotifier(false);
  bool isupdateStatus = false;
  bool isCreatePR = false;
  int purchaseproductId = 0;
  bool isCreatePPL = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    materialRequisitionBloc
        .getMaterialRequisitionListWithIdData(['id', '=', widget.id]);
    materialRequisitionBloc
        .getMaterialRequisitionListWithIdStream()
        .listen(getMaterialRequisitionListen);
    materialproductlineBloc
        .getMaterialProductLineListStream()
        .listen(getMaterialProductLineListen);
    materialrequisitioncreateBloc
        .getCallActionConfirmStream()
        .listen(getCallActionConfirmListen);
    // materialrequisitioncreateBloc
    //     .getUpdateMaterialRequisitionStatusStream()
    //     .listen(getUpdateMaterialRequisitionStatusListen);
    // purchaserequisitionBloc
    //     .getCreatePurchaseRequisitionStream()
    //     .listen(getCreatePurchaseRequisitionListen);
    // purchaserequisitionBloc
    //     .getCreatePurchaseProductLineStream()
    //     .listen(getCreatePurchaseProductLineListen);
    saleorderlineBloc
        .getProductProductListStream()
        .listen(getProductProductListen);
    saleorderlineBloc
        .getProductCategoryListStream()
        .listen(getProductCategoryListen);
  }

  Future<void> getproductlineListFromDB() async {
    print('Worked');
    for (var element in productlineList) {
      if (element['material_porduct_id'][0] == widget.id) {
        print('ORderId?????: ${element['material_porduct_id']}');
        print('Found: ${element['id']}');
        final productlineOb = ProductLineOb(
          id: element['id'],
          isSelect: 1,
          materialproductId: widget.id,
          productCodeName:
              element['product_id'] == false ? '' : element['product_id'][1],
          productCodeId:
              element['product_id'] == false ? 0 : element['product_id'][0],
          description:
              element['product_code'] == false ? '' : element['product_code'],
          fullName: element['product_name'] == false
              ? element['product_id'][1]
              : '${element['product_id'][1]} ${element['product_name']}',
          quantity: element['qty'] == false ? '' : element['qty'].toString(),
          uomName: element['product_uom_id'] == false
              ? ''
              : element['product_uom_id'][1],
          uomId: element['product_uom_id'] == false
              ? ''
              : element['product_uom_id'][0],
        );
        await databaseHelper.insertMaterialProductLineUpdate(productlineOb);
      }
    }

    setState(() {});
  }

  void getMaterialRequisitionListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      materialRequisitionList = responseOb.data;
      materialproductlineBloc.getMaterialProductLineListData(widget.id);
      saleorderlineBloc.getProductProductData();
      saleorderlineBloc.getProductCategoryData();
    }
  }

  void getMaterialProductLineListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productlineList = responseOb.data;
      if (productlineList.isNotEmpty) {
        getproductlineListFromDB();
      }
    }
  }

  void getProductProductListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productproductList = responseOb.data;
    } else if (responseOb.msgState == MsgState.error) {
      print("NoProductProductList");
    }
  } // listen to get ProductProduct List

  void getProductCategoryListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productcategoryList = responseOb.data;
    } else if (responseOb.msgState == MsgState.error) {
      print("NoProductCategoryList");
    }
  } // listen to get Product Category List

  void getUpdateMaterialRequisitionStatusListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isupdateStatus = false;
        print('isupdateStatus $isupdateStatus');
        isCreatePR = true;
        print('isCreatePR $isCreatePR');
      });
      purchaserequisitionBloc.createPurchaseRequisition(
        refno: materialRequisitionList[0]['ref_no'],
        requestPerson: materialRequisitionList[0]['request_person'] == false
            ? null
            : materialRequisitionList[0]['request_person'][0],
        departmentId: materialRequisitionList[0]['department_id'] == false
            ? null
            : materialRequisitionList[0]['department_id'][0],
        locationId: materialRequisitionList[0]['location_id'] == false
            ? null
            : materialRequisitionList[0]['location_id'][0],
        invoiceId: materialRequisitionList[0]['invoice_id'] == []
            ? []
            : materialRequisitionList[0]['invoice_id'],
        priority: materialRequisitionList[0]['priority'],
        orderdate: materialRequisitionList[0]['order_date'],
        scheduledDate: materialRequisitionList[0]['scheduled_date'],
        multiMRId: materialRequisitionList[0]['id'],
        description: materialRequisitionList[0]['desc'],
      );
    }
  }

  void getCreatePurchaseRequisitionListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        purchaseproductId = responseOb.data;
        isCreatePR = false;
        print('isCreatePR $isCreatePR');
        isCreatePPL = true;
        print('isCreatePPL $isCreatePPL');
      });
      for (var ppl in productlineList) {
        for (var product in productproductList) {
          if (product['id'] == ppl['product_id'][0]) {
            print('Product Name: ${product['name']}');
            for (var categ in productcategoryList) {
              if (categ['id'] == product['categ_id'][0]) {
                print(
                    'Product Category: ${categ['name']},${categ['property_account_income_categ_id']}');
                purchaserequisitionBloc.createPurchaseProductLine(
                  purchaseproductId: purchaseproductId,
                  productId: ppl['product_id'][0],
                  productName: ppl['product_id'][1],
                  categId: categ['property_account_income_categ_id'] == false
                      ? false
                      : categ['property_account_income_categ_id'][0],
                  qty: ppl['qty'],
                  uomId: ppl['product_uom_id'][0],
                );
              }
            }
          }
        }
      }
    }
  }

  void getCreatePurchaseProductLineListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isCreatePPL = false;
        print('isCreatePPL $isCreatePPL');
      });
      materialRequisitionBloc
          .getMaterialRequisitionListWithIdData(['id', '=', widget.id]);
    }
  }

  void getCallActionConfirmListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isupdateStatus = false;
      });
      materialRequisitionBloc
          .getMaterialRequisitionListWithIdData(['id', '=', widget.id]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
          await databaseHelper.deleteAllMaterialProductLineUpdate();
          await SharefCount.clearCount();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return MaterialRequisitionListMB();
          }), (route) => false);
          return true;
        }
      },
      child: SafeArea(
        child: StreamBuilder<ResponseOb>(
            initialData: materialRequisitionList.isNotEmpty
                ? null
                : ResponseOb(msgState: MsgState.loading),
            stream: materialRequisitionBloc
                .getMaterialRequisitionListWithIdStream(),
            builder: (context, snapshot) {
              ResponseOb? responseOb = snapshot.data;
              if (responseOb?.msgState == MsgState.error) {
                return Container(
                    color: Colors.white,
                    child: const Center(child: Text("Error")));
              } else if (responseOb?.msgState == MsgState.loading) {
                return Container(
                    color: Colors.white,
                    child: Center(
                      child: Image.asset(
                        'assets/gifs/loading.gif',
                        width: 100,
                        height: 100,
                      ),
                    ));
              } else {
                return StreamBuilder<ResponseOb>(
                    initialData: ResponseOb(msgState: MsgState.loading),
                    stream: materialproductlineBloc
                        .getMaterialProductLineListStream(),
                    builder: (context, snapshot) {
                      ResponseOb? responseOb = snapshot.data;
                      if (responseOb?.msgState == MsgState.error) {
                        return Container(
                            color: Colors.white,
                            child: const Center(child: Text("Error")));
                      } else if (responseOb?.msgState == MsgState.loading) {
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
                      } else {
                        return Stack(
                          children: [
                            Scaffold(
                                backgroundColor: Colors.grey[200],
                                appBar: AppBar(
                                  backgroundColor: AppColors.appBarColor,
                                  title: Text(
                                      '${materialRequisitionList[0]['name']}'),
                                  actions: [
                                    Visibility(
                                      visible: materialRequisitionList[0]
                                                  ['state'] ==
                                              'confirm'
                                          ? true
                                          : false,
                                      child: Center(
                                        child: Text(
                                            'Material Requisition (${materialRequisitionList[0]['mr_count']})'),
                                      ),
                                    )
                                  ],
                                ),
                                body: FutureBuilder<List<ProductLineOb>>(
                                    future: databaseHelper
                                        .getMaterialProductLineUpdateList(),
                                    builder: (context, snapshot) {
                                      materialproductlineDBList = snapshot.data;
                                      Widget materialproductlineWidget =
                                          SliverToBoxAdapter(
                                        child: Container(),
                                      );
                                      if (snapshot.hasData) {
                                        materialproductlineWidget = SliverList(
                                            delegate:
                                                SliverChildBuilderDelegate(
                                          (context, i) {
                                            print(
                                                'SOLLength------------: ${materialproductlineDBList?.length}');
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration:
                                                        const BoxDecoration(
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
                                                                'Product Code: ',
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
                                                                flex: 2,
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .productCodeName,
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 18),
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
                                                                    materialproductlineDBList![
                                                                            i]
                                                                        .description,
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
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Description: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                          materialproductlineDBList![i]
                                                                              .description,
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18),
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
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                          materialproductlineDBList![i]
                                                                              .uomName,
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18),
                                                                        )
                                                                      ])),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Quantity: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                          materialproductlineDBList![i]
                                                                              .quantity,
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18),
                                                                        )
                                                                      ])),
                                                                ],
                                                              ),
                                                            ]))),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            );
                                          },
                                          childCount:
                                              materialproductlineDBList!.length,
                                        ));
                                      } else {
                                        materialproductlineWidget =
                                            SliverToBoxAdapter(
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
                                                          const EdgeInsets.all(
                                                              8),
                                                      sliver: SliverList(
                                                          delegate:
                                                              SliverChildListDelegate([
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          color: Colors.white,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Text(
                                                                'PR Number',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        20),
                                                              ),
                                                              Text(
                                                                materialRequisitionList[
                                                                    0]['name'],
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        25),
                                                              ),
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
                                                                      'Ref No.: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${materialRequisitionList[0]['ref_no'] == false ? '-' : materialRequisitionList[0]['ref_no']}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Request Person: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${materialRequisitionList[0]['request_person'] == false ? '-' : materialRequisitionList[0]['request_person'][1]}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Department: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${materialRequisitionList[0]['department_id'] == false ? '-' : materialRequisitionList[0]['department_id'][1]}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Zone: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${materialRequisitionList[0]['zone_id'] == false ? '-' : materialRequisitionList[0]['zone_id'][1]}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
                                                                      ])),
                                                                ],
                                                              ),
                                                              // const SizedBox(
                                                              //   height: 10,
                                                              // ),
                                                              // Row(
                                                              //   crossAxisAlignment:
                                                              //       CrossAxisAlignment
                                                              //           .start,
                                                              //   children: [
                                                              //     const SizedBox(
                                                              //       width: 200,
                                                              //       child: Text(
                                                              //         'Invoice No: ',
                                                              //         style: TextStyle(
                                                              //             fontSize:
                                                              //                 20,
                                                              //             fontWeight: FontWeight
                                                              //                 .bold,
                                                              //             color:
                                                              //                 Colors.black),
                                                              //       ),
                                                              //     ),
                                                              //     Expanded(
                                                              //         child: Column(
                                                              //             crossAxisAlignment:
                                                              //                 CrossAxisAlignment.start,
                                                              //             children: [
                                                              //           Text(
                                                              //               '${materialRequisitionList[0]['department_id'] == false ? '-' : materialRequisitionList[0]['department_id'][1]}',
                                                              //               style:
                                                              //                   const TextStyle(color: Colors.black, fontSize: 18))
                                                              //         ])),
                                                              //   ],
                                                              // ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Priority: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .star,
                                                                          color: materialRequisitionList[0]['priority'] == 'a'
                                                                              ? Colors.grey
                                                                              : Colors.yellow),
                                                                      Icon(
                                                                          Icons
                                                                              .star,
                                                                          color: materialRequisitionList[0]['priority'] == 'b' || materialRequisitionList[0]['priority'] == 'a'
                                                                              ? Colors.grey
                                                                              : Colors.yellow),
                                                                      Icon(
                                                                          Icons
                                                                              .star,
                                                                          color: materialRequisitionList[0]['priority'] == 'c' || materialRequisitionList[0]['priority'] == 'b' || materialRequisitionList[0]['priority'] == 'a'
                                                                              ? Colors.grey
                                                                              : Colors.yellow),
                                                                      Icon(
                                                                          Icons
                                                                              .star,
                                                                          color: materialRequisitionList[0]['priority'] == 'f' || materialRequisitionList[0]['priority'] == 'e'
                                                                              ? Colors.yellow
                                                                              : Colors.grey),
                                                                      Icon(
                                                                          Icons
                                                                              .star,
                                                                          color: materialRequisitionList[0]['priority'] == 'f'
                                                                              ? Colors.yellow
                                                                              : Colors.grey),
                                                                    ],
                                                                  ))
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
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Order Date: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${materialRequisitionList[0]['order_date'] == false ? '-' : materialRequisitionList[0]['order_date']}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Scheduled Date: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${materialRequisitionList[0]['scheduled_date'] == false ? '-' : materialRequisitionList[0]['scheduled_date']}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Location: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${materialRequisitionList[0]['location_id'] == false ? '-' : materialRequisitionList[0]['location_id'][1]}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Description: ',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${materialRequisitionList[0]['desc'] == false ? '-' : materialRequisitionList[0]['desc']}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
                                                                      ])),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      ])),
                                                    ),
                                                    SliverPadding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      sliver:
                                                          SliverToBoxAdapter(
                                                              child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                top: 10,
                                                                bottom: 10),
                                                        height: 50,
                                                        width: 20,
                                                        color: Colors.white,
                                                        child: const Text(
                                                          "Product Line",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                        ),
                                                      )),
                                                    ),
                                                    SliverPadding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        sliver:
                                                            materialproductlineWidget),
                                                    const SliverToBoxAdapter(
                                                      child:
                                                          SizedBox(height: 20),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10, right: 10),
                                            child: Align(
                                              alignment: Alignment.topRight,
                                              child: Container(
                                                // width: 100,
                                                // height: 60,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  // color: AppColors.appBarColor,
                                                ),
                                                child: Container(
                                                    child:
                                                        materialRequisitionList[
                                                                        0]
                                                                    ['state'] ==
                                                                'draft'
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
                                                                      'Draft',
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
                                                                      'Confirm',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.white)),
                                                                ),
                                                              )),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                floatingActionButton: SpeedDial(
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
                                      //   visible: materialRequisitionList[0]
                                      //               ['state'] ==
                                      //           'confirm'
                                      //       ? false
                                      //       : true,
                                      //   onTap: () {
                                      //     Navigator.of(context).push(
                                      //         MaterialPageRoute(
                                      //             builder: (context) {
                                      //       return MaterialRequisitionCreatePage(
                                      //         name: materialRequisitionList[0]
                                      //             ['name'],
                                      //         neworedit: 0,
                                      //         userId: widget.userId,
                                      //       );
                                      //     })).then((value) {
                                      //       setState(() {});
                                      //     });
                                      //   },
                                      //   child: const Icon(Icons.edit),
                                      //   label: 'Edit',
                                      // ),
                                      // SpeedDialChild(
                                      //   onTap: () {
                                      //     Navigator.of(context).push(
                                      //         MaterialPageRoute(
                                      //             builder: (context) {
                                      //       return MaterialRequisitionCreatePage(
                                      //         name: '',
                                      //         neworedit: 0,
                                      //         userId: widget.userId,
                                      //       );
                                      //     })).then((value) {
                                      //       setState(() {});
                                      //     });
                                      //   },
                                      //   child: const Icon(Icons.add),
                                      //   label: 'Create',
                                      // ),
                                      SpeedDialChild(
                                        visible: materialRequisitionList[0]
                                                    ['state'] ==
                                                'confirm'
                                            ? false
                                            : true,
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Are you sure you want to Delete?"),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            "Cancel")),
                                                    TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                        onPressed: () {},
                                                        child: const Text(
                                                          "Delete",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ))
                                                  ],
                                                );
                                              }).then((value) {
                                            setState(() {});
                                          });
                                        },
                                        child: const Icon(Icons.delete_forever),
                                        label: 'Delete',
                                      ),
                                      SpeedDialChild(
                                        visible: materialRequisitionList[0]
                                                    ['state'] ==
                                                'confirm'
                                            ? false
                                            : true,
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Order Confirmation!'),
                                                  content: const Text(
                                                      'Do you want to Order Confirm?'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('No')),
                                                    TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            isupdateStatus =
                                                                true;
                                                            print(
                                                                'isupdateStatus $isupdateStatus');
                                                          });
                                                          materialrequisitioncreateBloc
                                                              .callActionConfirm(
                                                                  materialRequisitionList[
                                                                      0]['id']);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child:
                                                            const Text('Yes'))
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
                            isupdateStatus == true
                                ? StreamBuilder<ResponseOb>(
                                    initialData:
                                        ResponseOb(msgState: MsgState.loading),
                                    stream: materialrequisitioncreateBloc
                                        .getCallActionConfirmStream(),
                                    builder: (context,
                                        AsyncSnapshot<ResponseOb> snapshot) {
                                      ResponseOb? responseOb = snapshot.data;
                                      if (responseOb?.msgState ==
                                          MsgState.loading) {
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
                                          MsgState.data) {
                                        isupdateStatus = false;
                                      }
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
                            isCreatePR == true
                                ? StreamBuilder<ResponseOb>(
                                    initialData:
                                        ResponseOb(msgState: MsgState.loading),
                                    stream: purchaserequisitionBloc
                                        .getCreatePurchaseRequisitionStream(),
                                    builder: (context,
                                        AsyncSnapshot<ResponseOb> snapshot) {
                                      ResponseOb? responseOb = snapshot.data;
                                      if (responseOb?.msgState ==
                                          MsgState.loading) {
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
                                          MsgState.data) {
                                        isCreatePR = false;
                                        // int pickingIds = responseOb!.data;
                                        // print('PickingIds: $pickingIds');
                                        // quotationEditBloc.updateQuotationPickingIdsData(
                                        //     ids: quotationList[0]['id'],
                                        //     pickingIds: pickingIds);
                                      }
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
                            isCreatePPL == true
                                ? StreamBuilder<ResponseOb>(
                                    initialData:
                                        ResponseOb(msgState: MsgState.loading),
                                    stream: purchaserequisitionBloc
                                        .getCreatePurchaseProductLineStream(),
                                    builder: (context,
                                        AsyncSnapshot<ResponseOb> snapshot) {
                                      ResponseOb? responseOb = snapshot.data;
                                      if (responseOb?.msgState ==
                                          MsgState.loading) {
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
                                          MsgState.data) {
                                        isCreatePPL = false;
                                        // int pickingIds = responseOb!.data;
                                        // print('PickingIds: $pickingIds');
                                        // quotationEditBloc.updateQuotationPickingIdsData(
                                        //     ids: quotationList[0]['id'],
                                        //     pickingIds: pickingIds);
                                      }
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
                      }
                    });
              }
            }),
      ),
    );
  }
}
