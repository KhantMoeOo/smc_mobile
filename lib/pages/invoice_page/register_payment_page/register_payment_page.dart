import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../dbs/database_helper.dart';
import '../../../obs/response_ob.dart';
import '../../../utils/app_const.dart';
import '../../quotation_page/quotation_bloc.dart';
import '../invoice_bloc.dart';
import 'register_payment_bloc.dart';

class RegisterPaymentPage extends StatefulWidget {
  int invoiceId;
  int partnerId;
  String amountresidual;
  int currencyId;
  String invoiceName;
  RegisterPaymentPage({
    Key? key,
    required this.invoiceId,
    required this.partnerId,
    required this.amountresidual,
    required this.currencyId,
    required this.invoiceName,
  }) : super(key: key);

  @override
  State<RegisterPaymentPage> createState() => _RegisterPaymentPageState();
}

class _RegisterPaymentPageState extends State<RegisterPaymentPage> {
  final registerpaymentBloc = RegisterPaymentBloc();
  final invoiceBloc = InvoiceBloc();
  final quotationBloc = QuotationBloc();
  final databaseHelper = DatabaseHelper();
  final amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<dynamic> accountjournalList = [];
  List<dynamic> accountjournalListUpdate = [];
  bool hasAccountJournalData = false;
  bool hasNotAccountJournal = true;
  bool hasAmount = false;
  bool hasNotCurrency = true;
  int accountjournalId = 0;
  String accountjournalName = '';
  int inboundmethodId = 0;

  int currencyId = 0;
  String currencyName = '';
  List<dynamic> currencyList = [];
  bool hasCurrencyData = false;
  String currencysymbol = '';

  final paymentdateController = TextEditingController();
  String paymentdate = '';
  bool hasPaymentDate = false;

  final memoController = TextEditingController();
  bool hasMemo = false;

