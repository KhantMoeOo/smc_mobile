import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../pages/login_page/login_bloc.dart';
import '../../../pages/quotation_page/quotation_page.dart';
import '../../../services/odoo.dart';
import '../../../utils/app_const.dart';
import '../quotation/quotation_list.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
          return QuotationList();
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
          body: ListView(
            padding: const EdgeInsets.only(top: 20, left: 300, right: 300),
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/imgs/smc_logo.jpg',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    const Text(
                      'Database',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
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
                                popupItemBuilder: (context, item, isSelected) {
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
                                items: dbList.map((e) => e.toString()).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    dbName = value!;
                                  });
                                },
                                selectedItem: dbName,
                              );
                            } else {
                              return Center(
                                child: Image.asset(
                                  'assets/gifs/three_circle_loading.gif',
                                  width: 150,
                                  height: 150,
                                ),
                              );
                            }
                          }),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Email',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      height: 50,
                      child: TextFormField(
                        focusNode: emailFocus,
                        scrollPadding: const EdgeInsets.only(bottom: 40),
                        onEditingComplete: (() =>
                            FocusScope.of(context).requestFocus(pwdFocus)),
                        controller: _emailcontroller,
                        autofocus: false,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                      ),
                    ), // Email Text Field
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Password',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      height: 50,
                      child: TextFormField(
                        scrollPadding: const EdgeInsets.only(bottom: 40),
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
                              color: ispwdshow ? Colors.green : Colors.red,
                            ),
                            border: const OutlineInputBorder()),
                      ),
                    ), // Password Text Field
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<ResponseOb>(
                        stream: loginBloc.getLoginStream(),
                        builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                          ResponseOb? responseOb = snapshot.data;
                          if (responseOb?.msgState == MsgState.loading) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 12, 41, 92),
                              ),
                              height: 50,
                              child: Center(
                                child: Image.asset(
                                  'assets/gifs/loading.gif',
                                  width: 150,
                                  height: 150,
                                ),
                              ),
                            );
                          }
                          return Container(
                            height: 50,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 12, 41, 92),
                            ),
                            child: TextButton(
                                onPressed: () {
                                  // loginBloc.quotationLogin('admin',
                                  //     'Pr0fess!0n@l', 'smc_db_test');
                                  loginBloc.quotationLogin(
                                      'admin', 'admin', 'smc_uat_test');
                                  // loginBloc.quotationLogin(
                                  //     _emailcontroller.text,
                                  //     _passwordcontroller.text,
                                  //     dbName);
                                },
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )),
                          );
                        }),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
