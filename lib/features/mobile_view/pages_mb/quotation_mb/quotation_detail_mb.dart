import 'dart:io';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../dbs/database_helper.dart';
import '../../../../dbs/sharef.dart';
import '../../../../obs/response_ob.dart';
import '../../../../obs/sale_order_line_ob.dart';
import '../../../../pages/delivery_page/delivery_bloc.dart';
import '../../../../pages/delivery_page/delivery_create_bloc.dart';
import '../../../../pages/delivery_page/delivery_detail_page.dart';
import '../../../../pages/invoice_page/invoice_create_bloc.dart';
import '../../../../pages/invoice_page/invoice_detail_page.dart';
import '../../../../pages/invoice_page/invoice_line_page/invoice_line_bloc.dart';
import '../../../../pages/profile_page/profile_bloc.dart';
import '../../../../pages/quotation_page/quotation_bloc.dart';
import '../../../../pages/quotation_page/quotation_create_page.dart';
import '../../../../pages/quotation_page/quotation_delete_bloc.dart';
import '../../../../pages/quotation_page/quotation_edit_bloc.dart';
import '../../../../pages/quotation_page/quotation_page.dart';
import '../../../../pages/quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import '../../../../pages/way_planning_page/delivery_page/delivery_bloc.dart';
import '../../../../utils/app_const.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:device_info/device_info.dart';

import '../delivery_mb/delivery_detail_mb.dart';
import '../invoice_mb/invoice_detail_mb.dart';
import 'quotation_create_mb.dart';
import 'quotation_list_mb.dart';

class QuotationDetailMB extends StatefulWidget {
  String name;
  String userid;
  List<dynamic> customerId;
  String amountTotal;
  String state;
  String createTime;
  String expectedDate;
  String dateOrder;
  String validityDate;
  List<dynamic> currencyId;
  String exchangeRate;
  List<dynamic> pricelistId;
  List<dynamic> paymentTermId;
  List<dynamic> zoneId;
  List<dynamic> segmentId;
  List<dynamic> regionId;
  String filterBy;
  List<dynamic> zoneFilterId;
  List<dynamic> segmentFilterId;
  int quotationId;
  QuotationDetailMB({
    Key? key,
    required this.quotationId,
    required this.name,
    required this.userid,
    required this.customerId,
    required this.amountTotal,
    required this.state,
    required this.createTime,
    required this.expectedDate,
    required this.dateOrder,
    required this.validityDate,
    required this.currencyId,
    required this.exchangeRate,
    required this.pricelistId,
    required this.paymentTermId,
    required this.zoneId,
    required this.segmentId,
    required this.regionId,
    required this.filterBy,
    required this.zoneFilterId,
    required this.segmentFilterId,
  }) : super(key: key);

  @override
  State<QuotationDetailMB> createState() => _QuotationDetailMBState();
}

class _QuotationDetailMBState extends State<QuotationDetailMB> {
  // final quotationcreateBloc = QuotationBloc();
  final quotationdeleteBloc = DeleteQuoBloc();
  final quotationeditBloc = QuotationEditBloc();
  final saleorderlineBloc = SaleOrderLineBloc();
  final quotationBloc = QuotationBloc();
  final invoicecreateBloc = InvoiceCreateBloc();
  final invoicelineBloc = InvoiceLineBloc();
  final deliveryBloc = DeliveryBloc();
  final stockpickingBloc = StockPickingBloc();
  final stockpickingcreateBloc = StockPickingCreateBloc();
  final profileBloc = ProfileBloc();
  final isDialOpen = ValueNotifier(false);
  //Map<String, dynamic> saleorderidList = {};
  final databaseHelper = DatabaseHelper();
  List<SaleOrderLineOb>? materialproductlineDBList = [];
  List<dynamic> productlineList = [];
  List<dynamic> salediscountlist = [];
  List<dynamic> accounttaxsList = [];
  List<dynamic> customerList = [];
  List<dynamic> stockpickingtypeList = [];
  List<dynamic> productproductList = [];
  List<dynamic> productcategoryList = [];
  List<dynamic> accountIdList = [];
  List<dynamic> userList = [];
  List<dynamic> stockmoveList = [];
  int deleteornot = 0;
  int stockpickingId = 0;
  double totalSOLsubtotal = 0.0;
  String statusString = '';
  String discountName = '';
  String taxName = '';
  String customerAddress = '';
  List<dynamic> quotationList = [];
  bool updateStatus = false;
  bool isCreateDelivery = false;
  bool isUpdateDeliveryStatus = false;
  bool isCreateStockMove = false;
  bool isCreateInvoice = false;
  bool isCreateInvoiceLine = false;
  bool isUpdatePickingId = false;
  int invoiceId = 0;
  int createInvoice = 0;
  bool isCallStockPicking = false;
  bool isCallStockMove = false;
  bool isUpdateQtyDone = false;
  bool isWaitingState = false;

  // List<dynamic> tripplandeliveryList = [];
  // List<TripPlanDeliveryOb>? tripplandeliveryDBList = [];

