import 'package:flutter/material.dart';
import 'package:smc_mobile/obs/response_ob.dart';

import '../../../../pages/customer_page/customer_bloc.dart';
import '../../../../utils/app_const.dart';

class CustomerDetailMB extends StatefulWidget {
  int customerId;
  int zoneId;
  CustomerDetailMB({
    Key? key,
    required this.customerId,
    required this.zoneId,
  }) : super(key: key);

  @override
  State<CustomerDetailMB> createState() => _CustomerDetailMBState();
}

class _CustomerDetailMBState extends State<CustomerDetailMB> {
  final customerBloc = CustomerBloc();

  List<dynamic> customerList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customerBloc.getCustomerList(
        name: ['id', '=', widget.customerId], zoneId: widget.zoneId);
    customerBloc.getCustomerListStream().listen(getCustomerDataListen);
  }

  void getCustomerDataListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      customerList = responseOb.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ResponseOb>(
        initialData: customerList.isNotEmpty
            ? null
            : ResponseOb(msgState: MsgState.loading),
        stream: customerBloc.getCustomerListStream(),
        builder: (context, snapshot) {
          ResponseOb? responseOb = snapshot.data;
          if (responseOb?.msgState == MsgState.error) {
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
                          customerBloc.getCustomerList(
                              name: ['id', '=', widget.customerId],
                              zoneId: widget.zoneId);
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
                          customerBloc.getCustomerList(
                              name: ['id', '=', widget.customerId],
                              zoneId: widget.zoneId);
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
                          customerBloc.getCustomerList(
                              name: ['id', '=', widget.customerId],
                              zoneId: widget.zoneId);
                        },
                        child: const Text('Try Again'))
                  ],
                )),
              );
            }
          } else if (responseOb?.msgState == MsgState.loading) {
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
          } else {
            return Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                backgroundColor: AppColors.appBarColor,
                title: Text('${customerList[0]['name']}'),
              ),
              body: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    customerList[0]['company_type'] == 'person'
                                        ? const Icon(Icons.radio_button_checked)
                                        : const Icon(Icons.radio_button_off),
                                    const Text('Individual',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 20),
                                    customerList[0]['company_type'] == 'company'
                                        ? const Icon(Icons.radio_button_checked)
                                        : const Icon(Icons.radio_button_off),
                                    const Text('Company',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text('${customerList[0]['name']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 25)),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                    '${customerList[0]['code'] == false ? '' : customerList[0]['code']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: 20)),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Delivery',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Text(
                                      ':  ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          customerList[0]['delivery'] == 'yes'
                                              ? const Icon(
                                                  Icons.radio_button_checked)
                                              : const Icon(
                                                  Icons.radio_button_off),
                                          const Text('Yes',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 20),
                                          customerList[0]['delivery'] == 'no'
                                              ? const Icon(
                                                  Icons.radio_button_checked)
                                              : const Icon(
                                                  Icons.radio_button_off),
                                          const Text('No',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Address',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Text(
                                      ':  ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: [
                                          Text(
                                            '${customerList[0]['street'] == false ? '' : customerList[0]['street']} ${customerList[0]['street2'] == false ? '' : customerList[0]['street2']} ${customerList[0]['partner_city'] == false ? '' : customerList[0]['partner_city'][1]}, ${customerList[0]['partner_township'] == false ? '' : customerList[0]['partner_township'][1]}, ${customerList[0]['state_id'] == false ? '' : customerList[0]['state_id'][1]}, ${customerList[0]['zip'] == false ? '' : customerList[0]['zip']}, ${customerList[0]['country_id'] == false ? '' : customerList[0]['country_id'][1]}.',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                        ])),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Zone',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Text(
                                      ':  ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: [
                                          Text(
                                            '${customerList[0]['zone_id'] == false ? '' : customerList[0]['zone_id'][1]}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                        ])),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Segment',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Text(
                                      ':  ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: [
                                          Text(
                                            '${customerList[0]['segment_id'] == false ? '' : customerList[0]['segment_id'][1]}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                        ])),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Phone',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Text(
                                      ':  ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: [
                                          Text(
                                            '${customerList[0]['phone'] == false ? '' : customerList[0]['phone']}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                        ])),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Mobile',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Text(
                                      ':  ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: [
                                          Text(
                                            '${customerList[0]['mobile'] == false ? '' : customerList[0]['mobile']}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                        ])),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Email',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Text(
                                      ':  ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: [
                                          Text(
                                            '${customerList[0]['email'] == false ? '' : customerList[0]['email']}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                        ])),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      width: 200,
                                      child: Text(
                                        'Website',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                    const Text(
                                      ':  ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.start,
                                            children: [
                                          Text(
                                            '${customerList[0]['website'] == false ? '' : customerList[0]['website']}',
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black),
                                          ),
                                        ])),
                                  ],
                                ),
                                // const SizedBox(height: 10),
                                // Row(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     const SizedBox(
                                //       width: 200,
                                //       child: Text(
                                //         'Quantity Available',
                                //         style: TextStyle(
                                //             fontSize: 20,
                                //             fontWeight: FontWeight.bold,
                                //             color: Colors.black),
                                //       ),
                                //     ),
                                //     const Text(
                                //       ':  ',
                                //       style: TextStyle(
                                //           fontSize: 20,
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.black),
                                //     ),
                                //     Expanded(
                                //         child: Column(
                                //             crossAxisAlignment:
                                //                 CrossAxisAlignment.start,
                                //             mainAxisAlignment:
                                //                 MainAxisAlignment.start,
                                //             children: [
                                //           Text('',
                                //               style: const TextStyle(
                                //                   color: Colors.black,
                                //                   fontSize: 18))
                                //         ])),
                                //   ],
                                // ),
                                // const SizedBox(height: 10),
                                // Row(
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     const SizedBox(
                                //       width: 200,
                                //       child: Text(
                                //         'Unit of Measure',
                                //         style: TextStyle(
                                //             fontSize: 20,
                                //             fontWeight: FontWeight.bold,
                                //             color: Colors.black),
                                //       ),
                                //     ),
                                //     const Text(
                                //       ':  ',
                                //       style: TextStyle(
                                //           fontSize: 20,
                                //           fontWeight: FontWeight.bold,
                                //           color: Colors.black),
                                //     ),
                                //     Expanded(
                                //         child: Column(
                                //             crossAxisAlignment:
                                //                 CrossAxisAlignment.start,
                                //             mainAxisAlignment:
                                //                 MainAxisAlignment.start,
                                //             children: [
                                //           Text(
                                //               '${customerList[0]['uom_id'][1]}',
                                //               style: const TextStyle(
                                //                   color: Colors.black,
                                //                   fontSize: 18))
                                //         ])),
                                //   ],
                                // ),
                                const SizedBox(height: 10),
                              ]),
                        )
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
