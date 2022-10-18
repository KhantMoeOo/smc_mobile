import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../../dbs/database_helper.dart';
import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../obs/sale_order_line_ob.dart';
import '../../../pages/delivery_page/delivery_bloc.dart';
import '../../../pages/delivery_page/delivery_create_bloc.dart';
import '../../../pages/delivery_page/delivery_detail_page.dart';
import '../../../pages/invoice_page/invoice_create_bloc.dart';
import '../../../pages/invoice_page/invoice_detail_page.dart';
import '../../../pages/invoice_page/invoice_line_page/invoice_line_bloc.dart';
import '../../../pages/profile_page/profile_bloc.dart';
import '../../../pages/quotation_page/quotation_bloc.dart';
import '../../../pages/quotation_page/quotation_delete_bloc.dart';
import '../../../pages/quotation_page/quotation_edit_bloc.dart';
import '../../../pages/quotation_page/quotation_page.dart';
import '../../../pages/quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import '../../../pages/way_planning_page/delivery_page/delivery_bloc.dart';
import '../../../utils/app_const.dart';
import 'quotation_list.dart';

class QuotationDetail extends StatefulWidget {
  Map<String, dynamic> quotationList;
  QuotationDetail({
    Key? key,
    required this.quotationList,
  }) : super(key: key);

  @override
  State<QuotationDetail> createState() => _QuotationDetailState();
}

