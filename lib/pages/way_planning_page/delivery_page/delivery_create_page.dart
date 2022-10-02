import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/response_ob.dart';
import '../../../obs/trip_plan_delivery_ob.dart';
import '../../profile_page/profile_bloc.dart';
import 'delivery_bloc.dart';

class DeliveryCreatePage extends StatefulWidget {
  int newOrEdit;
  int? neworeditTPD;
  int tripLine;
  int? tripplandeliveryId;
  int teamId;
  int assignPersonId;
  int zoneId;
  String? zoneName;
  int invoiceId;
  int orderId;
  String state;
  String invoiceStatus;
  String remark;
  DeliveryCreatePage({Key? key,
  required this.newOrEdit,
  required this.neworeditTPD,
  required this.tripLine,
  required this.tripplandeliveryId,
  required this.teamId,
  required this.assignPersonId,
  required this.zoneId,
  required this.zoneName,
  required this.invoiceId,
  required this.orderId,
  required this.state,
  required this.invoiceStatus,
  required this.remark,
  }) : super(key: key);

  @override
  State<DeliveryCreatePage> createState() => _DeliveryCreatePageState();
}

class _DeliveryCreatePageState extends State<DeliveryCreatePage> {
  final deliveryBloc = DeliveryBloc();
  final profileBloc = ProfileBloc();
  final databaseHelper = DatabaseHelper();

  bool hasNotTeam = true;
  bool hasNotassignPerson = true;
  bool hasNotZone = true;
  bool hasNotInvoiceNo = true;
  bool hasNotOrderNo = true;

  int teamId = 0;
  String teamName = '';
  List<dynamic> teamList = [];

  List<dynamic> hremployeeList = [];
  int hremployeeId = 0;
  String hremployeeName = '';
  bool hasNotHrEmployee = true;

  int zoneId = 0;
  String? zoneName = '';
  final zoneController = TextEditingController();

  int invoiceId = 0;
  String invoiceName = '';
  List<dynamic> invoiceList = [];

  int orderId = 0;
  String orderName = '';
  List<dynamic> orderList = [];

