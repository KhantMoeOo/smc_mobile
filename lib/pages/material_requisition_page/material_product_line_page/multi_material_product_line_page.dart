import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/product_line_ob.dart';
import '../../../obs/response_ob.dart';
import '../../../obs/sale_order_line_ob.dart';
import '../../../utils/app_const.dart';
import '../../quotation_page/sale_order_line_page/sale_order_line_bloc.dart';

class MultiMaterialProductLinePage extends StatefulWidget {
  int quotationId;
  int newOrEdit;
  int newOrEditSOL;
  int solId;
  int? productCodeId;
  String? productCodeName;
  String? quantity;
  int? uomId;
  String? unitPrice;
  int partnerId;
  int zoneId;
  int segmentId;
  int regionId;
  int currencyId;
  String? subtotal;
  int? taxesId;
  String? taxesName;
  int? isFOC;
  MultiMaterialProductLinePage({
    Key? key,
    required this.quotationId,
    required this.newOrEdit,
    required this.newOrEditSOL,
    required this.solId,
    this.productCodeId,
    this.productCodeName,
    this.quantity,
    this.unitPrice,
    this.uomId,
    required this.partnerId,
    required this.zoneId,
    required this.segmentId,
    required this.regionId,
    required this.currencyId,
    this.subtotal,
    this.taxesId,
    this.taxesName,
    this.isFOC,
  }) : super(key: key);

  @override
  State<MultiMaterialProductLinePage> createState() =>
      _MultiMaterialProductLinePageState();
}