class _QuotationDetailState extends State<QuotationDetail> {
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
      if (element['order_id'][0] == widget.quotationList['id']) {
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
    print('State: ${widget.quotationList['state']}');
    print('QuotationIdForm QuoDetail: ${widget.quotationList['id']}');
    print('CUstoemrId:' + widget.quotationList['partner_id'][0].toString());
    quotationBloc.getQuotationWithIdData(widget.quotationList['id']);
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
      quotationBloc.getQuotationWithIdData(widget.quotationList['id']);
    }
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      if (userList.isNotEmpty) {
        quotationBloc.getCustomerList(
          ['id', '=', quotationList[0]['partner_id'][0]],
          ['namme', 'ilike', ''],
        );
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
        quotationBloc.getQuotationWithIdData(widget.quotationList['id']);
      } else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return InvoiceDetailPage(
            invoiceId: invoiceId,
            quotationId: quotationList[0]['id'],
            neworeditInvoice: 1,
            address: customerAddress,
          );
        })).then((value) => setState(() =>
            quotationBloc.getQuotationWithIdData(widget.quotationList['id'])));
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
    } else if (responseOb.msgState == MsgState.error) {
      print('No Customer List');
    }
  } // Listen to get Customer List

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
        return QuotationListPage();
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
        return QuotationListPage();
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
    setState(() {
      if (widget.quotationList['state'] == 'sale') {
        statusString = 'Sale Order';
      } else if (widget.quotationList['state'] == 'draft') {
        statusString = 'Quotation';
      } else if (widget.quotationList['state'] == 'sent') {
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
          .getStockPickingData(['sale_id', '=', widget.quotationList['id']]);
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await databaseHelper.deleteAllSaleOrderLineUpdate();
          await databaseHelper.deleteAllTripPlanDeliveryUpdate();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return QuotationList();
          }), (route) => false);
          return true;
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
                                '${quotationList[0]['name']} (${quotationList[0]['partner_id'][1]})'),
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
                                                      child:
                                                          const Text('Cancel')),
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
                                                            if (product['id'] ==
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
                                                            .contains(false)) {
                                                          Navigator.of(context)
                                                              .pop();
                                                          showDialog(
                                                              context: context,
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
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              Colors.cyan,
                                                                        ),
                                                                        child: const Text(
                                                                            'Ok',
                                                                            style:
                                                                                TextStyle(color: Colors.white)),
                                                                      )
                                                                    ]);
                                                              });
                                                          print(
                                                              'Missing required account on accountable invoice line.');
                                                        } else {
                                                          Navigator.of(context)
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
                                                                          .quotationList[
                                                                      'id']);
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
                                                            if (product['id'] ==
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
                                                            .contains(false)) {
                                                          Navigator.of(context)
                                                              .pop();
                                                          showDialog(
                                                              context: context,
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
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        },
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              Colors.cyan,
                                                                        ),
                                                                        child: const Text(
                                                                            'Ok',
                                                                            style:
                                                                                TextStyle(color: Colors.white)),
                                                                      )
                                                                    ]);
                                                              });
                                                          print(
                                                              'Missing required account on accountable invoice line.');
                                                        } else {
                                                          Navigator.of(context)
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
                                                                          .quotationList[
                                                                      'id']);
                                                        }
                                                      },
                                                      child: const Text(
                                                          'Create and View Invoice',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)))
                                                ]);
                                          });
                                    },
                                    child: const Text('Create Invoice',
                                        style: TextStyle(color: Colors.white))),
                              ),
                              Visibility(
                                  visible:
                                      quotationList[0]['delivery_count'] > 0
                                          ? true
                                          : false,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return DeliveryDetailPage(
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
                                  visible: quotationList[0]['invoice_count'] > 0
                                      ? true
                                      : false,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return InvoiceDetailPage(
                                          invoiceId: invoiceId,
                                          quotationId: quotationList[0]['id'],
                                          neworeditInvoice: 1,
                                          address: customerAddress,
                                        );
                                      })).then((value) =>
                                          quotationBloc.getQuotationWithIdData(
                                              widget.quotationList['id']));
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
                                Widget saleOrderLineWidget = SliverToBoxAdapter(
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
                                                  widget.quotationList['id'] &&
                                              materialproductlineDBList![i]
                                                      .isSelect !=
                                                  1
                                          ? Container()
                                          : Column(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  color: Colors.white,
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 130,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  '[${materialproductlineDBList![i].productCodeName}] ${materialproductlineDBList![i].description}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15))
                                                            ]),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      SizedBox(
                                                        width: 80,
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
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15))
                                                            ]),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      SizedBox(
                                                        width: 80,
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
                                                                      .qtyDelivered!,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15))
                                                            ]),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      SizedBox(
                                                        width: 80,
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
                                                                      .qtyInvoiced!,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15))
                                                            ]),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      SizedBox(
                                                        width: 80,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  materialproductlineDBList![
                                                                          i]
                                                                      .uomName,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15))
                                                            ]),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      Container(
                                                        width: 100,
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
                                                                      .unitPrice,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15))
                                                            ]),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      SizedBox(
                                                        width: 80,
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
                                                                      .saleDiscount!,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15))
                                                            ]),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      SizedBox(
                                                        width: 100,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  materialproductlineDBList![
                                                                          i]
                                                                      .discountName!,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15))
                                                            ]),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      SizedBox(
                                                        width: 80,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  materialproductlineDBList![
                                                                          i]
                                                                      .taxName,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          15))
                                                            ]),
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      SizedBox(
                                                        width: 50,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              materialproductlineDBList![
                                                                              i]
                                                                          .isFOC! ==
                                                                      0
                                                                  ? const Icon(Icons
                                                                      .check_box_outline_blank)
                                                                  : const Icon(Icons
                                                                      .check_box),
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
                                                                      .subTotal,
                                                                  style: const TextStyle(
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
                                                                visible: quotationList[0]['state'] ==
                                                                            'sale' ||
                                                                        quotationList[0]['state'] ==
                                                                            'cancel'
                                                                    ? false
                                                                    : true,
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
                                                                visible: quotationList[0]['state'] ==
                                                                            'sale' ||
                                                                        quotationList[0]['state'] ==
                                                                            'cancel'
                                                                    ? false
                                                                    : true,
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
                                                                                        updateStatus = true;
                                                                                      });
                                                                                      stockpickingcreateBloc.callActionConfirm(id: widget.quotationList['id']);
                                                                                      // quotationeditBloc
                                                                                      //     .updateQuotationStatusData(
                                                                                      //         widget
                                                                                      //             .quotationId,
                                                                                      //         'sale');
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
                                                                  color: quotationList[0]
                                                                              [
                                                                              'state'] ==
                                                                          'draft'
                                                                      ? AppColors
                                                                          .appBarColor
                                                                      : Colors.grey[
                                                                          200],
                                                                ),
                                                                child: Text(
                                                                    'Quotation',
                                                                    style:
                                                                        TextStyle(
                                                                      color: quotationList[0]['state'] ==
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
                                                                  color: quotationList[0]
                                                                              [
                                                                              'state'] ==
                                                                          'sent'
                                                                      ? AppColors
                                                                          .appBarColor
                                                                      : Colors.grey[
                                                                          200],
                                                                ),
                                                                child: Text(
                                                                    'Quotation Sent',
                                                                    style:
                                                                        TextStyle(
                                                                      color: quotationList[0]['state'] ==
                                                                              'sent'
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
                                                                  color: quotationList[0]
                                                                              [
                                                                              'state'] ==
                                                                          'sale'
                                                                      ? AppColors
                                                                          .appBarColor
                                                                      : Colors.grey[
                                                                          200],
                                                                ),
                                                                child: Text(
                                                                    'Sale Order',
                                                                    style:
                                                                        TextStyle(
                                                                      color: quotationList[0]['state'] ==
                                                                              'sale'
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
                                                                  color: quotationList[0]
                                                                              [
                                                                              'state'] ==
                                                                          'cancel'
                                                                      ? AppColors
                                                                          .appBarColor
                                                                      : Colors.grey[
                                                                          200],
                                                                ),
                                                                child: Text(
                                                                    'Cancelled',
                                                                    style:
                                                                        TextStyle(
                                                                      color: quotationList[0]['state'] ==
                                                                              'cancel'
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
                                                          const EdgeInsets.all(
                                                              8),
                                                      color: Colors.white,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
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
                                                          Row(
                                                            children: [
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    RichText(
                                                                      text: TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                                text: '${quotationList[i]['customer_filter'] == false ? '' : quotationList[i]['customer_filter']} - ',
                                                                                style: const TextStyle(color: Colors.black, fontSize: 18)),
                                                                            quotationList[i]['customer_filter'] == 'zone'
                                                                                ? TextSpan(text: '${quotationList[0]['zone_filter_id'][1]}', style: const TextStyle(color: Colors.black, fontSize: 18))
                                                                                : quotationList[i]['customer_filter'] == 'segment'
                                                                                    ? TextSpan(text: '${quotationList[0]['seg_filter_id'][1]}', style: const TextStyle(color: Colors.black, fontSize: 18))
                                                                                    : const TextSpan(),
                                                                          ]),
                                                                    ),
                                                                  ])),
                                                              const SizedBox(
                                                                  width: 10),
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    Text(
                                                                        '${quotationList[i]['date_order']}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
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
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    Text(
                                                                        '${quotationList[i]['partner_id'][1]}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 18))
                                                                  ])),
                                                              const SizedBox(
                                                                  width: 10),
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    Text(
                                                                        '${quotationList[i]['payment_term_id'] == false ? '-' : quotationList[i]['payment_term_id'][1]}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
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
                                                              const Expanded(
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
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 18))
                                                                  ])),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    Text(
                                                                        '${quotationList[i]['pricelist_id'][1]}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
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
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    Text(
                                                                        '${quotationList[i]['currency_id'][1]}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 18))
                                                                  ])),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    Text(
                                                                        '${quotationList[i]['zone_id'] == false ? '-' : quotationList[i]['zone_id'][1]}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
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
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    Text(
                                                                        '${quotationList[i]['exchange_rate']}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
                                                                            fontSize: 18))
                                                                  ])),
                                                              const SizedBox(
                                                                  width: 10),
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    Text(
                                                                        '${quotationList[i]['segment_id'] == false ? '-' : quotationList[i]['segment_id'][1]}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
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
                                                              Expanded(
                                                                  child:
                                                                      Container()),
                                                              Expanded(
                                                                  child:
                                                                      Container()),
                                                              const SizedBox(
                                                                  width: 10),
                                                              const Expanded(
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                    Text(
                                                                        '${quotationList[i]['region_id'] == false ? '-' : quotationList[i]['region_id'][1]}',
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.black,
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
                                                          SizedBox(
                                                              width: 130,
                                                              child: Text(
                                                                  'Product',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          SizedBox(
                                                              width: 80,
                                                              child: Text(
                                                                  'Quantity',
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
                                                          SizedBox(
                                                              width: 80,
                                                              child: Text(
                                                                  'Delivered',
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
                                                          SizedBox(
                                                              width: 80,
                                                              child: Text(
                                                                  'Invoiced',
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
                                                          SizedBox(
                                                              width: 80,
                                                              child: Text('UoM',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          SizedBox(
                                                              width: 100,
                                                              child: Text(
                                                                  'Unit Price',
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
                                                          SizedBox(
                                                              width: 80,
                                                              child: Text(
                                                                  'Sale Discount',
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
                                                          SizedBox(
                                                              width: 100,
                                                              child: Text(
                                                                  'Discount',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          SizedBox(
                                                              width: 80,
                                                              child: Text(
                                                                  'Taxes',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))),
                                                          SizedBox(
                                                            width: 2,
                                                          ),
                                                          SizedBox(
                                                              width: 50,
                                                              child: Text(
                                                                  'IsFOC',
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
                                                                  'Subtotal',
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
                                                          left: 10, right: 10),
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors.white),
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
                                                                    width: 200,
                                                                    child: Text(
                                                                      'Untaxed Amount',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  const Text(
                                                                    ':',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment
                                                                              .end,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${quotationList[0]['amount_untaxed']} K',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                      'Taxes',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  const Text(
                                                                    ':',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment
                                                                              .end,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${quotationList[0]['amount_tax']} K',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                      'Total Discount',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.black),
                                                                    ),
                                                                  ),
                                                                  const Text(
                                                                    ':',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .black),
                                                                  ),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment
                                                                              .end,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                        Text(
                                                                            '${quotationList[0]['amount_discount']} K',
                                                                            style:
                                                                                const TextStyle(color: Colors.black, fontSize: 18))
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
                                                                  fontSize: 20,
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
                                                child: SizedBox(height: 150),
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
                                            'assets/gifs/three_circle_loading.gif',
                                            width: 150,
                                            height: 150,
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
                                            'assets/gifs/three_circle_loading.gif',
                                            width: 150,
                                            height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                    );
                                  } else if (responseOb?.msgState ==
                                      MsgState.data) {}
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                    );
                                  } else if (responseOb?.msgState ==
                                      MsgState.data) {}
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
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
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                    );
                                  } else if (responseOb?.msgState ==
                                      MsgState.data) {}
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                    );
                                  } else if (responseOb?.msgState ==
                                      MsgState.data) {}
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                    );
                                  } else if (responseOb?.msgState ==
                                      MsgState.data) {}
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                    );
                                  } else if (responseOb?.msgState ==
                                      MsgState.data) {}
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                                    );
                                  } else if (responseOb?.msgState ==
                                      MsgState.data) {}
                                  return Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: Center(
                                      child: Image.asset(
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
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
                                        'assets/gifs/three_circle_loading.gif',
                                        width: 150,
                                        height: 150,
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
                                          'assets/gifs/three_circle_loading.gif',
                                          width: 150,
                                          height: 150,
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

  void deleteRecord() {
    if (widget.quotationList['state'] == 'draft' ||
        widget.quotationList['state'] == 'cancel') {
      setState(() {
        deleteornot = 1;
      });
      Navigator.of(context).pop();
      quotationdeleteBloc.deleteQuotationData(widget.quotationList['id']);
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
