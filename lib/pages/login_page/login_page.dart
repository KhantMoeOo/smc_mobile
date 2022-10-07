import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';
import '../home_page/home_page.dart';
import '../quotation_page/quotation_page.dart';
import 'login_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Sharef.clearSessionId();
    loginBloc.getLoginStream().listen((ResponseOb responseOb) {
      if (responseOb.msgState == MsgState.data) {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
            content:
                const Text('Login Successfully!', textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
          return QuotationListPage();
        }), (route) => false);
      }
      if (responseOb.msgState == MsgState.error) {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Color.fromARGB(255, 241, 15, 15),
            content: const Text('Something went wrong!',
                textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
        child: Scaffold(
            backgroundColor: Colors.grey[200],
            body: Form(
              child: Center(
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
                              image: AssetImage('assets/imgs/smc_logo.jpg')),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            // Container(
                            //   color: Colors.white,
                            //   height: 50,
                            //   child: TextFormField(
                            //     onEditingComplete: (() => FocusScope.of(context)
                            //         .requestFocus(emailFocus)),
                            //     scrollPadding: const EdgeInsets.only(bottom: 40),
                            //     focusNode: dbFocus,
                            //     controller: _dbcontroller,
                            //     autofocus: false,
                            //     style: const TextStyle(
                            //       fontSize: 18,
                            //     ),
                            //     decoration: InputDecoration(
                            //         suffixIcon: Directionality(
                            //           textDirection: TextDirection.rtl,
                            //           child: TextButton.icon(
                            //             onPressed: () {},
                            //             label: const Text(
                            //               'Select',
                            //               style: TextStyle(color: Colors.black),
                            //             ),
                            //             icon: const Icon(Icons.table_rows),
                            //           ),
                            //         ),
                            //         focusedBorder: OutlineInputBorder(
                            //             borderSide: BorderSide(
                            //               color: Theme.of(context).primaryColor,
                            //             ),
                            //             borderRadius: BorderRadius.circular(10)),
                            //         focusColor: Theme.of(context).primaryColor,
                            //         border: OutlineInputBorder()),
                            //   ),
                            // ), // Database Selector with Text Field
                            Container(
                              color: Colors.white,
                              height: 50,
                              child: FutureBuilder<List<dynamic>>(
                                  future: odoo.getDatabases(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      dbList = snapshot.data!;
                                      print('dblist: $dbList');
                                      return DropdownSearch<String>(
                                        dropDownButton: const Icon(
                                          Icons.table_rows,
                                          color: AppColors.appBarColor,
                                        ),
                                        popupItemBuilder:
                                            (context, item, isSelected) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  }),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              'Email',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
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
                                onEditingComplete: (() => FocusScope.of(context)
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
                                  fontSize: 20, fontWeight: FontWeight.bold),
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
                                      highlightColor: Colors.transparent,
                                      onPressed: () {
                                        setState(() {
                                          ispwdshow = !ispwdshow;
                                        });
                                      },
                                      icon: ispwdshow
                                          ? const Icon(Icons.visibility)
                                          : const Icon(Icons.visibility_off),
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
                                    AsyncSnapshot<ResponseOb> snapshot) {
                                  ResponseOb? responseOb = snapshot.data;
                                  if (responseOb?.msgState ==
                                      MsgState.loading) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        // color: Color(0xFFf31a22),
                                        color: Color.fromARGB(255, 12, 41, 92),
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
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      // color: Color(0xFFf31a22),
                                      color: Color.fromARGB(255, 12, 41, 92),
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
                                          //     'Pr0fess!0n@l', 'smc_uat');
                                          loginBloc.quotationLogin(
                                              _emailcontroller.text,
                                              _passwordcontroller.text,
                                              dbName);
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
            )),
      ),
    );
  }
} 

// Expanded(
//                 child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     onTap: () {},
//                     child: const Text(
//                       "Don't have an account?",
//                       style: TextStyle(color: Colors.purple, fontSize: 15),
//                     ),
//                   ), // Don't have an account? button
//                   InkWell(
//                     onTap: () {},
//                     child: const Text(
//                       "Reset Password",
//                       style: TextStyle(color: Colors.purple, fontSize: 15),
//                     ),
//                   ), // Reset Password button
//                 ],
//                           ),
//               ),