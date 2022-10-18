import 'package:flutter/material.dart';
import 'package:smc_mobile/features/pages/material_requisition/material_requisition_list.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/product_line_ob.dart';
import '../../../obs/response_ob.dart';
import '../../../pages/material_requisition_page/material_product_line_page/material_product_line_bloc.dart';
import '../../../pages/material_requisition_page/material_requisition_bloc.dart';
import '../../../pages/material_requisition_page/material_requisition_create_bloc.dart';
import '../../../pages/material_requisition_page/purchase_requisition_bloc.dart';
import '../../../pages/quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import '../../../utils/app_const.dart';

class MaterialRequisitionDetail extends StatefulWidget {
  Map<String, dynamic> mrList;
  MaterialRequisitionDetail({
    Key? key,
    required this.mrList,
  }) : super(key: key);

  @override
  State<MaterialRequisitionDetail> createState() =>
      _MaterialRequisitionDetailState();
}

class _MaterialRequisitionDetailState extends State<MaterialRequisitionDetail> {
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
        .getMaterialRequisitionListWithIdData(['id', '=', widget.mrList['id']]);
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
      if (element['material_porduct_id'][0] == widget.mrList['id']) {
        print('ORderId?????: ${element['material_porduct_id']}');
        print('Found: ${element['id']}');
        final productlineOb = ProductLineOb(
          id: element['id'],
          isSelect: 1,
          materialproductId: widget.mrList['id'],
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
      materialproductlineBloc
          .getMaterialProductLineListData(widget.mrList['id']);
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
      materialRequisitionBloc.getMaterialRequisitionListWithIdData(
          ['id', '=', widget.mrList['id']]);
    }
  }

