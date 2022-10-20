import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../dbs/sharef.dart';
import '../../features/pages/login/login.dart';
import '../../features/pages/quotation/quotation_list.dart';
import '../mobile_view/pages_mb/login_mb/login_mb.dart';
import '../mobile_view/pages_mb/quotation_mb/quotation_list_mb.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState

    //  SystemChrome.setPreferredOrientations(
    //         [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
    //     :
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.initState();
    checkLogin();
  }

  checkLogin() {
    Future.delayed(const Duration(seconds: 2), () async {
      bool userInfo = await Sharef.getUserInfo();
      if (userInfo == true) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
          return MediaQuery.of(context).size.width > 400.0
              ? const QuotationList()
              : const QuotationListMB();
        }), (route) => false);
      } else {
        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(builder: (BuildContext context) {
        //   return const LoginPage();
        // }), (route) => false);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
          return MediaQuery.of(context).size.width > 400.0
              ? const Login()
              : const LoginMB();
        }), (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: const Center(
            child: Text(
              'Please Wait...',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
