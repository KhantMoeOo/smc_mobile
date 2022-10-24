import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../quotation_mb/quotation_list_mb.dart';

class NoInternetConnectionMB extends StatefulWidget {
  const NoInternetConnectionMB({Key? key}) : super(key: key);

  @override
  State<NoInternetConnectionMB> createState() => _NoInternetConnectionMBState();
}

class _NoInternetConnectionMBState extends State<NoInternetConnectionMB> {
  late var listener;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          print('Data connection is available.');
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return QuotationListMB();
          }), (route) => false);
          break;
        case InternetConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
            return NoInternetConnectionMB();
          }), (route) => false);
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: Text('No Internet Connection!'),
      ),
    );
  }
}
