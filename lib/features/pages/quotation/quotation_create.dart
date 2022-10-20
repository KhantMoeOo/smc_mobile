import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../dbs/database_helper.dart';
import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../obs/sale_order_line_ob.dart';
import '../../../pages/invoice_page/invoice_line_page/invoice_line_bloc.dart';
import '../../../pages/product_page/product_bloc.dart';
import '../../../pages/profile_page/profile_bloc.dart';
import '../../../pages/quotation_page/quotation_bloc.dart';
import '../../../pages/quotation_page/quotation_create_bloc.dart';
import '../../../pages/quotation_page/quotation_delete_bloc.dart';
import '../../../pages/quotation_page/quotation_edit_bloc.dart';
import '../../../pages/quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import '../../../pages/quotation_page/sale_order_line_page/sale_order_line_multi_create_page.dart';
import '../../../utils/app_const.dart';
import 'quotation_list.dart';

class QuotationCreate extends StatefulWidget {
  int newOrEdit;
  Map<String, dynamic> quotationList;
  QuotationCreate({
    Key? key,
    required this.newOrEdit,
    required this.quotationList,
  }) : super(key: key);

  @override
  State<QuotationCreate> createState() => _QuotationCreateState();
}

class _QuotationCreateState extends State<QuotationCreate> {
  final databaseHelper = DatabaseHelper();
  final saleorderlineBloc = SaleOrderLineBloc();

  final quotationBloc = QuotationBloc();
  final quotationCreateBloc = QuotationCreateBloc();
  final quotationEditBloc = QuotationEditBloc();
  final quotationDeleteBloc = DeleteQuoBloc();
  final invoicelineBloc = InvoiceLineBloc();
  final profileBloc = ProfileBloc();
  final productBloc = ProductBloc();

  List<dynamic> filterbyList = ['No Filter', 'By Segment'];
  List<dynamic> customerList = [];
  List<dynamic> currencyList = [];
  List<dynamic> pricelistList = [];
  List<dynamic> paymentTermsList = [];
  List<dynamic> segmentList = [];
  List<dynamic> regionList = [];
  List<dynamic> zoneList = [];
  List<dynamic> quotationList = [];
  List<dynamic> productlineListWithId = [];
  List<dynamic> saleorderlineIdList = [];

  List<dynamic> filterpricelistList = [];

  int quotationId = 0;

  String customerName = '';
  int customerId = 0;

  String currencyName = '';
  int currencyId = 0;

  String pricelistName = '';
  int pricelistId = 0;

  String paymentTermsName = '';
  int paymentTermsId = 0;

  String zoneListName = '';
  int zoneListId = 0;

  String segmentListName = '';
  int segmentListId = 0;

  String regionListName = '';
  int regionListId = 0;

  int zoneFilterId = 0;
  String zoneFilterName = '';

  int segmentFilterId = 0;
  String segmentFilterName = '';

  List<dynamic> taxeslistUpload = [];

  bool hasNotCustomer = true;
  bool hasNotPriceList = true;
  bool hasNotPaymentTerms = true;
  bool hasNotQuoDate = true;
  bool hasNotZone = true;
  bool hasNotSegment = true;
  bool hasNotRegion = true;
  bool hasNotCurrency = true;
  bool hasNotZoneFilter = true;
  bool hasNotSegmentFilter = true;

  bool hasCustomerData = false;
  bool hasPricelistData = false;
  bool hasPaymentTermsData = false;
  bool hasZoneData = false;
  bool hasSegmentData = false;
  bool hasRegionData = false;
  bool hasCurrencyData = false;

  final exhchangeRateController = TextEditingController();
  final validityDateController = TextEditingController();
  final zoneController = TextEditingController();
  final segmentController = TextEditingController();
  final regionController = TextEditingController();
  final currencyController = TextEditingController();
  final pricelistController = TextEditingController();
  String validityDate = '';
  final dateOrderController = TextEditingController();
  String dateOrder = '';
  final slidableController = SlidableController();

  final _formKey = GlobalKey<FormState>();
  List<SaleOrderLineOb>? productlineList;
  List<SaleOrderLineOb>? productlineListUpdate;
  List<dynamic> productlineListInt = [];
  List<dynamic> saleorderlineDeleteList = [];
  List<dynamic> userList = [];
  List<dynamic> stockwarehouseList = [];

  int newPage = 0;

  bool isFinish = false;

  int counter = 0;

  bool isEnable = false;

  bool isUpdateQuoOrderLine = false;

  bool isCreateQuo = false;
  bool isCreateSOL = false;

  bool isUpdateQuo = false;
  bool isUpdateSOL = false;
  bool isDeleteSOL = false;

  bool zoneFilter = false;
  bool segFilter = false;
  bool hasNotFilter = true;
  String filterName = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transferData();

    debugPrint('New or Edit:' + widget.newOrEdit.toString());
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    print('QuoId:' + widget.quotationList['id'].toString());
    quotationBloc.getCustomerStream().listen(getCustomerList);
    quotationBloc.getCurrencyList();
    quotationBloc.getCurrencyStream().listen(getCurrencyList);
    quotationBloc.getPricelist();
    quotationBloc.getPricelistStream().listen(getPricelist);
    quotationBloc.getPaymentTermsData();
    quotationBloc.getPaymentTermsStream().listen(getPaymentTermslist);
    quotationBloc.getZoneListData();
    quotationBloc.getZoneListStream().listen(getZonelist);
    quotationBloc.getSegmenListData();
    quotationBloc.getSegmentListStream().listen(getSegmentlist);
    quotationBloc.getRegionListData('');
    quotationBloc.getRegionListStream().listen(getRegionlist);
    quotationCreateBloc.getCreateNewStream().listen(createNewQuoRecord);
    quotationEditBloc.getQuotationEditStream().listen(updateExistingQuoRecord);
    quotationDeleteBloc
        .deleteSaleOrderLineStream()
        .listen(listenDeleteSaleOrderLine);
    productBloc.getStockWarehouseStream().listen(getStockWarehouseListen);
    if (widget.newOrEdit == 1) {
      // newPage = -1;
      hasNotQuoDate = false;
      exhchangeRateController.text = widget.quotationList['exchange_rate'];
      validityDateController.text =
          widget.quotationList['validity_date'] == 'false'
              ? ''
              : widget.quotationList['validity_date'];
      validityDate = widget.quotationList['validity_date'];
      dateOrderController.text = widget.quotationList['date_order'];
      dateOrder = widget.quotationList['date_order'];
      filterName = widget.quotationList['customer_filter'];
      widget.quotationList['customer_filter'] == 'zone'
          ? zoneFilter = true
          : widget.quotationList['customer_filter'] == 'segment'
              ? segFilter = true
              : null;
    } else {
      hasNotQuoDate = false;
      dateOrderController.text = DateTime.now().toString().split('.')[0];
    }
    saleorderlineBloc
        .createproductlineListStream()
        .listen(listenCreateSaleOrderLine);

