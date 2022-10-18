import 'package:flutter/material.dart';

import '../../features/pages/login/login.dart';
import '../../obs/response_ob.dart';
import '../login_page/login_page.dart';
import 'logout_bloc.dart';

class LogoutPage extends StatefulWidget {
  const LogoutPage({Key? key}) : super(key: key);

  @override
  State<LogoutPage> createState() => _LogoutPageState();
}

class _LogoutPageState extends State<LogoutPage> {
  final logoutBloc = LogoutBloc();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    logoutBloc.smcLogout();
    logoutBloc.getLogoutStream().listen((ResponseOb responseOb) {
      if (responseOb.msgState == MsgState.data) {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
            content: const Text('Logout Successfully!',
                textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) {
          return const Login();
        }), (route) => false);
      } else if (responseOb.msgState == MsgState.error) {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
            content: const Text('Something went wrong!',
                textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<ResponseOb>(
        initialData: ResponseOb(msgState: MsgState.loading),
        stream: logoutBloc.getLogoutStream(),
        builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
          ResponseOb? responseOb = snapshot.data;
          return Center(
            child: Image.asset(
              'assets/gifs/three_circle_loading.gif',
              width: 150,
              height: 150,
            ),
          );
        },
      ),
    );
  }
}
