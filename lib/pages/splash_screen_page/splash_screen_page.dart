import 'package:flutter/material.dart';
import '../../dbs/sharef.dart';
import '../login_page/login_page.dart';
import '../quotation_page/quotation_page.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({Key? key}) : super(key: key);

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLogin();
  }

  checkLogin() {
    Future.delayed(const Duration(seconds: 2), () async {
      bool userInfo = await Sharef.getUserInfo();
      if (userInfo == true) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
          return const QuotationListPage();
        }), (route) => false);
      } else {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
          return const LoginPage();
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
            child: Text('Please Wait...', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
          ),
        ),
      ),
    );
  }
}
