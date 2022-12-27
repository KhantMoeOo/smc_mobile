import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../obs/response_ob.dart';
import '../../../../pages/customer_page/customer_bloc.dart';
import '../../../../pages/customer_page/customer_create_page.dart';
import '../../../../pages/profile_page/profile_bloc.dart';
import '../../../../utils/app_const.dart';
import '../../../../widgets/customer_widgets/customer_card_widget.dart';
import '../../../../widgets/drawer_widget.dart';
import '../menu_mb/menu_list_mb.dart';
import 'customer_create_mb.dart';

class CustomerListMB extends StatefulWidget {
  const CustomerListMB({Key? key}) : super(key: key);

  @override
  State<CustomerListMB> createState() => _CustomerListMBState();
}

class _CustomerListMBState extends State<CustomerListMB> {
  final customerBloc = CustomerBloc();
  final profileBloc = ProfileBloc();
  List<dynamic> customerList = [];
  List<dynamic> userList = [];
  final customerSearchController = TextEditingController();
  bool isSearch = false;
  bool searchDone = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    customerBloc.getCustomerListStream().listen(getCustomerListListen);
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      if (userList.isNotEmpty) {
        customerBloc.getCustomerList(
            name: ['name', 'ilike', ''], zoneId: userList[0]['zone_id'][0]);
      }
    }
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
            initialData: userList.isNotEmpty
                ? null
                : ResponseOb(msgState: MsgState.loading),
            stream: profileBloc.getResUsersStream(),
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
                              profileBloc.getResUsersData();
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
                              profileBloc.getResUsersData();
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
                              profileBloc.getResUsersData();
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
                return StreamBuilder<ResponseOb>(
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
                            backgroundColor: AppColors.appBarColor,
                            leading: IconButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return const MenuListMB();
                                }));
                              },
                              icon: const Icon(Icons.menu),
                            ),
                            title: Text(
                                "Customers (${userList[0]['zone_id'][1]})"),
                            // actions: [
                            //   TextButton(
                            //     onPressed: () {
                            //       Navigator.of(context)
                            //           .push(MaterialPageRoute(builder: (context) {
                            //         return CustomerCreateMB();
                            //       })).then((value) {
                            //         setState(() {
                            //           customerBloc.getCustomerList(name: [
                            //             'name',
                            //             'ilike',
                            //             customerSearchController.text
                            //           ], zoneId: userList[0]['zone_id'][0]);
                            //         });
                            //       });
                            //     },
                            //     child: const Text("Create",
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //         )),
                            //   )
                            // ],
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
                                                      customerSearchController
                                                          .clear();
                                                      searchDone = false;
                                                      customerBloc
                                                          .getCustomerList(
                                                              name: [
                                                            'name',
                                                            'ilike',
                                                            ''
                                                          ],
                                                              zoneId: userList[
                                                                          0][
                                                                      'zone_id']
                                                                  [0]);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      searchDone = true;
                                                      isSearch = false;
                                                      customerBloc
                                                          .getCustomerList(
                                                              name: [
                                                            'name',
                                                            'ilike',
                                                            customerSearchController
                                                                .text
                                                          ],
                                                              zoneId: userList[
                                                                          0][
                                                                      'zone_id']
                                                                  [0]);
                                                    });
                                                  }
                                                },
                                                icon: searchDone == true
                                                    ? const Icon(Icons.close)
                                                    : const Icon(Icons.search),
                                              ),
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                        ),
                                      ),
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
                                                  customerName: customerList[i]
                                                      ['name'],
                                                  code: customerList[i]
                                                              ['code'] ==
                                                          false
                                                      ? ''
                                                      : customerList[i]['code'],
                                                  address: customerList[i][
                                                              'contact_address_complete'] ==
                                                          false
                                                      ? ''
                                                      : customerList[i][
                                                          'contact_address_complete'],
                                                  companyType: customerList[i]
                                                      ['company_type'],
                                                  customerId: customerList[i]
                                                      ['id'],
                                                  zoneId: userList[0]['zone_id']
                                                      [0],
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
                                                    child: ListView(
                                                      // mainAxisSize: MainAxisSize.min,
                                                      shrinkWrap: true,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    isSearch =
                                                                        false;
                                                                    searchDone =
                                                                        true;
                                                                    customerBloc.getCustomerList(
                                                                        name: [
                                                                          'name',
                                                                          'ilike',
                                                                          customerSearchController
                                                                              .text
                                                                        ],
                                                                        zoneId: userList[0]['zone_id']
                                                                            [
                                                                            0]);
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  height: 50,
                                                                  child:
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Name for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                customerSearchController.text,
                                                                            style: const TextStyle(color: Colors.black))
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
                                                                    isSearch =
                                                                        false;
                                                                    searchDone =
                                                                        true;
                                                                    customerBloc.getCustomerList(
                                                                        name: [
                                                                          'email',
                                                                          'ilike',
                                                                          customerSearchController
                                                                              .text
                                                                        ],
                                                                        zoneId: userList[0]['zone_id']
                                                                            [
                                                                            0]);
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  height: 50,
                                                                  child:
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Email for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                customerSearchController.text,
                                                                            style: const TextStyle(color: Colors.black))
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
                                                                  isSearch =
                                                                      false;
                                                                  searchDone =
                                                                      true;
                                                                  customerBloc.getCustomerList(
                                                                      name: [
                                                                        'phone',
                                                                        'ilike',
                                                                        customerSearchController
                                                                            .text
                                                                      ],
                                                                      zoneId: userList[
                                                                              0]
                                                                          [
                                                                          'zone_id'][0]);
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  height: 50,
                                                                  child:
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Phone for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                customerSearchController.text,
                                                                            style: const TextStyle(color: Colors.black))
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
                                                                  isSearch =
                                                                      false;
                                                                  searchDone =
                                                                      true;
                                                                  customerBloc.getCustomerList(
                                                                      name: [
                                                                        'category_id',
                                                                        'ilike',
                                                                        customerSearchController
                                                                            .text
                                                                      ],
                                                                      zoneId: userList[
                                                                              0]
                                                                          [
                                                                          'zone_id'][0]);
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  height: 50,
                                                                  child:
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Tags for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                customerSearchController.text,
                                                                            style: const TextStyle(color: Colors.black))
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
                                                                  isSearch =
                                                                      false;
                                                                  searchDone =
                                                                      true;
                                                                  customerBloc.getCustomerList(
                                                                      name: [
                                                                        'user_id',
                                                                        'ilike',
                                                                        customerSearchController
                                                                            .text
                                                                      ],
                                                                      zoneId: userList[
                                                                              0]
                                                                          [
                                                                          'zone_id'][0]);
                                                                },
                                                                child:
                                                                    Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  height: 50,
                                                                  child:
                                                                      RichText(
                                                                          text: TextSpan(
                                                                              children: [
                                                                        const TextSpan(
                                                                            text:
                                                                                "Search Sale Person for: ",
                                                                            style: TextStyle(
                                                                                fontStyle: FontStyle.italic,
                                                                                color: Colors.black,
                                                                                fontWeight: FontWeight.bold)),
                                                                        TextSpan(
                                                                            text:
                                                                                customerSearchController.text,
                                                                            style: const TextStyle(color: Colors.black))
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
                );
              }
            }),
      ),
    );
  }
}