  Future<void> getproductlineListFromDB() async {
    print('Worked');
    for (var element in productlineList) {
      if (element['order_id'][0] == widget.quotationId) {
        print('ORderId?????: ${element['order_id']}');
        print('Found: ${element['id']}');
        if (element['discount_ids'].isNotEmpty) {
          for (var sd in salediscountlist) {
            if (sd['id'] == element['discount_ids'][0]) {
              discountName = sd['name'];
              print('Discount Name: $discountName');
            }
          }
        } else {
          discountName = '';
        }
        if (element['tax_id'].isNotEmpty) {
          for (var tax in accounttaxsList) {
            if (tax['id'] == element['tax_id'][0]) {
              taxName = tax['name'];
            }
          }
        } else {
          taxName = '';
        }
        final saleOrderLineOb = SaleOrderLineOb(
            id: element['id'],
            isSelect: 1,
            productCodeName:
                element['product_id'] == false ? '' : element['product_id'][1],
            productCodeId:
                element['product_id'] == false ? 0 : element['product_id'][0],
            description:
                element['product_name'] == false ? '' : element['product_name'],
            fullName: element['product_name'] == false
                ? element['product_id'][1]
                : '${element['product_id'][1]} ${element['product_name']}',
            quantity: element['product_uom_qty'] == false
                ? ''
                : element['product_uom_qty'].toString(),
            qtyDelivered: element['qty_delivered'].toString(),
            qtyInvoiced: element['qty_invoiced'].toString(),
            uomName: element['product_uom'] == false
                ? ''
                : element['product_uom'][1],
            uomId: element['product_uom'] == false
                ? ''
                : element['product_uom'][0],
            unitPrice: element['price_unit'] == false
                ? ''
                : element['price_unit'].toString(),
            quotationId:
                element['order_id'] == false ? '' : element['order_id'][0],
            discountId: element['discount_ids'].isEmpty
                ? 0
                : element['discount_ids'][0],
            discountName: discountName,
            promotionId: element['promotion_ids'].isEmpty
                ? 0
                : element['promotion_ids'][0],
            promotionName: '',
            saleDiscount: element['sale_discount'].toString(),
            promotionDiscount: element['promotion_discount'].toString(),
            taxId: element['tax_id'].toString(),
            taxName: taxName,
            isFOC: element['is_foc'] == false ? 0 : 1,
            subTotal: element['price_subtotal'].toString());
        await databaseHelper.insertOrderLineUpdate(saleOrderLineOb);
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('State: ${widget.state}');
    print('QuotationIdForm QuoDetail: ${widget.quotationId}');
    print('CUstoemrId:' + widget.customerId[0].toString());
    quotationBloc.getQuotationWithIdData(widget.quotationId);
    quotationBloc.getQuotationWithIdStream().listen(getQuotationListListen);
    profileBloc.getResUsersStream().listen(getResUsersData);
    // getproductlineList();

    saleorderlineBloc.getproductlineListStream().listen(getproductlineList);
    quotationdeleteBloc.deleteQuoStream().listen(quotationDeleteListen);
    saleorderlineBloc
        .getProductProductListStream()
        .listen(getProductProductListen);
    saleorderlineBloc
        .getProductCategoryListStream()
        .listen(getProductCategoryListen);
    saleorderlineBloc
        .getSaleDiscountlistListStream()
        .listen(saleDiscountListen);

    saleorderlineBloc
        .getAccountTaxeslistListStream()
        .listen(getAccountTaxesListListen);

    quotationBloc.getCustomerStream().listen(getCustomerListListen);
    //invoicecreateBloc.getCreateInvoiceStream().listen(createInvoiceListen);
    databaseHelper.deleteAllAccountMoveLine();
    databaseHelper.deleteAllAccountMoveLineUpdate();
    databaseHelper.deleteAllTaxIds();
    stockpickingBloc.getStockPickingTypeData(['id', '=', 2]);
    stockpickingBloc
        .getStockPickingTypeStream()
        .listen(getStockPickingTypeListen);
    quotationeditBloc
        .getUpdateQuotationStatusStream()
        .listen(getQuotationStatusUpdateListen);
    // invoicelineBloc
    //     .getInvoiceLineCreateStream()
    //     .listen(getInvoiceLineCreateListen);
    // stockpickingcreateBloc
    //     .getCreateStockPickingStream()
    //     .listen(getCreateDeliveryListen);
    // stockpickingcreateBloc
    //     .getCreateStockMoveStream()
    //     .listen(getCreateStockMoveListen);
    // stockpickingcreateBloc
    //     .getUpdateStockPickingStatusStream()
    //     .listen(getUpdateDeliveryStatus);
    // quotationeditBloc
    //     .getUpdateQuotationPickingIdsStream()
    //     .listen(getUpdateQuotationPickingIdsListen);
    // saleorderlineBloc
    //     .waitingproductlineListStream()
    //     .listen(getWaitingInvoiceLineCreate);
    invoicecreateBloc
        .getCallCreateInvoiceMethodStream()
        .listen(getCallCreateInvoiceMethodListen);
    stockpickingcreateBloc
        .getCallActionConfirmStream()
        .listen(getCallActionConfirmListen);
    stockpickingBloc.getStockPickingStream().listen(getStockPickingListen);
    stockpickingBloc.getStockMoveStream().listen(getStockMoveListen);
    stockpickingcreateBloc
        .getUpdateQtyDoneStream()
        .listen(getUpdateQtyDoneListen);
    saleorderlineBloc
        .waitingproductlineListStream()
        .listen(getproductlineListListen);
    // invoicelineBloc.getInvoiceLineData();
    // quotationdeleteBloc
    //     .deleteSaleOrderLineStream()
    //     .listen(saleorderlineDeleteListen);
    // saleorderlineBloc
    //     .waitingproductlineListStream()
    //     .listen(waitingDeleteListen);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    quotationdeleteBloc.dispose();
    saleorderlineBloc.dispose();
  }

  void getproductlineListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() => isWaitingState = false);
      quotationBloc.getQuotationWithIdData(widget.quotationId);
    }
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      if (userList.isNotEmpty) {
        quotationBloc.getCustomerList(
            ['id', '=', quotationList[0]['partner_id'][0]],
            ['name', 'ilike', '']);
      }
    }
  }

  void getStockPickingTypeListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockpickingtypeList = responseOb.data;
    } else if (responseOb.msgState == MsgState.error) {
      print('No Stock Picking Type List');
    }
  } // Listen to get stock picking type

  // void getStockPickingCreateListen(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
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
  //     print('Create StockPicking Create Error');
  //   }
  // }

  void getQuotationStatusUpdateListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      if (quotationList.isNotEmpty) {
        for (var customer in customerList) {
          if (customer['id'] == quotationList[0]['partner_id'][0]) {
            setState(() {
              isCreateDelivery = true;
              print('isCreateDelivery: $isCreateDelivery');
            });
            await stockpickingcreateBloc.stockpickingCreate(
                partnerId: quotationList[0]['partner_id'][0],
                refNo: '',
                pickingtypeId: 2,
                locationId:
                    stockpickingtypeList[0]['default_location_src_id'] == false
                        ? customer['property_stock_supplier'][0]
                        : stockpickingtypeList[0]['default_location_src_id'][0],
                locationDestId:
                    stockpickingtypeList[0]['default_location_dest_id'] == false
                        ? customer['property_stock_customer'][0]
                        : stockpickingtypeList[0]['default_location_dest_id']
                            [0],
                scheduledDate: DateTime.now().toString().split('.')[0],
                origin: quotationList[0]['name'],
                saleId: quotationList[0]['id'],
                state: 'confirmed');
          }
        }
      }
    }
  }

  void getQuotationListListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      quotationList = responseOb.data;
      await saleorderlineBloc.getSaleOrderLineData(quotationList[0]['id']);
      await saleorderlineBloc.getSaleDiscountlistData();
      await saleorderlineBloc.getAccountTaxeslistData();
      await saleorderlineBloc.getProductProductData();
      await saleorderlineBloc.getProductCategoryData();
      await profileBloc.getResUsersData();

      // getproductlineListFromDB();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoQuotationList");
    }
  } // listen to get Quotation List

  void getproductlineList(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      productlineList = responseOb.data;
      getproductlineListFromDB();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoproductlineList");
    }
  } // listen to get Sale Order Line List

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

  void saleDiscountListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salediscountlist = responseOb.data;
    } else if (responseOb.msgState == MsgState.error) {
      print('No Sale Dicount List');
    }
  } // listen to get Sale Discount List

  void getAccountTaxesListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      accounttaxsList = responseOb.data;
      // hasAccountTaxesData = true;
    } else if (responseOb.msgState == MsgState.error) {
      print("NoaccounttaxsList");
    }
  } // listen to get Account Taxes List

  void getCallCreateInvoiceMethodListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isCreateInvoice = false;
      });
      if (createInvoice == 0) {
        quotationBloc.getQuotationWithIdData(widget.quotationId);
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return InvoiceDetailMB(
            invoiceId: invoiceId,
            quotationId: quotationList[0]['id'],
            neworeditInvoice: 1,
            address: customerAddress,
          );
        })).then((value) => setState(
            () => quotationBloc.getQuotationWithIdData(widget.quotationId)));
      }
    }
  }

  void getCustomerListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      customerList = responseOb.data;
      print('Partner Id: ${quotationList[0]['partner_id'][0]}');
      if (customerList.isNotEmpty) {
        setState(() {
          customerAddress = customerList[0]['contact_address_complete'];
          print('customerAddress: $customerAddress');
        });
      }
      // for (var customer in customerList) {
      //   if (customer['id'] == quotationList[0]['partner_id'][0]) {
      //     if (!mounted) return;

      //   }
      // }
    } else if (responseOb.msgState == MsgState.error) {
      print('No Customer List');
    }
  } // Listen to get Customer List

  // void getTripPlanDeliveryList(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     tripplandeliveryList = responseOb.data;
  //     getproductlineListFromDB();
  //   } else if (responseOb.msgState == MsgState.error) {
  //     print("NoproductlineList");
  //   }
  // } // listen to get Sale Order Line List

  void waitingDeleteListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          content:
              const Text('Deleted Successfully!', textAlign: TextAlign.center));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return QuotationListMB();
      }), (route) => false);
    }
  }

  void saleorderlineDeleteListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      saleorderlineBloc.waitingSaleOrderLineData();
      print('Delete SOL Success');
    } else if (responseOb.msgState == MsgState.error) {
      print('Fail delete SOL');
    }
  }

  void quotationDeleteListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      // if (materialproductlineDBList!.isNotEmpty) {
      //   for (var element in materialproductlineDBList!) {
      //     print('SOLDBList from delete?_______________: ${materialproductlineDBList?.length}');
      //     if(element.quotationId != 0){
      //       print('SOLIDS..................: ${element.id}');
      //       await quotationdeleteBloc.deleteSaleOrderLineData(element.id);
      //     }
      //   }
      // }
      await databaseHelper.deleteAllHrEmployeeLine();
      await databaseHelper.deleteAllHrEmployeeLineUpdate();
      await databaseHelper.deleteAllSaleOrderLine();
      await databaseHelper.deleteAllSaleOrderLineUpdate();
      await databaseHelper.deleteAllTripPlanDelivery();
      await databaseHelper.deleteAllTripPlanDeliveryUpdate();
      await databaseHelper.deleteAllTripPlanSchedule();
      await databaseHelper.deleteAllTripPlanScheduleUpdate();
      await SharefCount.clearCount();
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          content:
              const Text('Deleted Successfully!', textAlign: TextAlign.center));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return QuotationListMB();
      }), (route) => false);
    } else if (responseOb.msgState == MsgState.error) {
      if (responseOb.msgState == MsgState.error) {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
            content: const Text('Something went wrong!',
                textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }
  }

  void checkState() {
    // widget.state == 'sale'
    //                       ? 'Sale Order'
    //                       : widget.state == 'draft'
    //                           ? 'Quotation'
    //                           : widget.state == 'sent'
    //                               ? 'Quotation Sent'
    //                               : widget.state == 'done'
    //                                   ? 'Locked'
    //                                   : 'Cancelled'
    setState(() {
      if (widget.state == 'sale') {
        statusString = 'Sale Order';
      } else if (widget.state == 'draft') {
        statusString = 'Quotation';
      } else if (widget.state == 'sent') {
        statusString = 'Quotation Sent';
      } else {
        statusString = 'Cancelled';
      }
    });
  }

  void getCallActionConfirmListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        updateStatus = false;
        isCallStockPicking = true;
      });
      stockpickingBloc
          .getStockPickingData(['sale_id', '=', widget.quotationId]);
    }
  }

  void getStockPickingListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isCallStockPicking = false;
        isCallStockMove = true;
      });
      stockpickingBloc.getStockMoveData(responseOb.data[0]['id']);
    }
  }

  void getStockMoveListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stockmoveList = responseOb.data;
      setState(() {
        isCallStockMove = false;
        isUpdateQtyDone = true;
      });
      for (var stockmove in stockmoveList) {
        stockpickingcreateBloc.updateQtyDoneData(
            stockmove['id'], stockmove['product_uom_qty']);
      }
    }
  }

  void getUpdateQtyDoneListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isUpdateQtyDone = false;
        isWaitingState = true;
      });
      SharefCount.setTotal(stockmoveList.length);
      saleorderlineBloc.waitingSaleOrderLineData();
    }
  }

  // void getCreateDeliveryListen(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     for (var customer in customerList) {
  //       if (customer['id'] == quotationList[0]['partner_id'][0]) {
  //         setState(() {
  //           stockpickingId = responseOb.data;
  //           isCreateDelivery = true;
  //           print('isCreateDelivery: $isCreateDelivery');
  //         });
  //         setState(() {
  //           isCreateDelivery = false;
  //           isCreateStockMove = true;
  //           for (var sol in productlineList) {
  //             stockpickingcreateBloc.createStockMove(
  //               pickingId: responseOb.data,
  //               description: sol['product_id'][1],
  //               productId: sol['product_id'][0],
  //               qty: sol['product_uom_qty'],
  //               productuom: sol['product_uom'][0],
  //               locationId:
  //                   stockpickingtypeList[0]['default_location_src_id'] == false
  //                       ? customer['property_stock_supplier'][0]
  //                       : stockpickingtypeList[0]['default_location_src_id'][0],
  //               locationdestId:
  //                   stockpickingtypeList[0]['default_location_dest_id'] == false
  //                       ? customer['property_stock_customer'][0]
  //                       : stockpickingtypeList[0]['default_location_dest_id']
  //                           [0],
  //               origin: quotationList[0]['name'],
  //             );
  //           }
  //         });
  //       }
  //     }
  //   }
  // }

  // void getCreateStockMoveListen(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     setState(() {
  //       isCreateStockMove = false;
  //       isUpdateDeliveryStatus = true;
  //       stockpickingcreateBloc.stockpickingUpdateStatus(
  //           ids: stockpickingId, state: 'confirmed');
  //     });
  //   }
  // }

  // void getUpdateDeliveryStatus(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     setState(() {
  //       isUpdateDeliveryStatus = false;
  //       isUpdatePickingId = true;
  //       quotationeditBloc.updateQuotationPickingIdsData(
  //           ids: quotationList[0]['id'], pickingIds: stockpickingId);
  //     });
  //   }
  // }

  // void getUpdateQuotationPickingIdsListen(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     setState(() {
  //       isUpdatePickingId = false;
  //     });
  //     quotationBloc.getQuotationWithIdData(widget.quotationId);
  //   }
  // }

  // createInvoice() async {
  //   setState(() {
  //     isCreateInvoice = true;
  //   });
  //   await invoicecreateBloc.invoiceCreate(
  //       partnerId: quotationList[0]['partner_id'][0],
  //       ref: '',
  //       invoiceDate: '',
  //       invoiceOrigin: quotationList[0]['name'],
  //       type: 'out_invoice',
  //       invoicePaymentTermId: quotationList[0]['payment_term_id'] == false
  //           ? null
  //           : quotationList[0]['payment_term_id'][0],
  //       invoiceDueDate: '',
  //       journalId: 0,
  //       currencyId: quotationList[0]['currency_id'] == false
  //           ? null
  //           : quotationList[0]['currency_id'][0],
  //       exchangeRate: quotationList[0]['exchange_rate']);
  // }

  // void createInvoiceListen(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     setState(() {
  //       invoiceId = responseOb.data;
  //       isCreateInvoiceLine = true;
  //       for (var sol in productlineList) {
  //         for (var product in productproductList) {
  //           if (product['id'] == sol['product_id'][0]) {
  //             print('Product Name: ${product['name']}');
  //             for (var categ in productcategoryList) {
  //               if (categ['id'] == product['categ_id'][0]) {
  //                 print(
  //                     'Product Category: ${categ['name']},${categ['property_account_income_categ_id']}');
  //                 invoicelineBloc.createInvoiceLine(
  //                     moveId: invoiceId,
  //                     excludefrominvoicetab:
  //                         sol['is_foc'] == false ? false : true,
  //                     productId: sol['product_id'][0],
  //                     balance: double.parse(sol['price_subtotal'].toString()),
  //                     salelineids: [sol['id']],
  //                     accountId:
  //                         categ['property_account_income_categ_id'] == false
  //                             ? false
  //                             : categ['property_account_income_categ_id'][0],
  //                     name: sol['product_id'][1],
  //                     accountinternaltype: 'other',
  //                     quantity: double.parse(sol['product_uom_qty'].toString()),
  //                     productUoMId: sol['product_uom'][0],
  //                     priceunit: sol['price_subtotal'],
  //                     salediscount: sol['sale_discount'],
  //                     taxIds: sol['tax_id'],
  //                     //credit: double.parse(sol['price_subtotal'].toString()),
  //                     //debit: double.parse(sol['price_subtotal'].toString()),
  //                     pricesubtotal: sol['price_subtotal']);
  //                 totalSOLsubtotal = totalSOLsubtotal + sol['price_subtotal'];
  //               }
  //             }
  //           }
  //         }
  //       }
  //       // invoicelineBloc.createInvoiceLine(
  //       //   moveId: invoiceId,
  //       //   productId: 1568,
  //       //   salelineids: [746],
  //       //   name: '',
  //       //   accountinternaltype: 'receivable',
  //       //   quantity: 1.0,
  //       //   salediscount: 0.0,
  //       //   taxIds: [],
  //       //   credit: 0.0,
  //       //   accountId: customerList[0]['property_account_receivable_id'][0],
  //       //   priceunit: totalSOLsubtotal,
  //       //   excludefrominvoicetab: true,
  //       //   debit: totalSOLsubtotal,
  //       // );
  //       print('invoiceId: $invoiceId');
  //     });
  //   } else if (responseOb.msgState == MsgState.error) {
  //     print('Creating invoice Error');
  //   }
  // }

  // void getInvoiceLineCreateListen(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     print('Product Line List Length: ${productlineList.length}');
  //     SharefCount.setTotal((productlineList.length) + 1);
  //     saleorderlineBloc.waitingSaleOrderLineData();
  //   }
  // }

  // void getWaitingInvoiceLineCreate(ResponseOb responseOb) {
  //   if (responseOb.msgState == MsgState.data) {
  //     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
  //       return InvoiceDetailPage(
  //         invoiceId: invoiceId,
  //         quotationId: quotationList[0]['id'],
  //         neworeditInvoice: 1,
  //         address: customerAddress,
  //       );
  //     }));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
          await databaseHelper.deleteAllSaleOrderLineUpdate();
          await databaseHelper.deleteAllTripPlanDeliveryUpdate();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return QuotationListMB();
          }), (route) => false);
          return true;
        }
      },
      child: SafeArea(
          child: StreamBuilder<ResponseOb>(
        initialData: ResponseOb(msgState: MsgState.loading),
        stream: quotationBloc.getQuotationWithIdStream(),
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
                initialData: ResponseOb(msgState: MsgState.loading),
                stream: saleorderlineBloc.getproductlineListStream(),
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
                              title: Text(
                                  '${widget.name} (${widget.customerId[1]})'),
                              actions: [
                                // TextButton(
                                //     onPressed: () async {
                                //       final invoice = Invoice(
                                //           info: InvoiceInfo(
                                //             number: widget.name,
                                //             date: widget.dateOrder
                                //                 .toString()
                                //                 .split(' ')[0],
                                //           ),
                                //           supplier: const Supplier(
                                //               name: 'SMc',
                                //               address: 'address',
                                //               paymentInfo: 'paymentInfo'),
                                //           customer: Customer(
                                //               name: widget.customerId[1],
                                //               address: 'Myanmar'),
                                //           items: materialproductlineDBList!.map((e) {
                                //             return InvoiceItem(
                                //                 description: e.description,
                                //                 uomName: e.uomName,
                                //                 quantity:
                                //                     double.parse(e.quantity),
                                //                 unitPrice:
                                //                     double.parse(e.unitPrice),
                                //                 subtotal: e.subTotal,
                                //                 isFOC: e.isFOC);
                                //           }).toList());
                                //       final pdfFile =
                                //           await PdfInvoiceApi.generate(invoice);
                                //       PdfApi.openFile(pdfFile);
                                //     },
                                //     child: const Text("Save as PDF")),
                                Visibility(
                                  visible: quotationList[0]['invoice_status'] ==
                                          'to invoice'
                                      ? true
                                      : false,
                                  child: TextButton(
                                      onPressed: () async {
                                        // var bluetoothScanstatus =
                                        //     await Permission.bluetoothScan.status;
                                        // var bluetoothAdvertise = await Permission
                                        //     .bluetoothAdvertise.status;
                                        // var bluetoothConnect = await Permission
                                        //     .bluetoothConnect.status;
                                        // if (!bluetoothScanstatus.isGranted) {
                                        //   await Permission.bluetoothScan.request();
                                        // }
                                        // if (!bluetoothAdvertise.isGranted) {
                                        //   await Permission.bluetoothAdvertise
                                        //       .request();
                                        // }
                                        // if (!bluetoothConnect.isGranted) {
                                        //   await Permission.bluetoothConnect
                                        //       .request();
                                        // }
                                        // if (await Permission
                                        //         .bluetoothScan.isGranted &&
                                        //     await Permission
                                        //         .bluetoothAdvertise.isGranted &&
                                        //     await Permission
                                        //         .bluetoothConnect.isGranted) {
                                        //   Navigator.of(context).push(
                                        //       MaterialPageRoute(builder: (context) {
                                        //     return Print(
                                        //       productlineList:
                                        //           materialproductlineDBList!,
                                        //       orderId: widget.name,
                                        //       customerName: widget.customerId[1],
                                        //       dateorder: quotationList[0]
                                        //           ['date_order'],
                                        //       amountUntaxed: quotationList[0]
                                        //               ['amount_untaxed']
                                        //           .toString(),
                                        //     );
                                        //   }));
                                        //}
                                        // var bluetoothConnect = await Permission
                                        //     .bluetoothConnect.status;
                                        // var bluetoothScan =
                                        //     await Permission.bluetoothScan.status;
                                        // var location =
                                        //     await Permission.location.status;
                                        // var bluetooth =
                                        //     await Permission.bluetooth.status;
                                        // Map<Permission, PermissionStatus> statuses;
                                        // DeviceInfoPlugin deviceInfoPlugin =
                                        //     DeviceInfoPlugin();
                                        // if (Platform.isAndroid) {
                                        //   AndroidDeviceInfo androidDeviceInfo =
                                        //       await deviceInfoPlugin.androidInfo;
                                        //   if (androidDeviceInfo.version.sdkInt >=
                                        //       31) {
                                        //     if (!bluetoothConnect.isGranted ||
                                        //         !bluetoothScan.isGranted ||
                                        //         !location.isGranted) {
                                        //       statuses = await [
                                        //         Permission.bluetoothConnect,
                                        //         Permission.bluetoothScan,
                                        //         Permission.location
                                        //       ].request();
                                        //     }
                                        //     if (await Permission
                                        //             .bluetoothConnect.isGranted &&
                                        //         await Permission
                                        //             .bluetoothScan.isGranted &&
                                        //         await Permission
                                        //             .location.isGranted) {
                                        //       Navigator.of(context).push(
                                        //           MaterialPageRoute(
                                        //               builder: (context) {
                                        //         return Print(
                                        //           productlineList:
                                        //               materialproductlineDBList!,
                                        //           orderId: widget.name,
                                        //           customerName:
                                        //               widget.customerId[1],
                                        //           dateorder: quotationList[0]
                                        //               ['date_order'],
                                        //           amountUntaxed: quotationList[0]
                                        //                   ['amount_untaxed']
                                        //               .toString(),
                                        //         );
                                        //       }));
                                        //     }
                                        //   } else {
                                        //     if (!bluetooth.isGranted ||
                                        //         !location.isGranted) {
                                        //       statuses = await [
                                        //         Permission.bluetooth,
                                        //         Permission.location
                                        //       ].request();
                                        //     }
                                        //     if (await Permission
                                        //             .bluetooth.isGranted &&
                                        //         await Permission
                                        //             .location.isGranted) {
                                        //       Navigator.of(context).push(
                                        //           MaterialPageRoute(
                                        //               builder: (context) {
                                        //         return Print(
                                        //           productlineList:
                                        //               materialproductlineDBList!,
                                        //           orderId: widget.name,
                                        //           customerName:
                                        //               widget.customerId[1],
                                        //           dateorder: quotationList[0]
                                        //               ['date_order'],
                                        //           amountUntaxed: quotationList[0]
                                        //                   ['amount_untaxed']
                                        //               .toString(),
                                        //         );
                                        //       }));
                                        //     }
                                        //   }
                                        // }
                                        // Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                        //   return InvoiceCreatePage(
                                        //     createInvoiceWithId: 1,
                                        //     quotationId: quotationList[0]['id'],
                                        //     customerId: quotationList[0]['partner_id'][0],
                                        //     paymentTermsId: quotationList[0]['payment_term_id'] == false ? 0: quotationList[0]['payment_term_id'][0],
                                        //     currencyId: quotationList[0]['currency_id'] == false ? 0: quotationList[0]['currency_id'][0],
                                        //   );
                                        // }));
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                  title: const Text(
                                                      'Create Invoices'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            createInvoice = 0;
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                            'Cancel')),
                                                    OutlinedButton(
                                                        style: OutlinedButton
                                                            .styleFrom(
                                                                side: const BorderSide(
                                                                    color: Colors
                                                                        .black)),
                                                        onPressed: () {
                                                          for (var sol
                                                              in productlineList) {
                                                            for (var product
                                                                in productproductList) {
                                                              if (product[
                                                                      'id'] ==
                                                                  sol['product_id']
                                                                      [0]) {
                                                                print(
                                                                    'Product Name: ${product['name']}');
                                                                for (var categ
                                                                    in productcategoryList) {
                                                                  if (categ[
                                                                          'id'] ==
                                                                      product['categ_id']
                                                                          [0]) {
                                                                    print(
                                                                        'Product Category: ${categ['name']},${categ['property_account_income_categ_id']}');
                                                                    accountIdList
                                                                        .add(categ[
                                                                            'property_account_income_categ_id']);
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                          print(
                                                              'AccountIdList: $accountIdList');
                                                          if (accountIdList
                                                              .contains(
                                                                  false)) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                      title: const Text(
                                                                          'Something went wrong !'),
                                                                      content:
                                                                          const Text(
                                                                              'Missing required account on accountable invoice line.'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          style:
                                                                              TextButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.cyan,
                                                                          ),
                                                                          child: const Text(
                                                                              'Ok',
                                                                              style: TextStyle(color: Colors.white)),
                                                                        )
                                                                      ]);
                                                                });
                                                            print(
                                                                'Missing required account on accountable invoice line.');
                                                          } else {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            // createInvoice();
                                                            setState(() {
                                                              createInvoice = 0;
                                                              isCreateInvoice =
                                                                  true;
                                                            });
                                                            invoicecreateBloc
                                                                .invoiceCreateMethod(
                                                                    id: widget
                                                                        .quotationId);
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Create Invoice')),
                                                    TextButton(
                                                        style: ButtonStyle(
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                        .cyan)),
                                                        onPressed: () {
                                                          for (var sol
                                                              in productlineList) {
                                                            for (var product
                                                                in productproductList) {
                                                              if (product[
                                                                      'id'] ==
                                                                  sol['product_id']
                                                                      [0]) {
                                                                print(
                                                                    'Product Name: ${product['name']}');
                                                                for (var categ
                                                                    in productcategoryList) {
                                                                  if (categ[
                                                                          'id'] ==
                                                                      product['categ_id']
                                                                          [0]) {
                                                                    print(
                                                                        'Product Category: ${categ['name']},${categ['property_account_income_categ_id']}');
                                                                    accountIdList
                                                                        .add(categ[
                                                                            'property_account_income_categ_id']);
                                                                  }
                                                                }
                                                              }
                                                            }
                                                          }
                                                          print(
                                                              'AccountIdList: $accountIdList');
                                                          if (accountIdList
                                                              .contains(
                                                                  false)) {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                      title: const Text(
                                                                          'Something went wrong !'),
                                                                      content:
                                                                          const Text(
                                                                              'Missing required account on accountable invoice line.'),
                                                                      actions: [
                                                                        TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          style:
                                                                              TextButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.cyan,
                                                                          ),
                                                                          child: const Text(
                                                                              'Ok',
                                                                              style: TextStyle(color: Colors.white)),
                                                                        )
                                                                      ]);
                                                                });
                                                            print(
                                                                'Missing required account on accountable invoice line.');
                                                          } else {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            // createInvoice();
                                                            setState(() {
                                                              createInvoice = 1;
                                                              isCreateInvoice =
                                                                  true;
                                                            });
                                                            invoicecreateBloc
                                                                .invoiceCreateMethod(
                                                                    id: widget
                                                                        .quotationId);
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Create and View Invoice',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)))
                                                  ]);
                                            });
                                        // Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                        //   return InvoicePage();
                                        // }));
                                      },
                                      child: const Text('Create Invoice',
                                          style:
                                              TextStyle(color: Colors.white))),
                                ),
                                // TextButton(onPressed: (){
                                //   Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                //     return PrintPage();
                                //   }));
                                // }, child: const Text('Print'))
                                Visibility(
                                    visible:
                                        quotationList[0]['delivery_count'] > 0
                                            ? true
                                            : false,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return DeliveryDetailMB(
                                            quotationId: quotationList[0]['id'],
                                          );
                                        }));
                                      },
                                      child: Text(
                                          'Delivery (${quotationList[0]['delivery_count']})',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          )),
                                    )),
                                Visibility(
                                    visible:
                                        quotationList[0]['invoice_count'] > 0
                                            ? true
                                            : false,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return InvoiceDetailMB(
                                            invoiceId: invoiceId,
                                            quotationId: quotationList[0]['id'],
                                            neworeditInvoice: 1,
                                            address: customerAddress,
                                          );
                                        })).then((value) => quotationBloc
                                            .getQuotationWithIdData(
                                                widget.quotationId));
                                      },
                                      child: Text(
                                          'Invoice (${quotationList[0]['invoice_count']})',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          )),
                                    ))
                              ],
                            ),
                            body: FutureBuilder<List<SaleOrderLineOb>>(
                                future:
                                    databaseHelper.getSaleOrderLineUpdateList(),
                                builder: (context, snapshot) {
                                  materialproductlineDBList = snapshot.data;
                                  Widget saleOrderLineWidget =
                                      SliverToBoxAdapter(
                                    child: Container(),
                                  );
                                  if (snapshot.hasData) {
                                    saleOrderLineWidget = SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                      (context, i) {
                                        print(
                                            'SOLLength------------: ${materialproductlineDBList?.length}');
                                        return materialproductlineDBList![i]
                                                        .quotationId !=
                                                    widget.quotationId &&
                                                materialproductlineDBList![i]
                                                        .isSelect !=
                                                    1
                                            ? Container()
                                            : Column(
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
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Product Code: ',
                                                            //         style: TextStyle(
                                                            //             fontSize: 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .productCodeName,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors.black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
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
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ]))
                                                          ],
                                                        ),
                                                        collapsed: Row(
                                                          children: [
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Description: ',
                                                            //         style: TextStyle(
                                                            //             fontSize: 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .description,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
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
                                                                    style: TextStyle(
                                                                        color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                            ? Colors.cyan
                                                                            : materialproductlineDBList![i].isFOC == 1
                                                                                ? Colors.amber
                                                                                : Colors.black,
                                                                        fontSize: 18),
                                                                  )
                                                                ]))
                                                          ],
                                                        ),
                                                        expanded: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Description: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .description,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .description,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Quantity: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .quantity,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Quantity: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .quantity,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                            Visibility(
                                                              visible: quotationList[
                                                                              0]
                                                                          [
                                                                          'state'] ==
                                                                      'sale'
                                                                  ? true
                                                                  : false,
                                                              child: Row(
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Delivered: ',
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
                                                                              .qtyDelivered!,
                                                                          style: TextStyle(
                                                                              color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                  ? Colors.cyan
                                                                                  : materialproductlineDBList![i].isFOC == 1
                                                                                      ? Colors.amber
                                                                                      : Colors.black,
                                                                              fontSize: 18),
                                                                        )
                                                                      ])),
                                                                ],
                                                              ),
                                                            ),
                                                            Visibility(
                                                              visible: quotationList[
                                                                              0]
                                                                          [
                                                                          'state'] ==
                                                                      'sale'
                                                                  ? true
                                                                  : false,
                                                              child: Row(
                                                                children: [
                                                                  const SizedBox(
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Invoiced: ',
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
                                                                              .qtyInvoiced!,
                                                                          style: TextStyle(
                                                                              color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                  ? Colors.cyan
                                                                                  : materialproductlineDBList![i].isFOC == 1
                                                                                      ? Colors.amber
                                                                                      : Colors.black,
                                                                              fontSize: 18),
                                                                        )
                                                                      ])),
                                                                ],
                                                              ),
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text: 'UOM: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .uomName,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'UOM: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .uomName,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Unit Price: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .unitPrice,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Unit Price: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .unitPrice,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Sale Discount: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .discountName,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Sale Discount: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Container(
                                                                        padding:
                                                                            const EdgeInsets.all(3),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.black,
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                        ),
                                                                        child:
                                                                            Text(
                                                                          materialproductlineDBList![i]
                                                                              .discountName!,
                                                                          style: TextStyle(
                                                                              color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                  ? Colors.cyan
                                                                                  : materialproductlineDBList![i].isFOC == 1
                                                                                      ? Colors.amber
                                                                                      : Colors.white,
                                                                              fontSize: 18),
                                                                        ),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Promotion: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .promotionName,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Promotion: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .promotionName!,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Discount: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .saleDiscount,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Discount: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .saleDiscount!,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Promo Discount: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .promotionDiscount,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Promotion Discount: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .promotionDiscount!,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Taxes: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .taxName,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Taxes: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .taxName,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
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
                                                                    'Is FOC: ',
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
                                                                Icon(materialproductlineDBList![i]
                                                                            .isFOC ==
                                                                        0
                                                                    ? Icons
                                                                        .check_box_outline_blank
                                                                    : Icons
                                                                        .check_box),
                                                              ],
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Subtotal: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: materialproductlineDBList![
                                                            //                   i]
                                                            //               .subTotal,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Subtotal: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                        materialproductlineDBList![i]
                                                                            .subTotal,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && materialproductlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : materialproductlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      )),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: CustomScrollView(
                                              slivers: [
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
                                                            const SizedBox(
                                                              height: 70,
                                                            ),
                                                            Text(
                                                              quotationList[i]
                                                                  ['name'],
                                                              style: const TextStyle(
                                                                  fontSize: 30,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            const SizedBox(
                                                              height: 30,
                                                            ),
                                                            // RichText(
                                                            //   text: TextSpan(
                                                            //       children: [
                                                            //         const TextSpan(
                                                            //           text:
                                                            //               'Filter By: ',
                                                            //           style: TextStyle(
                                                            //               fontSize:
                                                            //                   20,
                                                            //               fontWeight:
                                                            //                   FontWeight
                                                            //                       .bold,
                                                            //               color: Colors
                                                            //                   .black),
                                                            //         ),
                                                            //         TextSpan(
                                                            //             text:
                                                            //                 '${quotationList[i]['customer_filter'] == false ? '' : quotationList[i]['customer_filter']} - ',
                                                            //             style: const TextStyle(
                                                            //                 color: Colors
                                                            //                     .black,
                                                            //                 fontSize:
                                                            //                     18)),
                                                            //         quotationList[i]
                                                            //                     [
                                                            //                     'customer_filter'] ==
                                                            //                 'zone'
                                                            //             ? TextSpan(
                                                            //                 text:
                                                            //                     '${widget.zoneFilterId[1]}',
                                                            //                 style: const TextStyle(
                                                            //                     color: Colors
                                                            //                         .black,
                                                            //                     fontSize:
                                                            //                         18))
                                                            //             : quotationList[i]['customer_filter'] ==
                                                            //                     'segemnt'
                                                            //                 ? TextSpan(
                                                            //                     text: '${widget.segmentFilterId[1]}',
                                                            //                     style: const TextStyle(color: Colors.black, fontSize: 18))
                                                            //                 : const TextSpan(),
                                                            //       ]),
                                                            // ),
                                                            Row(
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Filter By: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      RichText(
                                                                        text: TextSpan(
                                                                            children: [
                                                                              TextSpan(text: '${quotationList[i]['customer_filter'] == false ? '' : quotationList[i]['customer_filter']} - ', style: const TextStyle(color: Colors.black, fontSize: 18)),
                                                                              quotationList[i]['customer_filter'] == 'zone'
                                                                                  ? TextSpan(text: '${widget.zoneFilterId[1]}', style: const TextStyle(color: Colors.black, fontSize: 18))
                                                                                  : quotationList[i]['customer_filter'] == 'segemnt'
                                                                                      ? TextSpan(text: '${widget.segmentFilterId[1]}', style: const TextStyle(color: Colors.black, fontSize: 18))
                                                                                      : const TextSpan(),
                                                                            ]),
                                                                      ),
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Customer: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text:
                                                            //               '${quotationList[i]['partner_id'][1]}',
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Customer: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['partner_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Customer Address: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text:
                                                            //               customerAddress,
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Customer Address: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          customerAddress,
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Currency: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text:
                                                            //               '${quotationList[i]['currency_id'] == false ? '-' : quotationList[i]['currency_id'][1]}',
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Currency: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['currency_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Exchange Rate: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: quotationList[i]
                                                            //                   [
                                                            //                   'exchange_rate']
                                                            //               .toString(),
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Exchange Rate: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['exchange_rate']}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Expiration: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: quotationList[i]['validity_date'] ==
                                                            //                   false
                                                            //               ? '-'
                                                            //               : quotationList[i]
                                                            //                   [
                                                            //                   'validity_date'],
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Expiration: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['validity_date'] == false ? '-' : quotationList[i]['validity_date']}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Quotation: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text: quotationList[
                                                            //                   i][
                                                            //               'date_order'],
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Quotation: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['date_order']}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Pricelist: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text:
                                                            //               '${quotationList[i]['pricelist_id'][1]}',
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Pricelist: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['pricelist_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Payment Terms: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text:
                                                            //               '${quotationList[i]['payment_term_id'] == false ? '-' : quotationList[i]['payment_term_id'][1]}',
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Payment Terms: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['payment_term_id'] == false ? '-' : quotationList[i]['payment_term_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Zone: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text:
                                                            //               '${quotationList[i]['zone_id'] == false ? '-' : quotationList[i]['zone_id'][1]}',
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['zone_id'] == false ? '-' : quotationList[i]['zone_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Segment: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text:
                                                            //               '${quotationList[i]['segment_id'] == false ? '-' : quotationList[i]['segment_id'][1]}',
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Segment: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['segment_id'] == false ? '-' : quotationList[i]['segment_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            // RichText(
                                                            //     text: TextSpan(
                                                            //         children: [
                                                            //       const TextSpan(
                                                            //         text:
                                                            //             'Region: ',
                                                            //         style: TextStyle(
                                                            //             fontSize:
                                                            //                 20,
                                                            //             fontWeight:
                                                            //                 FontWeight
                                                            //                     .bold,
                                                            //             color: Colors
                                                            //                 .black),
                                                            //       ),
                                                            //       TextSpan(
                                                            //           text:
                                                            //               '${quotationList[i]['region_id'] == false ? '-' : quotationList[i]['region_id'][1]}',
                                                            //           style: const TextStyle(
                                                            //               color: Colors
                                                            //                   .black,
                                                            //               fontSize:
                                                            //                   18))
                                                            //     ])),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Region: ',
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
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                      Text(
                                                                          '${quotationList[i]['region_id'] == false ? '-' : quotationList[i]['region_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                                childCount:
                                                                    quotationList
                                                                        .length))),
                                                // const SliverToBoxAdapter(
                                                //     child: Divider(
                                                //         thickness: 2,
                                                //         color: Colors.black)),
                                                SliverPadding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  sliver: SliverToBoxAdapter(
                                                      child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10,
                                                            bottom: 10),
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
                                                    sliver:
                                                        saleOrderLineWidget),
                                                const SliverToBoxAdapter(
                                                  child: SizedBox(height: 20),
                                                ),
                                                SliverToBoxAdapter(
                                                  child: Container(
                                                    padding: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width >
                                                            400.0
                                                        ? const EdgeInsets.only(
                                                            left: 220,
                                                            right: 20,
                                                            top: 20,
                                                            bottom: 20)
                                                        : const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10),
                                                    decoration:
                                                        const BoxDecoration(
                                                            color:
                                                                Colors.white),
                                                    child: Column(
                                                      children: [
                                                        Row(children: [
                                                          Expanded(
                                                            flex: 2,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          Text(
                                                                        'Untaxed Amount',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ),
                                                                    const Text(
                                                                      ':',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                    Expanded(
                                                                        child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            children: [
                                                                          Text(
                                                                              '${quotationList[0]['amount_untaxed']} K',
                                                                              style: const TextStyle(color: Colors.black, fontSize: 18))
                                                                        ])),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          Text(
                                                                        'Taxes',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ),
                                                                    const Text(
                                                                      ':',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                    Expanded(
                                                                        child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            children: [
                                                                          Text(
                                                                              '${quotationList[0]['amount_tax']} K',
                                                                              style: const TextStyle(color: Colors.black, fontSize: 18))
                                                                        ])),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const SizedBox(
                                                                      width:
                                                                          200,
                                                                      child:
                                                                          Text(
                                                                        'Total Discount',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                20,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: Colors.black),
                                                                      ),
                                                                    ),
                                                                    const Text(
                                                                      ':',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                    Expanded(
                                                                        child: Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.end,
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            children: [
                                                                          Text(
                                                                              '${quotationList[0]['amount_discount']} K',
                                                                              style: const TextStyle(color: Colors.black, fontSize: 18))
                                                                        ])),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ]),
                                                        const Divider(
                                                          thickness: 1.5,
                                                          color: Colors.black,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const SizedBox(
                                                              width: 200,
                                                              child: Text(
                                                                'Total',
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
                                                            const Text(
                                                              ':',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black),
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
                                                                      '${quotationList[0]['amount_total']} K',
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .black,
                                                                          fontSize:
                                                                              18))
                                                                ])),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SliverToBoxAdapter(
                                                  child: SizedBox(height: 100),
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
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              // color: AppColors.appBarColor,
                                            ),
                                            child: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    400.0
                                                ? SpeedDial(
                                                    buttonSize: 80,
                                                    childrenButtonSize: 100,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    elevation: 0.0,
                                                    activeChild: const Icon(
                                                      Icons.close,
                                                      color:
                                                          AppColors.appBarColor,
                                                    ),
                                                    child: quotationList[0]
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
                                                            child: const Center(
                                                              child: Text(
                                                                  'Quotation',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          10)),
                                                            ),
                                                          )
                                                        : quotationList[0]
                                                                    ['state'] ==
                                                                'sent'
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
                                                                      'Quotation Sent',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              10)),
                                                                ),
                                                              )
                                                            : quotationList[0][
                                                                        'state'] ==
                                                                    'sale'
                                                                ? Container(
                                                                    width: 80,
                                                                    height: 40,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        const Center(
                                                                      child: Text(
                                                                          'Sale Order',
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style:
                                                                              TextStyle(fontSize: 10)),
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
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        const Center(
                                                                      child: Text(
                                                                          'Cancelled',
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style:
                                                                              TextStyle(fontSize: 10)),
                                                                    ),
                                                                  ),
                                                    spaceBetweenChildren: 5,
                                                    direction:
                                                        SpeedDialDirection.left,
                                                    renderOverlay: false,
                                                    children: [
                                                        SpeedDialChild(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          elevation: 0.0,
                                                          child: Container(
                                                            height: 40,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                        width:
                                                                            1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: quotationList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'cancel'
                                                                    ? AppColors
                                                                        .appBarColor
                                                                    : Colors
                                                                        .white),
                                                            child: Center(
                                                              child: Text(
                                                                "Cancelled",
                                                                style: TextStyle(
                                                                    color: quotationList[0]['state'] ==
                                                                            'cancel'
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .grey,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SpeedDialChild(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          elevation: 0.0,
                                                          child: Container(
                                                            height: 40,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                        width:
                                                                            1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: quotationList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'sale'
                                                                    ? AppColors
                                                                        .appBarColor
                                                                    : Colors
                                                                        .white),
                                                            child: Center(
                                                              child: Text(
                                                                "Sale Order",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: quotationList[0]['state'] ==
                                                                            'sale'
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .grey,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SpeedDialChild(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          elevation: 0.0,
                                                          child: Container(
                                                            height: 40,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                        width:
                                                                            1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: quotationList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'sent'
                                                                    ? AppColors
                                                                        .appBarColor
                                                                    : Colors
                                                                        .white),
                                                            child: Center(
                                                              child: Text(
                                                                "Quotation Sent",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    color: quotationList[0]['state'] ==
                                                                            'sent'
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .grey,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SpeedDialChild(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          elevation: 0.0,
                                                          child: Container(
                                                            height: 40,
                                                            width: 80,
                                                            decoration: BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                        width:
                                                                            1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: quotationList[0]
                                                                            [
                                                                            'state'] ==
                                                                        'draft'
                                                                    ? AppColors
                                                                        .appBarColor
                                                                    : Colors
                                                                        .white),
                                                            child: Center(
                                                              child: Text(
                                                                "Quotation",
                                                                style: TextStyle(
                                                                    color: quotationList[0]['state'] ==
                                                                            'draft'
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .grey,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ])
                                                : Container(
                                                    child: quotationList[0]
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
                                                            child: const Center(
                                                              child: Text(
                                                                  'Quotation',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .white,
                                                                  )),
                                                            ),
                                                          )
                                                        : quotationList[0]
                                                                    ['state'] ==
                                                                'sent'
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
                                                                      'Quotation Sent',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color: Colors
                                                                            .white,
                                                                      )),
                                                                ),
                                                              )
                                                            : quotationList[0][
                                                                        'state'] ==
                                                                    'sale'
                                                                ? Container(
                                                                    width: 80,
                                                                    height: 40,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: AppColors
                                                                          .appBarColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        const Center(
                                                                      child: Text(
                                                                          'Sale Order',
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                Colors.white,
                                                                          )),
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
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        const Center(
                                                                      child: Text(
                                                                          'Cancelled',
                                                                          textAlign: TextAlign
                                                                              .center,
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                Colors.white,
                                                                          )),
                                                                    ),
                                                                  ),
                                                  ),
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
                                  SpeedDialChild(
                                    visible:
                                        quotationList[0]['state'] == 'sale' ||
                                                quotationList[0]['state'] ==
                                                    'cancel'
                                            ? false
                                            : true,
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return QuotationCreateMB(
                                          quotationId: widget.quotationId,
                                          name: widget.name,
                                          userid: widget.userid,
                                          customerId: widget.customerId,
                                          dateOrder: widget.dateOrder,
                                          validityDate: widget.validityDate,
                                          currencyId: widget.currencyId,
                                          exchangeRate: widget.exchangeRate,
                                          pricelistId: widget.pricelistId,
                                          paymentTermId: widget.paymentTermId,
                                          zoneId: widget.zoneId,
                                          segmentId: widget.segmentId,
                                          regionId: widget.regionId,
                                          newOrEdit: 1,
                                          productlineList: productlineList,
                                          filter: widget.filterBy,
                                          zoneFilterId:
                                              widget.zoneFilterId.isNotEmpty
                                                  ? widget.zoneFilterId[0]
                                                  : 0,
                                          segmentFilterId:
                                              widget.segmentFilterId.isNotEmpty
                                                  ? widget.segmentFilterId[0]
                                                  : 0,
                                        );
                                      })).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: const Icon(Icons.edit),
                                    label: 'Edit',
                                  ),
                                  SpeedDialChild(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return QuotationCreateMB(
                                          quotationId: widget.quotationId,
                                          name: widget.name,
                                          userid: widget.userid,
                                          customerId: widget.customerId,
                                          dateOrder: widget.dateOrder,
                                          validityDate: widget.validityDate,
                                          currencyId: widget.currencyId,
                                          exchangeRate: widget.exchangeRate,
                                          pricelistId: widget.pricelistId,
                                          paymentTermId: widget.paymentTermId,
                                          zoneId: widget.zoneId,
                                          segmentId: widget.segmentId,
                                          regionId: widget.regionId,
                                          newOrEdit: 0,
                                          productlineList: productlineList,
                                          filter: '',
                                          zoneFilterId: 0,
                                          segmentFilterId: 0,
                                        );
                                      })).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: const Icon(Icons.add),
                                    label: 'Create',
                                  ),
                                  SpeedDialChild(
                                    visible: quotationList[0]['state'] == 'sale'
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
                                                    child:
                                                        const Text("Cancel")),
                                                TextButton(
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                    onPressed: deleteRecord,
                                                    child: const Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                          color: Colors.white),
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
                                    visible:
                                        quotationList[0]['state'] == 'sale' ||
                                                quotationList[0]['state'] ==
                                                    'cancel'
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
                                                    child: const Text('No')),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        updateStatus = true;
                                                      });
                                                      stockpickingcreateBloc
                                                          .callActionConfirm(
                                                              id: widget
                                                                  .quotationId);
                                                      // quotationeditBloc
                                                      //     .updateQuotationStatusData(
                                                      //         widget
                                                      //             .quotationId,
                                                      //         'sale');
                                                    },
                                                    child: const Text('Yes'))
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
                        deleteornot == 0
                            ? Container()
                            : Positioned(
                                child: StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: quotationdeleteBloc.deleteQuoStream(),
                                builder: (context,
                                    AsyncSnapshot<ResponseOb> snapshot) {
                                  ResponseOb? responseOb = snapshot.data;
                                  if (responseOb?.msgState ==
                                      MsgState.loading) {
                                    return Container(
                                        color: Colors.white,
                                        child: Center(
                                          child: Image.asset(
                                            'assets/gifs/loading.gif',
                                            width: 100,
                                            height: 100,
                                          ),
                                        ));
                                  }
                                  return Container(
                                    color: Colors.white,
                                  );
                                },
                              )),
                        updateStatus == false
                            ? Container()
                            : Positioned(
                                child: StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: stockpickingcreateBloc
                                    .getCallActionConfirmStream(),
                                builder: (context,
                                    AsyncSnapshot<ResponseOb> snapshot) {
                                  ResponseOb? responseOb = snapshot.data;
                                  if (responseOb?.msgState ==
                                      MsgState.loading) {
                                    return Container(
                                        color: Colors.white,
                                        child: Center(
                                          child: Image.asset(
                                            'assets/gifs/loading.gif',
                                            width: 100,
                                            height: 100,
                                          ),
                                        ));
                                  } else if (responseOb?.msgState ==
                                      MsgState.data) {
                                    updateStatus = false;
                                  }
                                  return Container(
                                    color: Colors.white,
                                  );
                                },
                              )),
                        isCreateDelivery == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: stockpickingcreateBloc
                                    .getCreateStockPickingStream(),
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
                                      MsgState.data) {}
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
                        isCreateStockMove == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: stockpickingcreateBloc
                                    .getCreateStockMoveStream(),
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
                                      MsgState.data) {}
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
                        isUpdateDeliveryStatus == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: stockpickingcreateBloc
                                    .getUpdateStockPickingStatusStream(),
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
                                    // quotationBloc.getQuotationWithIdData(
                                    //     widget.quotationId);
                                    // // stockpickingcreateBloc
                                    // //     .stockpickingUpdateStatus(
                                    // //         state: 'confirmed');
                                    // isUpdateDeliveryStatus = false;
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
                        isUpdatePickingId == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: quotationeditBloc
                                    .getUpdateQuotationPickingIdsStream(),
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
                                      MsgState.data) {}
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
                        isCallStockPicking == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream:
                                    stockpickingBloc.getStockPickingStream(),
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
                                      MsgState.data) {}
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
                        isCallStockMove == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: stockpickingBloc.getStockMoveStream(),
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
                                      MsgState.data) {}
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
                        isUpdateQtyDone == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: stockpickingcreateBloc
                                    .getUpdateQtyDoneStream(),
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
                                      MsgState.data) {}
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
                        isWaitingState == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: saleorderlineBloc
                                    .waitingproductlineListStream(),
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
                                      MsgState.data) {}
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
                        isCreateInvoice == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: invoicecreateBloc
                                    .getCallCreateInvoiceMethodStream(),
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
                                    // quotationBloc.getQuotationWithIdData(
                                    //     widget.quotationId);
                                    isCreateInvoice = false;
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
                        isCreateInvoiceLine == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: invoicelineBloc
                                    .getInvoiceLineCreateStream(),
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
                                      MsgState.data) {}
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
        },
      )),
    );
  }

  void deleteRecord() {
    if (widget.state == 'draft' || widget.state == 'cancel') {
      setState(() {
        deleteornot = 1;
      });
      Navigator.of(context).pop();
      quotationdeleteBloc.deleteQuotationData(widget.quotationId);
    } else {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                "Something Went Wrong!",
                style: TextStyle(color: Colors.red),
              ),
              content: const Text(
                  "You can not delete a sent quotation or a confirmed sales order. You must first cancel it."),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.purple),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Ok",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            );
          });
    }
  }
}