  bool isCreateRegisterPayment = false;
  bool isCallPost = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    invoiceBloc.getAccountJournalData(['id', 'ilike', '']);
    invoiceBloc.getAccountJournalStream().listen(getAccountJournalListen);
    quotationBloc.getCurrencyList();
    quotationBloc.getCurrencyStream().listen(getCurrencyList);
    registerpaymentBloc
        .getCreateRegisterPaymentStream()
        .listen(getCreateRegisterPaymentListen);
    registerpaymentBloc
        .getCallRegisterPaymentPostMethodStream()
        .listen(getCallPostMethodListen);
    paymentdateController.text = DateTime.now().toString();
    hasPaymentDate = true;
    amountController.text = widget.amountresidual;
    hasAmount = true;
    memoController.text = widget.invoiceName;
  }

  void getAccountJournalListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        accountjournalList = responseOb.data;
        hasAccountJournalData = true;
        if (accountjournalList.isNotEmpty) {
          for (var ajL in accountjournalList) {
            if (ajL['type'] == 'bank' || ajL['type'] == 'cash') {
              accountjournalListUpdate.add(ajL);
            }
          }
        }
        print('accountjournalListUpdate: $accountjournalListUpdate');
      });
    }
  }

  void getJournalId(String? v) {
    if (v != null) {
      setState(() {
        accountjournalId = int.parse(v.toString().split(',')[0]);
        //hasNotCurrency = false;
        for (var element in accountjournalListUpdate) {
          if (element['id'] == accountjournalId) {
            accountjournalName = element['name'];
            accountjournalId = element['id'];
            inboundmethodId = element['inbound_payment_method_ids'][0];
            print('accountjournalName:$accountjournalName');
            print('accountjournalId:$accountjournalId');
            print('inbound_payment_method_ids: $inboundmethodId');
          }
        }
      });
    }
  }

  void getCurrencyList(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      currencyList = responseOb.data;
      hasCurrencyData = true;
      setCurrencyNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoCurrencyList");
    }
  }

  void getCurrencyId(String? v) {
    if (v != null) {
      setState(() {
        currencyId = int.parse(v.toString().split(',')[0]);
        hasNotCurrency = false;
        for (var element in currencyList) {
          if (element['id'] == currencyId) {
            currencyName = element['name'];
            currencyId = element['id'];
            currencysymbol = element['symbol'];
            print('CurrencyName:$currencyName');
            print('CurrencyId:$currencyId');
            print('CurrencySymbol: $currencysymbol');
          }
        }
      });
    } else {
      hasNotCurrency = true;
    }
  }

  void setCurrencyNameMethod() {
    if (widget.currencyId != 0) {
      for (var element in currencyList) {
        if (element['id'] == widget.currencyId) {
          hasNotCurrency = false;
          currencyId = element['id'];
          currencyName = element['name'];
          currencysymbol = element['symbol'];
          print('CurrencyListId: ' + currencyId.toString());
          print('SetCurrencyName:' + currencyName);
        }
      }
    }
  }

  createRegisterPayment() {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        isCreateRegisterPayment = true;
      });
      registerpaymentBloc.createRegisterPayment(
        invoiceIds: [widget.invoiceId],
        partnerId: widget.partnerId,
        amount: amountController.text,
        exchangerate: '1.0',
        paymentdate: paymentdateController.text,
        communication: memoController.text,
        journalId: accountjournalId,
        paymentmethodId: inboundmethodId,
      );
    }
  }

  void getCreateRegisterPaymentListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        isCreateRegisterPayment = false;
        isCallPost = true;
      });
      registerpaymentBloc.callregisterpaymentPostMethod(id: responseOb.data);
    }
  }

  void getCallPostMethodListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      databaseHelper.deleteAllAccountMoveLine();
      databaseHelper.deleteAllAccountMoveLineUpdate();
      databaseHelper.deleteAllTaxIds();
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          content:
              const Text('Create Successfully!', textAlign: TextAlign.center));
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await databaseHelper.deleteAllAccountMoveLine();
        await databaseHelper.deleteAllAccountMoveLineUpdate();
        await databaseHelper.deleteAllTaxIds();
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                backgroundColor: AppColors.appBarColor,
                title: const Text('Register Payment'),
                actions: [
                  TextButton(
                      onPressed: createRegisterPayment,
                      child: const Text(
                        'Validate',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ))
                ],
              ),
              body: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Type:",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Container(
                      color: Colors.white,
                      height: 40,
                      child: StreamBuilder<ResponseOb>(
                          initialData: hasAccountJournalData == false
                              ? ResponseOb(msgState: MsgState.loading)
                              : null,
                          stream: invoiceBloc.getAccountJournalStream(),
                          builder:
                              (context, AsyncSnapshot<ResponseOb> snapshot) {
                            ResponseOb? responseOb = snapshot.data;
                            if (responseOb?.msgState == MsgState.loading) {
                              return Center(
                                child: Image.asset(
                                  'assets/gifs/loading.gif',
                                  width: 100,
                                  height: 100,
                                ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.toString().split(',')[1]),
                                        const Divider(),
                                      ],
                                    ),
                                  );
                                },
                                autoValidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select Customer Name';
                                  }
                                  return null;
                                },
                                //showSearchBox: true,
                                showSelectedItems: true,
                                //showClearButton: !hasNotAccountJournal,
                                items: accountjournalListUpdate.map((e) {
                                  return '${e['id']},${e['name']} (MMK)';
                                }).toList(),
                                onChanged: getJournalId,
                                selectedItem: accountjournalName,
                              );
                            }
                          }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 200,
                          child: Text(
                            'Amount Due',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        const Text(
                          ":",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                            child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey),
                            color: Colors.white,
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.amountresidual,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 18))
                              ]),
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Amount*:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: hasAmount == true && hasNotCurrency == false
                              ? Colors.black
                              : Colors.red),
                    ),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            color: Colors.white,
                            child: TextFormField(
                              //readOnly: hasNotProductProduct == true ? true : false,
                              //focusNode: unitpriceFocus,
                              onChanged: (value) {
                                if (value == '') {
                                  setState(() {
                                    hasAmount = false;
                                  });
                                } else {
                                  setState(() {
                                    hasAmount = true;
                                  });
                                }
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Amount';
                                }
                                return null;
                              },
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^(\d+)?\.?\d{0,2}'))
                              ],
                              // onFieldSubmitted: (value) {
                              //   subTotalController.text =
                              //       (double.parse(quantityController.text) *
                              //               double.parse(value))
                              //           .toString();
                              //   print('subtotal: ${subTotalController.text}');
                              // },
                              controller: amountController,
                              decoration: InputDecoration(
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      currencysymbol,
                                      //textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  border: const OutlineInputBorder()),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.white,
                            height: 40,
                            child: StreamBuilder<ResponseOb>(
                                initialData: hasCurrencyData == false
                                    ? ResponseOb(msgState: MsgState.loading)
                                    : null,
                                stream: quotationBloc.getCurrencyStream(),
                                builder: (context,
                                    AsyncSnapshot<ResponseOb> snapshot) {
                                  ResponseOb? responseOb = snapshot.data;
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
                                    return const Center(
                                      child: Text("Something went Wrong!"),
                                    );
                                  } else {
                                    return DropdownSearch<String>(
                                      // enabled: false,
                                      popupItemBuilder:
                                          (context, item, isSelected) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item
                                                  .toString()
                                                  .split(',')[1]),
                                              const Divider(),
                                            ],
                                          ),
                                        );
                                      },
                                      autoValidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please select Currency Name';
                                        }
                                        return null;
                                      },
                                      showSearchBox: true,
                                      showSelectedItems: true,
                                      //showClearButton: !hasNotCurrency,
                                      items: currencyList
                                          .map((e) => '${e['id']},${e['name']}')
                                          .toList(),
                                      onChanged: getCurrencyId,
                                      selectedItem: currencyName,
                                    );
                                  }
                                }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Payment Date*:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: hasPaymentDate == false
                              ? Colors.red
                              : Colors.black),
                    ),
                    Container(
                        color: Colors.white,
                        height: 40,
                        child: TextFormField(
                            readOnly: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select Payment Date';
                              }
                              return null;
                            },
                            controller: paymentdateController,
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onPressed: () async {
                                    final DateTime? selected =
                                        await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2023));

                                    if (selected != null) {
                                      setState(() {
                                        paymentdate =
                                            '${selected.toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].split('.')[0]}';
                                        paymentdateController.text =
                                            '${selected.toString().split(' ')[0]} ${DateTime.now().toString().split(' ')[1].split('.')[0]}';
                                        hasPaymentDate = true;
                                        print(paymentdate);
                                      });
                                    }
                                  },
                                )))),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "Memo:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Container(
                      height: 40,
                      color: Colors.white,
                      child: TextFormField(
                        //readOnly: hasNotProductProduct == true ? true : false,
                        //focusNode: unitpriceFocus,
                        onChanged: (value) {
                          if (value == '') {
                            setState(() {
                              hasMemo = false;
                            });
                          } else {
                            setState(() {
                              hasMemo = true;
                            });
                          }
                        },
                        // autovalidateMode: AutovalidateMode.onUserInteraction,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return 'Please enter Amount';
                        //   }
                        //   return null;
                        // },
                        // keyboardType:
                        //     const TextInputType.numberWithOptions(decimal: true),
                        // inputFormatters: <TextInputFormatter>[
                        //   FilteringTextInputFormatter.allow(
                        //       RegExp(r'^(\d+)?\.?\d{0,2}'))
                        // ],
                        // onFieldSubmitted: (value) {
                        //   subTotalController.text =
                        //       (double.parse(quantityController.text) *
                        //               double.parse(value))
                        //           .toString();
                        //   print('subtotal: ${subTotalController.text}');
                        // },
                        controller: memoController,
                        decoration: const InputDecoration(
                            // suffixIcon: Padding(
                            //   padding: const EdgeInsets.all(8.0),
                            //   child: Text(
                            //     currencysymbol,
                            //     //textAlign: TextAlign.center,
                            //     style: const TextStyle(fontSize: 20),
                            //   ),
                            // ),
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              )),
          isCreateRegisterPayment == true
              ? StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: registerpaymentBloc.getCreateRegisterPaymentStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Image.asset(
                            'assets/gifs/loading.gif',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      );
                    } else if (responseOb?.msgState == MsgState.data) {}
                    return Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Image.asset(
                          'assets/gifs/loading.gif',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    );
                  })
              : Container(),
          isCallPost == true
              ? StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: registerpaymentBloc
                      .getCallRegisterPaymentPostMethodStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Image.asset(
                            'assets/gifs/loading.gif',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      );
                    } else if (responseOb?.msgState == MsgState.data) {}
                    return Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Image.asset(
                          'assets/gifs/loading.gif',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    );
                  })
              : Container(),
        ],
      ),
    );
  }
}
