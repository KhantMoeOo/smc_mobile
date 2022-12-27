import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smc_mobile/dbs/database_helper.dart';
import 'package:smc_mobile/obs/invoice_line_ob.dart';
import 'dart:ui' as ui;
import '../../../../pages/print_page/print_page.dart';
import '../../../../utils/app_const.dart';
import '../../../../widgets/invoice_widgets/invoice_line_widget/invoice_line_detail_widget.dart';

class InvoicePreview extends StatefulWidget {
  List<dynamic> invoiceList;
  String address;
  InvoicePreview({
    Key? key,
    required this.invoiceList,
    required this.address,
  }) : super(key: key);

  @override
  State<InvoicePreview> createState() => _InvoicePreviewState();
}

class _InvoicePreviewState extends State<InvoicePreview> {
  final GlobalKey _captureKey = GlobalKey();
  final databaseHelper = DatabaseHelper();

  List<InvoiceLineOb>? invoicelineListDB = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const Text('Invoice Preview'),
        actions: [
          TextButton(
              onPressed: () async {
                RenderRepaintBoundary boundary = _captureKey.currentContext!
                    .findRenderObject() as RenderRepaintBoundary;
                ui.Image image = await boundary.toImage();
                ByteData? byteData =
                    await image.toByteData(format: ui.ImageByteFormat.png);
                var pngBytes = byteData!.buffer.asUint8List();
                var bs64 = base64Encode(pngBytes);
                var bluetoothConnect = await Permission.bluetoothConnect.status;
                var bluetoothScan = await Permission.bluetoothScan.status;
                var location = await Permission.location.status;
                var bluetooth = await Permission.bluetooth.status;
                Map<Permission, PermissionStatus> statuses;
                DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
                if (Platform.isAndroid) {
                  AndroidDeviceInfo androidDeviceInfo =
                      await deviceInfoPlugin.androidInfo;
                  if (androidDeviceInfo.version.sdkInt >= 31) {
                    if (!bluetoothConnect.isGranted ||
                        !bluetoothScan.isGranted ||
                        !location.isGranted) {
                      statuses = await [
                        Permission.bluetoothConnect,
                        Permission.bluetoothScan,
                        Permission.location
                      ].request();
                    }
                    if (await Permission.bluetoothConnect.isGranted &&
                        await Permission.bluetoothScan.isGranted &&
                        await Permission.location.isGranted) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return Print(
                          invoiceImage: pngBytes,
                        );
                      }));
                    }
                  } else {
                    if (!bluetooth.isGranted || !location.isGranted) {
                      statuses = await [
                        Permission.bluetooth,
                        Permission.location
                      ].request();
                    }
                    if (await Permission.bluetooth.isGranted &&
                        await Permission.location.isGranted) {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return Print(
                          invoiceImage: pngBytes,
                        );
                      }));
                    }
                  }
                }
              },
              child: const Text('Print',
                  style: TextStyle(
                    color: Colors.white,
                  )))
        ],
      ),
      body: FutureBuilder<List<InvoiceLineOb>>(
        future: databaseHelper.getAccountMoveLineListUpdate(),
        builder: (context, snapshot) {
          invoicelineListDB = snapshot.data;
          Widget invoiceLineWidget = SliverToBoxAdapter(
            child: Container(),
          );
          if (snapshot.hasData) {
            invoiceLineWidget = SliverList(
                delegate: SliverChildBuilderDelegate((c, i) {
              return Row(
                children: [
                  Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invoicelineListDB![i].label,
                              style: const TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontSize: 18)),
                        ],
                      )),
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invoicelineListDB![i].quantity,
                              style: const TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontSize: 18)),
                        ],
                      )),
                  Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invoicelineListDB![i].uomName,
                              style: const TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontSize: 18)),
                        ],
                      )),
                  Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(invoicelineListDB![i].unitPrice,
                              style: const TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontSize: 18)),
                        ],
                      )),
                  Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(invoicelineListDB![i].subTotal,
                              style: const TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontSize: 18)),
                        ],
                      )),
                ],
              );
            }, childCount: invoicelineListDB!.length));
          } else {
            invoiceLineWidget = SliverToBoxAdapter(
              child: Center(
                child: Image.asset(
                  'assets/gifs/loading.gif',
                  width: 100,
                  height: 100,
                ),
              ),
            );
          }
          return RepaintBoundary(
            key: _captureKey,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  SliverList(
                      delegate: SliverChildListDelegate([
                    const Text('SPECIAL MANUFACTURING CO.,LTD.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'f25_bank_printer_regular',
                            fontWeight: FontWeight.bold,
                            fontSize: 25)),
                    const SizedBox(height: 10),
                    const Text('No. 399, Mya Taung Wun Gyi U Hmo Street,',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'f25_bank_printer_regular',
                            fontSize: 20)),
                    const Text('Shwe Lin Pan Industrial Zone',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'f25_bank_printer_regular',
                            fontSize: 20)),
                    const Text('Hlaing Tar Yar Township, Yangon, Myanmar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'f25_bank_printer_regular',
                            fontSize: 20)),
                    const Text('Tel: 09-977242771, 09-977848825, 09-977242784',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'f25_bank_printer_regular',
                            fontSize: 20)),
                    const SizedBox(height: 10),
                    const Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                    const Text('SALES INVOICE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'f25_bank_printer_regular',
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Customer Name',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${widget.invoiceList[0]['partner_id'][1]}',
                                    style: const TextStyle(
                                        fontFamily: 'f25_bank_printer_regular',
                                        fontSize: 18)),
                              ],
                            )),
                        // const Expanded(
                        //   child: SizedBox(),
                        // ),
                        // const Expanded(
                        //   child: SizedBox(),
                        // )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Vr. No.',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${widget.invoiceList[0]['name']}',
                                style: const TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Address',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.address,
                                    style: const TextStyle(
                                        fontFamily: 'f25_bank_printer_regular',
                                        fontSize: 18)),
                              ],
                            )),
                      ],
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Date',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${widget.invoiceList[0]['invoice_date']}',
                                style: const TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('PO No.',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('',
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Our DO No.',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('',
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Terms',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${widget.invoiceList[0]['invoice_payment_term_id'][1]}',
                                style: const TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Sales Person',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${widget.invoiceList[0]['invoice_user_id'][1]}',
                                style: const TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Page',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('',
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                    Row(
                      children: const [
                        Expanded(
                            flex: 6,
                            child: Text('Description',
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))),
                        Expanded(
                            flex: 2,
                            child: Text('Qty',
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))),
                        Expanded(
                            flex: 2,
                            child: Text('U/M',
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))),
                        Expanded(
                            flex: 3,
                            child: Text('Price\n(Ks)',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))),
                        Expanded(
                            flex: 3,
                            child: Text('Amount\n(Ks)',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))),
                      ],
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                  ])),
                  invoiceLineWidget,
                  const SliverToBoxAdapter(
                    child: Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Sub. Total',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${widget.invoiceList[0]['amount_untaxed']}',
                                style: const TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Tax @ 0 % on',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text('',
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Advance',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${widget.invoiceList[0]['amount_total']}',
                                style: const TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Discount',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                                '${widget.invoiceList[0]['amount_sale_discount']}',
                                style: const TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: SizedBox(),
                        ),
                        const Expanded(
                          child: Text('Net Due Amount',
                              style: TextStyle(
                                  fontFamily: 'f25_bank_printer_regular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                        ),
                        const Text(':   ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${widget.invoiceList[0]['amount_residual']}',
                                style: const TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.black,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notes : ',
                            style: TextStyle(
                                fontFamily: 'f25_bank_printer_regular',
                                fontSize: 18)),
                        // // const Expanded(
                        // //   child: SizedBox(),
                        // // ),
                        // // const Expanded(
                        // //   child: SizedBox(),
                        // // ),
                        // const Expanded(
                        //   child: Text('Sub. Total',
                        //       style: TextStyle(
                        //           fontFamily: 'f25_bank_printer_regular',
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 18)),
                        // ),
                        // const Text(':   ',
                        //     style: TextStyle(
                        //         fontFamily: 'f25_bank_printer_regular',
                        //         fontSize: 18)),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                                'Goods sold are neither returnable nor refundable. Otherwise a cancelation fee of 20% on purchase price will be imposed.',
                                style: TextStyle(
                                    fontFamily: 'f25_bank_printer_regular',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ]))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
