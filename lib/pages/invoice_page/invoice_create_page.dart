import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../quotation_page/quotation_bloc.dart';
import 'invoice_bloc.dart';

class InvoiceCreatePage extends StatefulWidget {
  int createInvoiceWithId;
  int quotationId;
  int customerId;
  int paymentTermsId;
  int currencyId;
  InvoiceCreatePage({
    Key? key,
    required this.createInvoiceWithId,
    required this.quotationId,
    required this.customerId,
    required this.paymentTermsId,
    required this.currencyId,
  }) : super(key: key);

  @override
  State<InvoiceCreatePage> createState() => _InvoiceCreatePageState();
}

class _InvoiceCreatePageState extends State<InvoiceCreatePage> {
  final quotationBloc = QuotationBloc();
  final invoiceBloc = InvoiceBloc();
  List<dynamic> customerList = [];
  String customerName = '';
  int customerId = 0;
  bool hasCustomerData = false;
  bool hasNotCustomer = true;
  String invoiceDate = '';

  List<dynamic> paymentTermsList = [];
  bool hasPaymentTermsData = false;
  int paymentTermsId = 0;
  String paymentTermsName = '';
  bool hasNotPaymentTerms = true;

  List<dynamic> journalList = [];
  bool hasJournalData = false;
  int journalId = 0;
  String journalName = '';
  bool hasNotJournal = true;

  List<dynamic> currencyList = [];
  bool hasCurrencyData = false;
  bool hasNotCurrency = true;
  int currencyId = 0;
  String currencyName = '';

