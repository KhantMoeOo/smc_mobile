import 'dart:async';

import 'package:flutter/material.dart';
import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class InvoiceEditBloc {
  StreamController<ResponseOb> updateInvoiceStatusStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getUpdateQuotationStatusStream() =>
      updateInvoiceStatusStreamController
          .stream; //updateQuotationStatusStreamController

  late Odoo odoo;

  updateInvoiceStatusData(ids, state) {
    print('EnterupdatInvoiceStatusData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    updateInvoiceStatusStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.write('account.move', [ids], {'state': state});
        if (res.getResult() != null) {
          print('result');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          updateInvoiceStatusStreamController.sink.add(responseOb);
        } else {
          print('updatInvoiceStatusError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          updateInvoiceStatusStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        updateInvoiceStatusStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        updateInvoiceStatusStreamController.sink.add(responseOb);
      }
    }
  } // updatInvoiceStatus Data

  dispose() {
    updateInvoiceStatusStreamController.close();
  }
}
