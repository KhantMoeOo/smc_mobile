import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import 'package:odoo_api/odoo_user_response.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class InvoiceCreateBloc {
  StreamController<ResponseOb> createInvoiceStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCreateInvoiceStream() => createInvoiceStreamController.stream; // Create Invoice Stream Controller

  late Odoo odoo;

  invoiceCreate({partnerId, ref, invoiceOrigin, type, invoiceDate, invoicePaymentTermId, invoiceDueDate, journalId, currencyId, exchangeRate}) async {
    print('Create Invoice');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createInvoiceStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('account.move', {
          'partner_id': partnerId,
          'ref': ref == '' ? null: ref,
          'invoice_origin': invoiceOrigin,
          'type': type,
          'invoice_date': invoiceDate == '' ? null: invoiceDate,
          'invoice_payment_term_id': invoicePaymentTermId,
          'invoice_date_due': invoiceDueDate == '' ? null: invoiceDueDate,
          //'journal_id': 1,
          'currency_id': currencyId,
          'exchange_rate': exchangeRate == '' ? null: exchangeRate
        });
        if (res.getResult() != null) {
          print('Invoice Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createInvoiceStreamController.sink.add(responseOb);
        } else {
          print('GetCreateInvoiceError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createInvoiceStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createInvoiceStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createInvoiceStreamController.sink.add(responseOb);
      }
    }
  } // Create Invoice

  dispose() {
    createInvoiceStreamController.close();
  }
}