import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';

import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../services/odoo.dart';
import '../../../utils/app_const.dart';

class RegisterPaymentBloc {
  StreamController<ResponseOb> createRegisterPaymentStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCreateRegisterPaymentStream() =>
      createRegisterPaymentStreamController
          .stream; // createRegisterPaymentStreamController

  StreamController<ResponseOb> callregisterpaymentPostMethodStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCallRegisterPaymentPostMethodStream() =>
      callregisterpaymentPostMethodStreamController
          .stream; // callregisterpaymentPostMethodStreamController

  late Odoo odoo;

  createRegisterPayment(
      {invoiceIds,
      partnerId,
      amount,
      exchangerate,
      paymentdate,
      communication,
      journalId,
      paymentmethodId}) async {
    print('Create RegisterPayment');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createRegisterPaymentStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('account.payment', {
          'invoice_ids': invoiceIds,
          'payment_type': 'inbound',
          'partner_type': 'customer',
          'partner_id': partnerId,
          'amount': amount,
          'exchange_rate': exchangerate,
          'payment_date': paymentdate,
          'communication': communication,
          'journal_id': journalId,
          'payment_method_id': paymentmethodId,
        });
        if (res.getResult() != null) {
          print('RegisterPayment Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createRegisterPaymentStreamController.sink.add(responseOb);
        } else {
          print('GetCreateRegisterPaymentError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createRegisterPaymentStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createRegisterPaymentStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createRegisterPaymentStreamController.sink.add(responseOb);
      }
    }
  } // Create Register Payment

  callregisterpaymentPostMethod({id}) async {
    print('callregisterpaymentPostMethod');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    callregisterpaymentPostMethodStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.callKW('account.payment', 'post', [id]);
        if (!res.hasError()) {
          print('callregisterpaymentPostMethod Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          callregisterpaymentPostMethodStreamController.sink.add(responseOb);
        } else {
          print('callregisterpaymentPostMethod Error:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          callregisterpaymentPostMethodStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        callregisterpaymentPostMethodStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        callregisterpaymentPostMethodStreamController.sink.add(responseOb);
      }
    }
  } // callregisterpaymentPostMethod

  dispose() {
    callregisterpaymentPostMethodStreamController.close();
    createRegisterPaymentStreamController.close();
  }
}
