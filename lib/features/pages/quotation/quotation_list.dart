import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../dbs/database_helper.dart';
import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../pages/quotation_page/quotation_bloc.dart';
import '../../../pages/quotation_page/quotation_create_page.dart';
import '../../../utils/app_const.dart';
import '../menu/menu_list.dart';
import 'quotation_create.dart';
import 'quotation_detail.dart';

class QuotationList extends StatefulWidget {
  const QuotationList({Key? key}) : super(key: key);

  @override
  State<QuotationList> createState() => _QuotationListState();
}

class _QuotationListState extends State<QuotationList> {
  final quotationBloc = QuotationBloc();
  List<dynamic> quotationList = [];

  ScrollController scrollController = ScrollController();
  final searchController = TextEditingController();
  final databaseHelper = DatabaseHelper();
  bool isScroll = false;
  bool isSearch = false;
  bool searchDone = false;
  bool closeFilter = true;
  String filterName = '';
  String totalDraft = '';
  String totalSale = '';
  String totalCancel = '';

  late double screenHeight;
  late double screenWidth;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    deleteAllDatabase();
    quotationBloc.getQuotationData(
        name: ['name', 'ilike', ''], state: ['id', 'ilike', '']);
    quotationBloc.getQuotationStream().listen(getQuotationListListen);
  }

  void deleteAllDatabase() async {
    await databaseHelper.deleteAllHrEmployeeLine();
    await databaseHelper.deleteAllHrEmployeeLineUpdate();
    await databaseHelper.deleteAllSaleOrderLine();
    await databaseHelper.deleteAllSaleOrderLineUpdate();
    await databaseHelper.deleteAllMaterialProductLine();
    await databaseHelper.deleteAllMaterialProductLineUpdate();
    await databaseHelper.deleteAllProductLineMultiSelect();
    await databaseHelper.deleteAllStockMove();
    await databaseHelper.deleteAllStockMoveUpdate();
    await databaseHelper.deleteAllSaleOrderLineMultiSelect();
    await databaseHelper.deleteAllTripPlanDelivery();
    await databaseHelper.deleteAllTripPlanDeliveryUpdate();
    await databaseHelper.deleteAllTripPlanSchedule();
    await databaseHelper.deleteAllTripPlanScheduleUpdate();
    await databaseHelper.deleteAllAccountMoveLine();
    await databaseHelper.deleteAllAccountMoveLineUpdate();
    await databaseHelper.deleteAllTaxIds();
    await SharefCount.clearCount();
  }

  void getQuotationListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      quotationList = responseOb.data;
      totalDraft = quotationList
          .where((element) => element['state'] == 'draft')
          .length
          .toString();
      totalSale = quotationList
          .where((element) => element['state'] == 'sale')
          .length
          .toString();
      totalCancel = quotationList
          .where((element) => element['state'] == 'cancel')
          .length
          .toString();
      print(
          'Draft: ${quotationList.where((element) => element['state'] == 'draft').length}');
      print(
          'Sale Order: ${quotationList.where((element) => element['state'] == 'sale').length}');
      print(
          'Cancel: ${quotationList.where((element) => element['state'] == 'cancel').length}');
      // hasAccountTaxesData = true;
    } else if (responseOb.msgState == MsgState.error) {
      print("NoaccounttaxsList");
    }
  } // listen to get Account Taxes List

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    quotationBloc.dipose();
    scrollController.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Do you want to exit?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        exit(0);
                      },
                      child: const Text('OK'))
                ],
              );
            });
        return true;
      },
      child: SafeArea(
          child: StreamBuilder<ResponseOb>(
        initialData: ResponseOb(msgState: MsgState.loading),
        stream: quotationBloc.getQuotationStream(),
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
            return Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                backgroundColor: AppColors.appBarColor,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return MenuList();
                    }));
                  },
                  icon: const Icon(Icons.menu),
                ),
                title: const Text('Quotation'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return
                              // QuotationNewPage(
                              //   quotationId: 0,
                              //   name: '',
                              //   userid: '',
                              //   customerId: [],
                              //   dateOrder: '',
                              //   validityDate: '',
                              //   currencyId: [],
                              //   exchangeRate: '',
                              //   pricelistId: [],
                              //   paymentTermId: [],
                              //   zoneId: [],
                              //   segmentId: [],
                              //   regionId: [],
                              //   newOrEdit: 2,
                              //   productlineList: [],
                              //   filter: '',
                              //   zoneFilterId: 0,
                              //   segmentFilterId: 0,
                              // );
                              QuotationCreate(
                            newOrEdit: 0,
                            quotationList: {},
                          );
                        })).then((value) {
                          quotationBloc.getQuotationData(
                              name: ['name', 'ilike', ''],
                              state: ['id', 'ilike', '']);
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight
                          ]);
                        });
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 5, left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SizedBox(
                              width: 100,
                              child: Text('Quotation Number',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 140,
                              child: Text('Create Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 140,
                              child: Text('Delivery Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 140,
                              child: Text('Expected Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 130,
                              child: Text('Customer',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 130,
                              child: Text('Salesperson',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 100,
                              child: Text('Total',
                                  textAlign: TextAlign.end,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          Expanded(
                              child: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: quotationList.length,
                        itemBuilder: (c, i) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return QuotationDetail(
                                      quotationList: quotationList[i],
                                    );
                                  })).then((value) =>
                                      quotationBloc.getQuotationData());
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${quotationList[i]['name']}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width: 140,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${quotationList[i]['create_date']}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width: 140,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${quotationList[i]['commitment_date'] == false ? '' : quotationList[i]['commitment_date']}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width: 140,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${quotationList[i]['expected_date']}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width: 130,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${quotationList[i]['partner_id'][1]}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Container(
                                        width: 130,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${quotationList[i]['user_id'] == false ? '' : quotationList[i]['user_id'][1]}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${quotationList[i]['amount_total']}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  quotationList[i]['state'] ==
                                                          'sale'
                                                      ? 'Sale Order'
                                                      : quotationList[i]
                                                                  ['state'] ==
                                                              'draft'
                                                          ? 'Quotation'
                                                          : quotationList[i][
                                                                      'state'] ==
                                                                  'sent'
                                                              ? 'Quotation Sent'
                                                              : quotationList[i]
                                                                          [
                                                                          'state'] ==
                                                                      'done'
                                                                  ? 'Locked'
                                                                  : 'Cancelled',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      )),
    );
  }
}
