import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/trip_plan_delivery_ob.dart';
import '../../../pages/way_planning_page/delivery_page/delivery_create_page.dart';
import '../../../utils/app_const.dart';

class DeliveryCreateWidget extends StatefulWidget {
  int neworedit;
  int tripId;
  DeliveryCreateWidget({
    Key? key,
    required this.neworedit,
    required this.tripId,
  }) : super(key: key);

  @override
  State<DeliveryCreateWidget> createState() => DeliveryCreateWidgetState();
}

class DeliveryCreateWidgetState extends State<DeliveryCreateWidget> {
  static List<TripPlanDeliveryOb>? tripplandeliveryList = [];
  static List<dynamic> tripplandeliveryInt = [];
  static List<TripPlanDeliveryOb>? tripplandeliveryListUpdate = [];
  static List<dynamic> tripplandeliveryDeleteList = [];
  final databaseHelper = DatabaseHelper();
  final slidableController = SlidableController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    transferData();
  }

  Future<void> transferData() async {
    tripplandeliveryListUpdate =
        await databaseHelper.getTripPlanDeliveryListUpdate();
    for (var element in tripplandeliveryListUpdate!) {
      tripplandeliveryInt.add(element.id);
      print('TripPlanDeliveryListIDs: ${element.id}');
    }
    if (widget.neworedit == 1) {
      print('TransferData');
      print('TripPlanId: ${widget.tripId}');
      tripplandeliveryList =
          await databaseHelper.insertTable2TableTripPlanDelivery();
      print('HrEmployeeLineListLength: ${tripplandeliveryList?.length}');
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 130,
              decoration: const BoxDecoration(
                color: AppColors.appBarColor,
                // boxShadow: const[
                //   BoxShadow(
                //     offset: Offset(0,0),
                //     blurRadius: 2,
                //   )
                // ],
                // borderRadius: BorderRadius.circular(10)
              ),
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return DeliveryCreatePage(
                          newOrEdit: widget.neworedit,
                          neworeditTPD: 0,
                          tripLine: 0,
                          tripplandeliveryId: 0,
                          teamId: 0,
                          assignPersonId: 0,
                          zoneId: 0,
                          zoneName: '',
                          invoiceId: 0,
                          orderId: 0,
                          state: '',
                          invoiceStatus: '',
                          remark: '');
                    })).then((value) {
                      setState(() {});
                    });
                  },
                  child: const Text(
                    "Add a delivery",
                    style: TextStyle(color: Colors.white),
                  )),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<TripPlanDeliveryOb>>(
                future: databaseHelper.getTripPlanDeliveryList(),
                builder: (context, snapshot) {
                  tripplandeliveryList = snapshot.data;
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: tripplandeliveryList!.length,
                        itemBuilder: (context, i) {
                          print(
                              "DeliveryList: ${tripplandeliveryList!.length}");
                          print('DeliveryIDS: ${tripplandeliveryList![i].id}');
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Slidable(
                                controller: slidableController,
                                actionPane: const SlidableBehindActionPane(),
                                actions: [
                                  IconSlideAction(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return DeliveryCreatePage(
                                            newOrEdit: widget.neworedit,
                                            neworeditTPD: 1,
                                            tripLine: tripplandeliveryList![i]
                                                .tripline,
                                            tripplandeliveryId:
                                                tripplandeliveryList![i].id,
                                            teamId:
                                                tripplandeliveryList![i].teamId,
                                            assignPersonId:
                                                tripplandeliveryList![i]
                                                    .assignPersonId,
                                            zoneId:
                                                tripplandeliveryList![i].zoneId,
                                            zoneName: tripplandeliveryList![i]
                                                .zoneName,
                                            invoiceId: tripplandeliveryList![i]
                                                .invoiceId,
                                            orderId: tripplandeliveryList![i]
                                                .orderId,
                                            state:
                                                tripplandeliveryList![i].state,
                                            invoiceStatus:
                                                tripplandeliveryList![i]
                                                    .invoiceStatus,
                                            remark: tripplandeliveryList![i]
                                                .remark);
                                      })).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    color: Colors.yellow,
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
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                secondaryActions: [
                                  IconSlideAction(
                                    onTap: () async {
                                      await databaseHelper
                                          .deleteTripPlanDeliveryManual(
                                              tripplandeliveryList![i].id);
                                      tripplandeliveryDeleteList
                                          .add(tripplandeliveryList![i].id);
                                      setState(() {});
                                    },
                                    color: Colors.red,
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
                                              fontSize: 18,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                                child: Container(
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                          text: TextSpan(children: [
                                        const TextSpan(
                                          text: 'Team: ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                            text: tripplandeliveryList![i]
                                                .teamName,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                      RichText(
                                          text: TextSpan(children: [
                                        const TextSpan(
                                          text: 'Assign Person: ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                            text: tripplandeliveryList![i]
                                                .assignPerson,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                      RichText(
                                          text: TextSpan(children: [
                                        const TextSpan(
                                          text: 'Zone: ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                            text: tripplandeliveryList![i]
                                                .zoneName,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                      RichText(
                                          text: TextSpan(children: [
                                        const TextSpan(
                                          text: 'Invoice No: ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                            text: tripplandeliveryList![i]
                                                .invoiceName
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                      RichText(
                                          text: TextSpan(children: [
                                        const TextSpan(
                                          text: 'Order No: ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                            text: tripplandeliveryList![i]
                                                .orderName
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                      RichText(
                                          text: TextSpan(children: [
                                        const TextSpan(
                                          text: 'Status: ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                            text: tripplandeliveryList![i]
                                                .state
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                      RichText(
                                          text: TextSpan(children: [
                                        const TextSpan(
                                          text: 'Invoice Status: ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                            text: tripplandeliveryList![i]
                                                .invoiceStatus
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                      RichText(
                                          text: TextSpan(children: [
                                        const TextSpan(
                                          text: 'Remark: ',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        TextSpan(
                                            text: tripplandeliveryList![i]
                                                .remark
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 18))
                                      ])),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                        });
                  } else {
                    print(snapshot.hasError.toString());
                    return Center(
                      child: Image.asset(
                        'assets/gifs/loading.gif',
                        width: 100,
                        height: 100,
                      ),
                    );
                  }
                }),
          )
        ]),
      ),
    );
  }
}
