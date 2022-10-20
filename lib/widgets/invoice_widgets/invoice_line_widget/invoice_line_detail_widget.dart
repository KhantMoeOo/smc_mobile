import 'dart:typed_data';
import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/invoice_line_ob.dart';
import '../../../utils/app_const.dart';

class InvoiceLineDetailWidget extends StatefulWidget {
  List<dynamic> invoiceList;
  InvoiceLineDetailWidget({
    Key? key,
    required this.invoiceList,
  }) : super(key: key);

  @override
  State<InvoiceLineDetailWidget> createState() =>
      InvoiceLineDetailWidgetState();
}

class InvoiceLineDetailWidgetState extends State<InvoiceLineDetailWidget> {
  final databaseHelper = DatabaseHelper();
  List<InvoiceLineOb>? invoiceLineListDB = [];
  late SignatureController customerSigncontroller;
  late SignatureController authorSigncontroller;

  bool isFinishCustomerSign = false;
  bool isFinishAuthorSign = false;

  static Uint8List customersignature = Uint8List.fromList([0, 2, 5, 7]);
  static Uint8List authorizedsignature = Uint8List.fromList([0, 2, 5, 7]);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customerSigncontroller = SignatureController(
      penColor: Colors.black,
    );
    authorSigncontroller = SignatureController(
      penColor: Colors.black,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    customerSigncontroller.dispose();
    authorSigncontroller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FutureBuilder<List<InvoiceLineOb>>(
        future: databaseHelper.getAccountMoveLineListUpdate(),
        builder: (context, snapshot) {
          invoiceLineListDB = snapshot.data;
          Widget invoicelineWidget = SliverToBoxAdapter(
            child: Container(),
          );
          if (snapshot.hasData) {
            invoicelineWidget = SliverList(
              delegate: SliverChildBuilderDelegate(
                (c, i) {
                  return Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.white,
                          child: ExpandablePanel(
                            header: Row(
                              children: [
                                const SizedBox(
                                  width: 200,
                                  child: Text(
                                    'Product Code: ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            invoiceLineListDB![i]
                                                .productCodeName,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          )
                                        ]))
                              ],
                            ),
                            collapsed: Row(
                              children: [
                                const SizedBox(
                                  width: 200,
                                  child: Text(
                                    'Label: ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            invoiceLineListDB![i].label,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18),
                                          )
                                        ]))
                              ],
                            ),
                            expanded: Column(
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Label: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoiceLineListDB![i].label,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ]))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Asset Category: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoiceLineListDB![i]
                                                    .assetCategoryName,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ]))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Account: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoiceLineListDB![i]
                                                    .accountName,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ]))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Analytic Account: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoiceLineListDB![i]
                                                    .analyticAccountName,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ]))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Quantity: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoiceLineListDB![i].quantity,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ]))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'UoM: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoiceLineListDB![i].uomName,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ]))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Price: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoiceLineListDB![i].unitPrice,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ]))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Discounts: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoiceLineListDB![i]
                                                    .saleDiscount,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ]))
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Subtotal: ',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                invoiceLineListDB![i].subTotal,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              )
                                            ]))
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
                childCount: invoiceLineListDB!.length,
              ),
            );
          } else {
            invoicelineWidget = SliverToBoxAdapter(
              child: Center(
                child: Image.asset(
                  'assets/gifs/loading.gif',
                  width: 100,
                  height: 100,
                ),
              ),
            );
          }
          return CustomScrollView(
            slivers: [
              invoicelineWidget,
              const SliverToBoxAdapter(
                  child: SizedBox(
                height: 50,
              )),
              SliverToBoxAdapter(
                child: Container(
                  padding: MediaQuery.of(context).size.width > 400.0
                      ? const EdgeInsets.only(
                          left: 220, right: 20, top: 20, bottom: 20)
                      : const EdgeInsets.only(left: 10, right: 10),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      Row(children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Untaxed Amount',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ':',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                        Text(
                                            '${widget.invoiceList[0]['amount_untaxed']} K',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Taxes',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ':',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                        Text(
                                            '${widget.invoiceList[0]['amount_by_group'].isEmpty ? '0.0' : widget.invoiceList[0]['amount_by_group'][0][1]} K',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Total Discount',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ':',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                        Text(
                                            '${widget.invoiceList[0]['amount_sale_discount']} K',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 200,
                            child: Text(
                              'Total',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          const Text(
                            ':',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                Text(
                                    '${widget.invoiceList[0]['amount_total']} K',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 18))
                              ])),
                        ],
                      ),
                      const Divider(
                        thickness: 1.5,
                        color: Colors.black,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            width: 200,
                            child: Text(
                              'Amount Due',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                          ),
                          const Text(
                            ':',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                Text(
                                    '${widget.invoiceList[0]['amount_residual']} K',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 18))
                              ])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                ),
              ),
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Customer Signature',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 10),
                          isFinishCustomerSign == true
                              ? Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey)),
                                  child: Image.memory(
                                    customersignature,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey)),
                                  child: Signature(
                                    controller: customerSigncontroller,
                                    height: 200,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                          Container(
                            color: AppColors.appBarColor,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    iconSize: 36,
                                    onPressed: () async {
                                      if (customerSigncontroller.isNotEmpty &&
                                          isFinishCustomerSign == false) {
                                        customersignature =
                                            await exportCustomerSignature();
                                      }
                                      setState(() {
                                        isFinishCustomerSign =
                                            !isFinishCustomerSign;
                                      });
                                    },
                                    icon: Icon(
                                      isFinishCustomerSign == false
                                          ? Icons.check
                                          : Icons.edit,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Visibility(
                                    visible: isFinishCustomerSign == false
                                        ? true
                                        : false,
                                    child: IconButton(
                                      iconSize: 36,
                                      onPressed: () =>
                                          customerSigncontroller.clear(),
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ]),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Authorized Signature',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 10),
                          isFinishAuthorSign == true
                              ? Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey)),
                                  child: Image.memory(
                                    authorizedsignature,
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey)),
                                  child: Signature(
                                    controller: authorSigncontroller,
                                    height: 200,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                          Container(
                            color: AppColors.appBarColor,
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    iconSize: 36,
                                    onPressed: () async {
                                      if (authorSigncontroller.isNotEmpty &&
                                          isFinishAuthorSign == false) {
                                        authorizedsignature =
                                            await exportAuthorizedSignature();
                                      }
                                      setState(() {
                                        isFinishAuthorSign =
                                            !isFinishAuthorSign;
                                      });
                                    },
                                    icon: Icon(
                                      isFinishAuthorSign == false
                                          ? Icons.check
                                          : Icons.edit,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Visibility(
                                    visible: isFinishAuthorSign == false
                                        ? true
                                        : false,
                                    child: IconButton(
                                      iconSize: 36,
                                      onPressed: () =>
                                          authorSigncontroller.clear(),
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.red,
                                      ),
                                    ),
                                  )
                                ]),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<Uint8List> exportCustomerSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      points: customerSigncontroller.points,
    );
    final signature = await exportController.toPngBytes();
    exportController.dispose();
    return signature;
  }

  Future<Uint8List> exportAuthorizedSignature() async {
    final exportController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
      points: authorSigncontroller.points,
    );
    final signature = await exportController.toPngBytes();
    exportController.dispose();
    return signature;
  }
}
