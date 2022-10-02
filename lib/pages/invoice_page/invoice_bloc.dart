import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class InvoiceBloc {
  StreamController<ResponseOb> invoiceStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getInvoiceStream() =>
      invoiceStreamController.stream; // Invoice Stream Controller

  StreamController<ResponseOb> accountjournalStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getAccountJournalStream() => accountjournalStreamController
      .stream; // Account Journal Stream Controller

  late Odoo odoo;

  getInvoiceData(name) async {
    print('EntergetInvoiceData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    invoiceStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'account.move',
            [
              name,
            ],
            [
              'id',
              'name',
              'invoice_origin',
              'type',
              'partner_id',
              'invoice_user_id',
              'invoice_partner_display_name',
              'ref',
              'narration',
              'fiscal_position_id',
              'partner_shipping_id',
              'invoice_payment_ref',
              'invoice_date',
              'invoice_payment_term_id',
              'invoice_partner_bank_id',
              'team_id',
              'campaign_id',
              'invoice_date_due',
              'medium_id',
              'source_id',
              'invoice_line_ids',
              'journal_id',
              'currency_id',
              'exchange_rate',
              'amount_untaxed',
              'amount_sale_discount',
              'amount_by_group',
              'amount_total',
              'state'
            ],
            order: 'id desc');
        if (res.getResult() != null) {
          print('InvoiceResult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !invoiceStreamController.isClosed
              ? invoiceStreamController.sink.add(responseOb)
              : null;
        } else {
          data = null;
          print('GetInvoiceError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          invoiceStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Invoice catch: $e');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        invoiceStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        invoiceStreamController.sink.add(responseOb);
      }
    }
  } // get Invoice List

  getAccountJournalData(name) async {
    print('EntergetAccountJournalData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    accountjournalStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'account.journal',
            [
              name,
            ],
            [
              'id',
              'name',
              'currency_id'
            ],
            order: 'id desc');
        if (res.getResult() != null) {
          print('AccountJournalResult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !accountjournalStreamController.isClosed
              ? accountjournalStreamController.sink.add(responseOb)
              : null;
        } else {
          data = null;
          print('GetAccountJournalError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          accountjournalStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Journal catch: $e');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        accountjournalStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        accountjournalStreamController.sink.add(responseOb);
      }
    }
  } // get Account Journal List

  dispose() {
    invoiceStreamController.close();
    accountjournalStreamController.close();
  }
}
