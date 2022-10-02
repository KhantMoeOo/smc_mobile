import 'package:flutter/material.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/trip_plan_delivery_ob.dart';

class DeliveryDetailWidget extends StatefulWidget {
  int wayplanId;
  List<dynamic> tripplandeliveryList;
  DeliveryDetailWidget({
    Key? key,
    required this.wayplanId,
    required this.tripplandeliveryList,
  }) : super(key: key);

  @override
  State<DeliveryDetailWidget> createState() => _DeliveryDetailWidgetState();
}

class _DeliveryDetailWidgetState extends State<DeliveryDetailWidget> {
  final _databaseHelper = DatabaseHelper();
  List<TripPlanDeliveryOb>? tripplandeliveryDB = [];
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<List<TripPlanDeliveryOb>>(
          future: _databaseHelper.getTripPlanDeliveryListUpdate(),
          builder: (context, snapshot) {
            Widget deliveryWidget = const SliverToBoxAdapter();
            if (snapshot.hasData) {
              tripplandeliveryDB = snapshot.data;
              deliveryWidget = SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  print('TriplineId: ${tripplandeliveryDB!.length}');
                    print('TripLine: ${tripplandeliveryDB![i].tripline}');
                    return tripplandeliveryDB![i].tripline != widget.wayplanId
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                            color: Colors.white,
                                            // borderRadius: BorderRadius.circular(10),
                                            // boxShadow: const [
                                            //   BoxShadow(
                                            //     color: Colors.black,
                                            //     offset: Offset(0, 0),
                                            //     blurRadius: 2,
                                            //   )
                                            // ]
                                            ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          text: tripplandeliveryDB![i].teamName,
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
                                          text: tripplandeliveryDB![i]
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
                                          text: tripplandeliveryDB![i].zoneName,
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
                                          text: tripplandeliveryDB![i]
                                              .invoiceName,
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
                                          text:
                                              tripplandeliveryDB![i].orderName,
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
                                          text: tripplandeliveryDB![i].state,
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
                                          text: tripplandeliveryDB![i]
                                              .invoiceStatus,
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
                                          text: tripplandeliveryDB![i].remark,
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18))
                                    ])),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                },childCount: tripplandeliveryDB!.length));
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return CustomScrollView(
              slivers: [
                deliveryWidget,
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100,),
                )
              ],
            );
          }),
    );
  }
}