  final stateController = TextEditingController();
  final invoiceStatusController = TextEditingController();
  final remarkController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    deliveryBloc.getCRMTeamListData();
    deliveryBloc.getCRMTeamListStream().listen(getCRMTeamListListen);
    profileBloc.getHrEmployeeData();
    profileBloc.getHrEmployeeStream().listen(getHrEmployeeListListen);
    deliveryBloc.getAccountMoveListData();
    deliveryBloc.getAccountMoveListStream().listen(getAccountMoveListListen);
    deliveryBloc.getOrderListData();
    deliveryBloc.getOrderListStream().listen(getOrderListListen);
  }

  void getCRMTeamListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      teamList = responseOb.data;
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoCRMTeamList");
    }
  } // listen to get CRM Team List

  void getCRMTeamListId(String? v) {
    if (v != null) {
      setState(() {
        teamId = int.parse(v.toString().split(',')[0]);
        hasNotTeam = false;
        for (var element in teamList) {
          if (element['id'] == teamId) {
            teamName = element['name'];
            teamId = element['id'];
            zoneId = element['zone_id'] == false ? 0 : element['zone_id'][0];
            zoneController.text =
                element['zone_id'] == false ? '' : element['zone_id'][1];
            print('CRMTeamName:$teamName');
            print('CRMTeamId:$teamId');
            print('zoneName: ${zoneController.text}');
          }
        }
      });
    } else {
      hasNotTeam = true;
    }
  } // get CRM Team ListId from CRMTeamListSelection

  void setCRMTeamNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.teamId != 0) {
        for (var element in teamList) {
          if (element['id'] == widget.teamId) {
            hasNotTeam = false;
            teamId = element['id'];
            teamName = element['name'];
            zoneId = widget.zoneId;
            zoneName = widget.zoneName;
            print('teamId: $teamId');
            print('teamName: $teamName');
          }
        }
      }
    }
  }

  void getHrEmployeeListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      hremployeeList = responseOb.data;
      print('hremployee: ${hremployeeList.length}');
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoHremployeeList");
    }
  } // listen to get Hr Employee List

  void setHrEmployeeNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.assignPersonId != 0) {
        for (var element in hremployeeList) {
          if (element['id'] == widget.assignPersonId) {
            hasNotHrEmployee = false;
            hremployeeId = element['id'];
            hremployeeName = element['name'];
            print('hremployeeId: $hremployeeId');
            print('hremployeeName: $hremployeeName');
          }
        }
      }
    }
  }

  void getHrEmployeeListId(String? v) {
    if (v != null) {
      setState(() {
        hremployeeId = int.parse(v.toString().split(',')[0]);
        hasNotHrEmployee = false;
        for (var element in hremployeeList) {
          if (element['id'] == hremployeeId) {
            hremployeeName = element['name'];
            hremployeeId = element['id'];
            print('HrEmployeeName:$hremployeeName');
            print('HrEmployeeId:$hremployeeId');
          }
        }
      });
    } else {
      hasNotHrEmployee = true;
    }
  } // get HrEmployee ListId from HrEmployeeListSelection

  void getAccountMoveListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      invoiceList = responseOb.data;
      print('accountInvoice: ${invoiceList.length}');
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoaccountInvoiceList");
    }
  } // listen to get Account Invoice List

  void getAccountMoveListId(String? v) {
    if (v != null) {
      setState(() {
        invoiceId = int.parse(v.toString().split(',')[0]);
        hasNotInvoiceNo = false;
        for (var element in invoiceList) {
          if (element['id'] == invoiceId) {
            invoiceName = element['name'];
            invoiceId = element['id'];
            for (var ele in orderList) {
              if (ele['name'] == element['invoice_origin']) {
                orderId = ele['id'];
                orderName = ele['name'];
                stateController.text = ele['state'];
                invoiceStatusController.text = ele['invoice_status'];
              }
            }
            print('InvoiceName:$invoiceName');
            print('InvoiceId:$invoiceId');
          }
        }
      });
    } else {
      hasNotInvoiceNo = true;
    }
  } // get Account Move ListId from Account Move ListSelection

  void getOrderListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      orderList = responseOb.data;
      print('orderListLength: ${orderList.length}');
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoOrderList");
    }
  } // listen to get Order List

  void getOrderListId(String? v) {
    if (v != null) {
      setState(() {
        orderId = int.parse(v.toString().split(',')[0]);
        hasNotOrderNo = false;
        for (var element in orderList) {
          if (element['id'] == orderId) {
            orderName = element['name'];
            orderId = element['id'];
            stateController.text = element['state'];
            invoiceStatusController.text = element['invoice_status'];
            print('orderName:$orderName');
            print('orderId:$orderId');
          }
        }
      });
    } else {
      hasNotOrderNo = true;
    }
  } // get Order ListId from Order ListSelection

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Delivery"),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            const Text(
              "Team:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 40,
              child: StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: deliveryBloc.getCRMTeamListStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (responseOb?.msgState == MsgState.error) {
                      return const Center(
                        child: Text("Something went Wrong!"),
                      );
                    } else {
                      return DropdownSearch<String>(
                        popupItemBuilder: (context, item, isSelected) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.toString().split(',')[1]),
                                const Divider(),
                              ],
                            ),
                          );
                        },
                        showSearchBox: true,
                        showSelectedItems: true,
                        showClearButton: !hasNotTeam,
                        items: teamList
                            .map((e) => '${e['id']},${e['name']}')
                            .toList(),
                        onChanged: getCRMTeamListId,
                        selectedItem: teamName,
                      );
                    }
                  }),
            ),
            const SizedBox(height: 10),
            const Text(
              "Assign Person:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 40,
              child: StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(
                      msgState: MsgState.loading),
                  stream: profileBloc.getHrEmployeeStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (responseOb?.msgState == MsgState.error) {
                      return const Center(
                        child: Text("Something went Wrong!"),
                      );
                    } else {
                      return DropdownSearch<String>(
                        popupItemBuilder: (context, item, isSelected) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.toString().split(',')[1]),
                                const Divider(),
                              ],
                            ),
                          );
                        },
                        showSearchBox: true,
                        showSelectedItems: true,
                        showClearButton: !hasNotHrEmployee,
                        items: hremployeeList
                            .map((e) => '${e['id']},${e['name']}')
                            .toList(),
                        onChanged: getHrEmployeeListId,
                        selectedItem: hremployeeName,
                      );
                    }
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Zone:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 40,
              child: TextField(
                readOnly: true,
                controller: zoneController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Invoice No:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 40,
              child: StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(
                      msgState: MsgState.loading),
                  stream: deliveryBloc.getAccountMoveListStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (responseOb?.msgState == MsgState.error) {
                      return const Center(
                        child: Text("Something went Wrong!"),
                      );
                    } else {
                      return DropdownSearch<String>(
                        popupItemBuilder: (context, item, isSelected) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.toString().split(',')[1]),
                                const Divider(),
                              ],
                            ),
                          );
                        },
                        showSearchBox: true,
                        showSelectedItems: true,
                        showClearButton: !hasNotInvoiceNo,
                        items: invoiceList
                            .map((e) => '${e['id']},${e['name']}')
                            .toList(),
                        onChanged: getAccountMoveListId,
                        selectedItem: invoiceName,
                      );
                    }
                  }),
            ),
            const SizedBox(height: 10),
            const Text(
              "Order No:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 40,
              child: StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(
                      msgState: MsgState.loading),
                  stream: deliveryBloc.getOrderListStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (responseOb?.msgState == MsgState.error) {
                      return const Center(
                        child: Text("Something went Wrong!"),
                      );
                    } else {
                      return DropdownSearch<String>(
                        popupItemBuilder: (context, item, isSelected) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.toString().split(',')[1]),
                                const Divider(),
                              ],
                            ),
                          );
                        },
                        showSearchBox: true,
                        showSelectedItems: true,
                        showClearButton: !hasNotOrderNo,
                        items: orderList
                            .map((e) => '${e['id']},${e['name']}')
                            .toList(),
                        onChanged: getOrderListId,
                        selectedItem: orderName,
                      );
                    }
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Status:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 40,
              child: TextField(
                readOnly: true,
                controller: stateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Invoice Status:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 40,
              child: TextField(
                readOnly: true,
                controller: invoiceStatusController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Remark:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 100,
              child: TextField(
                controller: remarkController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                onPressed: () async {
                  final tripplandeliveryOb = TripPlanDeliveryOb(
                      tripline: 0,
                      teamId: teamId,
                      teamName: teamName,
                      assignPersonId: hremployeeId,
                      assignPerson: hremployeeName,
                      zoneId: zoneId,
                      zoneName: zoneController.text,
                      invoiceId: invoiceId,
                      invoiceName: invoiceName,
                      orderId: orderId,
                      orderName: orderName,
                      state: stateController.text,
                      invoiceStatus: invoiceStatusController.text,
                      remark: remarkController.text);
                  int isCreated = await databaseHelper
                      .insertTripPlanDelivery(tripplandeliveryOb);
                  if (isCreated > 0) {
                    print('Success Created a delivery');
                    Navigator.of(context).pop();
                  } else {
                    print('Error');
                  }
                },
                child: const Text(
                  "Add a Delivery",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
