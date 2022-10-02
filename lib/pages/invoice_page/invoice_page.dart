import 'package:flutter/material.dart';

import 'invoice_bloc.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({ Key? key }) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  final invoiceBloc = InvoiceBloc();
  List<dynamic> invoiceList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    invoiceBloc.getInvoiceData(['type', 'ilike', 'out_refund']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Page'),
      ),
    );
  }
}