import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';

import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../services/odoo.dart';
import '../../../utils/app_const.dart';

class InvoiceLineBloc {
  StreamController<ResponseOb> invoicelineStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getInvoiceLineStream() =>
      invoicelineStreamController.stream; // INvoice Line Stream Controller

  StreamController<ResponseOb> invoicelineCreateStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getInvoiceLineCreateStream() =>
      invoicelineCreateStreamController
          .stream; // Create INvoice Line Stream Controller

  late Odoo odoo;

  getInvoiceLineData(name) async {
    print('EntergetInvoiceLineData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    invoicelineStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'account.move.line',
            [
              name,
            ],
            [
              'id',
              'move_id',
              'exclude_from_invoice_tab',
              'product_id',
              'sale_line_ids',
              'name',
              'asset_category_id',
              'account_id',
              'analytic_account_id',
              'quantity',
              'product_uom_id',
              'price_unit',
              'sale_discount',
              'tax_ids',
              'price_subtotal'
            ],
            order: 'id desc');
        if (res.getResult() != null) {
          print('InvoiceLineResult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !invoicelineStreamController.isClosed
              ? invoicelineStreamController.sink.add(responseOb)
              : null;
        } else {
          data = null;
          print('GetInvoiceLineError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          invoicelineStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Invoice Line catch: $e');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        invoicelineStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        invoicelineStreamController.sink.add(responseOb);
      }
    }
  } // get Invoice Line List

  createInvoiceLine(
      {moveId,
      productId,
      balance,
      accountinternaltype,
      excludefrominvoicetab,
      salelineids,
      accountId,
      name,
      quantity,
      productUoMId,
      priceunit,
      salediscount,
      taxIds,
      debit,
      credit,
      pricesubtotal}) async {
    print('Create Invoice Line');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    invoicelineCreateStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('account.move.line', {
          'move_id': moveId,
          'product_id': productId,
          //'balance': balance,
          'account_internal_type': accountinternaltype,
          'exclude_from_invoice_tab': excludefrominvoicetab,
          'sale_line_ids': salelineids,
          'account_id': accountId,
          //'journal_id': 1,
          'name': name,
          'quantity': quantity,
          'product_uom_id': productUoMId,
          'price_unit': priceunit,
          'sale_discount': salediscount,
          'tax_ids': taxIds,
          //'debit': debit,
          //'credit': credit,
          //'price_subtotal': pricesubtotal,
        });
        if (res.getResult() != null) {
          print('Invoice Line Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          invoicelineCreateStreamController.sink.add(responseOb);
        } else {
          print(
              'GetCreateInvoiceLineError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          invoicelineCreateStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        invoicelineCreateStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        invoicelineCreateStreamController.sink.add(responseOb);
      }
    }
  } // Create Invoice Line

  dispose() {
    invoicelineStreamController.close();
    invoicelineCreateStreamController.close();
  }
}