    saleorderlineBloc
        .updateproductlineListStream()
        .listen(listenUpdateSaleOrderLine);

    saleorderlineBloc
        .waitingproductlineListStream()
        .listen(getproductlineListListen);

    saleorderlineBloc
        .getproductlineListStream()
        .listen(getSaleOrderLineWithIDListen);

    quotationEditBloc
        .getUpdateQuotationOrderLineStream()
        .listen(getQuotationOrderLineUpdateListen);
    // quotationBloc.getQuotationWithIdStream().listen(getQuotationListListen);
    // quotationEditBloc.getQuotationEditStream().listen(getQuotationEditListen);
  }

  // void getQuotationEditListen(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     isQuotationEdit = true;
  //     final snackbar = SnackBar(
  //         elevation: 0.0,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //         behavior: SnackBarBehavior.floating,
  //         duration: const Duration(seconds: 1),
  //         backgroundColor: Colors.green,
  //         content:
  //             const Text('Create Successfully!', textAlign: TextAlign.center));
  //     Navigator.of(context).pushAndRemoveUntil(
  //         MaterialPageRoute(builder: (context) {
  //       return QuotationListPage();
  //     }), (route) => false);
  //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
  //   } else if (responseOb.msgState == MsgState.error) {
  //     print('Error Update Quotation');
  //   }
  // } // Get Quotation Edit List Listen

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //   print('DIDchange');
  //   // quotationBloc.getCustomerList();
  //   // quotationBloc.getCustomerStream().listen(getCustomerList);
  // }
  void getQuotationOrderLineUpdateListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          content:
              const Text('Create Successfully!', textAlign: TextAlign.center));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return QuotationList();
      }), (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      if (userList.isNotEmpty) {
        productBloc.getStockWarehouseData(zoneId: userList[0]['zone_id'][0]);
        quotationBloc.getCustomerList(
          ['name', 'ilike', ''],
          ['zone_id.id', '=', userList[0]['zone_id'][0]],
        );
      }
    }
  }

  void getStockWarehouseListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockwarehouseList = responseOb.data;
    }
  }

  void getSaleOrderLineWithIDListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productlineListWithId = responseOb.data;
      for (var sol in productlineListWithId) {
        saleorderlineIdList.add(sol['id']);
      }
      print('saleorderlineIdList: $saleorderlineIdList');
      if (productlineListWithId.isNotEmpty) {
        setState(() {
          isUpdateQuoOrderLine = true;
          print('QuotationID: $quotationId');
        });
        quotationEditBloc.updateQuotationOrderLineData(
            ids: quotationId, orderline: saleorderlineIdList);
      }
    }
  }

  void getproductlineListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      print('QuotationID: $quotationId');
      saleorderlineBloc.getSaleOrderLineData(quotationId);
      if (widget.newOrEdit == 1) {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
            content: const Text('Create Successfully!',
                textAlign: TextAlign.center));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return QuotationList();
        }), (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }
  }

  void getFilterName(String? v) {
    if (v != null) {
      hasNotFilter = false;
      setState(() {
        if (v == 'By Segment') {
          filterName = 'segment';
          customerId = 0;
          customerName = '';
          hasNotCustomer = true;
          segFilter = true;
        } else {
          filterName = '';
          quotationBloc.getCustomerList(['name', 'ilike', ''],
              ['zone_id.id', '=', userList[0]['zone_id'][0]]);
          customerId = 0;
          customerName = '';
          zoneFilter = false;
          segFilter = false;
        }
      });
    }
  }

  void setZoneFilterNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.quotationList['zone_filter_id'] != 0) {
        for (var element in zoneList) {
          if (element['id'] == widget.quotationList['zone_filter_id']) {
            hasNotZoneFilter = false;
            zoneFilterId = element['id'];
            zoneFilterName = element['name'];
            print('zoneFilterId: ' + zoneFilterId.toString());
            print('zoneFilterName:' + zoneFilterName);
          }
        }
      }
    }
  }

  void setSegmentFilterNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.quotationList['seg_filter_id'] != 0) {
        for (var element in segmentList) {
          if (element['id'] == widget.quotationList['seg_filter_id']) {
            hasNotSegmentFilter = false;
            segmentFilterId = element['id'];
            segmentFilterName = element['name'];
            print('segmentFilterId: ' + segmentFilterId.toString());
            print('segmentFilterName:' + segmentFilterName);
          }
        }
      }
    }
  }

  void getSegmentFilterId(String? v) {
    if (v != null) {
      setState(() {
        segmentFilterId = int.parse(v.toString().split(',')[0]);
        hasNotSegmentFilter = false;
        hasCurrencyData = false;
        for (var element in segmentList) {
          if (element['id'] == segmentFilterId) {
            segmentFilterName = element['name'];
            segmentFilterId = element['id'];
            print('segmentFilterName:$segmentFilterName');
            print('segmentFilterId:$segmentFilterId');
            // customerList = customerList.where((customer) =>
            //   customer['zone_id'][0] == element['id']).toList();
            quotationBloc.getCustomerList(
                ['segment_id.id', '=', segmentFilterId],
                ['zone_id.id', '=', userList[0]['zone_id'][0]]);
            // for(var filterCustomer in customerList){
            //   if(filterCustomer['zone_id'][0] == element['id']){
            //     customerFilterList.add(filterCustomer);
            //   }
            // }

          }
        }
      });
    } else {
      setState(() {
        hasNotZoneFilter = true;
      });
    }
  }

  void getCustomerId(String? v) {
    if (v != null) {
      setState(() {
        customerId = int.parse(v.toString().split(',')[0]);
        hasNotCustomer = false;
        for (var element in customerList) {
          if (element['id'] == customerId) {
            if (element['code'] != false) {
              customerName = '${element['code']} ${element['name']}';
            } else {
              customerName = element['name'];
            }
            customerId = element['id'];
            print('CustomerName:$customerName');
            print('CustomerId:$customerId');
            print('Partner City: ${element['partner_city']}');
            for (var paymentterm in paymentTermsList) {
              if (element['property_payment_term_id'] != false) {
                if (paymentterm['id'] ==
                    element['property_payment_term_id'][0]) {
                  hasNotPaymentTerms = false;
                  paymentTermsId = paymentterm['id'];
                  paymentTermsName = paymentterm['name'];
                  print('PaymentTermId: $paymentTermsId');
                  print('PaymentTermName: $paymentTermsName');
                }
              }
            }
            for (var pricelist in pricelistList) {
              if (element['property_product_pricelist'] != false) {
                if (pricelist['id'] ==
                    element['property_product_pricelist'][0]) {
                  hasNotPriceList = false;
                  pricelistId = pricelist['id'];
                  pricelistName =
                      '${pricelist['name']} (${pricelist['currency_id'][1]})';
                  hasNotCurrency = false;
                  currencyId = pricelist['currency_id'][0];
                  currencyName = pricelist['currency_id'][1];
                  print('pricelistName: $pricelistName');
                }
              }
            }
            for (var segment in segmentList) {
              if (element['segment_id'] != false) {
                if (segment['id'] == element['segment_id'][0]) {
                  hasNotSegment = false;
                  segmentListId = segment['id'];
                  segmentListName = segment['name'];
                  segmentController.text = segment['name'];
                  print('SegmentPartner: $segmentListName');
                }
              }
            }
            for (var zone in zoneList) {
              if (element['zone_id'] != false) {
                if (zone['id'] == element['zone_id'][0]) {
                  hasNotZone = false;
                  zoneListId = zone['id'];
                  zoneListName = zone['name'];
                  zoneController.text = zone['name'];
                  print('ZonePartner: $zoneListName');
                }
              }
            }
            for (var region in regionList) {
              if (element['partner_city'] != false) {
                if (region['id'] == element['partner_city'][0]) {
                  hasNotRegion = false;
                  regionListId = region['id'];
                  regionListName = region['name'];
                  regionController.text = region['name'];
                  print('RegionPartner: $regionListName');
                }
              }
            }
          }
        }
      });
    } else {
      setState(() {
        hasNotCustomer = true;
      });
    }
  } // get CustomerId from CustomerSelection

  void getCustomerList(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      customerList = responseOb.data;
      hasCustomerData = true;
      setCustomerNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoCustomerList");
    }
  } // listen to get Customer List

  void getCurrencyList(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      currencyList = responseOb.data;
      hasCurrencyData = true;
      setCurrencyNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoCurrencyList");
    }
  } // listen to get Currency List

  void getPricelist(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      pricelistList = responseOb.data;
      hasPricelistData = true;
      filterPricelistList();
      setPriceListNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoPriceList");
    }
  } // listen to get Pricelist List

  void filterPricelistList() {
    for (var element in pricelistList) {
      if (element['company_id'] == false ||
          element['company_id'] == element['company_id']) {
        filterpricelistList.add(element);
      }
    }
  } // filter priclistlist

  void getPaymentTermslist(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      paymentTermsList = responseOb.data;
      hasPaymentTermsData = true;
      setPaymentTermListNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoPaymentTermsList");
    }
  } // listen to get PaymentTerms List

  void getZonelist(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      zoneList = responseOb.data;
      hasZoneData = true;
      setZoneListNameMethod();
      setZoneFilterNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoZoneList");
    }
  } // listen to get Zone List

  void getSegmentlist(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      segmentList = responseOb.data;
      hasSegmentData = true;
      setSegmnetNameMethod();
      setSegmentFilterNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoSegmentList");
    }
  } // listen to get Segment List

  void getRegionlist(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      regionList = responseOb.data;
      hasRegionData = true;
      setRegionNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoRegionList");
    }
  } // listen to get Segment List

  void setCustomerNameMethod() {
    print('set work');
    setState(() {
      if (widget.newOrEdit == 1) {
        print('its 1');
        for (var element in customerList) {
          if (element['id'] == widget.quotationList['partner_id'][0]) {
            hasNotCustomer = false;
            customerId = element['id'];
            if (element['code'] != false) {
              customerName = '${element['code']} ${element['name']}';
            } else {
              customerName = element['name'];
            }
            print('CustomerId: ' + element['id'].toString());
            print('SetCustomerName:' + customerName);
          }
        }
      }
    });
  } // Set Customer Name to Update Quotation Page

  void getCurrencyId(String? v) {
    if (v != null) {
      setState(() {
        currencyId = int.parse(v.toString().split(',')[0]);
        hasNotCurrency = false;
        for (var element in currencyList) {
          if (element['id'] == currencyId) {
            currencyName = element['name'];
            currencyId = element['id'];
            print('CurrencyName:$currencyName');
            print('CurrencyId:$currencyId');
          }
        }
      });
    } else {
      hasNotCurrency = true;
    }
  } // get CurrencyId from CurrencySelection

  void setCurrencyNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.quotationList['currency_id'].isNotEmpty) {
        for (var element in currencyList) {
          if (element['id'] == widget.quotationList['currency_id'][0]) {
            hasNotCurrency = false;
            currencyId = element['id'];
            currencyName = element['name'];
            print('CurrencyListId: ' + currencyId.toString());
            print('SetCurrencyName:' + currencyName);
          }
        }
      }
    }
  } // Set Currency Name to Update Quotation Page

  void getPricelistId(String? v) {
    if (v != null) {
      setState(() {
        pricelistId = int.parse(v.toString().split(',')[0]);
        hasNotPriceList = false;
        for (var element in pricelistList) {
          if (element['id'] == pricelistId) {
            pricelistName = '${element['name']} (${element['currency_id'][1]})';
            pricelistId = element['id'];
            currencyId = element['currency_id'][0];
            currencyName = element['currency_id'][1];
            print('PricelistName:$pricelistName');
            print('PricelistId:$pricelistId');
          }
        }
      });
    } else {
      setState(() {
        hasNotPriceList = true;
      });
    }
  } // get PricelistId from PricelistSelection

  void setPriceListNameMethod() {
    if (widget.newOrEdit == 1) {
      for (var element in pricelistList) {
        if (element['id'] == widget.quotationList['pricelist_id'][0]) {
          hasNotPriceList = false;
          pricelistId = element['id'];
          pricelistName = element['name'];
          print('PriceListId: ' + pricelistId.toString());
          print('SetPriceListName:' + pricelistName);
        }
      }
    }
  } // Set PriceList Name to Update Quotation Page

  void getPaymentTermsId(String? v) {
    if (v != null) {
      setState(() {
        paymentTermsId = int.parse(v.toString().split(',')[0]);
        hasNotPaymentTerms = false;
        for (var element in paymentTermsList) {
          if (element['id'] == paymentTermsId) {
            paymentTermsName = element['name'];
            paymentTermsId = element['id'];
            print('PaymentTermsName:$paymentTermsName');
            print('PaymentTermsId:$paymentTermsId');
          }
        }
      });
    } else {
      setState(() {
        hasNotPaymentTerms = true;
      });
    }
  } // get PaymentTermsId from PaymentTermsSelection

  void setPaymentTermListNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.quotationList['payment_term_id'].isNotEmpty) {
        for (var element in paymentTermsList) {
          if (element['id'] == widget.quotationList['payment_term_id'][0]) {
            hasNotPaymentTerms = false;
            paymentTermsId = element['id'];
            paymentTermsName = element['name'];
            print('PaymentTermListId: ' + paymentTermsId.toString());
            print('SetPaymentTermListName:' + paymentTermsName);
          }
        }
      }
    }
  } // Set PaymentTerm Name to Update Quotation Page

  void getZoneListId(String? v) {
    if (v != null) {
      setState(() {
        zoneListId = int.parse(v.toString().split(',')[0]);
        hasNotZone = false;
        for (var element in zoneList) {
          if (element['id'] == zoneListId) {
            zoneListName = element['name'];
            zoneListId = element['id'];
            print('ZoneListName:$zoneListName');
            print('ZoneListId:$zoneListId');
          }
        }
      });
    } else {
      hasNotZone = true;
    }
  } // get ZoneListId from ZoneListSelection

  void setZoneListNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.quotationList['zone_id'].isNotEmpty) {
        for (var element in zoneList) {
          if (element['id'] == widget.quotationList['zone_id'][0]) {
            hasNotZone = false;
            zoneListId = element['id'];
            zoneListName = element['name'];
            zoneController.text = element['name'];
            print('ZoneListId: ' + zoneListId.toString());
            print('SetZoneName:' + zoneListName);
          }
        }
      }
    }
  } // Set ZoneList Name to Update Quotation Page

  void getSegmentListId(String? v) {
    if (v != null) {
      setState(() {
        segmentListId = int.parse(v.toString().split(',')[0]);
        hasNotSegment = false;
        for (var element in segmentList) {
          if (element['id'] == segmentListId) {
            segmentListName = element['name'];
            segmentListId = element['id'];
            print('SegmentListName:$segmentListName');
            print('SegmentListId:$segmentListId');
          }
        }
      });
    } else {
      hasNotSegment = true;
    }
  } // get SegmentListId from SegmentListSelection

  void setSegmnetNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.quotationList['segment_id'].isNotEmpty) {
        for (var element in segmentList) {
          if (element['id'] == widget.quotationList['segment_id'][0]) {
            hasNotSegment = false;
            segmentListId = element['id'];
            segmentListName = element['name'];
            segmentController.text = element['name'];
            print('SegmentListId: ' + segmentListId.toString());
            print('SetSegmentName:' + segmentListName);
          }
        }
      }
    }
  } // Set Segment Name to Update Quotation Page

  void getRegionListId(String? v) {
    if (v != null) {
      setState(() {
        regionListId = int.parse(v.toString().split(',')[0]);
        hasNotRegion = false;
        for (var element in regionList) {
          if (element['id'] == regionListId) {
            regionListName = element['name'];
            regionListId = element['id'];
            print('RegionListName:$regionListName');
            print('RegionListId:$regionListId');
          }
        }
      });
    } else {
      hasNotRegion = true;
    }
  } // get RegionListId from RegionListSelection

  void setRegionNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.quotationList['region_id'].isNotEmpty) {
        for (var element in regionList) {
          if (element['id'] == widget.quotationList['region_id'][0]) {
            hasNotRegion = false;
            regionListId = element['id'];
            regionListName = element['name'];
            regionController.text = element['name'];
            print('RegionListId: ' + regionListId.toString());
            print('SetRegionName:' + regionListName);
          }
        }
      }
    }
  } // Set Region Name to Update Quotation Page

  void createNewQuoRecord(ResponseOb responseOb) async {
    if (customerName.isNotEmpty ||
        dateOrder.isNotEmpty ||
        pricelistName.isNotEmpty) {
      if (responseOb.msgState == MsgState.data) {
        quotationId = responseOb.data;
        print('Responeobdata: $quotationId');
        for (var element in productlineList!) {
          setState(() {
            isCreateSOL = true;
            print('isCreateSOL: $isCreateSOL');
          });
          if (element.quotationId == 0) {
            // await databaseHelper.updateSaleOrderLineOrderId(
            //     element.id, quotationId);
            await saleorderlineBloc.saleOrderLineCreate(
                orderId: quotationId,
                currencyId: currencyId,
                dateorder: dateOrderController.text,
                productId: element.productCodeId,
                productName: element.description,
                productUOMQty: element.quantity,
                uomId: element.uomId,
                priceUnit: element.unitPrice,
                taxesId: json.decode(element.taxId),
                subtotal: element.subTotal);
            print('DbId: ${element.id}');
          }
        }
        if (productlineList!.isEmpty) {
          final snackbar = SnackBar(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
              content: const Text('Create Quo Successfully!',
                  textAlign: TextAlign.center));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return QuotationList();
          }), (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
        print('Create New Quo Record Successfully!');
        // await databaseHelper.deleteAllHrEmployeeLine();
        // await databaseHelper.deleteAllHrEmployeeLineUpdate();
        // await databaseHelper.deleteAllSaleOrderLine();
        // await databaseHelper.deleteAllSaleOrderLineUpdate();
        // await databaseHelper.deleteAllTripPlanDelivery();
        // await databaseHelper.deleteAllTripPlanDeliveryUpdate();
        // await databaseHelper.deleteAllTripPlanSchedule();
        // await databaseHelper.deleteAllTripPlanScheduleUpdate();
        // await SharefCount.clearCount();
      } else if (responseOb.msgState == MsgState.error) {
        setState(() {
          isUpdateQuo = false;
          print('isUpdateQuo: $isUpdateQuo');
        });
        print('Create New Quo Record Error!');
      }
    }
  } // Record Creating Successful or not

  void listenCreateSaleOrderLine(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      print("SOLLEngth: ${productlineList!.length}");
      SharefCount.setTotal(productlineList!.length);
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Create SOL Sccess');
    } else {
      setState(() {
        isCreateSOL = false;
        print('isCreateSOL: $isCreateSOL');
      });
      print("Create SOL fail");
    }
  }

  void listenUpdateSaleOrderLine(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      print("SOlupdatelength: ${productlineList!.length}");
      SharefCount.setTotal(productlineList!.length);
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Update SOL Sccess');
    } else {
      setState(() {
        isUpdateSOL = false;
        print('isUpdateSOL: $isUpdateSOL');
      });
      print("Update SOL fail");
    }
  }

  void listenDeleteSaleOrderLine(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      print('Delete SOL Successfully');
    } else if (responseOb.msgState == MsgState.error) {
      // setState(() {
      //   isDeleteSOL = false;
      //   print('isDeleteSOL: $isDeleteSOL');
      // });
      print('Delete SOL Fail');
    }
  }

  Future<void> transferData() async {
    productlineListUpdate = await databaseHelper.getSaleOrderLineUpdateList();
    for (var element in productlineListUpdate!) {
      productlineListInt.add(element.id);
    }
    if (widget.newOrEdit == 1) {
      print('TransferData');
      print('QuotationId: ${widget.quotationList['id']}');
      productlineList = await databaseHelper.insertTable2Table();
      print('SOLListLength: ${productlineList?.length}');
    }
    setState(() {});
  }

  void updateExistingQuoRecord(ResponseOb responseOb) async {
    if (customerName.isNotEmpty ||
        dateOrder.isNotEmpty ||
        pricelistName.isNotEmpty) {
      print('SOLLength: ${productlineList!.length}');
      if (responseOb.msgState == MsgState.data) {
        if (saleorderlineDeleteList.isNotEmpty) {
          for (var element in saleorderlineDeleteList) {
            bool deleteFound = productlineListInt.contains(element);
            if (deleteFound) {
              setState(() {
                isDeleteSOL = true;
                print('isDeleteSOL: $isDeleteSOL');
              });
              for (var element in saleorderlineDeleteList) {
                await quotationDeleteBloc.deleteSaleOrderLineData(element);
              }
            }
          }
        }
        for (var element in productlineList!) {
          print('workdeeee: ${element.id}');
          bool found = productlineListInt.contains(element.id);
          if (found) {
            setState(() {
              isUpdateSOL = true;
              print('isUpdateSOL: $isUpdateSOL');
            });
            await saleorderlineBloc.editSaleOrderLineData(
                ids: element.id,
                orderId: element.quotationId,
                productId: element.productCodeId,
                productName: element.description,
                productUOMQty: double.parse(element.quantity),
                uomId: element.uomId,
                priceUnit: double.parse(element.unitPrice),
                taxesId: json.decode(element.taxId),
                subtotal: element.subTotal);
            print('Found');
            print('FOund: ${element.id}');
          } else {
            setState(() {
              isCreateSOL = true;
              print('isCreateSOL: $isCreateSOL');
            });
            await saleorderlineBloc.saleOrderLineCreate(
                orderId: widget.quotationList['id'],
                currencyId: currencyId,
                dateorder: dateOrderController.text,
                productId: element.productCodeId,
                productName: element.description,
                productUOMQty: element.quantity,
                uomId: element.uomId,
                priceUnit: element.unitPrice,
                taxesId: json.decode(element.taxId),
                subtotal: element.subTotal);
            print('DbId: ${element.id}');
            print('NotFound');
            print('NotFOund: ${element.id}');
          }
        }

        if (productlineList!.isEmpty) {
          final snackbar = SnackBar(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.green,
              content: const Text('Create Quo Successfully!',
                  textAlign: TextAlign.center));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return QuotationList();
          }), (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
        // await databaseHelper.deleteAllHrEmployeeLine();
        // await databaseHelper.deleteAllHrEmployeeLineUpdate();
        // await databaseHelper.deleteAllSaleOrderLine();
        // await databaseHelper.deleteAllSaleOrderLineUpdate();
        // await databaseHelper.deleteAllTripPlanDelivery();
        // await databaseHelper.deleteAllTripPlanDeliveryUpdate();
        // await databaseHelper.deleteAllTripPlanSchedule();
        // await databaseHelper.deleteAllTripPlanScheduleUpdate();
        // await SharefCount.clearCount();
      } else if (responseOb.msgState == MsgState.error) {
        setState(() {
          isUpdateQuo = false;
          print('isUpdateQuo: $isUpdateQuo');
        });
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
            content:
                const Text('Updating Failed!', textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }
  } // Record Updating Successful or not

  createNewRecord() async {
    SharefCount.setTotal(productlineList!.length);
    bool isValid = _formKey.currentState!.validate();
    if (stockwarehouseList.isEmpty || stockwarehouseList.length > 1) {
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
          content: const Text('Please fill Warehouse name first!',
              textAlign: TextAlign.center));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } else {
      if (isValid) {
        setState(() {
          isCreateQuo = true;
          print('Iscreatequo: $isCreateQuo');
        });
        await quotationCreateBloc.quotationCreate(
            warehouseId: stockwarehouseList[0]['id'],
            customerId: customerId,
            currencyId: 119,
            exchangeRate: '1',
            dateOrder: dateOrderController.text,
            priceListId: 2,
            paymentTermId: paymentTermsId,
            zoneId: zoneListId,
            segmentId: segmentListId,
            regionId: regionListId,
            customFilter: filterName,
            zoneFilter: zoneFilterId,
            segFilter: segmentFilterId);
      } else {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
            content: const Text('Please fill first required fields!',
                textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }
  }

  updateExistingRecord() {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        isUpdateQuo = true;
        print('isUpdateQuo: $isUpdateQuo');
      });
      quotationEditBloc.editQuotationData(
          ids: widget.quotationList['id'],
          partnerId: customerId,
          dateOrder: dateOrder,
          currencyId: 119,
          exchangeRate: exhchangeRateController.text == ''
              ? null
              : exhchangeRateController.text,
          priceListId: 2,
          paymentTermId: paymentTermsId == 0 ? null : paymentTermsId,
          zoneId: zoneListId == 0 ? null : zoneListId,
          segmentId: segmentListId == 0 ? null : segmentListId,
          regionId: regionListId == 0 ? null : regionListId);
    } else {
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
          content: const Text('Please fill first required fields!',
              textAlign: TextAlign.center));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print('Dispose');
    quotationBloc.dipose();
    quotationCreateBloc.dispose();
    quotationEditBloc.dispose();
    exhchangeRateController.dispose();
    validityDateController.dispose();
    dateOrderController.dispose();
    saleorderlineBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await databaseHelper.deleteAllSaleOrderLine();
        await SharefCount.clearCount();
        Navigator.of(context).pop();
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 12, 41, 92),
              elevation: 0.0,
              title: const Text('New'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Discard',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                    onPressed: widget.newOrEdit == 1
                        ? updateExistingRecord
                        : createNewRecord,
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
            body: FutureBuilder<List<SaleOrderLineOb>>(
                future: databaseHelper.getproductlineList(),
                builder: (context, snapshot) {
                  productlineList = snapshot.data;
                  Widget saleOrderLineWidget = SliverToBoxAdapter(
                    child: Container(),
                  );
                  if (snapshot.hasData) {
                    saleOrderLineWidget = SliverList(
                        delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        print(
                            'SOLLength------------: ${productlineList?.length}');
                        print(
                            'SOLlist fromm DB: discountname: ${productlineList![i].discountName} delivered: ${productlineList![i].qtyDelivered} invoiced: ${productlineList![i].qtyInvoiced} salediscount ${productlineList![i].saleDiscount} discount: ${productlineList![i].discountName}');
                        return productlineList![i].isSelect != 1
                            ? Container()
                            : Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    color: Colors.white,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 130,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '[${productlineList![i].productCodeName}] ${productlineList![i].description}',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15))
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    productlineList![i]
                                                        .quantity,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15))
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                // Text(
                                                //     productlineList![i]
                                                //         .qtyDelivered!,
                                                //     style: const TextStyle(
                                                //         color: Colors.black,
                                                //         fontSize: 15))
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                // Text(
                                                //     productlineList![i]
                                                //         .qtyInvoiced!,
                                                //     style: const TextStyle(
                                                //         color: Colors.black,
                                                //         fontSize: 15))
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    productlineList![i].uomName,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15))
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Container(
                                          width: 100,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    productlineList![i]
                                                        .unitPrice,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15))
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                // Text(
                                                //     productlineList![i]
                                                //                 .saleDiscount ==
                                                //             ''
                                                //         ? ''
                                                //         : productlineList![i]
                                                //             .saleDiscount!,
                                                //     style: const TextStyle(
                                                //         color: Colors.black,
                                                //         fontSize: 15))
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                // Text(
                                                //     productlineList![i]
                                                //                 .discountName ==
                                                //             ''
                                                //         ? ''
                                                //         : productlineList![i]
                                                //             .discountName!,
                                                //     style: const TextStyle(
                                                //         color: Colors.black,
                                                //         fontSize: 15))
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    productlineList![i].taxName,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15))
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                          width: 50,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                productlineList![i].isFOC! == 0
                                                    ? const Icon(Icons
                                                        .check_box_outline_blank)
                                                    : const Icon(
                                                        Icons.check_box),
                                              ]),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                    productlineList![i]
                                                        .subTotal,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15))
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              );
                      },
                      childCount: productlineList!.length,
                    ));
                  } else {
                    saleOrderLineWidget = SliverToBoxAdapter(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              slivers: [
                                SliverPadding(
                                    padding: const EdgeInsets.all(8),
                                    sliver: SliverList(
                                        delegate: SliverChildListDelegate([
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        color: Colors.white,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Row(
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Filter By: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          height: 40,
                                                          color: Colors.white,
                                                          child: DropdownSearch<
                                                              String>(
                                                            popupItemBuilder:
                                                                (context, item,
                                                                    isSelected) {
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(item
                                                                        .toString()),
                                                                    const Divider(),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                            showSearchBox:
                                                                false,
                                                            showSelectedItems:
                                                                true,
                                                            items: filterbyList
                                                                .map((e) => e
                                                                    .toString())
                                                                .toList(),
                                                            onChanged:
                                                                getFilterName,
                                                            selectedItem:
                                                                filterName ==
                                                                        'segment'
                                                                    ? 'By Segment'
                                                                    : '',
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(" - "),
                                                      Visibility(
                                                        visible: segFilter,
                                                        child: Expanded(
                                                          child: Container(
                                                            color: Colors.white,
                                                            height: 40,
                                                            child: StreamBuilder<
                                                                    ResponseOb>(
                                                                initialData: hasSegmentData ==
                                                                        false
                                                                    ? ResponseOb(
                                                                        msgState:
                                                                            MsgState
                                                                                .loading)
                                                                    : null,
                                                                stream: quotationBloc
                                                                    .getSegmentListStream(),
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
                                                                      popupItemBuilder: (context,
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
                                                                      showSearchBox:
                                                                          false,
                                                                      showSelectedItems:
                                                                          true,
                                                                      showClearButton:
                                                                          !hasNotSegmentFilter,
                                                                      items: segmentList
                                                                          .map((e) =>
                                                                              '${e['id']},${e['name']}')
                                                                          .toList(),
                                                                      onChanged:
                                                                          getSegmentFilterId,
                                                                      selectedItem:
                                                                          segmentFilterName,
                                                                    );
                                                                  }
                                                                }),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                const Expanded(
                                                  child: Text(
                                                    'Quotation: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                      color: Colors.white,
                                                      height: 40,
                                                      child: TextFormField(
                                                          readOnly: true,
                                                          autovalidateMode:
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          validator: (value) {
                                                            if (value == null ||
                                                                value.isEmpty) {
                                                              return 'Please select Quotation Date';
                                                            }
                                                            return null;
                                                          },
                                                          controller:
                                                              dateOrderController,
                                                          decoration:
                                                              InputDecoration(
                                                                  border:
                                                                      const OutlineInputBorder(),
                                                                  suffixIcon:
                                                                      IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .arrow_drop_down),
                                                                    onPressed:
                                                                        () async {
                                                                      final DateTime? selected = await showDatePicker(
                                                                          context:
                                                                              context,
                                                                          initialDate: DateTime
                                                                              .now(),
                                                                          firstDate: DateTime
                                                                              .now(),
                                                                          lastDate:
                                                                              DateTime(2023));

                                                                      if (selected !=
                                                                          null) {
                                                                        setState(
                                                                            () {
                                                                          dateOrder =
                                                                              '${selected.toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].split('.')[0]}';
                                                                          dateOrderController.text =
                                                                              '${selected.toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].split('.')[0]}';
                                                                          hasNotQuoDate =
                                                                              false;
                                                                          print(
                                                                              dateOrder);
                                                                        });
                                                                      }
                                                                    },
                                                                  )))),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Customer: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    color: Colors.white,
                                                    height: 40,
                                                    child: StreamBuilder<
                                                            ResponseOb>(
                                                        initialData:
                                                            hasCustomerData ==
                                                                    false
                                                                ? ResponseOb(
                                                                    msgState:
                                                                        MsgState
                                                                            .loading)
                                                                : null,
                                                        stream: quotationBloc
                                                            .getCustomerStream(),
                                                        builder: (context,
                                                            AsyncSnapshot<
                                                                    ResponseOb>
                                                                snapshot) {
                                                          ResponseOb?
                                                              responseOb =
                                                              snapshot.data;
                                                          if (responseOb
                                                                  ?.msgState ==
                                                              MsgState
                                                                  .loading) {
                                                            return Center(
                                                              child:
                                                                  Image.asset(
                                                                'assets/gifs/loading.gif',
                                                                width: 100,
                                                                height: 100,
                                                              ),
                                                            );
                                                          } else if (responseOb
                                                                  ?.msgState ==
                                                              MsgState.error) {
                                                            return const Center(
                                                              child: Text(
                                                                  "Something went Wrong!"),
                                                            );
                                                          } else {
                                                            return DropdownSearch<
                                                                String>(
                                                              popupItemBuilder:
                                                                  (context,
                                                                      item,
                                                                      isSelected) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(item
                                                                          .toString()
                                                                          .split(
                                                                              ',')[1]),
                                                                      const Divider(),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                              autoValidateMode:
                                                                  AutovalidateMode
                                                                      .onUserInteraction,
                                                              validator:
                                                                  (value) {
                                                                if (value ==
                                                                        null ||
                                                                    value
                                                                        .isEmpty) {
                                                                  return 'Please select Customer Name';
                                                                }
                                                                return null;
                                                              },
                                                              showSearchBox:
                                                                  true,
                                                              showSelectedItems:
                                                                  true,
                                                              showClearButton:
                                                                  !hasNotCustomer,
                                                              items:
                                                                  customerList
                                                                      .map((e) {
                                                                return e['code'] !=
                                                                        false
                                                                    ? '${e['id']},${e['code']} ${e['name']}'
                                                                    : '${e['id']},${e['name']}';
                                                              }).toList(),
                                                              onChanged:
                                                                  getCustomerId,
                                                              selectedItem:
                                                                  customerName,
                                                            );
                                                          }
                                                        }),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                const Expanded(
                                                  child: Text(
                                                    'Payment Terms: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    color: Colors.white,
                                                    height: 40,
                                                    child: StreamBuilder<
                                                            ResponseOb>(
                                                        initialData:
                                                            hasPaymentTermsData ==
                                                                    false
                                                                ? ResponseOb(
                                                                    msgState:
                                                                        MsgState
                                                                            .loading)
                                                                : null,
                                                        stream: quotationBloc
                                                            .getPaymentTermsStream(),
                                                        builder: (context,
                                                            AsyncSnapshot<
                                                                    ResponseOb>
                                                                snapshot) {
                                                          ResponseOb?
                                                              responseOb =
                                                              snapshot.data;
                                                          if (responseOb
                                                                  ?.msgState ==
                                                              MsgState
                                                                  .loading) {
                                                            return Center(
                                                              child:
                                                                  Image.asset(
                                                                'assets/gifs/loading.gif',
                                                                width: 100,
                                                                height: 100,
                                                              ),
                                                            );
                                                          } else if (responseOb
                                                                  ?.msgState ==
                                                              MsgState.error) {
                                                            return const Center(
                                                              child: Text(
                                                                  "Something went Wrong!"),
                                                            );
                                                          } else {
                                                            return DropdownSearch<
                                                                String>(
                                                              popupItemBuilder:
                                                                  (context,
                                                                      item,
                                                                      isSelected) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(item
                                                                          .toString()
                                                                          .split(
                                                                              ',')[1]),
                                                                      const Divider(),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                              showSearchBox:
                                                                  true,
                                                              showSelectedItems:
                                                                  true,
                                                              showClearButton:
                                                                  !hasNotPaymentTerms,
                                                              items: paymentTermsList
                                                                  .map((e) =>
                                                                      '${e['id']},${e['name']}')
                                                                  .toList(),
                                                              onChanged:
                                                                  getPaymentTermsId,
                                                              selectedItem:
                                                                  paymentTermsName,
                                                            );
                                                          }
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Currency: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: const [
                                                        Text('MMK',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18))
                                                      ]),
                                                )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                const Expanded(
                                                  child: Text(
                                                    'Zone: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(zoneListName,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18))
                                                      ]),
                                                )),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Exchange Rate: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: const [
                                                        Text('1.0',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18))
                                                      ]),
                                                )),
                                                const SizedBox(width: 10),
                                                const Expanded(
                                                  child: Text(
                                                    'Segment: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(segmentListName,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18))
                                                      ]),
                                                )),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Pricelist: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: const [
                                                        Text(
                                                            'Publice Pricelist (MMK)',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18))
                                                      ]),
                                                )),
                                                const SizedBox(width: 10),
                                                const Expanded(
                                                  child: Text(
                                                    'Region: ',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(regionListName,
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 18))
                                                      ]),
                                                )),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                const Expanded(
                                                  child: Text(
                                                    'Warehouse',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                StreamBuilder<ResponseOb>(
                                                    initialData:
                                                        stockwarehouseList
                                                                .isNotEmpty
                                                            ? null
                                                            : ResponseOb(
                                                                msgState: MsgState
                                                                    .loading),
                                                    stream: productBloc
                                                        .getStockWarehouseStream(),
                                                    builder:
                                                        (context, snapshot) {
                                                      ResponseOb? responseOb =
                                                          snapshot.data;
                                                      if (responseOb
                                                              ?.msgState ==
                                                          MsgState.error) {
                                                        return const Center(
                                                            child:
                                                                Text('Error'));
                                                      } else if (responseOb
                                                              ?.msgState ==
                                                          MsgState.loading) {
                                                        return Expanded(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            color: Colors.white,
                                                            child: Center(
                                                              child:
                                                                  Image.asset(
                                                                'assets/gifs/loading.gif',
                                                                width: 100,
                                                                height: 100,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        return Expanded(
                                                            child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            color: Colors.white,
                                                          ),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    '${stockwarehouseList.isNotEmpty ? stockwarehouseList[0]['name'] : ''}',
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18))
                                                              ]),
                                                        ));
                                                      }
                                                    }),
                                                const Expanded(
                                                    child: SizedBox()),
                                                const Expanded(
                                                    child: SizedBox()),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ]))),
                                SliverPadding(
                                  padding: const EdgeInsets.all(8),
                                  sliver: SliverToBoxAdapter(
                                      child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    height: 50,
                                    width: 20,
                                    color: Colors.white,
                                    child: const Text(
                                      "Order Line",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                  )),
                                ),
                                SliverPadding(
                                    padding: const EdgeInsets.all(8),
                                    sliver: SliverToBoxAdapter(
                                      child: Container(
                                        color: Colors.white,
                                        padding: const EdgeInsets.only(
                                            top: 5,
                                            bottom: 5,
                                            left: 8,
                                            right: 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: const [
                                            SizedBox(
                                                width: 130,
                                                child: Text('Product',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                                width: 80,
                                                child: Text('Quantity',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                                width: 80,
                                                child: Text('Delivered',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                                width: 80,
                                                child: Text('Invoiced',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                                width: 80,
                                                child: Text('UoM',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                                width: 100,
                                                child: Text('Unit Price',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                                width: 80,
                                                child: Text('Sale Discount',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                                width: 100,
                                                child: Text('Discount',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                                width: 80,
                                                child: Text('Taxes',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            SizedBox(
                                                width: 50,
                                                child: Text('IsFOC',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                            SizedBox(
                                              width: 2,
                                            ),
                                            Expanded(
                                                child: Text('Subtotal',
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold))),
                                          ],
                                        ),
                                      ),
                                    )),
                                SliverPadding(
                                  padding: const EdgeInsets.only(left: 8),
                                  sliver: SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TextButton(
                                            style: TextButton.styleFrom(
                                              // maximumSize: Size(40, 20),
                                              backgroundColor:
                                                  AppColors.appBarColor,
                                            ),
                                            onPressed: customerId == 0
                                                ? null
                                                : () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return SaleOrderLineMultiCreatePage(
                                                        newOrEditSOL: 0,
                                                        newOrEdit:
                                                            widget.newOrEdit,
                                                        quotationId: widget
                                                                .quotationList[
                                                            'id'],
                                                        solId: 0,
                                                        partnerId: customerId,
                                                        zoneId: zoneListId,
                                                        segmentId:
                                                            segmentListId,
                                                        regionId: regionListId,
                                                        currencyId: 119,
                                                      );
                                                    })).then(
                                                        (value) => setState(() {
                                                              SystemChrome
                                                                  .setPreferredOrientations([
                                                                DeviceOrientation
                                                                    .landscapeLeft,
                                                                DeviceOrientation
                                                                    .landscapeRight
                                                              ]);
                                                              newPage = -1;
                                                              //databaseHelper
                                                              //.deleteAllSaleOrderLineUpdate();
                                                              databaseHelper
                                                                  .deleteAllSaleOrderLineMultiSelect();
                                                            }));
                                                  },
                                            child: const Text(
                                              "Add an Order",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: 30,
                                  ),
                                ),
                                SliverPadding(
                                    padding: const EdgeInsets.all(8),
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
          isCreateQuo == true
              ? StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: quotationCreateBloc.getCreateNewStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
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
                    }
                    return Container(
                      color: Colors.black.withOpacity(0.5),
                    );
                  })
              : Container(),
          isCreateSOL == true
              ? StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: saleorderlineBloc.createproductlineListStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
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
          isUpdateQuo == true
              ? StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: quotationEditBloc.getQuotationEditStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
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
          isUpdateSOL == true
              ? StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: saleorderlineBloc.updateproductlineListStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
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
          isDeleteSOL == true
              ? StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: quotationDeleteBloc.deleteSaleOrderLineStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
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
          isUpdateQuoOrderLine == true
              ? StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: quotationEditBloc.getUpdateQuotationOrderLineStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
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
      ),
    );
  }
}
