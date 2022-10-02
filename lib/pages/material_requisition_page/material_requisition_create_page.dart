import 'package:dropdown_search/dropdown_search.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../dbs/database_helper.dart';
import '../../dbs/sharef.dart';
import '../../obs/product_line_ob.dart';
import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../profile_page/profile_bloc.dart';
import '../quotation_page/quotation_bloc.dart';
import '../quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import '../way_planning_page/delivery_page/delivery_bloc.dart';
import '../way_planning_page/sale_team_page/sale_team_bloc.dart';
import 'material_product_line_page/material_product_line_bloc.dart';
import 'material_product_line_page/material_product_line_create_page.dart';
import 'material_requisition_bloc.dart';
import 'material_requisition_create_bloc.dart';
import 'material_requisition_page.dart';

class MaterialRequisitionCreatePage extends StatefulWidget {
  String name;
  int neworedit;
  MaterialRequisitionCreatePage({
    Key? key,
    required this.name,
    required this.neworedit,
  }) : super(key: key);

  @override
  State<MaterialRequisitionCreatePage> createState() =>
      _MaterialRequisitionCreatePageState();
}

class _MaterialRequisitionCreatePageState
    extends State<MaterialRequisitionCreatePage> {
  final quotationBloc = QuotationBloc();
  final materialrequisitionBloc = MaterialRequisitionBloc();
  final materialrequisitioncreateBloc = MaterialRequisitionCreateBloc();
  final materialproductlineBloc = MaterialProductLineBloc();
  final saleorderlineBloc = SaleOrderLineBloc();
  final profileBloc = ProfileBloc();
  final saleteamBloc = SaleTeamBloc();
  final deliveryBloc = DeliveryBloc();
  final databaseHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  final refnoController = TextEditingController();

  int materialrequisitionId = 0;

  final scheduleddateController = TextEditingController();
  String scheduleddate = '';
  bool hasNotScheduledDate = true;

  final dateorderController = TextEditingController();
  String dateorder = '';

  final descriptionController = TextEditingController();
  bool hasNotDescription = true;

  List<dynamic> hremployeeList = [];
  int hremployeeId = 0;
  String hremployeeName = '';
  bool hasHrEmployeeData = false;
  bool hasNotHrEmployee = true;

  List<dynamic> hrdepartmentList = [];
  int hrdepartmentId = 0;
  String hrdepartmentName = '';
  bool hasHrDepartmentData = false;
  bool hasNotHrDepartment = true;

  List<dynamic> zoneList = [];
  int zoneId = 0;
  String zoneName = '';
  bool hasZoneData = false;
  bool hasNotZone = true;

  List<dynamic> invoiceId = [];
  List<dynamic> invoiceName = [];
  List<dynamic> invoiceList = [];
  bool hasInvoiceData = false;
  bool hasNotInvoice = true;

  int stocklocationId = 0;
  String stocklocationName = '';
  List<dynamic> stocklocationList = [];
  bool hasStockLocationData = false;
  bool hasNotStockLocation = true;

  List<ProductLineOb>? productlineList = [];

  bool isCreateMaterialRequisition = false;
  bool isCreateMaterialProductLine = false;

  final slidableController = SlidableController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileBloc.getHrEmployeeData();
    profileBloc.getHrEmployeeStream().listen(getHrEmployeeListen);
    saleteamBloc.getHrDeparmentListData();
    saleteamBloc.getHrDeparmentListStream().listen(getHrDepartmentListen);
    quotationBloc.getZoneListData();
    quotationBloc.getZoneListStream().listen(getZonelist);
    deliveryBloc.getAccountMoveListData();
    deliveryBloc.getAccountMoveListStream().listen(getAccountMoveListListen);
    materialrequisitionBloc.getStockLocationList();
    materialrequisitionBloc
        .getStockLocationListStream()
        .listen(getStockLocationListListen);
    materialrequisitioncreateBloc
        .getCreateMaterialRequisitionStream()
        .listen(getCreateMaterialRequisitionListen);
    materialproductlineBloc
        .getMaterialProductLineCreateStream()
        .listen(getCreateMaterialProductLineListen);
    saleorderlineBloc
        .waitingproductlineListStream()
        .listen(getproductlineListListen);
    dateorderController.text = DateTime.now().toString().split('.')[0];
    hasNotScheduledDate = false;
    scheduleddateController.text = DateTime.now().toString().split('.')[0];
  }

  void getHrEmployeeListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      hremployeeList = responseOb.data;
      hasHrEmployeeData = true;
    }
  }

  void getHrDepartmentListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      hrdepartmentList = responseOb.data;
      hasHrDepartmentData = true;
    }
  }

  void getZonelist(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      zoneList = responseOb.data;
      hasZoneData = true;
    } else if (responseOb.msgState == MsgState.error) {
      print("NoZoneList");
    }
  }

  void getAccountMoveListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      invoiceList = responseOb.data;
      hasInvoiceData = true;
    } else if (responseOb.msgState == MsgState.error) {
      print("NoaccountInvoiceList");
    }
  }

  void getStockLocationListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      stocklocationList = responseOb.data;
      hasStockLocationData = true;
    } else if (responseOb.msgState == MsgState.error) {
      print("NostocklocationList");
    }
  }

  void getHrEmployeeId(String? v) {
    if (v != null) {
      setState(() {
        hremployeeId = int.parse(v.toString().split(',')[0]);
        hasNotHrEmployee = false;
        for (var element in hremployeeList) {
          if (element['id'] == hremployeeId) {
            hremployeeName = element['name'];
            hremployeeId = element['id'];
            hrdepartmentId = element['department_id'] == false
                ? 0
                : element['department_id'][0];
            hrdepartmentName = element['department_id'] == false
                ? ''
                : element['department_id'][1];
            if (element['department_id'] != false) {
              hasNotHrDepartment = false;
            }
            print('HrEmployeeName:$hremployeeName');
            print('HrEmployeeId:$hremployeeId');
          }
        }
      });
    } else {
      hasNotHrEmployee = true;
    }
  }

  void getHrDepartmentId(String? v) {
    if (v != null) {
      setState(() {
        hrdepartmentId = int.parse(v.toString().split(',')[0]);
        hasNotHrDepartment = false;
        for (var element in hrdepartmentList) {
          if (element['id'] == hrdepartmentId) {
            hrdepartmentName = element['name'];
            hrdepartmentId = element['id'];
            print('hrdepartmentName:$hrdepartmentName');
            print('hrdepartmentId:$hrdepartmentId');
          }
        }
      });
    } else {
      hasNotHrDepartment = true;
    }
  }

  void getZoneListId(String? v) {
    if (v != null) {
      setState(() {
        zoneId = int.parse(v.toString().split(',')[0]);
        hasNotZone = false;
        for (var element in zoneList) {
          if (element['id'] == zoneId) {
            zoneName = element['name'];
            zoneId = element['id'];
            print('ZoneListName:$zoneName');
            print('ZoneListId:$zoneId');
          }
        }
      });
    } else {
      hasNotZone = true;
    }
  }

  void getAccountMoveListId(List v) {
    if (v != null) {
      setState(() {
        print('v $v');
        for (var element in v) {
          invoiceId.add(int.parse(element.toString().split(',')[0]));
        }
        hasNotInvoice = false;
        print('InvoiceId: $invoiceId');
        // for (var element in invoiceList) {
        //   if (element['id'] == invoiceId) {
        //     invoiceName = element['name'];
        //     invoiceId = element['id'];

        //     print('InvoiceName:$invoiceName');
        //     print('InvoiceId:$invoiceId');
        //   }
        // }
      });
    } else {
      hasNotInvoice = true;
    }
  }

  void getStockLocationListId(String? v) {
    if (v != null) {
      setState(() {
        stocklocationId = int.parse(v.toString().split(',')[0]);
        hasNotStockLocation = false;
        for (var element in stocklocationList) {
          if (element['id'] == stocklocationId) {
            stocklocationName = element['name'];
            stocklocationId = element['id'];
            print('stocklocationName:$stocklocationName');
            print('stocklocationId:$stocklocationId');
          }
        }
      });
    } else {
      hasNotStockLocation = true;
    }
  }

  void createMaterialRequisition() {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        isCreateMaterialRequisition = true;
      });
      materialrequisitioncreateBloc.createMaterialRequisition(
          refno: refnoController.text,
          zoneId: zoneId,
          requestPerson: hremployeeId,
          departmentId: hrdepartmentId,
          locationId: stocklocationId,
          invoiceId: invoiceId,
          priority: 'b',
          orderdate: dateorderController.text,
          scheduledDate: scheduleddateController.text,
          description: descriptionController.text);
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

  void getCreateMaterialRequisitionListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      materialrequisitionId = responseOb.data;
      setState(() {
        isCreateMaterialProductLine = true;
      });
      for (var productline in productlineList!) {
        print('enter productlineList');
        if (productline.materialproductId == 0) {
          print('materialproductId = 0');
          materialproductlineBloc.createMaterialProductLine(
              materialproductId: materialrequisitionId,
              productId: productline.productCodeId,
              productName: productline.description,
              qty: productline.quantity,
              uomId: productline.uomId);
        }
      }
      if (productlineList!.isEmpty) {
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
          return MaterialRequisitionPage();
        }), (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
      print('Create Successfully!');
    }
  }

  void getCreateMaterialProductLineListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      SharefCount.setTotal(productlineList!.length);
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Create MPL Sccess');
    }
  }

  void getproductlineListListen(ResponseOb responseOb) {
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
        return MaterialRequisitionPage();
      }), (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              await databaseHelper.deleteAllMaterialProductLine();
              await SharefCount.clearCount();
              Navigator.of(context).pop();
              return true;
            },
            child: Stack(children: [
              Scaffold(
                  backgroundColor: Colors.grey[200],
                  appBar: AppBar(
                    backgroundColor: AppColors.appBarColor,
                    title: Text(widget.neworedit == 1 ? widget.name : 'New'),
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
                          onPressed: createMaterialRequisition,
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                  body: FutureBuilder<List<ProductLineOb>>(
                      future: databaseHelper.getMaterialProductLineList(),
                      builder: (context, snapshot) {
                        productlineList = snapshot.data;
                        Widget productlineWidget = SliverToBoxAdapter(
                          child: Container(),
                        );
                        if (snapshot.hasData) {
                          productlineWidget = SliverList(
                              delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              print(
                                  'productlineListLength: ${productlineList!.length}');
                              print('MPLIDs: ${productlineList![i].id}');
                              return productlineList![i].isSelect != 1
                                  ? Container()
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Slidable(
                                          controller: slidableController,
                                          actionPane:
                                              const SlidableBehindActionPane(),
                                          actions: [
                                            IconSlideAction(
                                              color: Colors.yellow,
                                              onTap: () {},
                                              // iconWidget: const Icon(
                                              //   Icons.edit,
                                              //   size: 40,
                                              //   color: Colors.yellow,
                                              // ),
                                              iconWidget: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.edit,
                                                    size: 25,
                                                  ),
                                                  Text(
                                                    "Edit",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                          secondaryActions: [
                                            IconSlideAction(
                                              color: Colors.red,
                                              onTap: () async {
                                                await databaseHelper
                                                    .deleteMaterialProductLineManul(
                                                        productlineList![i].id);
                                                // saleorderlineDeleteList
                                                //     .add(productlineList![i].id);
                                                setState(() {});
                                              },
                                              iconWidget: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.delete,
                                                    size: 25,
                                                  ),
                                                  Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                          child: Container(
                                              // margin: const EdgeInsets.only(
                                              //     left: 8, right: 8),
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(10),
                                              decoration: const BoxDecoration(
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
                                                      Container(
                                                        width: 200,
                                                        child: const Text(
                                                          'Product Code: ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
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
                                                                  productlineList![
                                                                          i]
                                                                      .productCodeName,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18),
                                                                )
                                                              ]))
                                                    ],
                                                  ),
                                                  collapsed: Row(
                                                    children: [
                                                      Container(
                                                        width: 200,
                                                        child: const Text(
                                                          'Description: ',
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                            Text(
                                                              productlineList![
                                                                      i]
                                                                  .description,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
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
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  Text(
                                                                    productlineList![
                                                                            i]
                                                                        .description,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                ])),
                                                          ],
                                                        ),
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
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  Text(
                                                                    productlineList![
                                                                            i]
                                                                        .uomName,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                ])),
                                                          ],
                                                        ),
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
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                  Text(
                                                                    productlineList![
                                                                            i]
                                                                        .quantity,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            18),
                                                                  )
                                                                ])),
                                                          ],
                                                        ),
                                                      ]))),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    );
                            },
                            childCount: productlineList!.length,
                          ));
                        } else {
                          productlineWidget = const SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return Form(
                            key: _formKey,
                            child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    color: Colors.grey[200],
                                    child: CustomScrollView(slivers: [
                                      SliverList(
                                        delegate: SliverChildListDelegate(
                                          [
                                            const Text(
                                              "Ref No.:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Container(
                                                height: 40,
                                                color: Colors.white,
                                                child: TextField(
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  readOnly: true,
                                                  controller: refnoController,
                                                )),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              "Request Person:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Container(
                                              color: Colors.white,
                                              height: 40,
                                              child: StreamBuilder<ResponseOb>(
                                                  initialData:
                                                      hasHrEmployeeData == false
                                                          ? ResponseOb(
                                                              msgState: MsgState
                                                                  .loading)
                                                          : null,
                                                  stream: profileBloc
                                                      .getHrEmployeeStream(),
                                                  builder: (context,
                                                      AsyncSnapshot<ResponseOb>
                                                          snapshot) {
                                                    ResponseOb? responseOb =
                                                        snapshot.data;
                                                    if (responseOb?.msgState ==
                                                        MsgState.loading) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
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
                                                        // enabled: false,
                                                        popupItemBuilder:
                                                            (context, item,
                                                                isSelected) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
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
                                                        showSearchBox: true,
                                                        showSelectedItems: true,
                                                        showClearButton:
                                                            !hasNotHrEmployee,
                                                        items: hremployeeList
                                                            .map((e) =>
                                                                '${e['id']},${e['name']}')
                                                            .toList(),
                                                        onChanged:
                                                            getHrEmployeeId,
                                                        selectedItem:
                                                            hremployeeName,
                                                      );
                                                    }
                                                  }),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              "Department:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Container(
                                              color: Colors.white,
                                              height: 40,
                                              child: StreamBuilder<ResponseOb>(
                                                  initialData:
                                                      hasHrDepartmentData ==
                                                              false
                                                          ? ResponseOb(
                                                              msgState: MsgState
                                                                  .loading)
                                                          : null,
                                                  stream: saleteamBloc
                                                      .getHrDeparmentListStream(),
                                                  builder: (context,
                                                      AsyncSnapshot<ResponseOb>
                                                          snapshot) {
                                                    ResponseOb? responseOb =
                                                        snapshot.data;
                                                    if (responseOb?.msgState ==
                                                        MsgState.loading) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
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
                                                        // enabled: false,
                                                        popupItemBuilder:
                                                            (context, item,
                                                                isSelected) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
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
                                                        showSearchBox: true,
                                                        showSelectedItems: true,
                                                        showClearButton:
                                                            !hasNotHrDepartment,
                                                        items: hrdepartmentList
                                                            .map((e) =>
                                                                '${e['id']},${e['name']}')
                                                            .toList(),
                                                        onChanged:
                                                            getHrDepartmentId,
                                                        selectedItem:
                                                            hrdepartmentName,
                                                      );
                                                    }
                                                  }),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              "Zone:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Container(
                                              color: Colors.white,
                                              height: 40,
                                              child: StreamBuilder<ResponseOb>(
                                                  initialData: hasZoneData ==
                                                          false
                                                      ? ResponseOb(
                                                          msgState:
                                                              MsgState.loading)
                                                      : null,
                                                  stream: quotationBloc
                                                      .getZoneListStream(),
                                                  builder: (context,
                                                      AsyncSnapshot<ResponseOb>
                                                          snapshot) {
                                                    ResponseOb? responseOb =
                                                        snapshot.data;
                                                    if (responseOb?.msgState ==
                                                        MsgState.loading) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
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
                                                            (context, item,
                                                                isSelected) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
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
                                                        showSearchBox: true,
                                                        showSelectedItems: true,
                                                        showClearButton:
                                                            !hasNotZone,
                                                        items: zoneList
                                                            .map((e) =>
                                                                '${e['id']},${e['name']}')
                                                            .toList(),
                                                        onChanged:
                                                            getZoneListId,
                                                        selectedItem: zoneName,
                                                      );
                                                    }
                                                  }),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              "Invoice No:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Container(
                                              color: Colors.white,
                                              child: StreamBuilder<ResponseOb>(
                                                  initialData: hasInvoiceData ==
                                                          true
                                                      ? null
                                                      : ResponseOb(
                                                          msgState:
                                                              MsgState.loading),
                                                  stream: deliveryBloc
                                                      .getAccountMoveListStream(),
                                                  builder: (context,
                                                      AsyncSnapshot<ResponseOb>
                                                          snapshot) {
                                                    ResponseOb? responseOb =
                                                        snapshot.data;
                                                    if (responseOb?.msgState ==
                                                        MsgState.loading) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    } else if (responseOb
                                                            ?.msgState ==
                                                        MsgState.error) {
                                                      return const Center(
                                                        child: Text(
                                                            "Something went Wrong!"),
                                                      );
                                                    } else {
                                                      return DropdownSearch
                                                          .multiSelection(
                                                        popupItemBuilder:
                                                            (context, item,
                                                                isSelected) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
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
                                                        showSearchBox: true,
                                                        showSelectedItems: true,
                                                        showClearButton:
                                                            !hasNotInvoice,
                                                        items: invoiceList
                                                            .map((e) =>
                                                                '${e['id']},${e['name']}')
                                                            .toList(),
                                                        onChanged:
                                                            getAccountMoveListId,
                                                        // selectedItem:
                                                        //     invoiceName,
                                                      );
                                                    }
                                                  }),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              "Order Date:",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            Container(
                                                color: Colors.white,
                                                height: 40,
                                                child: TextFormField(
                                                    readOnly: true,
                                                    controller:
                                                        dateorderController,
                                                    decoration: InputDecoration(
                                                      suffixIcon: IconButton(
                                                        icon: const Icon(Icons
                                                            .arrow_drop_down),
                                                        onPressed: () async {
                                                          final DateTime?
                                                              selected =
                                                              await showDatePicker(
                                                                  context:
                                                                      context,
                                                                  initialDate:
                                                                      DateTime
                                                                          .now(),
                                                                  firstDate:
                                                                      DateTime
                                                                          .now(),
                                                                  lastDate:
                                                                      DateTime(
                                                                          2023));

                                                          if (selected !=
                                                              null) {
                                                            setState(() {
                                                              dateorder =
                                                                  '${selected.toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].split('.')[0]}';
                                                              dateorderController
                                                                      .text =
                                                                  '${selected.toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].split('.')[0]}';

                                                              print(dateorder);
                                                            });
                                                          }
                                                        },
                                                      ),
                                                      border:
                                                          OutlineInputBorder(),
                                                    ))),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "Scheduled Date*:",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: hasNotScheduledDate ==
                                                          true
                                                      ? Colors.red
                                                      : Colors.black),
                                            ),
                                            Container(
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
                                                        return 'Please select Scheduled Date';
                                                      }
                                                      return null;
                                                    },
                                                    controller:
                                                        scheduleddateController,
                                                    decoration: InputDecoration(
                                                        border:
                                                            const OutlineInputBorder(),
                                                        suffixIcon: IconButton(
                                                          icon: const Icon(Icons
                                                              .arrow_drop_down),
                                                          onPressed: () async {
                                                            final DateTime?
                                                                selected =
                                                                await showDatePicker(
                                                                    context:
                                                                        context,
                                                                    initialDate:
                                                                        DateTime
                                                                            .now(),
                                                                    firstDate:
                                                                        DateTime
                                                                            .now(),
                                                                    lastDate:
                                                                        DateTime(
                                                                            2023));

                                                            if (selected !=
                                                                null) {
                                                              setState(() {
                                                                scheduleddate =
                                                                    '${selected.toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].split('.')[0]}';
                                                                scheduleddateController
                                                                        .text =
                                                                    '${selected.toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].split('.')[0]}';
                                                                hasNotScheduledDate =
                                                                    false;
                                                                print(
                                                                    scheduleddate);
                                                              });
                                                            }
                                                          },
                                                        )))),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            const Text(
                                              "Location:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20),
                                            ),
                                            Container(
                                              color: Colors.white,
                                              height: 40,
                                              child: StreamBuilder<ResponseOb>(
                                                  initialData:
                                                      hasStockLocationData ==
                                                              true
                                                          ? null
                                                          : ResponseOb(
                                                              msgState: MsgState
                                                                  .loading),
                                                  stream: materialrequisitionBloc
                                                      .getStockLocationListStream(),
                                                  builder: (context,
                                                      AsyncSnapshot<ResponseOb>
                                                          snapshot) {
                                                    ResponseOb? responseOb =
                                                        snapshot.data;
                                                    if (responseOb?.msgState ==
                                                        MsgState.loading) {
                                                      return const Center(
                                                        child:
                                                            CircularProgressIndicator(),
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
                                                            (context, item,
                                                                isSelected) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
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
                                                        showSearchBox: true,
                                                        showSelectedItems: true,
                                                        showClearButton:
                                                            !hasNotStockLocation,
                                                        items: stocklocationList
                                                            .map((e) =>
                                                                '${e['id']},${e['name']}')
                                                            .toList(),
                                                        onChanged:
                                                            getStockLocationListId,
                                                        selectedItem:
                                                            stocklocationName,
                                                      );
                                                    }
                                                  }),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "Description*:",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      hasNotDescription == true
                                                          ? Colors.red
                                                          : Colors.black),
                                            ),
                                            Container(
                                                color: Colors.white,
                                                child: TextFormField(
                                                    minLines: 3,
                                                    maxLines: 6,
                                                    autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                    validator: (value) {
                                                      if (value == null ||
                                                          value.isEmpty) {
                                                        return 'Please Enter Description';
                                                      }
                                                      return null;
                                                    },
                                                    onChanged: (value) {
                                                      if (value.isNotEmpty) {
                                                        setState(() {
                                                          hasNotDescription =
                                                              false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          hasNotDescription =
                                                              true;
                                                        });
                                                      }
                                                    },
                                                    controller:
                                                        descriptionController,
                                                    decoration:
                                                        const InputDecoration(
                                                      border:
                                                          OutlineInputBorder(),
                                                    ))),
                                          ],
                                        ),
                                      ),
                                      const SliverToBoxAdapter(
                                        child: SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      SliverToBoxAdapter(
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          color: Colors.white,
                                          child: const Text(
                                            "Proudct Line",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20),
                                          ),
                                        ),
                                      ),
                                      const SliverToBoxAdapter(
                                        child: SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      SliverToBoxAdapter(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 130,
                                              child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    // maximumSize: Size(40, 20),
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255, 12, 41, 92),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return MaterialProductLineCreatePage();
                                                    })).then((value) =>
                                                        setState(() {}));
                                                  },
                                                  child: const Text(
                                                    "Add Product",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SliverToBoxAdapter(
                                        child: SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                      productlineWidget,
                                      const SliverToBoxAdapter(
                                        child: SizedBox(
                                          height: 30,
                                        ),
                                      ),
                                    ]))));
                      })),
              isCreateMaterialRequisition == true
                  ? StreamBuilder<ResponseOb>(
                      initialData: ResponseOb(msgState: MsgState.loading),
                      stream: materialrequisitioncreateBloc
                          .getCreateMaterialRequisitionStream(),
                      builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                        ResponseOb? responseOb = snapshot.data;
                        if (responseOb?.msgState == MsgState.loading) {
                          return Container(
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return Container(
                          color: Colors.black.withOpacity(0.5),
                        );
                      })
                  : Container(),
              isCreateMaterialProductLine == true
                  ? StreamBuilder<ResponseOb>(
                      initialData: ResponseOb(msgState: MsgState.loading),
                      stream: materialproductlineBloc
                          .getMaterialProductLineCreateStream(),
                      builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                        ResponseOb? responseOb = snapshot.data;
                        if (responseOb?.msgState == MsgState.loading) {
                          return Container(
                            color: Colors.black.withOpacity(0.5),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return Container(
                          color: Colors.black.withOpacity(0.5),
                        );
                      })
                  : Container(),
            ])));
  }
}
