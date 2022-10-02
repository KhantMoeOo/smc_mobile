import 'dart:async';
import 'package:odoo_api/odoo_user_response.dart';

import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class LoginBloc {
  StreamController<ResponseOb> loginStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getLoginStream() =>
      loginStreamController.stream; // Log in Stream Controller

  late Odoo odoo;

  quotationLogin(username, password, db) async {
    print('EnterLogin');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    loginStreamController.sink.add(responseOb);
    try {
      odoo = Odoo(BASEURL);
      AuthenticateCallback auth =
          await odoo.authenticate(username, password, db);

      if (auth.isSuccess) {
        Sharef.saveUser(auth.getUser());
        responseOb.msgState = MsgState.data;
        loginStreamController.sink.add(responseOb);
      } else if (!auth.isSuccess) {
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        loginStreamController.sink.add(responseOb);
      }
    } catch (e) {
      print('LoginError: ${e.toString()}');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        loginStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        loginStreamController.sink.add(responseOb);
      }
    }
  }

  dispose() {
    loginStreamController.close();
  }
}
