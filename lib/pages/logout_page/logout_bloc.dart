import 'dart:async';

import 'package:odoo_api/odoo_user_response.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class LogoutBloc {
  StreamController<ResponseOb> logoutStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getLogoutStream() =>
      logoutStreamController.stream; // Log Out Stream Controller

  late Odoo odoo;

  smcLogout() async {
    print('EnterLogout');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    logoutStreamController.sink.add(responseOb);
    try {
      print('try');
      bool isLogout = await Sharef.logout();

      if (isLogout) {
        print('Success Logout');
        responseOb.msgState = MsgState.data;
        logoutStreamController.sink.add(responseOb);
      } else if (!isLogout) {
        print('Error Logout');
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        logoutStreamController.sink.add(responseOb);
      }
    } catch (e) {
      print('error: ${e.toString()}');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        logoutStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        logoutStreamController.sink.add(responseOb);
      }
    }
  }

  dispose() {
    logoutStreamController.close();
  }
}
