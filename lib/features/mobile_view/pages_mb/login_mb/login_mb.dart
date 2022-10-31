import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../../../../dbs/sharef.dart';
import '../../../../obs/response_ob.dart';
import '../../../../pages/login_page/login_bloc.dart';
import '../../../../services/odoo.dart';
import '../../../../utils/app_const.dart';
import '../quotation_mb/quotation_list_mb.dart';

class LoginMB extends StatefulWidget {
  const LoginMB({Key? key}) : super(key: key);

  @override
  State<LoginMB> createState() => _LoginMBState();
}

class _LoginMBState extends State<LoginMB> {
  final TextEditingController _dbcontroller = TextEditingController();
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passwordcontroller = TextEditingController();
  List<dynamic> dbList = [];
  String dbName = '';
  bool isLoading = false;
  bool ispwdshow = false;
  FocusNode dbFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode pwdFocus = FocusNode();
  final loginBloc = LoginBloc();
  final Odoo odoo = Odoo(BASEURL);

  late var listener;
  bool isConnection = true;
  bool hasDatabases = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      print('listen isConnection or Not');
      switch (status) {
        case InternetConnectionStatus.connected:
          print('Data connection is 1 available.');
          setState(() {
            isConnection = true;
            print('isConnection: $isConnection');
          });
          break;
        case InternetConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          setState(() {
            isConnection = false;
            print('isConnection: $isConnection');
          });
          break;
      }
    });
    Sharef.clearSessionId();
    loginBloc.getDatabasesList();
    loginBloc.getDBListStream().listen(getDBListListen);
    loginBloc.getLoginStream().listen(getLoginListen);
  }

  void getLoginListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      const snackbar = SnackBar(
          elevation: 0.0,
          // shape:
          //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.fixed,
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
          content: Text('Login Successfully!',
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.center));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) {
        return const QuotationListMB();
      }), (route) => false);
    } else if (responseOb.msgState == MsgState.error) {
      if (responseOb.errState == ErrState.severErr) {
        final snackbar = SnackBar(
            elevation: 0.0,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.fixed,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
            content: Text('${responseOb.data}',
                style: const TextStyle(color: Colors.black),
                textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      } else if (responseOb.errState == ErrState.noConnection) {
        setState(() {
          isConnection = true;
        });
        const snackbar = SnackBar(
            elevation: 0.0,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
            backgroundColor: Colors.red,
            content: Text('No Internet Connection',
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      } else {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
            content: const Text('Unknown Error',
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    }
  }

  void getDBListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      dbList = responseOb.data;
      setState(() {
        hasDatabases = true;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    listener.cancel();
    loginBloc.dispose();
    _dbcontroller.dispose();
    _emailcontroller.dispose();
    _passwordcontroller.dispose();
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
        child: Stack(
          children: [
            Scaffold(
                backgroundColor: Colors.grey[200],
                body: Form(
                  child: Center(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    left: 30, right: 30, top: 100, bottom: 100),
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 12, 41, 92),
                                    // gradient: LinearGradient(colors: [
                                    //   Color(0xFFf31a22),
                                    //   Color(0xFFa80b11),
                                    // ]),
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(100),
                                        topRight: Radius.circular(100))),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/imgs/smc_logo.jpg')),
                                  ),
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              Container(
                                // color: Color(0xFFf31a22),
                                decoration: const BoxDecoration(
                                    // gradient: LinearGradient(colors: [
                                    //   Color(0xFFf31a22),
                                    //   Color(0xFFa80b11),
                                    // ]),
                                    ),
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 30,
                                    right: 30,
                                  ),
                                  decoration: const BoxDecoration(
                                      // color: Colors.red,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(100))),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      // const Divider(
                                      //   color: Colors.grey,
                                      //   thickness: 1.5,
                                      // ),
                                      const SizedBox(
                                        height: 30,
                                      ),
                                      const Text(
                                        'Database',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                          color: Colors.white,
                                          height: 50,
                                          child: StreamBuilder<ResponseOb>(
                                            initialData: hasDatabases == true
                                                ? null
                                                : ResponseOb(
                                                    msgState: MsgState.loading),
                                            stream: loginBloc.getDBListStream(),
                                            builder: (context, snapshot) {
                                              ResponseOb? responseOb =
                                                  snapshot.data;
                                              if (responseOb?.msgState ==
                                                  MsgState.loading) {
                                                return Center(
                                                  child: Image.asset(
                                                    'assets/gifs/loading.gif',
                                                    width: 100,
                                                    height: 100,
                                                  ),
                                                );
                                              } else if (responseOb?.msgState ==
                                                  MsgState.error) {
                                                if (responseOb?.errState ==
                                                    ErrState.severErr) {
                                                  return Container(
                                                      height: 50,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Center(
                                                              child: Text(
                                                                  '${responseOb?.data}',
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .red))),
                                                          IconButton(
                                                              onPressed: () {
                                                                loginBloc
                                                                    .getDatabasesList();
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .refresh))
                                                        ],
                                                      ));
                                                } else if (responseOb
                                                        ?.errState ==
                                                    ErrState.noConnection) {
                                                  return SizedBox(
                                                      height: 50,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          const Center(
                                                              child: Text(
                                                                  'No Internet Connection!',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color: Colors
                                                                          .red))),
                                                          IconButton(
                                                              onPressed: () {
                                                                loginBloc
                                                                    .getDatabasesList();
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .refresh))
                                                        ],
                                                      ));
                                                } else {
                                                  return const Center(
                                                      child: Text(
                                                          'Unknown Error'));
                                                }
                                              } else {
                                                return DropdownSearch<String>(
                                                  dropDownButton: const Icon(
                                                    Icons.table_rows,
                                                    color:
                                                        AppColors.appBarColor,
                                                  ),
                                                  popupItemBuilder: (context,
                                                      item, isSelected) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(item.toString()),
                                                          const Divider(),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  showSearchBox: true,
                                                  showSelectedItems: true,
                                                  // showClearButton:
                                                  //     !hasNotPaymentTerms,
                                                  items: dbList
                                                      .map((e) => e.toString())
                                                      .toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      dbName = value!;
                                                    });
                                                  },
                                                  selectedItem: dbName,
                                                );
                                              }
                                            },
                                          )),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text(
                                        'Email',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        color: Colors.white,
                                        height: 50,
                                        child: TextFormField(
                                          focusNode: emailFocus,
                                          scrollPadding:
                                              const EdgeInsets.only(bottom: 40),
                                          onEditingComplete: (() =>
                                              FocusScope.of(context)
                                                  .requestFocus(pwdFocus)),
                                          controller: _emailcontroller,
                                          autofocus: false,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                          decoration: const InputDecoration(
                                              // focusedBorder: OutlineInputBorder(
                                              //     borderSide: BorderSide(
                                              //         color:
                                              //             Theme.of(context).primaryColor),
                                              //     borderRadius: BorderRadius.circular(10)),
                                              border: OutlineInputBorder(
                                                  // borderRadius: BorderRadius.circular(10),
                                                  )),
                                        ),
                                      ), // Email Text Field
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      const Text(
                                        'Password',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        color: Colors.white,
                                        height: 50,
                                        child: TextFormField(
                                          scrollPadding:
                                              const EdgeInsets.only(bottom: 40),
                                          onEditingComplete: () {
                                            FocusScope.of(context).unfocus();
                                            // loginButton();
                                          },
                                          focusNode: pwdFocus,
                                          controller: _passwordcontroller,
                                          autofocus: false,
                                          obscureText: !ispwdshow,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                          decoration: InputDecoration(
                                              suffixIcon: IconButton(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onPressed: () {
                                                  setState(() {
                                                    ispwdshow = !ispwdshow;
                                                  });
                                                },
                                                icon: ispwdshow
                                                    ? const Icon(
                                                        Icons.visibility)
                                                    : const Icon(
                                                        Icons.visibility_off),
                                              ),
                                              // focusedBorder: OutlineInputBorder(
                                              //     borderSide: BorderSide(
                                              //         color:
                                              //             Theme.of(context).primaryColor),
                                              //     borderRadius: BorderRadius.circular(10)),
                                              border: const OutlineInputBorder(
                                                  //     // borderRadius: BorderRadius.circular(10)
                                                  )),
                                        ),
                                      ), // Password Text Field
                                      const SizedBox(
                                        height: 50,
                                      ),
                                      StreamBuilder<ResponseOb>(
                                          stream: loginBloc.getLoginStream(),
                                          builder: (context,
                                              AsyncSnapshot<ResponseOb>
                                                  snapshot) {
                                            ResponseOb? responseOb =
                                                snapshot.data;
                                            if (responseOb?.msgState ==
                                                MsgState.loading) {
                                              return Container(
                                                decoration: const BoxDecoration(
                                                  // color: Color(0xFFf31a22),
                                                  color: Color.fromARGB(
                                                      255, 12, 41, 92),
                                                  // borderRadius: BorderRadius.only(
                                                  //     bottomLeft: Radius.circular(20),
                                                  //     bottomRight: Radius.circular(20)),
                                                  // boxShadow: [
                                                  //   BoxShadow(
                                                  //     offset: Offset(0, 2),
                                                  //     blurRadius: 4,
                                                  //   )
                                                  // ]
                                                ),
                                                height: 50,
                                                child: Center(
                                                  child: Image.asset(
                                                    'assets/gifs/loading.gif',
                                                    width: 100,
                                                    height: 100,
                                                  ),
                                                ),
                                              );
                                            }
                                            return Container(
                                              height: 50,
                                              width: double.infinity,
                                              decoration: const BoxDecoration(
                                                // color: Color(0xFFf31a22),
                                                color: Color.fromARGB(
                                                    255, 12, 41, 92),
                                                // borderRadius: BorderRadius.only(
                                                //     bottomLeft: Radius.circular(20),
                                                //     bottomRight: Radius.circular(20)),
                                                // boxShadow: [
                                                //   BoxShadow(
                                                //     offset: Offset(0, 2),
                                                //     blurRadius: 4,
                                                //   )
                                                // ]
                                              ),
                                              child: TextButton(
                                                  onPressed: () {
                                                    // loginBloc.quotationLogin('admin',
                                                    //     'Pr0fess!0n@l', 'smc_db_test');
                                                    // loginBloc.quotationLogin(
                                                    //     'Sai Nay Lin',
                                                    //     '123',
                                                    //     'smc_sale_test');
                                                    print('db: $dbName');
                                                    print(
                                                        'email: ${_emailcontroller.text}');
                                                    print(
                                                        'pwd: ${_passwordcontroller.text}');
                                                    loginBloc.quotationLogin(
                                                        email: _emailcontroller
                                                            .text,
                                                        password:
                                                            _passwordcontroller
                                                                .text,
                                                        db: dbName);
                                                  },
                                                  child: const Text(
                                                    'Log in',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  )),
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text('Version 31.10.2022')
                      ],
                    ),
                  ),
                )),
            Visibility(
              visible: false,
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: Colors.red,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/imgs/no_internet_connection_icon.png',
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              'No Internet Connection!',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey.withOpacity(.2),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
