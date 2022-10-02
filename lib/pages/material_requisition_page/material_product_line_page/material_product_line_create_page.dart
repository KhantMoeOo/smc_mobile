import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/product_line_ob.dart';
import '../../../obs/response_ob.dart';
import '../../../utils/app_const.dart';
import '../../quotation_page/sale_order_line_page/sale_order_line_bloc.dart';

class MaterialProductLineCreatePage extends StatefulWidget {
  const MaterialProductLineCreatePage({Key? key}) : super(key: key);

  @override
  State<MaterialProductLineCreatePage> createState() =>
      _MaterialProductLineCreatePageState();
}

class _MaterialProductLineCreatePageState
    extends State<MaterialProductLineCreatePage> {
  final saleorderlineBloc = SaleOrderLineBloc();
  final databaseHelper = DatabaseHelper();

  bool hasProductProductData = false;
  bool hasNotProductProduct = true;
  List<dynamic> productproductList = [];
  int productproductId = 0;
  String productproductName = '';

  final descriptionController = TextEditingController();
  String description = '';

  List<dynamic> uomList = [];
  bool hasUOMData = false;
  List<dynamic> uomListUpdate = [];
  bool hasNotUOM = true;
  int uomId = 0;
  String uomName = '';
  int productproductuomId = 0;
  String productproductuomName = '';
  int productUOMCategoryId = 0;
  String productUOMCategoryName = '';

  final quantityController = TextEditingController();
  String quantity = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    saleorderlineBloc.getProductProductData();
    saleorderlineBloc
        .getProductProductListStream()
        .listen(getProductProductListListen);
    saleorderlineBloc.getUOMListData();
    saleorderlineBloc.getUOMListStream().listen(getUOMListListen);
  }

  void getProductProductListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productproductList = responseOb.data;
      hasProductProductData = true;
    } else if (responseOb.msgState == MsgState.error) {
      print("NoProductProductList");
    }
  } // listen to get ProductProduct List

  void getUOMListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      uomList = responseOb.data;
      hasUOMData = true;
    } else if (responseOb.msgState == MsgState.error) {
      print("NoUOMList");
    }
  } // listen to get UOM List

  void getProductProductId(String? v) {
    if (v != null) {
      print('v result: $v');
      setState(() {
        productproductId = int.parse(v.toString().split(',')[0]);
        hasNotProductProduct = false;
        uomListUpdate.clear();
        for (var element in productproductList) {
          if (element['id'] == productproductId) {
            hasNotUOM = false;
            productproductName = element['product_code'];
            descriptionController.text = element['name'];
            productproductId = element['id'];
            productproductuomId = element['uom_id'][0];
            productproductuomName = element['uom_id'][1];
            uomId = productproductuomId;
            uomName = productproductuomName;
            print('ProductProductName:$productproductName');
            print('ProductProductId:$productproductId');
            print(
                'ProductProductuomID&Name:$productproductuomId , $productproductuomName');
            print('work sppl');
            for (var uom in uomList) {
              if (uom['id'] == productproductuomId) {
                productUOMCategoryId = uom['category_id'][0];
                productUOMCategoryName = uom['category_id'][1];
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
      });
    } else {
      setState(() {
        hasNotProductProduct = true;
      });
    }
  }

  void getUOMListId(String? v) {
    if (v != null) {
      setState(() {
        uomId = int.parse(v.toString().split(',')[0]);
        hasNotUOM = false;
        for (var element in uomList) {
          if (element['id'] == uomId) {
            uomName = element['name'];
            uomId = element['id'];
            productUOMCategoryId = element['category_id'][0];
            productUOMCategoryName = element['category_id'][1];
            print('uomName:$uomName');
            print('uomId:$uomId');
            print(
                'productUOM Category: [$productUOMCategoryId, $productUOMCategoryName]');
          }
        }
      });
    } else {
      hasNotUOM = true;
    }
  } // get UOMId from UOMListSelection

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          title: const Text('New'),
          actions: [
            TextButton(
                onPressed: () async {
                  final productlineOb = ProductLineOb(
                      isSelect: 1,
                      materialproductId: 0,
                      productCodeName: productproductName,
                      productCodeId: productproductId,
                      description: descriptionController.text,
                      fullName:
                          '$productproductName ${descriptionController.text}',
                      quantity: quantity,
                      uomName: uomName,
                      uomId: uomId);
                  await databaseHelper.insertMaterialProductLine(productlineOb);
                  Navigator.of(context).pop();
                },
                child: const Text('Save'))
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            const Text(
              "Product Code:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
              color: Colors.white,
              height: 40,
              child: StreamBuilder<ResponseOb>(
                  initialData: hasProductProductData == true
                      ? null
                      : ResponseOb(msgState: MsgState.loading),
                  stream: saleorderlineBloc.getProductProductListStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
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
                            return 'Please select Product Name';
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
                        showClearButton: !hasNotProductProduct,
                        items: productproductList.map((e) {
                          return '${e['id']},${e['product_code']}';
                        }).toList(),
                        onChanged: getProductProductId,
                        selectedItem: productproductName,
                      );
                    }
                  }),
            ), // Product Code Many2one from Order Line
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Description:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
              color: Colors.white,
              height: 40,
              child: TextField(
                controller: descriptionController,
                readOnly: true,
                onChanged: (des) {
                  setState(() {
                    description = des;
                  });
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ), // description field from Order Line
            const SizedBox(
              height: 10,
            ),
            const Text(
              "UOM:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
              color: Colors.white,
              height: 40,
              child: StreamBuilder<ResponseOb>(
                  initialData: hasUOMData == true
                      ? null
                      : ResponseOb(msgState: MsgState.loading),
                  stream: saleorderlineBloc.getUOMListStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
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
                        showClearButton: !hasNotUOM,
                        items: uomListUpdate
                            .map((e) => '${e['id']},${e['name']}')
                            .toList(),
                        onChanged: getUOMListId,
                        selectedItem: uomName,
                      );
                    }
                  }),
            ), // UOM Many2one from Order Line

            const SizedBox(
              height: 10,
            ),
            const Text(
              "Quantity:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
              color: Colors.white,
              height: 40,
              child: TextField(
                controller: quantityController,
                onChanged: (qty) {
                  setState(() {
                    quantity = qty;
                  });
                },
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ), // description field from Order Line
          ],
        ),
      ),
    );
  }
}
