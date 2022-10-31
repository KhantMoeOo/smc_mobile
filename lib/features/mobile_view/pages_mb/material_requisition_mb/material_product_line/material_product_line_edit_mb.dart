import 'dart:convert';
import 'dart:typed_data';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../dbs/database_helper.dart';
import '../../../../../obs/product_line_ob.dart';
import '../../../../../obs/response_ob.dart';
import '../../../../../obs/sale_order_line_ob.dart';
import '../../../../../pages/quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import '../../../../../utils/app_const.dart';

class MaterialProductLineEditMB extends StatefulWidget {
  int mrId;
  int newOrEdit;
  ProductLineOb? productlineList;
  MaterialProductLineEditMB({
    Key? key,
    required this.mrId,
    required this.newOrEdit,
    required this.productlineList,
  }) : super(key: key);

  @override
  State<MaterialProductLineEditMB> createState() =>
      _MaterialProductLineEditMBState();
}

class _MaterialProductLineEditMBState extends State<MaterialProductLineEditMB> {
  bool hasNotProductProduct = true;
  bool hasNotUOM = true;
  bool hasNotAccountTaxes = true;

  bool hasProductProductData = false;
  bool hasUOMData = false;
  bool hasAccountTaxesData = false;

  final saleorderlineBloc = SaleOrderLineBloc();

  String productproductName = '';
  int productproductId = 0;
  int productproductuomId = 0;
  String productproductuomName = '';
  int productUOMCategoryId = 0;
  String productUOMCategoryName = '';
  double productUOMFactor = 0.0;
  String uomName = '';
  String description = '';
  String unitPrice = '';
  int uomId = 0;
  double uomFactor = 0.0;
  String quantity = '';
  bool hasQuantity = false;
  bool hasUnitPrice = false;
  String accounttaxesName = '';
  int accounttaxesId = 0;
  List<dynamic> accounttaxesIdList = [];
  List<dynamic> accounttaxesNameList = [];
  bool isCheck = false;
  int prioritySortUOMCategoryId = 0;
  String prioritySortUOMCategoryName = '';
  double totalFactor = 0.0;

  String custPriority = '';
  String zonePriority = '';
  String segPriority = '';
  String regionPriority = '';
  String productPriority = '';
  List<dynamic> custPrice = [];
  List<dynamic> zonePrice = [];
  List<dynamic> segPrice = [];
  List<dynamic> regionPrice = [];
  List<dynamic> productPrice = [];
  List<dynamic> prioritySort = [];
  List<dynamic> finalprioritySort = [];

  List<dynamic> productproductList = [];
  List<dynamic> uomList = [];

  List<dynamic> productproductListUpdate = [];
  List<dynamic> uomListUpdate = [];

  List<dynamic> salepricelistproductlineList = [];
  List<dynamic> unitpriceList = [];
  List<dynamic> salepricelistList = [];
  List<dynamic> accounttaxsList = [];
  List<dynamic> taxslistUpload = [];

  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();
  final subTotalController = TextEditingController();
  final salediscountController = TextEditingController();
  final promotinController = TextEditingController();
  final discountController = TextEditingController();
  final promodiscountController = TextEditingController();
  final databaseHelper = DatabaseHelper();
  int saleorderlineId = 0;
  final _formKey = GlobalKey<FormState>();