class _MultiMaterialProductLinePageState
    extends State<MultiMaterialProductLinePage> {
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
  String uomName = 'pcs';
  String description = '';
  String unitPrice = '';
  int uomId = 0;
  double uomFactor = 0.0;
  String quantity = '';
  bool hasQuantity = false;
  bool hasUnitPrice = false;
  String accounttaxesName = '';
  int accounttaxesId = 0;
  bool isCheck = false;
  int prioritySortUOMCategoryId = 0;
  String prioritySortUOMCategoryName = '';
  double totalFactor = 0.0;

  String searchProductName = '';

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

  List<ProductLineOb>? productlineDBList = [];
  List<ProductLineOb>? productlinemultiselectList = [];

  List list = ['one', 'two', 'three'];

  final descriptionController = TextEditingController();
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();
  final subTotalController = TextEditingController();
  final salediscountController = TextEditingController();
  final promotinController = TextEditingController();
  final discountController = TextEditingController();
  final promodiscountController = TextEditingController();
  final productsearchController = TextEditingController();
  final databaseHelper = DatabaseHelper();
  int saleorderlineId = 0;
  final _formKey = GlobalKey<FormState>();

  FocusNode unitpriceFocus = FocusNode();
  FocusNode quantityFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    print("SOLIDS: ${widget.solId}");
    print("NewOrEdit: ${widget.newOrEditSOL}");
    print('CurrencyId: ${widget.currencyId}');
    print('SegmentId: ${widget.segmentId}');
    quantityFocus.addListener(() {
      if (!quantityFocus.hasFocus) {
        print('Quantity UnFocus');
        subTotalController.text = (double.parse(quantityController.text) *
                double.parse(unitPriceController.text))
            .toString();
        print('subtotal: ${subTotalController.text}');
      }
    });
    unitpriceFocus.addListener(() {
      if (!unitpriceFocus.hasFocus) {
        print('Unit Price UnFocus');
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
    saleorderlineBloc.getUOMListData();
    saleorderlineBloc.getUOMListStream().listen(getUOMListListen);
    saleorderlineBloc.getSalePricelistProductLineListData();
    saleorderlineBloc
        .getSalePricelistProductLineListStream()
        .listen(getSalePricelistProductLineListen);

    saleorderlineBloc.getSalePricelistData(['id', 'ilike', '']);
    saleorderlineBloc
        .getSalePricelistListStream()
        .listen(getSalePricelistListen);
    saleorderlineBloc.getAccountTaxeslistData();
    saleorderlineBloc
        .getAccountTaxeslistListStream()
        .listen(getAccountTaxesListListen);
    if (widget.newOrEditSOL == 1) {
      quantityController.text = widget.quantity!;
      unitPriceController.text = widget.unitPrice!;
      subTotalController.text = widget.subtotal!;
      hasQuantity = true;
      hasUnitPrice = true;
      // isCheck = widget.isFOC == 0 ? false : true;
    } else {
      quantityController.text = '1';
      hasQuantity = true;
      unitPriceController.text = '0.00';
      hasUnitPrice = true;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    saleorderlineBloc.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    unitpriceFocus.dispose();
  }

  void getSalePricelistProductLineListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salepricelistproductlineList = responseOb.data;
    } else if (responseOb.msgState == MsgState.error) {
      print("No SalePricelistProductline Data");
    }
  } // listen SalePricelistProductline

  Future<void> insertProductIntoSOLDB() async {
    for (var product in productproductList) {
      final productlineOb = ProductLineOb(
          isSelect: 0,
          materialproductId: 0,
          productCodeName:
              product['product_code'] == false ? '' : product['product_code'],
          productCodeId: product['id'],
          description: product['name'] == false ? '' : product['name'],
          fullName: product['name'] == false
              ? product['product_code']
              : '${product['product_code']} ${product['name']}',
          quantity: '0',
          uomName: '',
          uomId: 0);
      await databaseHelper.insertProductLineMultiSelect(productlineOb);
    }
    setState(() {});
  }

  void getSalePricelistListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salepricelistList = responseOb.data;
      print('salepricelistlength: ${salepricelistList.length}');
    } else if (responseOb.msgState == MsgState.error) {
      print('No SalePricelist Data');
    }
  }

  void getProductProductListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productproductList = responseOb.data;
      hasProductProductData = true;
      getProductProduct();
      setProductCodeNameMethod();
      insertProductIntoSOLDB();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoProductProductList");
    }
  } // listen to get ProductProduct List

  void getProductProduct() {
    for (var element in productproductList) {
      if (element['sale_ok'] == true &&
          (element['company_id'] == false || element['company_id'][0] == 1)) {
        productproductListUpdate.add(element);
      }
    }
    // print('Productproductlist: ' + productproductList.toString());
  }

  void getProductProductId(
      {int? productId, String? quantity, String? unitPrice, String? uom}) {
    if (productId != 0) {
      print('productproductId: $productId');
      setState(() {
        //productproductId = int.parse(v.toString().split(',')[0]);
        hasNotProductProduct = false;
        print('hasNotProductProduct $hasNotProductProduct');
        uomListUpdate.clear();
        prioritySort.clear();
        quantityController.text = quantity!;
        uomName = uom!;
        for (var element in productproductList) {
          if (element['id'] == productId) {
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
                productUOMFactor = uom['factor'];
                uomFactor = uom['factor'];
                print(
                    "ProductUOMCategory: [$productUOMCategoryId,$productUOMCategoryName]");
                print("productUOMFactor: $productUOMFactor");
                print("uomFactor: $uomFactor");
              }
            }
            Future.delayed(Duration(seconds: 2), () {
              calculateUnitPrice();
            });
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
        print('HasNotProduct: $hasNotProductProduct');
      });
    }
  } // get Product Product Id from Product ProductListSelection

  void calculateUnitPrice() {
    print("work");
    // for (var spl in salepricelistList) {
    //   print('SPLIds: ${spl['id']}, priority: ${spl['priority']}');
    //   print('pricelist_type: ${spl['pricelist_type']}');
    //   print('spplpricelistId: ${spl['pricelist_id'][0]}');
    // }
    setState(() {
      for (var sppl in salepricelistproductlineList) {
        //         print('widget.currencyId: ${widget.currencyId}');
        // print('widget.partnerId: ${widget.partnerId}');

        int currencyIdNew =
            sppl['currency_id'].isNotEmpty ? sppl['currency_id'][0] : 0;
        int customerIdNew =
            sppl['customer_ids'].isNotEmpty ? sppl['customer_ids'][0] : 0;
        int zoneIdNew = sppl['zone_ids'].isNotEmpty ? sppl['zone_id'][0] : 0;
        int segIdNew =
            sppl['segment_id'].isNotEmpty ? sppl['segment_id'][0] : 0;
        int regionIdNew =
            sppl['region_ids'].isNotEmpty ? sppl['region_ids'][0] : 0;
        // print('currencyIdNew: $currencyIdNew');
        // print('customerIdNew: $customerIdNew');
        if (widget.partnerId != 0) {
          if (sppl['pricelist_type'] == 'customer' &&
              sppl['product_id'][0] == productproductId &&
              currencyIdNew == widget.currencyId &&
              customerIdNew == widget.partnerId &&
              sppl['state'] == 'approved') {
            for (var spl in salepricelistList) {
              if (spl['id'] == sppl['pricelist_id'][0]) {
                custPriority = spl['priority'];
                sppl['priority_new'] = int.parse(custPriority);
              }
            }
            custPrice.add(sppl);
            prioritySort.add(sppl);
            print('CustPrice: $custPrice, priority: $custPriority');
          }
        }
        if (widget.zoneId != 0) {
          if (sppl['pricelist_type'] == 'zone' &&
              sppl['product_id'][0] == productproductId &&
              currencyIdNew == widget.currencyId &&
              zoneIdNew == widget.zoneId &&
              sppl['state'] == 'approved') {
            for (var spl in salepricelistList) {
              if (spl['id'] == sppl['pricelist_id'][0]) {
                zonePriority = spl['priority'];
                sppl['priority_new'] = int.parse(zonePriority);
              }
            }
            zonePrice.add(sppl);
            prioritySort.add(sppl);
            print('ZonePrice: $zonePrice, priority: $zonePriority');
          }
        }
        if (widget.segmentId != 0) {
          if (sppl['pricelist_type'] == 'segment' &&
              sppl['product_id'][0] == productproductId &&
              currencyIdNew == widget.currencyId &&
              segIdNew == widget.segmentId &&
              sppl['state'] == 'approved') {
            for (var spl in salepricelistList) {
              if (spl['id'] == sppl['pricelist_id'][0]) {
                segPriority = spl['priority'];
                sppl['priority_new'] = int.parse(segPriority);
              }
            }
            segPrice.add(sppl);
            prioritySort.add(sppl);
            print('segPrice: $segPrice, priority: $segPriority');
          }
        }
        if (widget.regionId != 0) {
          if (sppl['pricelist_type'] == 'region' &&
              sppl['product_id'][0] == productproductId &&
              currencyIdNew == widget.currencyId &&
              regionIdNew == widget.regionId &&
              sppl['state'] == 'approved') {
            for (var spl in salepricelistList) {
              if (spl['id'] == sppl['pricelist_id'][0]) {
                regionPriority = spl['priority'];
                sppl['priority_new'] = int.parse(regionPriority);
              }
            }
            regionPrice.add(sppl);
            prioritySort.add(sppl);
            print('regionPrice: $regionPrice, priority: $regionPriority');
          }
        }
        if (custPrice.isEmpty &&
            zonePrice.isEmpty &&
            segPrice.isEmpty &&
            regionPrice.isEmpty) {
          if (sppl['pricelist_type'] == 'product' &&
              sppl['product_id'][0] == productproductId &&
              currencyIdNew == widget.currencyId &&
              sppl['state'] == 'approved') {
            for (var spl in salepricelistList) {
              if (sppl['pricelist_id'][0] == spl['id']) {
                productPriority = spl['priority'];
                sppl['priority_new'] = int.parse(productPriority);
              }
            }
            productPrice.add(sppl);
            prioritySort.add(sppl);
            print('productPrice: $productPrice, priority: $productPriority');
          }
        }
        // prioritySort.sort();
        // print('prioritySort: ${prioritySort.reversed}');
        // prioritySort.reversed.map((e) => finalprioritySort.add(e)).toList();

      }
      if (prioritySort.isNotEmpty) {
        print('Priority Sort List: $prioritySort');
        prioritySort
            .sort((a, b) => (b['priority_new']).compareTo(a['priority_new']));
        print('Sorted Priority: ${prioritySort.toList()}');
        for (var uom in uomList) {
          if (uom['id'] == prioritySort[0]['uom_id'][0]) {
            prioritySortUOMCategoryId = uom['category_id'][0];
            prioritySortUOMCategoryName = uom['category_id'][1];
            print('prioritySortUOMCategoryId: $prioritySortUOMCategoryId');
            print('prioritySortUOMCategoryName: $prioritySortUOMCategoryName');
          }
        }
        if (prioritySortUOMCategoryId == productUOMCategoryId) {
          print('prioritySortUOMCategoryId == productUOMCategoryId');
          if (prioritySort[0]['uom_id'] != null &&
              prioritySort[0]['uom_id'][0] != uomId) {
            print('Does not same uomIds');
            totalFactor = (1.0 * uomFactor);
            totalFactor = (totalFactor / productUOMFactor);
            hasUnitPrice = true;
            unitPriceController.text =
                (prioritySort[0]['price'] * totalFactor).toString();
          } else {
            hasUnitPrice = true;
            unitPriceController.text = prioritySort[0]['price'].toString();
            print('Unit Price: ${prioritySort[0]['price']}');
            subTotalController.text = (double.parse(quantityController.text) *
                    double.parse(unitPriceController.text))
                .toString();
            print('subtotal: ${subTotalController.text}');
          }
        }
      } else {
        print('prioritySortUOMCategoryId != productUOMCategoryId');
        unitPriceController.text = '0.00';
        subTotalController.text = (double.parse(quantityController.text) *
                double.parse(unitPriceController.text))
            .toString();
        print('subtotal: ${subTotalController.text}');
      }
    });
    // unitpriceList.map((e) => print("UnitPriceList: ${e['id']}"));
  }

  void setProductCodeNameMethod() {
    setState(() {
      if (widget.newOrEditSOL == 1) {
        if (widget.productCodeId != 0) {
          for (var element in productproductList) {
            if (element['id'] == widget.productCodeId) {
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
      }
    });
  } // Set productproduct Name to Update productproductName Page

  void getUOMListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      uomList = responseOb.data;
      hasUOMData = true;
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
            productUOMCategoryId = element['category_id'][0];
            productUOMCategoryName = element['category_id'][1];
            // productUOMFactor = element['factor'];
            productUOMFactor = element['factor'];
            print('uomName:$uomName');
            print('uomId:$uomId');
            print(
                'productUOM Category: [$productUOMCategoryId, $productUOMCategoryName]');
            print("uomFactor: $uomFactor");
            if (prioritySort.isNotEmpty) {
              print('Priority Sort List: ${prioritySort}');
              prioritySort.sort(
                  (a, b) => (b['priority_new']).compareTo(a['priority_new']));
              print('Sorted Priority: ${prioritySort.toList()}');
              for (var uom in uomList) {
                if (uom['id'] == prioritySort[0]['uom_id'][0]) {
                  prioritySortUOMCategoryId = uom['category_id'][0];
                  prioritySortUOMCategoryName = uom['category_id'][1];
                  print(
                      'prioritySortUOMCategoryId: $prioritySortUOMCategoryId');
                  print(
                      'prioritySortUOMCategoryName: $prioritySortUOMCategoryName');
                }
              }
              if (prioritySortUOMCategoryId == productUOMCategoryId) {
                if (prioritySort[0]['uom_id'] != null &&
                    prioritySort[0]['uom_id'][0] != uomId) {
                  print('Does not same uomIds');
                  totalFactor = (1.0 * uomFactor);
                  totalFactor = (totalFactor / productUOMFactor);
                  unitPriceController.text =
                      (prioritySort[0]['price'] * totalFactor).toString();
                  subTotalController.text =
                      (double.parse(quantityController.text) *
                              double.parse(unitPriceController.text))
                          .toString();
                  print('subtotal: ${subTotalController.text}');
                  print('unit Price: ${unitPriceController.text}');
                } else {
                  unitPriceController.text =
                      prioritySort[0]['price'].toString();
                  print('Unit Price: ${prioritySort[0]['price']}');
                  subTotalController.text =
                      (double.parse(quantityController.text) *
                              double.parse(unitPriceController.text))
                          .toString();
                  print('unit Price: ${unitPriceController.text}');
                  print('subtotal: ${subTotalController.text}');
                }
              }
            } else {
              unitPriceController.text = '1.0';
              subTotalController.text = (double.parse(quantityController.text) *
                      double.parse(unitPriceController.text))
                  .toString();
              print('subtotal: ${subTotalController.text}');
            }
          }
        }
      });
    } else {
      hasNotUOM = true;
    }
  } // get UOMId from UOMListSelection

  void setUOMNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.uomId != 0) {
        for (var element in uomList) {
          if (element['id'] == widget.uomId) {
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

  void getAccountTaxesListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      accounttaxsList = responseOb.data;
      hasAccountTaxesData = true;
      setTaxesNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoaccounttaxsList");
    }
  } // listen to get Account Taxes List

  void getAccountTaxesListId(String? v) {
    if (v != null) {
      setState(() {
        accounttaxesId = int.parse(v.toString().split(',')[0]);
        hasNotAccountTaxes = false;
        for (var element in accounttaxsList) {
          if (element['id'] == accounttaxesId) {
            accounttaxesName = element['name'];
            accounttaxesId = element['id'];
            print('accounttaxesName: $accounttaxesName');
            print('accounttaxesId: $accounttaxesId');
          }
        }
      });
    } else {
      hasNotAccountTaxes = true;
    }
  } // get AccountTaxes ID from UOMListSelection

  void setTaxesNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.taxesId != 0) {
        for (var element in accounttaxsList) {
          if (element['id'] == widget.taxesId) {
            hasNotAccountTaxes = false;
            accounttaxesId = element['id'];
            accounttaxesName = element['name'];
            print('accounttaxesId: $accounttaxesId');
            print('accounttaxesName: $accounttaxesName');
          }
        }
      }
    }
  } // Set accounttaxesName Name to Update Quotation Page

  void calculateSubTotal() {
    subTotalController.text = (double.parse(quantityController.text) *
            double.parse(unitPriceController.text))
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: AppColors.appBarColor,
          title: const Text('Create Order Lines'),
          actions: [
            TextButton(
                onPressed: () async {
                  //await databaseHelper.insertTable2Table();
                  await databaseHelper.updateMPLSelect();
                  Navigator.of(context).pop();
                },
                child: const Text('Update',
                    style: TextStyle(
                      color: Colors.white,
                    )))
          ],
        ),
        body: StreamBuilder<ResponseOb>(
          initialData: ResponseOb(msgState: MsgState.loading),
          stream: saleorderlineBloc.getProductProductListStream(),
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
                child: const Center(child: Text('Error')),
              );
            } else {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                          onChanged: (value) {
                            // final result =
                            //     productlineDBList!.where((element) {
                            //   final productNameResult =
                            //       element.productCodeName.toLowerCase();
                            //   final input = value.toLowerCase();
                            //   return productNameResult.contains(input);
                            // }).toList();
                            // setState(() => productlineDBList = result);
                            searchProductName = value;
                            setState(() {});
                          },
                          controller: productsearchController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          )),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FutureBuilder<List<ProductLineOb>>(
                      future: databaseHelper
                          .getMaterialProductLineMultiSelectList(),
                      builder: (context, snapshot) {
                        productlinemultiselectList = snapshot.data;
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                spacing: 5,
                                //alignment: WrapAlignment.spaceBetween,
                                direction: Axis.horizontal,
                                children: productlinemultiselectList!.map((e) {
                                  return e.isSelect != 1
                                      ? Container()
                                      : Container(
                                          //width: 100,
                                          //padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: TextButton.icon(
                                                  onPressed: () async {
                                                    await databaseHelper
                                                        .updateMaterialProductLineMultiSelectIsSelect(
                                                            id: e.id);
                                                    setState(() {});
                                                  },
                                                  icon: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text(
                                                    e.productCodeName,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        );
                                }).toList(),
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            child: Center(
                              child: Image.asset(
                                'assets/gifs/loading.gif',
                                width: 100,
                                height: 100,
                              ),
                            ),
                          );
                        }
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(8),
                            width: 250,
                            child: const Text(
                              'Product Code',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )),
                        Container(
                            padding: const EdgeInsets.all(8),
                            width: 50,
                            child: const Text(
                              'QTY',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )),
                        Container(
                            padding: const EdgeInsets.all(8),
                            width: 100,
                            child: const Text(
                              'UOM',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            )),
                        // Container(
                        //     padding: const EdgeInsets.all(8),
                        //     width: 100,
                        //     child: const Text(
                        //       'Unit Price',
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 15,
                        //       ),
                        //     ))
                      ],
                    ),
                  ),
                  Expanded(
                      child: FutureBuilder<List<ProductLineOb>>(
                    future:
                        databaseHelper.searchProductLineName(searchProductName),
                    builder: (c, snapshot) {
                      productlineDBList = snapshot.data;
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: productlineDBList!.length,
                                  itemBuilder: (c, i) {
                                    print(
                                        'productlineDBList Length: ${productlineDBList!.length}');
                                    // print(
                                    //   'productlineDBList : ${productlineDBList![i].id}, ${productlineDBList![i].productCodeName}, ${productlineDBList![i].quantity}, ${productlineDBList![i].isSelect}');
                                    return Column(
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            getProductProductId(
                                                productId: productlineDBList![i]
                                                    .productCodeId,
                                                quantity: productlineDBList![i]
                                                    .quantity,
                                                uom: productlineDBList![i]
                                                    .uomName);
                                            print(
                                                'ProductCodeId: ${productlineDBList![i].productCodeId}');
                                            print(
                                                'ProductCodeName : ${productlineDBList![i].productCodeName}');
                                            print(
                                                'SOL id: ${productlineDBList![i].id}');
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    actions: [
                                                      Container(
                                                        color: Colors.green,
                                                        child: TextButton(
                                                          onPressed: () async {
                                                            // setState(() {
                                                            //   // subTotalController
                                                            //   //     .text = (int.parse(
                                                            //   //             unitPriceController
                                                            //   //                 .text) *
                                                            //   //         double.parse(
                                                            //   //             quantityController
                                                            //   //                 .text))
                                                            //   //     .toString();
                                                            // });
                                                            await databaseHelper.updateProductLineMultiSelect(
                                                                id: productlineDBList![
                                                                        i]
                                                                    .id,
                                                                materialproductId:
                                                                    0,
                                                                isSelect: 1,
                                                                productCodeId:
                                                                    productlineDBList![
                                                                            i]
                                                                        .productCodeId,
                                                                productCodeName:
                                                                    productlineDBList![
                                                                            i]
                                                                        .productCodeName,
                                                                description:
                                                                    productlineDBList![
                                                                            i]
                                                                        .description,
                                                                quantity:
                                                                    quantityController
                                                                        .text,
                                                                uomId: uomId,
                                                                uomName:
                                                                    uomName);
                                                            setState(() {});
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            'Select',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                    content: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          "Quantity:",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                              color:
                                                                  hasQuantity ==
                                                                          true
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .red),
                                                        ),
                                                        SizedBox(
                                                          height: 40,
                                                          child: TextFormField(
                                                            readOnly:
                                                                hasNotProductProduct ==
                                                                        true
                                                                    ? true
                                                                    : false,
                                                            focusNode:
                                                                quantityFocus,
                                                            onChanged: (value) {
                                                              if (value == '') {
                                                                setState(() {
                                                                  hasQuantity =
                                                                      false;
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  hasQuantity =
                                                                      true;
                                                                });
                                                              }
                                                            },
                                                            autovalidateMode:
                                                                AutovalidateMode
                                                                    .onUserInteraction,
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Please enter Quantity';
                                                              }
                                                              return null;
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            inputFormatters: <
                                                                TextInputFormatter>[
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly
                                                            ],
                                                            onFieldSubmitted:
                                                                (value) {
                                                              subTotalController
                                                                  .text = (double
                                                                          .parse(
                                                                              value) *
                                                                      double.parse(
                                                                          unitPriceController
                                                                              .text))
                                                                  .toString();
                                                              print(
                                                                  'subtotal: ${subTotalController.text}');
                                                            },
                                                            controller:
                                                                quantityController,
                                                            decoration:
                                                                const InputDecoration(
                                                                    border:
                                                                        OutlineInputBorder()),
                                                          ),
                                                        ), // Quantity from Order Line
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        const Text(
                                                          "UOM:",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                        ),
                                                        SizedBox(
                                                          height: 40,
                                                          child: StreamBuilder<
                                                                  ResponseOb>(
                                                              initialData: hasUOMData ==
                                                                      true
                                                                  ? null
                                                                  : ResponseOb(
                                                                      msgState:
                                                                          MsgState
                                                                              .loading),
                                                              stream: saleorderlineBloc
                                                                  .getUOMListStream(),
                                                              builder: (context,
                                                                  AsyncSnapshot<
                                                                          ResponseOb>
                                                                      snapshot) {
                                                                ResponseOb?
                                                                    responseOb =
                                                                    snapshot
                                                                        .data;
                                                                if (responseOb
                                                                        ?.msgState ==
                                                                    MsgState
                                                                        .loading) {
                                                                  return Center(
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/gifs/loading.gif',
                                                                      width:
                                                                          100,
                                                                      height:
                                                                          100,
                                                                    ),
                                                                  );
                                                                } else if (responseOb
                                                                        ?.msgState ==
                                                                    MsgState
                                                                        .error) {
                                                                  return const Center(
                                                                    child: Text(
                                                                        "Something went Wrong!"),
                                                                  );
                                                                } else {
                                                                  return DropdownSearch<
                                                                      String>(
                                                                    dialogMaxWidth:
                                                                        10,
                                                                    maxHeight:
                                                                        200,
                                                                    autoValidateMode:
                                                                        AutovalidateMode
                                                                            .onUserInteraction,
                                                                    validator:
                                                                        (value) {
                                                                      if (value ==
                                                                              null ||
                                                                          value
                                                                              .isEmpty) {
                                                                        return 'Please select UOM';
                                                                      }
                                                                      return null;
                                                                    },
                                                                    popupItemBuilder:
                                                                        (context,
                                                                            item,
                                                                            isSelected) {
                                                                      return Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(8.0),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(item.toString().split(',')[1]),
                                                                            const Divider(),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                    // showSearchBox:
                                                                    //     true,
                                                                    showSelectedItems:
                                                                        true,
                                                                    // showClearButton:
                                                                    //     !hasNotUOM,
                                                                    items: uomListUpdate
                                                                        .map((e) =>
                                                                            '${e['id']},${e['name']}')
                                                                        .toList(),
                                                                    onChanged:
                                                                        getUOMListId,
                                                                    selectedItem:
                                                                        uomName,
                                                                  );
                                                                }
                                                              }),
                                                        ), // UOM Many2one from Order Line
                                                        // const SizedBox(
                                                        //   height: 10,
                                                        // ),
                                                        // Text(
                                                        //   "Unit Price:",
                                                        //   style: TextStyle(
                                                        //       fontWeight:
                                                        //           FontWeight
                                                        //               .bold,
                                                        //       fontSize: 20,
                                                        //       color:
                                                        //           hasUnitPrice ==
                                                        //                   true
                                                        //               ? Colors
                                                        //                   .black
                                                        //               : Colors
                                                        //                   .red),
                                                        // ),
                                                        // SizedBox(
                                                        //   height: 40,
                                                        //   child: TextFormField(
                                                        //     readOnly: true,
                                                        //     focusNode:
                                                        //         unitpriceFocus,
                                                        //     onChanged: (value) {
                                                        //       if (value == '') {
                                                        //         setState(() {
                                                        //           hasUnitPrice =
                                                        //               false;
                                                        //         });
                                                        //       } else {
                                                        //         setState(() {
                                                        //           hasUnitPrice =
                                                        //               true;
                                                        //         });
                                                        //       }
                                                        //     },
                                                        //     autovalidateMode:
                                                        //         AutovalidateMode
                                                        //             .onUserInteraction,
                                                        //     validator: (value) {
                                                        //       if (value ==
                                                        //               null ||
                                                        //           value
                                                        //               .isEmpty) {
                                                        //         return 'Please enter Unit Price';
                                                        //       }
                                                        //       return null;
                                                        //     },
                                                        //     keyboardType:
                                                        //         const TextInputType
                                                        //                 .numberWithOptions(
                                                        //             decimal:
                                                        //                 true),
                                                        //     inputFormatters: <
                                                        //         TextInputFormatter>[
                                                        //       FilteringTextInputFormatter
                                                        //           .allow(RegExp(
                                                        //               r'^(\d+)?\.?\d{0,2}'))
                                                        //     ],
                                                        //     onFieldSubmitted:
                                                        //         (value) {
                                                        //       subTotalController
                                                        //           .text = (double.parse(
                                                        //                   quantityController
                                                        //                       .text) *
                                                        //               double.parse(
                                                        //                   value))
                                                        //           .toString();
                                                        //       print(
                                                        //           'subtotal: ${subTotalController.text}');
                                                        //     },
                                                        //     controller:
                                                        //         unitPriceController,
                                                        //     decoration:
                                                        //         const InputDecoration(
                                                        //             border:
                                                        //                 OutlineInputBorder()),
                                                        //   ),
                                                        // ), // Unit Price from Order Line
                                                        // const SizedBox(
                                                        //     height: 10),
                                                        // const Text(
                                                        //   "Subtotal:",
                                                        //   style: TextStyle(
                                                        //       fontWeight:
                                                        //           FontWeight
                                                        //               .bold,
                                                        //       fontSize: 20),
                                                        // ),
                                                        // SizedBox(
                                                        //   height: 40,
                                                        //   child: TextField(
                                                        //     readOnly: true,
                                                        //     controller:
                                                        //         subTotalController,
                                                        //     decoration:
                                                        //         const InputDecoration(
                                                        //             border:
                                                        //                 OutlineInputBorder()),
                                                        //   ),
                                                        // ), // Subtotal from Order Line
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 250,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          productlineDBList![i]
                                                              .productCodeName,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                          )),
                                                      Text(
                                                          productlineDBList![i]
                                                              .description,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 15,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 50,
                                                  child: Text(
                                                      productlineDBList![i]
                                                          .quantity),
                                                ),
                                                Container(
                                                  width: 100,
                                                  child: Text(
                                                      productlineDBList![i]
                                                          .uomName),
                                                ),
                                                // Container(
                                                //   width: 100,
                                                //   child: Text(
                                                //       productlineDBList![i]
                                                //           .unitPrice),
                                                // ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: productlineDBList![i]
                                                                .isSelect ==
                                                            1
                                                        ? Colors.green
                                                        : Colors.grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  width: 80,
                                                  child: Text(
                                                    productlineDBList![i]
                                                                .isSelect ==
                                                            1
                                                        ? 'Selected'
                                                        : 'Unselect',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    );
                                  }),
                            ),
                          ],
                        );
                      } else {
                        return const Center(
                          child: Text('No Data'),
                        );
                      }
                    },
                  )),
                ],
              );
            }
          },
        ));
  }
}
