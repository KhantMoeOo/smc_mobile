import 'dart:convert';
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
  List<dynamic> userid;
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
  List<SaleOrderLineOb>? saleorderlineDBList = [];
  List<dynamic> productlineList = [];
  List<dynamic> salediscountlist = [];
  List<dynamic> salepromotionlist = [];
  List<dynamic> accounttaxsList = [];
  List<dynamic> customerList = [];
  List<dynamic> stockpickingtypeList = [];
  List<dynamic> productproductList = [];
  List<dynamic> productcategoryList = [];
  List<dynamic> accountIdList = [];
  List<dynamic> userList = [];
  List<dynamic> stockmoveList = [];
  bool checkqtyresult = false;
  int deleteornot = 0;
  int stockpickingId = 0;
  double totalSOLsubtotal = 0.0;
  String statusString = '';
  List<dynamic> discountName = [];
  List<dynamic> promotionName = [];
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
  bool isCheckQty = false;

  Future<void> getproductlineListFromDB() async {
    print('Worked');
    for (var element in productlineList) {
      if (element['order_id'][0] == widget.quotationId) {
        print('ORderId?????: ${element['order_id']}');
        print('Found: ${element['id']}');
        if (element['discount_ids'].isNotEmpty) {
          discountName.clear();
          for (var sd in salediscountlist) {
            if (element['discount_ids'].contains(sd['id'])) {
              discountName.add(sd['name']);
              print('Discount Name: $discountName');
            }
          }
        } else {
          discountName = [];
        }
        if (element['promotion_ids'].isNotEmpty) {
          promotionName.clear();
          for (var sd in salepromotionlist) {
            if (element['promotion_ids'].contains(sd['id'])) {
              promotionName.add(sd['name']);
              print('Promotion Name: $promotionName');
            }
          }
        } else {
          promotionName = [];
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
            discountId: 0,
            discountName: element['discount_ids'].toString(),
            promotionId: 0,
            promotionName: element['promotion_ids'].toString(),
            saleDiscount: element['sale_discount'].toString(),
            promotionDiscount: element['promotion_discount'].toString(),
            taxId: element['tax_id'].toString(),
            taxName: '',
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
        .getSalePromotionlistListStream()
        .listen(salePromotionListen);

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
    quotationeditBloc
        .getCheckQtyAvailableStream()
        .listen(checkQtyAvailableListen);
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
      await saleorderlineBloc.getSalePromotionlistData();
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
      print('No Sale Discount List');
    }
  } // listen to get Sale Discount List

  void salePromotionListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salepromotionlist = responseOb.data;
    } else if (responseOb.msgState == MsgState.error) {
      print('No Sale Promotion List');
    }
  } // listen to get Sale Promotion List

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

  void checkQtyAvailableListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isCheckQty = false;
        checkqtyresult = responseOb.data;
      });
      if (checkqtyresult == true) {
        setState(() {
          updateStatus = true;
        });
        stockpickingcreateBloc.callActionConfirm(id: widget.quotationId);
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text('Warning!'),
                  content:
                      const Text('Not enough Remaining Stock in Warehouse'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.cyan,
                      ),
                      child: const Text('Ok',
                          style: TextStyle(color: Colors.white)),
                    )
                  ]);
            });
        print('Not enough stock');
      }
    }
  } // listen to checkQtyAvailable

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
      // if (saleorderlineDBList!.isNotEmpty) {
      //   for (var element in saleorderlineDBList!) {
      //     print('SOLDBList from delete?_______________: ${saleorderlineDBList?.length}');
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
    } else if (responseOb.msgState == MsgState.error) {
      if (responseOb.errState == ErrState.unKnownErr) {
        setState(() {
          updateStatus = false;
        });
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: const Text('Something went wrong !'),
                  content: Text('${responseOb.data}'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.cyan,
                      ),
                      child: const Text('Ok',
                          style: TextStyle(color: Colors.white)),
                    )
                  ]);
            });
      }
    }
  }

  void getStockPickingListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        stockpickingId = responseOb.data;
        isCallStockPicking = false;
        isCallStockMove = true;
      });
      stockpickingBloc.getStockMoveData(stockpickingId);
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
            if (responseOb.errState == ErrState.severErr) {
              return Scaffold(
                body: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${responseOb.data}'),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () {
                          quotationBloc
                              .getQuotationWithIdData(widget.quotationId);
                        },
                        child: const Text('Try Again'))
                  ],
                )),
              );
            } else if (responseOb.errState == ErrState.noConnection) {
              return Scaffold(
                body: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/imgs/no_internet_connection_icon.png',
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text('No Internet Connection'),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () {
                          quotationBloc
                              .getQuotationWithIdData(widget.quotationId);
                        },
                        child: const Text('Try Again'))
                  ],
                )),
              );
            } else {
              return Scaffold(
                body: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Unknown Error'),
                    const SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: () {
                          quotationBloc
                              .getQuotationWithIdData(widget.quotationId);
                        },
                        child: const Text('Try Again'))
                  ],
                )),
              );
            }
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
                    if (responseOb?.errState == ErrState.severErr) {
                      return Scaffold(
                        body: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${responseOb?.data}'),
                            const SizedBox(
                              height: 20,
                            ),
                            TextButton(
                                onPressed: () {
                                  quotationBloc.getQuotationWithIdData(
                                      widget.quotationId);
                                },
                                child: const Text('Try Again'))
                          ],
                        )),
                      );
                    } else if (responseOb?.errState == ErrState.noConnection) {
                      return Scaffold(
                        body: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/imgs/no_internet_connection_icon.png',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text('No Internet Connection'),
                            const SizedBox(
                              height: 20,
                            ),
                            TextButton(
                                onPressed: () {
                                  quotationBloc.getQuotationWithIdData(
                                      widget.quotationId);
                                },
                                child: const Text('Try Again'))
                          ],
                        )),
                      );
                    } else {
                      return Scaffold(
                        body: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Unknown Error'),
                            const SizedBox(
                              height: 20,
                            ),
                            TextButton(
                                onPressed: () {
                                  quotationBloc.getQuotationWithIdData(
                                      widget.quotationId);
                                },
                                child: const Text('Try Again'))
                          ],
                        )),
                      );
                    }
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
                                Visibility(
                                  visible: quotationList[0]['invoice_status'] ==
                                          'to invoice'
                                      ? true
                                      : false,
                                  child: TextButton(
                                      onPressed: () async {
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
                                                          accountIdList.clear();
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
                                                                        'Categ Id: ${product['categ_id'][0]}, ${categ['id']}');
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
                                  saleorderlineDBList = snapshot.data;
                                  Widget saleOrderLineWidget =
                                      SliverToBoxAdapter(
                                    child: Container(),
                                  );
                                  if (snapshot.hasData) {
                                    saleOrderLineWidget = SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                      (context, i) {
                                        print(
                                            'SOLLength------------: ${saleorderlineDBList?.length}');
                                        return saleorderlineDBList![i]
                                                        .quotationId !=
                                                    widget.quotationId &&
                                                saleorderlineDBList![i]
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
                                                            //           text: saleorderlineDBList![
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
                                                                        saleorderlineDBList![i]
                                                                            .productCodeName,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : saleorderlineDBList![i].isFOC == 1
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
                                                            //           text: saleorderlineDBList![
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
                                                                    saleorderlineDBList![
                                                                            i]
                                                                        .description,
                                                                    style: TextStyle(
                                                                        color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                            ? Colors.cyan
                                                                            : saleorderlineDBList![i].isFOC == 1
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
                                                            //           text: saleorderlineDBList![
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
                                                                        saleorderlineDBList![i]
                                                                            .description,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : saleorderlineDBList![i].isFOC == 1
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
                                                            //           text: saleorderlineDBList![
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
                                                                        saleorderlineDBList![i]
                                                                            .quantity,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : saleorderlineDBList![i].isFOC == 1
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
                                                                          saleorderlineDBList![i]
                                                                              .qtyDelivered!,
                                                                          style: TextStyle(
                                                                              color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                  ? Colors.cyan
                                                                                  : saleorderlineDBList![i].isFOC == 1
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
                                                                          saleorderlineDBList![i]
                                                                              .qtyInvoiced!,
                                                                          style: TextStyle(
                                                                              color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                  ? Colors.cyan
                                                                                  : saleorderlineDBList![i].isFOC == 1
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
                                                            //           text: saleorderlineDBList![
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
                                                                        saleorderlineDBList![i]
                                                                            .uomName,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : saleorderlineDBList![i].isFOC == 1
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
                                                            //           text: saleorderlineDBList![
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
                                                                        saleorderlineDBList![i]
                                                                            .unitPrice,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : saleorderlineDBList![i].isFOC == 1
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
                                                            //           text: saleorderlineDBList![
                                                            //                   i]
                                                            //               .discountName,
                                                            //           style: TextStyle(
                                                            //               color: quotationList[0]['state'] == 'sale'? Colors.cyan: Colors
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
                                                                Visibility(
                                                                  visible: saleorderlineDBList![i]
                                                                              .discountName ==
                                                                          '[]'
                                                                      ? false
                                                                      : true,
                                                                  child:
                                                                      Expanded(
                                                                          child:
                                                                              Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: salediscountlist
                                                                        .where((element) => json
                                                                            .decode(saleorderlineDBList![i]
                                                                                .discountName!)
                                                                            .contains(element[
                                                                                'id']))
                                                                        .map(
                                                                            (e) {
                                                                      return Container(
                                                                          padding: const EdgeInsets.all(
                                                                              3),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              border: Border.all(color: Colors.black)),
                                                                          child: Text(
                                                                            e['name'],
                                                                            style: TextStyle(
                                                                                color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                    ? Colors.cyan
                                                                                    : saleorderlineDBList![i].isFOC == 1
                                                                                        ? Colors.amber
                                                                                        : Colors.black,
                                                                                fontSize: 18),
                                                                          ));
                                                                    }).toList(),
                                                                    //         [
                                                                    //   Container(
                                                                    //     padding:
                                                                    //         const EdgeInsets.all(3),
                                                                    //     decoration:
                                                                    //         BoxDecoration(
                                                                    //       color:
                                                                    //           Colors.black,
                                                                    //       borderRadius:
                                                                    //           BorderRadius.circular(5),
                                                                    //     ),
                                                                    //     child:
                                                                    //         Text(
                                                                    //       saleorderlineDBList![i].discountName == '[]'
                                                                    //           ? ''
                                                                    //           : saleorderlineDBList![i].discountName!.substring(1, saleorderlineDBList![i].discountName!.length - 1),
                                                                    //       style: TextStyle(
                                                                    //           color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                    //               ? Colors.cyan
                                                                    //               : saleorderlineDBList![i].isFOC == 1
                                                                    //                   ? Colors.amber
                                                                    //                   : Colors.white,
                                                                    //           fontSize: 18),
                                                                    //     ),
                                                                    //   )
                                                                    // ]
                                                                  )),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
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
                                                                Visibility(
                                                                  visible: saleorderlineDBList![i]
                                                                              .promotionName ==
                                                                          '[]'
                                                                      ? false
                                                                      : true,
                                                                  child:
                                                                      Expanded(
                                                                          child:
                                                                              Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: salepromotionlist
                                                                        .where((element) => json
                                                                            .decode(saleorderlineDBList![i]
                                                                                .promotionName!)
                                                                            .contains(element[
                                                                                'id']))
                                                                        .map(
                                                                            (e) {
                                                                      return Container(
                                                                          padding: const EdgeInsets.all(
                                                                              3),
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              border: Border.all(color: Colors.black)),
                                                                          child: Text(
                                                                            e['name'],
                                                                            style: TextStyle(
                                                                                color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                    ? Colors.cyan
                                                                                    : saleorderlineDBList![i].isFOC == 1
                                                                                        ? Colors.amber
                                                                                        : Colors.black,
                                                                                fontSize: 18),
                                                                          ));
                                                                    }).toList(),
                                                                    //         [
                                                                    //   Container(
                                                                    //     padding:
                                                                    //         const EdgeInsets.all(3),
                                                                    //     decoration:
                                                                    //         BoxDecoration(
                                                                    //       color:
                                                                    //           Colors.black,
                                                                    //       borderRadius:
                                                                    //           BorderRadius.circular(5),
                                                                    //     ),
                                                                    //     child:
                                                                    //         Text(
                                                                    //       saleorderlineDBList![i].promotionName == '[]'
                                                                    //           ? ''
                                                                    //           : saleorderlineDBList![i].promotionName!.substring(1, saleorderlineDBList![i].promotionName!.length - 1),
                                                                    //       style: TextStyle(
                                                                    //           color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                    //               ? Colors.cyan
                                                                    //               : saleorderlineDBList![i].isFOC == 1
                                                                    //                   ? Colors.amber
                                                                    //                   : Colors.white,
                                                                    //           fontSize: 18),
                                                                    //     ),
                                                                    //   )
                                                                    // ]
                                                                  )),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
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
                                                                        saleorderlineDBList![i]
                                                                            .saleDiscount!,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : saleorderlineDBList![i].isFOC == 1
                                                                                    ? Colors.amber
                                                                                    : Colors.black,
                                                                            fontSize: 18),
                                                                      )
                                                                    ])),
                                                              ],
                                                            ),
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
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
                                                                        saleorderlineDBList![i]
                                                                            .promotionDiscount!,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : saleorderlineDBList![i].isFOC == 1
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
                                                            //           text: saleorderlineDBList![
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
                                                                    child:
                                                                        Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: accounttaxsList
                                                                      .where((element) => json
                                                                          .decode(saleorderlineDBList![i]
                                                                              .taxId)
                                                                          .contains(
                                                                              element['id']))
                                                                      .map((e) {
                                                                    return Container(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                                3),
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                            border: Border.all(color: Colors.black)),
                                                                        child: Text(
                                                                          e['name'],
                                                                          style: TextStyle(
                                                                              color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                  ? Colors.cyan
                                                                                  : saleorderlineDBList![i].isFOC == 1
                                                                                      ? Colors.amber
                                                                                      : Colors.black,
                                                                              fontSize: 18),
                                                                        ));
                                                                  }).toList(),
                                                                  //     [
                                                                  //   Text(
                                                                  //     saleorderlineDBList![i]
                                                                  //         .taxName,
                                                                  //     style: TextStyle(
                                                                  //         color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                  //             ? Colors.cyan
                                                                  //             : saleorderlineDBList![i].isFOC == 1
                                                                  //                 ? Colors.amber
                                                                  //                 : Colors.black,
                                                                  //         fontSize: 18),
                                                                  //   )
                                                                  // ]
                                                                )),
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
                                                                Icon(saleorderlineDBList![i]
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
                                                            //           text: saleorderlineDBList![
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
                                                                        saleorderlineDBList![i]
                                                                            .subTotal,
                                                                        style: TextStyle(
                                                                            color: quotationList[0]['state'] == 'sale' && saleorderlineDBList![i].isFOC == 0 && quotationList[0]['invoice_count'] == 0
                                                                                ? Colors.cyan
                                                                                : saleorderlineDBList![i].isFOC == 1
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
                                      childCount: saleorderlineDBList!.length,
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
                                                                                  ? TextSpan(text: '${quotationList[i]['zone_filter_id'] == false ? '' : quotationList[i]['zone_filter_id'][1]}', style: const TextStyle(color: Colors.black, fontSize: 18))
                                                                                  : quotationList[i]['customer_filter'] == 'segment'
                                                                                      ? TextSpan(text: '${quotationList[i]['seg_filter_id'][1]}', style: const TextStyle(color: Colors.black, fontSize: 18))
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
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const SizedBox(
                                                                  width: 200,
                                                                  child: Text(
                                                                    'Saleperson: ',
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
                                                                          '${quotationList[i]['user_id'] == false ? '-' : quotationList[i]['user_id'][1]}',
                                                                          style: const TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 18))
                                                                    ])),
                                                              ],
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
                                            child: Container(
                                              child: quotationList[0]
                                                          ['state'] ==
                                                      'draft'
                                                  ? Container(
                                                      width: 80,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .appBarColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: const Center(
                                                        child: Text('Quotation',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                      ),
                                                    )
                                                  : quotationList[0]['state'] ==
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
                                                          child: const Center(
                                                            child: Text(
                                                                'Quotation Sent',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white,
                                                                )),
                                                          ),
                                                        )
                                                      : quotationList[0]
                                                                  ['state'] ==
                                                              'sale'
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
                                                                    'Sale Order',
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
                                                                    'Cancelled',
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
                                            segmentFilterId: widget
                                                    .segmentFilterId.isNotEmpty
                                                ? widget.segmentFilterId[0]
                                                : 0,
                                            userzoneId: userList[0]['zone_id']);
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
                                            userzoneId: userList[0]['zone_id']);
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
                                                    style: TextButton.styleFrom(
                                                        backgroundColor:
                                                            AppColors
                                                                .appBarColor),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() {
                                                        // updateStatus = true;
                                                        isCheckQty = true;
                                                      });
                                                      quotationeditBloc
                                                          .checkQtyAvailable(
                                                              id: widget
                                                                  .quotationId);
                                                      // quotationeditBloc
                                                      //     .updateQuotationStatusData(
                                                      //         widget
                                                      //             .quotationId,
                                                      //         'sale');
                                                    },
                                                    child: const Text('Yes',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)))
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
                                  } else {
                                    if (responseOb?.errState ==
                                        ErrState.severErr) {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('${responseOb?.data}'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  stockpickingcreateBloc
                                                      .callActionConfirm(
                                                          id: widget
                                                              .quotationId);
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    } else if (responseOb?.errState ==
                                        ErrState.noConnection) {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/imgs/no_internet_connection_icon.png',
                                              width: 100,
                                              height: 100,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text(
                                                'No Internet Connection'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  stockpickingcreateBloc
                                                      .callActionConfirm(
                                                          id: widget
                                                              .quotationId);
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    } else {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Unknown Error'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  stockpickingcreateBloc
                                                      .callActionConfirm(
                                                          id: widget
                                                              .quotationId);
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    }
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
                                      MsgState.error) {
                                    if (responseOb?.errState ==
                                        ErrState.severErr) {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('${responseOb?.data}'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  stockpickingBloc
                                                      .getStockPickingData([
                                                    'sale_id',
                                                    '=',
                                                    widget.quotationId
                                                  ]);
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    } else if (responseOb?.errState ==
                                        ErrState.noConnection) {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/imgs/no_internet_connection_icon.png',
                                              width: 100,
                                              height: 100,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text(
                                                'No Internet Connection'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  stockpickingBloc
                                                      .getStockPickingData([
                                                    'sale_id',
                                                    '=',
                                                    widget.quotationId
                                                  ]);
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    } else {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Unknown Error'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  stockpickingBloc
                                                      .getStockPickingData([
                                                    'sale_id',
                                                    '=',
                                                    widget.quotationId
                                                  ]);
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    }
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
                                      MsgState.error) {
                                    if (responseOb?.errState ==
                                        ErrState.severErr) {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('${responseOb?.data}'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  stockpickingBloc
                                                      .getStockMoveData(
                                                          stockpickingId);
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    } else if (responseOb?.errState ==
                                        ErrState.noConnection) {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/imgs/no_internet_connection_icon.png',
                                              width: 100,
                                              height: 100,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text(
                                                'No Internet Connection'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  stockpickingBloc
                                                      .getStockMoveData(
                                                          stockpickingId);
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    } else {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Unknown Error'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  stockpickingBloc
                                                      .getStockMoveData(
                                                          stockpickingId);
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    }
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
                                      MsgState.error) {
                                    if (responseOb?.errState ==
                                        ErrState.severErr) {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('${responseOb?.data}'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  for (var stockmove
                                                      in stockmoveList) {
                                                    stockpickingcreateBloc
                                                        .updateQtyDoneData(
                                                            stockmove['id'],
                                                            stockmove[
                                                                'product_uom_qty']);
                                                  }
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    } else if (responseOb?.errState ==
                                        ErrState.noConnection) {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/imgs/no_internet_connection_icon.png',
                                              width: 100,
                                              height: 100,
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text(
                                                'No Internet Connection'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  for (var stockmove
                                                      in stockmoveList) {
                                                    stockpickingcreateBloc
                                                        .updateQtyDoneData(
                                                            stockmove['id'],
                                                            stockmove[
                                                                'product_uom_qty']);
                                                  }
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    } else {
                                      return Scaffold(
                                        body: Center(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text('Unknown Error'),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            TextButton(
                                                onPressed: () {
                                                  for (var stockmove
                                                      in stockmoveList) {
                                                    stockpickingcreateBloc
                                                        .updateQtyDoneData(
                                                            stockmove['id'],
                                                            stockmove[
                                                                'product_uom_qty']);
                                                  }
                                                },
                                                child: const Text('Try Again'))
                                          ],
                                        )),
                                      );
                                    }
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
                        isCheckQty == true
                            ? StreamBuilder<ResponseOb>(
                                initialData:
                                    ResponseOb(msgState: MsgState.loading),
                                stream: quotationeditBloc
                                    .getCheckQtyAvailableStream(),
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