  FocusNode unitpriceFocus = FocusNode();
  FocusNode quantityFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('New or Edit: ${widget.newOrEdit}');
    print('MRId: ${widget.mrId}');
    print('MPL id: ${widget.productlineList!.id}');
    quantityFocus.addListener(() {
      if (!quantityFocus.hasFocus) {
        print('Quantity UnFocus');
        subTotalController.text = (double.parse(quantityController.text) *
                double.parse(unitPriceController.text))
            .toString();
        print('subtotal: ${subTotalController.text}');
      }
    });
    saleorderlineBloc.getProductProductData();
    saleorderlineBloc
        .getProductProductListStream()
        .listen(getProductProductListListen);
    saleorderlineBloc.getUOMListStream().listen(getUOMListListen);
    quantityController.text = widget.productlineList!.quantity;
    hasQuantity = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    saleorderlineBloc.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    unitpriceFocus.dispose();
  }

  void getProductProductListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productproductList = responseOb.data;
      hasProductProductData = true;
      saleorderlineBloc.getUOMListData();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoProductProductList");
    }
  }

  void setProductCodeNameMethod() {
    setState(() {
      if (widget.productlineList!.productCodeId != 0) {
        for (var element in productproductList) {
          if (element['id'] == widget.productlineList!.productCodeId) {
            hasNotProductProduct = false;
            productproductId = element['id'];
            productproductName = element['product_code'];
            descriptionController.text = element['name'];
            productproductuomId = element['uom_id'][0];
            productproductuomName = element['uom_id'][1];

            print('ProductProductName:$productproductName');
            print('ProductProductId:$productproductId');
            print(
                'ProductProductuomID&Name:$productproductuomId , $productproductuomName');
            for (var uom in uomList) {
              if (uom['id'] == productproductuomId) {
                productUOMCategoryId = uom['category_id'][0];
                productUOMCategoryName = uom['category_id'][1];
                productUOMFactor = element['factor'];
                print('productUOMFactor: $productUOMFactor');
                print(
                    "ProductUOMCategory: [$productUOMCategoryId,$productUOMCategoryName]");
              }
            }
          }
        }
        for (var getuomList in uomList) {
          if (getuomList['category_id'][0] == productUOMCategoryId) {
            uomListUpdate.add(getuomList);
          }
        }
        print("UOMList: $uomList");
      }
    });
  }

  void getUOMListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      uomList = responseOb.data;
      hasUOMData = true;
      setProductCodeNameMethod();
      setUOMNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoUOMList");
    }
  } // listen to get UOM List

  void getUOMListId(String? v) {
    if (v != null) {
      setState(() {
        uomId = int.parse(v.toString().split(',')[0]);
        hasNotUOM = false;
        for (var element in uomList) {
          if (element['id'] == uomId) {
            uomName = element['name'];
            uomId = element['id'];
            print('UOM Name: $uomName');
            print('UOM Id : $uomId');
          }
        }
      });
    } else {
      hasNotUOM = true;
    }
  } // get UOMId from UOMListSelection

  void setUOMNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.productlineList!.uomId != 0) {
        for (var element in uomList) {
          if (element['id'] == widget.productlineList!.uomId) {
            hasNotUOM = false;
            uomId = element['id'];
            uomName = element['name'];
            print('uomId: $uomId');
            print('uomName: $uomName');
          }
        }
      }
    }
  } // Set Region Name to Update Quotation Page

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          title: const Text("Create Order Line"),
          actions: [
            TextButton(
                onPressed: () async {
                  if (widget.newOrEdit == 1) {
                    bool isValid = _formKey.currentState!.validate();
                    if (isValid) {
                      await databaseHelper.updateMaterialProductLine(
                        id: widget.productlineList!.id,
                        mrId: widget.mrId,
                        isSelect: 1,
                        quantity: quantityController.text,
                        uomId: uomId,
                        uomName: uomName,
                      );
                      Navigator.of(context).pop();
                    }
                  } else {
                    bool isValid = _formKey.currentState!.validate();
                    if (isValid) {
                      await databaseHelper.updateMaterialProductLine(
                        id: widget.productlineList!.id,
                        mrId: 0,
                        isSelect: 1,
                        quantity: quantityController.text,
                        uomId: uomId,
                        uomName: uomName,
                      );
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 200,
                    child: Text(
                      'Product Name',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const Text(
                    ":",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.productlineList!.description,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18))
                        ]),
                  )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 200,
                    child: Text(
                      'Product Code',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const Text(
                    ":",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey),
                      color: Colors.white,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.productlineList!.productCodeName,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18))
                        ]),
                  )),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Quantity:",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: hasQuantity == true ? Colors.black : Colors.red),
              ),
              Container(
                height: 40,
                color: Colors.white,
                child: TextFormField(
                  // readOnly: hasNotProductProduct == true ? true : false,
                  focusNode: quantityFocus,
                  onChanged: (value) {
                    if (value == '') {
                      setState(() {
                        hasQuantity = false;
                      });
                    } else {
                      setState(() {
                        hasQuantity = true;
                      });
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Quantity';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  // onFieldSubmitted: (value) {
                  //   subTotalController.text = (double.parse(value) *
                  //           double.parse(unitPriceController.text))
                  //       .toString();
                  //   print('subtotal: ${subTotalController.text}');
                  // },
                  controller: quantityController,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ), // Quantity from Order Line
              const SizedBox(
                height: 10,
              ),
              const Text(
                "UOM:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Container(
                height: 40,
                color: Colors.white,
                child: StreamBuilder<ResponseOb>(
                    initialData: hasUOMData == true
                        ? null
                        : ResponseOb(msgState: MsgState.loading),
                    stream: saleorderlineBloc.getUOMListStream(),
                    builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                      ResponseOb? responseOb = snapshot.data;
                      if (responseOb?.msgState == MsgState.loading) {
                        return Center(
                          child: Image.asset(
                            'assets/gifs/loading.gif',
                            width: 100,
                            height: 100,
                          ),
                        );
                      } else if (responseOb?.msgState == MsgState.error) {
                        return const Center(
                          child: Text("Something went Wrong!"),
                        );
                      } else {
                        return DropdownSearch<String>(
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select UOM';
                            }
                            return null;
                          },
                          popupItemBuilder: (context, item, isSelected) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.toString().split(',')[1]),
                                  const Divider(),
                                ],
                              ),
                            );
                          },
                          showSearchBox: true,
                          showSelectedItems: true,
                          // showClearButton: !hasNotUOM,
                          items: uomListUpdate
                              .map((e) => '${e['id']},${e['name']}')
                              .toList(),
                          onChanged: getUOMListId,
                          selectedItem: uomName,
                        );
                      }
                    }),
              ), // UOM Many2one from Order Line
            ],
          ),
        ),
      ),
    );
  }
}
