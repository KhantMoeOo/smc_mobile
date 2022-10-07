import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../dbs/database_helper.dart';
import '../../obs/invoice_line_ob.dart';
import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../../widgets/invoice_widgets/invoice_line_widget/invoice_line_detail_widget.dart';
import '../print_page/print_page.dart';
import 'invoice_bloc.dart';
import 'invoice_create_page.dart';
import 'invoice_edit_bloc.dart';
import 'invoice_line_page/invoice_line_bloc.dart';

class InvoiceDetailPage extends StatefulWidget {
  int invoiceId;
  int quotationId;
  int neworeditInvoice;
  String address;
  InvoiceDetailPage({
    Key? key,
    required this.invoiceId,
    required this.quotationId,
    required this.neworeditInvoice,
    required this.address,
  }) : super(key: key);

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage>
    with SingleTickerProviderStateMixin {
  final invoiceBloc = InvoiceBloc();
  final invoicelineBloc = InvoiceLineBloc();
  final invoiceeditBloc = InvoiceEditBloc();
  final databaseHelper = DatabaseHelper();
  final isDialOpen = ValueNotifier(false);
  late TabController _tabController;
  List<dynamic> invoiceList = [];
  List<dynamic> invoiceLineList = [];
  List<InvoiceLineOb>? invoiceLineListDB = [];
  bool updateStatus = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    print('invoiceId: ${widget.invoiceId}');
    print('quotationId: ${widget.quotationId}');
    if (widget.neworeditInvoice == 1) {
      invoiceBloc.getInvoiceData(
          ['line_ids.sale_line_ids.order_id', '=', widget.quotationId]);
    } else {
      invoiceBloc.getInvoiceData(['id', '=', widget.invoiceId]);
    }
    invoiceeditBloc.getCallActionPostStream().listen(getCallActionPostListen);
    invoiceBloc.getInvoiceStream().listen(getInvoiceListListen);
    invoicelineBloc.getInvoiceLineStream().listen(getInvoiceLineListListen);
  }

