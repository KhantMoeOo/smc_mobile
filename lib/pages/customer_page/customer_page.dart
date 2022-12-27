import 'dart:io';

import 'package:flutter/material.dart';

import '../../obs/response_ob.dart';
import '../../widgets/customer_widgets/customer_card_widget.dart';
import '../../widgets/drawer_widget.dart';
import 'customer_bloc.dart';
import 'customer_create_page.dart';

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({Key? key}) : super(key: key);

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  final customerBloc = CustomerBloc();
  List<dynamic> customerList = [];
  final customerSearchController = TextEditingController();
  bool isSearch = false;
  bool searchDone = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    customerBloc.getCustomerList(name: ['name', 'ilike', '']);
  }

  void getCustomerListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      customerList = responseOb.data;
    } else if (responseOb.msgState == MsgState.error) {
      print('Get Customer List Failed');
    }
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
          initialData: customerList.isNotEmpty
              ? null
              : ResponseOb(msgState: MsgState.loading),
          stream: customerBloc.getCustomerListStream(),
          builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
            ResponseOb? responseOb = snapshot.data;
            if (responseOb?.msgState == MsgState.error) {
              return const Center(
                child: Text('Error'),
              );
            } else if (responseOb?.msgState == MsgState.data) {
              customerList = responseOb!.data;
              return Scaffold(
                  backgroundColor: Colors.grey[200],
                  drawer: const DrawerWidget(),
                  appBar: AppBar(
                    backgroundColor: Color.fromARGB(255, 12, 41, 92),
                    title: const Text("Customers"),
                  ),
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 10, bottom: 10),
                        child: SizedBox(
                          height: 50,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  readOnly: searchDone,
                                  controller: customerSearchController,
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        isSearch = true;
                                      });
                                    } else {
                                      setState(() {
                                        isSearch = false;
                                      });
                                    }
                                  },
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          if (searchDone == true) {
                                            setState(() {
                                              customerSearchController.clear();
                                              searchDone = false;
                                              customerBloc.getCustomerList(
                                                  name: ['name', 'ilike', '']);
                                            });
                                          } else {
                                            setState(() {
                                              searchDone = true;
                                              isSearch = false;
                                              customerBloc
                                                  .getCustomerList(name: [
                                                'name',
                                                'ilike',
                                                customerSearchController.text
                                              ]);
                                            });
                                          }
                                        },
                                        icon: searchDone == true
                                            ? const Icon(Icons.close)
                                            : const Icon(Icons.search),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.green,
                                  ),
                                  width: 60,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return CustomerCreatePage();
                                      })).then((value) {
                                        setState(() {
                                          customerBloc.getCustomerList(name: [
                                            'name',
                                            'ilike',
                                            customerSearchController.text
                                          ]);
                                        });
                                      });
                                    },
                                    child: const Text("Create",
                                        style: TextStyle(
                                          color: Colors.white,
                                        )),
                                  )),
                            ],
                          ),
                        ),
                      ),
                      customerList.isEmpty
                          ? const Center(
                              child: Text('No Data'),
                            )
                          : Expanded(
                              child: Stack(
                                children: [
                                  ListView.builder(
                                      // controller: customerSearchController,
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      itemCount: customerList.length,
                                      itemBuilder: (context, i) {
                                        return CustomerCardWidget(
                                          customerId: customerList[i]['id'],
                                          customerName: customerList[i]['name'],
                                          code: customerList[i]['code'] == false
                                              ? ''
                                              : customerList[i]['code'],
                                          address: customerList[i][
                                                      'contact_address_complete'] ==
                                                  false
                                              ? ''
                                              : customerList[i]
                                                  ['contact_address_complete'],
                                          companyType: customerList[i]
                                              ['company_type'],
                                          zoneId: 0,
                                        );
                                      }),
                                  Visibility(
                                    visible: isSearch,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      margin: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey[200],
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black,
                                              blurRadius: 2,
                                              offset: Offset(0, 0),
                                            )
                                          ]),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            isSearch = false;
                                                            searchDone = true;
                                                            customerBloc
                                                                .getCustomerList(
                                                                    name: [
                                                                  'name',
                                                                  'ilike',
                                                                  customerSearchController
                                                                      .text
                                                                ]);
                                                          });
                                                        },
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          height: 50,
                                                          child: RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                const TextSpan(
                                                                    text:
                                                                        "Search Name for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: customerSearchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
                                                              ])),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  thickness: 1.5,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            isSearch = false;
                                                            searchDone = true;
                                                            customerBloc
                                                                .getCustomerList(
                                                                    name: [
                                                                  'email',
                                                                  'ilike',
                                                                  customerSearchController
                                                                      .text
                                                                ]);
                                                          });
                                                        },
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          height: 50,
                                                          child: RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                const TextSpan(
                                                                    text:
                                                                        "Search Email for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: customerSearchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
                                                              ])),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  thickness: 1.5,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          isSearch = false;
                                                          searchDone = true;
                                                          customerBloc
                                                              .getCustomerList(
                                                            name: [
                                                              'phone',
                                                              'ilike',
                                                              customerSearchController
                                                                  .text
                                                            ],
                                                          );
                                                        },
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          height: 50,
                                                          child: RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                const TextSpan(
                                                                    text:
                                                                        "Search Phone for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: customerSearchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
                                                              ])),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  thickness: 1.5,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          isSearch = false;
                                                          searchDone = true;
                                                          customerBloc
                                                              .getCustomerList(
                                                                  name: [
                                                                'category_id',
                                                                'ilike',
                                                                customerSearchController
                                                                    .text
                                                              ]);
                                                        },
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          height: 50,
                                                          child: RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                const TextSpan(
                                                                    text:
                                                                        "Search Tags for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: customerSearchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
                                                              ])),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  thickness: 1.5,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () {
                                                          isSearch = false;
                                                          searchDone = true;
                                                          customerBloc
                                                              .getCustomerList(
                                                                  name: [
                                                                'user_id',
                                                                'ilike',
                                                                customerSearchController
                                                                    .text
                                                              ]);
                                                        },
                                                        child: Container(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          height: 50,
                                                          child: RichText(
                                                              text: TextSpan(
                                                                  children: [
                                                                const TextSpan(
                                                                    text:
                                                                        "Search Sale Person for: ",
                                                                    style: TextStyle(
                                                                        fontStyle:
                                                                            FontStyle
                                                                                .italic,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                TextSpan(
                                                                    text: customerSearchController
                                                                        .text,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .black))
                                                              ])),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                    ],
                  ));
            } else {
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
            }
          },
        ),
      ),
    );
  }
}