  final referenceController = TextEditingController();
  final invoiceDateController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint('New or Edit:' + widget.createInvoiceWithId.toString());
    print('QuoId:' + widget.quotationId.toString());
    quotationBloc.getCustomerList(['name', 'ilike', '']);
    quotationBloc.getCustomerStream().listen(getCustomerList);
    quotationBloc.getPaymentTermsData();
    quotationBloc.getPaymentTermsStream().listen(getPaymentTermslist);
    invoiceBloc.getAccountJournalData(['name', 'ilike', '']);
    invoiceBloc.getAccountJournalStream().listen((event) {});
    quotationBloc.getCurrencyList();
    quotationBloc.getCurrencyStream().listen(getCurrencyList);
  }

  void getCustomerList(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      customerList = responseOb.data;
      hasCustomerData = true;
      setCustomerNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoCustomerList");
    }
  } // listen to get Customer List

  void getCustomerId(String? v) {
    if (v != null) {
      setState(() {
        customerId = int.parse(v.toString().split(',')[0]);
        hasNotCustomer = false;
        for (var element in customerList) {
          if (element['id'] == customerId) {
            if (element['code'] != false) {
              customerName = '${element['code']} ${element['name']}';
            } else {
              customerName = element['name'];
            }
            customerId = element['id'];
            print('CustomerName:$customerName');
            print('CustomerId:$customerId');
          }
        }
      });
    } else {
      setState(() {
        hasNotCustomer = true;
      });
    }
  } // get CustomerId from CustomerSelection

  void setCustomerNameMethod() {
    print('set work');
    setState(() {
      if (widget.createInvoiceWithId == 1) {
        print('its 1');
        for (var element in customerList) {
          if (element['id'] == widget.customerId) {
            hasNotCustomer = false;
            customerId = element['id'];
            if (element['code'] != false) {
              customerName = '${element['code']} ${element['name']}';
            } else {
              customerName = element['name'];
            }
            print('CustomerId: ' + element['id'].toString());
            print('SetCustomerName:' + customerName);
          }
        }
      }
    });
  } // Set Customer Name to Update Quotation Page

  void getPaymentTermslist(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      paymentTermsList = responseOb.data;
      hasPaymentTermsData = true;
      setPaymentTermListNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoPaymentTermsList");
    }
  } // listen to get PaymentTerms List

  void getPaymentTermsId(String? v) {
    if (v != null) {
      setState(() {
        paymentTermsId = int.parse(v.toString().split(',')[0]);
        hasNotPaymentTerms = false;
        for (var element in paymentTermsList) {
          if (element['id'] == paymentTermsId) {
            paymentTermsName = element['name'];
            paymentTermsId = element['id'];
            print('PaymentTermsName:$paymentTermsName');
            print('PaymentTermsId:$paymentTermsId');
          }
        }
      });
    } else {
      setState(() {
        hasNotPaymentTerms = true;
      });
    }
  } // get PaymentTermsId from PaymentTermsSelection

  void setPaymentTermListNameMethod() {
    if (widget.createInvoiceWithId == 1) {
      if (widget.paymentTermsId != 0) {
        for (var element in paymentTermsList) {
          if (element['id'] == widget.paymentTermsId) {
            hasNotPaymentTerms = false;
            paymentTermsId = element['id'];
            paymentTermsName = element['name'];
            print('PaymentTermListId: ' + paymentTermsId.toString());
            print('SetPaymentTermListName:' + paymentTermsName);
          }
        }
      }
    }
  } // Set PaymentTerm Name to Update Quotation Page

  void getAccountJournalList(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      customerList = responseOb.data;
      hasCustomerData = true;
      setCustomerNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoCustomerList");
    }
  } // listen to get Customer List

  void getAccountJournalId(String? v) {
    if (v != null) {
      setState(() {
        customerId = int.parse(v.toString().split(',')[0]);
        hasNotCustomer = false;
        for (var element in customerList) {
          if (element['id'] == customerId) {
            if (element['code'] != false) {
              customerName = '${element['code']} ${element['name']}';
            } else {
              customerName = element['name'];
            }
            customerId = element['id'];
            print('CustomerName:$customerName');
            print('CustomerId:$customerId');
          }
        }
      });
    } else {
      setState(() {
        hasNotCustomer = true;
      });
    }
  } // get CustomerId from CustomerSelection

  void getCurrencyList(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      currencyList = responseOb.data;
      hasCurrencyData = true;
      setCurrencyNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoCurrencyList");
    }
  } // listen to get Currency List

  void getCurrencyId(String? v) {
    if (v != null) {
      setState(() {
        currencyId = int.parse(v.toString().split(',')[0]);
        hasNotCurrency = false;
        for (var element in currencyList) {
          if (element['id'] == currencyId) {
            currencyName = element['name'];
            currencyId = element['id'];
            print('CurrencyName:$currencyName');
            print('CurrencyId:$currencyId');
          }
        }
      });
    } else {
      hasNotCurrency = true;
    }
  } // get CurrencyId from CurrencySelection

  void setCurrencyNameMethod() {
    if (widget.createInvoiceWithId == 1) {
      if (widget.currencyId != 0) {
        for (var element in currencyList) {
          if (element['id'] == widget.currencyId) {
            hasNotCurrency = false;
            currencyId = element['id'];
            currencyName = element['name'];
            print('CurrencyListId: ' + currencyId.toString());
            print('SetCurrencyName:' + currencyName);
          }
        }
      }
    }
  } // Set Currency Name to Update Quotation Page

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: AppColors.appBarColor,
        title: const Text('Draft Invoice'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverList(
                delegate: SliverChildListDelegate([
              Text(
                "Customer*:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: hasNotCustomer == true ? Colors.red : Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 40,
                child: StreamBuilder<ResponseOb>(
                    initialData: hasCustomerData == false
                        ? ResponseOb(msgState: MsgState.loading)
                        : null,
                    stream: quotationBloc.getCustomerStream(),
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
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select Customer Name';
                            }
                            return null;
                          },
                          showSearchBox: true,
                          showSelectedItems: true,
                          showClearButton: !hasNotCustomer,
                          items: customerList.map((e) {
                            return e['code'] != false
                                ? '${e['id']},${e['code']} ${e['name']}'
                                : '${e['id']},${e['name']}';
                          }).toList(),
                          onChanged: getCustomerId,
                          selectedItem: customerName,
                        );
                      }
                    }),
              ),
              const SizedBox(height: 20),
              const Text(
                "Reference:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 40,
                child: TextField(
                  // keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  //     inputFormatters: <TextInputFormatter>[
                  //       FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
                  //     ],
                  controller: referenceController,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Invoice Date:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10),
              Container(
                color: Colors.white,
                height: 40,
                child: TextField(
                  readOnly: true,
                  controller: invoiceDateController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                          onPressed: () async {
                            final DateTime? selected = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2023));

                            if (selected != null) {
                              invoiceDate = selected.toString().split(' ')[0];
                              invoiceDateController.text =
                                  selected.toString().split(' ')[0];
                            }
                          },
                          icon: const Icon(Icons.arrow_drop_down))),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Payment Terms:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 10),
              Container(
                color: Colors.white,
                height: 40,
                child: StreamBuilder<ResponseOb>(
                    initialData: hasPaymentTermsData == false
                        ? ResponseOb(msgState: MsgState.loading)
                        : null,
                    stream: quotationBloc.getPaymentTermsStream(),
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
                          showClearButton: !hasNotPaymentTerms,
                          items: paymentTermsList
                              .map((e) => '${e['id']},${e['name']}')
                              .toList(),
                          onChanged: getPaymentTermsId,
                          selectedItem: paymentTermsName,
                        );
                      }
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Journal:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 40,
                child: StreamBuilder<ResponseOb>(
                    initialData: hasCurrencyData == false
                        ? ResponseOb(msgState: MsgState.loading)
                        : null,
                    stream: quotationBloc.getCurrencyStream(),
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
                          // enabled: false,
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
                          showClearButton: !hasNotCurrency,
                          items: currencyList
                              .map((e) => '${e['id']},${e['name']}')
                              .toList(),
                          onChanged: getCurrencyId,
                          selectedItem: currencyName,
                        );
                      }
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Currency:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 40,
                child: StreamBuilder<ResponseOb>(
                    initialData: hasCurrencyData == false
                        ? ResponseOb(msgState: MsgState.loading)
                        : null,
                    stream: quotationBloc.getCurrencyStream(),
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
                          // enabled: false,
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
                          showClearButton: !hasNotCurrency,
                          items: currencyList
                              .map((e) => '${e['id']},${e['name']}')
                              .toList(),
                          onChanged: getCurrencyId,
                          selectedItem: currencyName,
                        );
                      }
                    }),
              ),
            ])),
          )
        ],
      ),
    );
  }
}
