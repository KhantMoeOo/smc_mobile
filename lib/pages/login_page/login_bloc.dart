import 'dart:async';
import 'package:odoo_api/odoo_api_connector.dart';
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

  StreamController<ResponseOb> getDBListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getDBListStream() =>
      getDBListStreamController.stream; // getDBListStreamController

  late Odoo odoo;

  quotationLogin({email, password, db}) async {
    print('EnterLogin');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    loginStreamController.sink.add(responseOb);
    odoo = Odoo(BASEURL);
    AuthenticateCallback auth = await odoo.authenticate(email, password, db);
    try {
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

  getDatabasesList() async {
    print('EntergetQuotationData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    getDBListStreamController.sink.add(responseOb);
    List<dynamic>? data;
    odoo = Odoo(BASEURL);
    data = await odoo.getDatabases();
    try {
      print('Try');
      if (data.isNotEmpty) {
        print('QuotationResult: $data');
        // data = res.getResult()['records'];
        responseOb.msgState = MsgState.data;
        responseOb.data = data;
        !getDBListStreamController.isClosed
            ? getDBListStreamController.sink.add(responseOb)
            : null;
      } else {
        print('Quotation error');
        data = [];
        // print('GetquoError:' + res.getErrorMessage().toString());
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        getDBListStreamController.sink.add(responseOb);
      }
    } catch (e) {
      print('Quotation catch: $e');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        getDBListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        getDBListStreamController.sink.add(responseOb);
      }
    }
  } // get Quotation List

  dispose() {
    loginStreamController.close();
    getDBListStreamController.close();
  }
}