  void getCallActionConfirmListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isupdateStatus = false;
      });
      materialRequisitionBloc.getMaterialRequisitionListWithIdData(
          ['id', '=', widget.mrList['id']]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await databaseHelper.deleteAllSaleOrderLineUpdate();
        await databaseHelper.deleteAllTripPlanDeliveryUpdate();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return MaterialRequisitionList();
        }), (route) => false);
        return true;
      },
      child: SafeArea(
          child: StreamBuilder<ResponseOb>(
        initialData: materialRequisitionList.isNotEmpty
            ? null
            : ResponseOb(msgState: MsgState.loading),
        stream:
            materialRequisitionBloc.getMaterialRequisitionListWithIdStream(),
        builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
          ResponseOb? responseOb = snapshot.data;
          if (responseOb!.msgState == MsgState.loading) {
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
          } else if (responseOb.msgState == MsgState.error) {
            return const Center(
              child: Text('Error'),
            );
          } else {
            return StreamBuilder<ResponseOb>(
                initialData: productlineList.isNotEmpty
                    ? null
                    : ResponseOb(msgState: MsgState.loading),
                stream:
                    materialproductlineBloc.getMaterialProductLineListStream(),
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
                    return const Center(
                      child: Text("Something went wrong!"),
                    );
                  } else {
                    return Stack(
                      children: [
                        Scaffold(
                          backgroundColor: Colors.grey[200],
                          appBar: AppBar(
                            backgroundColor:
                                const Color.fromARGB(255, 12, 41, 92),
                            elevation: 0.0,
                            title:
                                Text('${materialRequisitionList[0]['name']}'),
                            actions: [
                              Visibility(
                                visible: materialRequisitionList[0]['state'] ==
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
                                Widget saleOrderLineWidget = SliverToBoxAdapter(
                                  child: Container(),
                                );
                                if (snapshot.hasData) {
                                  saleOrderLineWidget = SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                    (context, i) {
                                      print(
                                          'SOLLength------------: ${materialproductlineDBList?.length}');
                                      return Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            color: Colors.white,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            '${materialproductlineDBList![i].productCodeName}}',
                                                            style: const TextStyle(
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
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            materialproductlineDBList![
                                                                    i]
                                                                .description,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15))
                                                      ]),
                                                ),
                                                const SizedBox(
                                                  width: 2,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            materialproductlineDBList![
                                                                    i]
                                                                .uomName,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15))
                                                      ]),
                                                ),
                                                const SizedBox(
                                                  width: 2,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            materialproductlineDBList![
                                                                    i]
                                                                .quantity,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        15))
                                                      ]),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      );
                                    },
                                    childCount:
                                        materialproductlineDBList!.length,
                                  ));
                                } else {
                                  saleOrderLineWidget = SliverToBoxAdapter(
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                                          const EdgeInsets.all(
                                                              5),
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
                                                              TextButton(
                                                                  style: TextButton.styleFrom(
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .appBarColor),
                                                                  onPressed:
                                                                      () {},
                                                                  child: const Text(
                                                                      'Create',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                      ))),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Visibility(
                                                                visible: materialRequisitionList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'draft'
                                                                    ? true
                                                                    : false,
                                                                child: TextButton(
                                                                    style: TextButton.styleFrom(backgroundColor: Colors.grey[200]),
                                                                    onPressed: () {},
                                                                    child: const Text('Edit',
                                                                        style: TextStyle(
                                                                          color:
                                                                              AppColors.appBarColor,
                                                                        ))),
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Visibility(
                                                                visible: materialRequisitionList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'draft'
                                                                    ? true
                                                                    : false,
                                                                child: TextButton(
                                                                    style: TextButton.styleFrom(
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .appBarColor,
                                                                    ),
                                                                    onPressed: () {
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return AlertDialog(
                                                                              title: const Text('Order Confirmation!'),
                                                                              content: const Text('Do you want to Order Confirm?'),
                                                                              actions: [
                                                                                TextButton(
                                                                                    onPressed: () {
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: const Text('No')),
                                                                                TextButton(
                                                                                    onPressed: () {
                                                                                      setState(() {
                                                                                        isupdateStatus = true;
                                                                                        print('isupdateStatus $isupdateStatus');
                                                                                      });
                                                                                      materialrequisitioncreateBloc.callActionConfirm(materialRequisitionList[0]['id']);
                                                                                      Navigator.of(context).pop();
                                                                                    },
                                                                                    child: const Text('Yes'))
                                                                              ],
                                                                            );
                                                                          });
                                                                    },
                                                                    child: const Text('Order Confirm',
                                                                        style: TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                        ))),
                                                              ),
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
                                                                  color: materialRequisitionList[0]
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
                                                                      color: materialRequisitionList[0]['state'] ==
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
                                                                  color: materialRequisitionList[0]
                                                                              [
                                                                              'state'] ==
                                                                          'confirm'
                                                                      ? AppColors
                                                                          .appBarColor
                                                                      : Colors.grey[
                                                                          200],
                                                                ),
                                                                child: Text(
                                                                    'Confirm',
                                                                    style:
                                                                        TextStyle(
                                                                      color: materialRequisitionList[0]['state'] ==
                                                                              'confirm'
                                                                          ? Colors
                                                                              .white
                                                                          : AppColors
                                                                              .appBarColor,
                                                                    ))),
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
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                materialRequisitionList[
                                                                    i]['name'],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        30,
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
                                                                            '${materialRequisitionList[i]['ref_no'] == false ? '' : materialRequisitionList[i]['ref_no']}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
                                                                      ])),
                                                                  const SizedBox(
                                                                      width:
                                                                          10),
                                                                  const Expanded(
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
                                                                            '${materialRequisitionList[i]['scheduled_date']}',
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
                                                                  const Expanded(
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
                                                                            materialRequisitionList[i]['request_person'][
                                                                                1],
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
                                                                      ])),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  const Expanded(
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
                                                                            '${materialRequisitionList[i]['location_id'] == false ? '' : materialRequisitionList[i]['location_id'][1]}',
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
                                                                  const Expanded(
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
                                                                            '${materialRequisitionList[i]['department_id'] == false ? '' : materialRequisitionList[i]['department_id'][1]}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
                                                                      ])),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  const Expanded(
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
                                                                            '${materialRequisitionList[i]['desc']}',
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
                                                                  const Expanded(
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
                                                                            '${materialRequisitionList[i]['zone_id'][1]}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                            '${materialRequisitionList[i]['order_date']}',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
                                                                      ])),
                                                                  const Expanded(
                                                                      child:
                                                                          SizedBox()),
                                                                  const Expanded(
                                                                      child:
                                                                          SizedBox()),
                                                                ],
                                                              ),
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  const Expanded(
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
                                                                  )),
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
                                                                  materialRequisitionList
                                                                      .length))),
                                              SliverPadding(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                sliver: SliverToBoxAdapter(
                                                    child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                          Expanded(
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
                                                                          .end,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          Expanded(
                                                              child: Text(
                                                                  'Unit of Measures',
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
                                                          Expanded(
                                                              child: Text('Qty',
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
                                          width: 150,
                                          height: 150,
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
                                        width: 150,
                                        height: 150,
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
                                          width: 150,
                                          height: 150,
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
                                        width: 150,
                                        height: 150,
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
                                          width: 150,
                                          height: 150,
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
                                        width: 150,
                                        height: 150,
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
        },
      )),
    );
  }
}