  void getCallActionPostListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      invoiceBloc.getInvoiceData(
          ['line_ids.sale_line_ids.order_id', '=', widget.quotationId]);
      setState(() {
        updateStatus = false;
      });
    }
  }

  void getInvoiceListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      invoiceList = responseOb.data;
      invoicelineBloc
          .getInvoiceLineData(['move_id', '=', invoiceList[0]['id']]);
    } else if (responseOb.msgState == MsgState.error) {
      print('No Invoice List');
    }
  } // get Invoice List Listen

  void getInvoiceLineListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      invoiceLineList = responseOb.data;
      getInvoiceLineListDB();
    } else if (responseOb.msgState == MsgState.error) {
      print('No Invoice Line List');
    }
  } // get Invoice line List Listen

  Future<void> getInvoiceLineListDB() async {
    for (var element in invoiceLineList) {
      if (element['exclude_from_invoice_tab'] == false) {
        final invoicelineOb = InvoiceLineOb(
            productCodeName:
                element['product_id'] == false ? '' : element['product_id'][1],
            productCodeId:
                element['product_id'] == false ? 0 : element['product_id'][0],
            label: element['name'] == false ? '' : element['name'],
            assetCategoryId: element['asset_category_id'] == false
                ? 0
                : element['asset_category_id'][0],
            assetCategoryName: element['asset_category_id'] == false
                ? ''
                : element['asset_category_id'][1],
            accountId:
                element['account_id'] == false ? 0 : element['account_id'][0],
            accountName:
                element['account_id'] == false ? '' : element['account_id'][1],
            quantity: element['quantity'].toString(),
            uomName: element['product_uom_id'] == false
                ? ''
                : element['product_uom_id'][1],
            uomId: element['product_uom_id'] == false
                ? 0
                : element['product_uom_id'][0],
            unitPrice: element['price_unit'].toString(),
            analyticAccountId: element['analytic_account_id'] == false
                ? 0
                : element['analytic_account_id'][0],
            analyticAccountName: element['analytic_account_id'] == false
                ? ''
                : element['analytic_account_id'][1],
            saleDiscount: element['sale_discount'].toString(),
            subTotal: element['price_subtotal'].toString());
        if (element['tax_ids'].isNotEmpty) {
          for (var taxIds in element['tax_ids']) {
            final taxesOb = TaxesOb(
              lineId: element['id'],
              taxId: taxIds,
            );
            await databaseHelper.insertTaxIDs(taxesOb);
          }
        }
        await databaseHelper.insertaccountmovelineupdate(invoicelineOb);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    invoiceBloc.dispose();
    invoiceeditBloc.dispose();
    invoicelineBloc.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (isDialOpen.value) {
            isDialOpen.value = false;
            return false;
          } else {
            await databaseHelper.deleteAllAccountMoveLine();
            await databaseHelper.deleteAllAccountMoveLineUpdate();
            await databaseHelper.deleteAllTaxIds();
            return true;
          }
        },
        child: StreamBuilder<ResponseOb>(
            initialData: ResponseOb(msgState: MsgState.loading),
            stream: invoiceBloc.getInvoiceStream(),
            builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
              ResponseOb? responseOb = snapshot.data;
              if (responseOb?.msgState == MsgState.loading) {
                return Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ));
              } else if (responseOb?.msgState == MsgState.error) {
                return const Center(child: Text('Error'));
              } else {
                return Stack(
                  children: [
                    Scaffold(
                        backgroundColor: Colors.grey[200],
                        appBar: AppBar(
                          backgroundColor: AppColors.appBarColor,
                          title: Text(
                              '${invoiceList[0]['name'] == '/' ? 'Draft Invoice (* ${invoiceList[0]['id']})' : invoiceList[0]['name']}'),
                          actions: [
                            Visibility(
                              visible: true,
                              child: TextButton(
                                  onPressed: () async {
                                    // var bluetoothScanstatus =
                                    //         await Permission.bluetoothScan.status;
                                    //     var bluetoothAdvertise = await Permission
                                    //         .bluetoothAdvertise.status;
                                    //     var bluetoothConnect = await Permission
                                    //         .bluetoothConnect.status;
                                    //     if (!bluetoothScanstatus.isGranted) {
                                    //       await Permission.bluetoothScan.request();
                                    //     }
                                    //     if (!bluetoothAdvertise.isGranted) {
                                    //       await Permission.bluetoothAdvertise
                                    //           .request();
                                    //     }
                                    //     if (!bluetoothConnect.isGranted) {
                                    //       await Permission.bluetoothConnect
                                    //           .request();
                                    //     }
                                    //     if (await Permission
                                    //             .bluetoothScan.isGranted &&
                                    //         await Permission
                                    //             .bluetoothAdvertise.isGranted &&
                                    //         await Permission
                                    //             .bluetoothConnect.isGranted) {
                                    //       Navigator.of(context).push(
                                    //           MaterialPageRoute(builder: (context) {
                                    //         return Print(
                                    //           productlineList:
                                    //               invoiceLineListDB!,
                                    //           orderId: widget.quotationId.toString(),
                                    //           customerName: invoiceList[0]['partner_id'][0],
                                    //           dateorder: quotationList[0]
                                    //               ['date_order'],
                                    //           amountUntaxed: quotationList[0]
                                    //                   ['amount_untaxed']
                                    //               .toString(),
                                    //         );
                                    //       }));
                                    //     }
                                    var bluetoothConnect = await Permission
                                        .bluetoothConnect.status;
                                    var bluetoothScan =
                                        await Permission.bluetoothScan.status;
                                    var location =
                                        await Permission.location.status;
                                    var bluetooth =
                                        await Permission.bluetooth.status;
                                    Map<Permission, PermissionStatus> statuses;
                                    DeviceInfoPlugin deviceInfoPlugin =
                                        DeviceInfoPlugin();
                                    if (Platform.isAndroid) {
                                      AndroidDeviceInfo androidDeviceInfo =
                                          await deviceInfoPlugin.androidInfo;
                                      if (androidDeviceInfo.version.sdkInt >=
                                          31) {
                                        if (!bluetoothConnect.isGranted ||
                                            !bluetoothScan.isGranted ||
                                            !location.isGranted) {
                                          statuses = await [
                                            Permission.bluetoothConnect,
                                            Permission.bluetoothScan,
                                            Permission.location
                                          ].request();
                                        }
                                        if (await Permission
                                                .bluetoothConnect.isGranted &&
                                            await Permission
                                                .bluetoothScan.isGranted &&
                                            await Permission
                                                .location.isGranted) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return Print(
                                              customerSign:
                                                  InvoiceLineDetailWidgetState
                                                      .customersignature,
                                              authorSign:
                                                  InvoiceLineDetailWidgetState
                                                      .authorizedsignature,
                                              orderId:
                                                  widget.quotationId.toString(),
                                              customerName: invoiceList[0]
                                                  ['partner_id'][1],
                                              address: widget.address,
                                              vrno: invoiceList[0]['name'],
                                              terms: invoiceList[0][
                                                          'invoice_payment_term_id'] ==
                                                      false
                                                  ? ''
                                                  : invoiceList[0][
                                                      'invoice_payment_term_id'][1],
                                              saleperson: invoiceList[0]
                                                  ['invoice_user_id'][1],
                                              invoicedate: invoiceList[0]
                                                  ['invoice_date'],
                                            );
                                          }));
                                        }
                                      } else {
                                        if (!bluetooth.isGranted ||
                                            !location.isGranted) {
                                          statuses = await [
                                            Permission.bluetooth,
                                            Permission.location
                                          ].request();
                                        }
                                        if (await Permission
                                                .bluetooth.isGranted &&
                                            await Permission
                                                .location.isGranted) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return Print(
                                              authorSign:
                                                  InvoiceLineDetailWidgetState
                                                      .authorizedsignature,
                                              customerSign:
                                                  InvoiceLineDetailWidgetState
                                                      .customersignature,
                                              orderId:
                                                  widget.quotationId.toString(),
                                              customerName: invoiceList[0]
                                                  ['partner_id'][1],
                                              address: widget.address,
                                              vrno: invoiceList[0]['name'],
                                              terms: invoiceList[0][
                                                          'invoice_payment_term_id'] ==
                                                      false
                                                  ? ''
                                                  : invoiceList[0]
                                                      ['invoice_user_id'][1],
                                              saleperson: invoiceList[0][
                                                  'invoice_payment_term_id'][1],
                                              invoicedate: invoiceList[0]
                                                  ['invoice_date'],
                                            );
                                          }));
                                        }
                                      }
                                    }
                                    // Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                    //   return InvoiceCreatePage(
                                    //     createInvoiceWithId: 1,
                                    //     quotationId: quotationList[0]['id'],
                                    //     customerId: quotationList[0]['partner_id'][0],
                                    //     paymentTermsId: quotationList[0]['payment_term_id'] == false ? 0: quotationList[0]['payment_term_id'][0],
                                    //     currencyId: quotationList[0]['currency_id'] == false ? 0: quotationList[0]['currency_id'][0],
                                    //   );
                                    // }));
                                  },
                                  child: const Text(
                                    'Invoice Print',
                                    style: TextStyle(color: Colors.white),
                                  )),
                            )
                          ],
                        ),
                        body: Stack(
                          children: [
                            CustomScrollView(slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.all(8),
                                sliver: SliverList(
                                    delegate: SliverChildListDelegate([
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    color: const Color(0xFFFFFFFF),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 70,
                                        ),
                                        Text(
                                            '${invoiceList[0]['name'] == '/' ? 'Draft Invoice' : invoiceList[0]['name']}',
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
                                                'Customer: ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                  Text(
                                                      '${invoiceList[0]['partner_id'][1]}',
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
                                                'Reference: ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                  Text(
                                                      '${invoiceList[0]['ref']}',
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
                                                'Invoice Date: ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                  Text(
                                                      '${invoiceList[0]['invoice_date'] == false ? '' : invoiceList[0]['invoice_date']}',
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
                                                'Payment Terms: ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                  Text(
                                                      '${invoiceList[0]['invoice_payment_term_id'] == false ? '' : invoiceList[0]['invoice_payment_term_id'][1]}',
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
                                                'Journal: ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                  Text(
                                                      '${invoiceList[0]['journal_id'][1]}',
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
                                                'Currency: ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                  Text(
                                                      '${invoiceList[0]['currency_id'][1]}',
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
                                                'Exchange Rate: ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                            ),
                                            Expanded(
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                  Text(
                                                      '${invoiceList[0]['exchange_rate']}',
                                                      style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18))
                                                ])),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  )
                                ])),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 20),
                              ),
                              SliverFillRemaining(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      decoration: const BoxDecoration(
                                        color: AppColors.appBarColor,
                                      ),
                                      child: const Text('Invoice Lines',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20)),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                    child: InvoiceLineDetailWidget(
                                      invoiceList: invoiceList,
                                    ),
                                  ),
                                ],
                              )),
                            ]),
                            Padding(
                              padding: const EdgeInsets.only(top: 0, right: 10),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  // width: 150,
                                  // height: 60,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    // color: AppColors.appBarColor,
                                  ),
                                  child: MediaQuery.of(context).size.width >
                                          400.0
                                      ? SpeedDial(
                                          buttonSize: 80,
                                          childrenButtonSize: 100,
                                          backgroundColor: Colors.transparent,
                                          elevation: 0.0,
                                          activeChild: const Icon(
                                            Icons.close,
                                            color: AppColors.appBarColor,
                                          ),
                                          child: invoiceList[0]['state'] ==
                                                  'draft'
                                              ? Container(
                                                  width: 80,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.appBarColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Center(
                                                    child: Text('Draft',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 10)),
                                                  ),
                                                )
                                              : invoiceList[0]['state'] ==
                                                      'posted'
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
                                                        child: Text('Posted',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 10)),
                                                      ),
                                                    )
                                                  : Container(
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
                                                        child: Text('Cancelled',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 10)),
                                                      ),
                                                    ),
                                          spaceBetweenChildren: 5,
                                          direction: SpeedDialDirection.left,
                                          renderOverlay: false,
                                          children: [
                                              SpeedDialChild(
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0.0,
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                      border:
                                                          Border.all(width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: invoiceList[0]
                                                                  ['state'] ==
                                                              'cancel'
                                                          ? AppColors
                                                              .appBarColor
                                                          : Colors.white),
                                                  child: Center(
                                                    child: Text(
                                                      "Cancelled",
                                                      style: TextStyle(
                                                          color: invoiceList[0][
                                                                      'state'] ==
                                                                  'cancel'
                                                              ? Colors.white
                                                              : Colors.grey,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SpeedDialChild(
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0.0,
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                      border:
                                                          Border.all(width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: invoiceList[0]
                                                                  ['state'] ==
                                                              'posted'
                                                          ? AppColors
                                                              .appBarColor
                                                          : Colors.white),
                                                  child: Center(
                                                    child: Text(
                                                      "Posted",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: invoiceList[0][
                                                                      'state'] ==
                                                                  'posted'
                                                              ? Colors.white
                                                              : Colors.grey,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SpeedDialChild(
                                                backgroundColor:
                                                    Colors.transparent,
                                                elevation: 0.0,
                                                child: Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                      border:
                                                          Border.all(width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: invoiceList[0]
                                                                  ['state'] ==
                                                              'draft'
                                                          ? AppColors
                                                              .appBarColor
                                                          : Colors.white),
                                                  child: Center(
                                                    child: Text(
                                                      "Draft",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          color: invoiceList[0][
                                                                      'state'] ==
                                                                  'draft'
                                                              ? Colors.white
                                                              : Colors.grey,
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ])
                                      : Container(
                                          child: invoiceList[0]['state'] ==
                                                  'draft'
                                              ? Container(
                                                  width: 80,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.appBarColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Center(
                                                    child: Text('Draft',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                        )),
                                                  ),
                                                )
                                              : invoiceList[0]['state'] ==
                                                      'posted'
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
                                                        child: Text('Posted',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                      ),
                                                    )
                                                  : Container(
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
                                                        child: Text('Cancelled',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 15,
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
                        ),
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
                                visible: invoiceList[0]['state'] == 'posted'
                                    ? false
                                    : true,
                                onTap: () {},
                                child: const Icon(Icons.edit),
                                label: 'Edit',
                              ),
                              SpeedDialChild(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return InvoiceCreatePage(
                                        createInvoiceWithId: 0,
                                        quotationId: 0,
                                        customerId: 0,
                                        paymentTermsId: 0,
                                        currencyId: 0);
                                  }));
                                },
                                child: const Icon(Icons.add),
                                label: 'Create',
                              ),
                              SpeedDialChild(
                                visible: invoiceList[0]['state'] == 'posted'
                                    ? false
                                    : true,
                                onTap: () {},
                                child: const Icon(Icons.delete_forever),
                                label: 'Delete',
                              ),
                              SpeedDialChild(
                                visible: invoiceList[0]['state'] == 'posted'
                                    ? false
                                    : true,
                                onTap: () async {
                                  setState(() {
                                    updateStatus = true;
                                  });
                                  invoiceeditBloc
                                      .callactionpost(invoiceList[0]['id']);
                                  await databaseHelper
                                      .deleteAllAccountMoveLine();
                                  await databaseHelper
                                      .deleteAllAccountMoveLineUpdate();
                                  await databaseHelper.deleteAllTaxIds();
                                },
                                child: const Icon(Icons.upload_outlined),
                                label: 'Post',
                              )
                            ])),
                    updateStatus == false
                        ? Container()
                        : Positioned(
                            child: StreamBuilder<ResponseOb>(
                            initialData: ResponseOb(msgState: MsgState.loading),
                            stream: invoiceeditBloc.getCallActionPostStream(),
                            builder:
                                (context, AsyncSnapshot<ResponseOb> snapshot) {
                              ResponseOb? responseOb = snapshot.data;
                              if (responseOb?.msgState == MsgState.loading) {
                                return Container(
                                    color: Colors.white,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ));
                              } else if (responseOb?.msgState ==
                                  MsgState.data) {}
                              return Container(
                                color: Colors.white,
                              );
                            },
                          ))
                  ],
                );
              }
            }),
      ),
    );
  }
}
