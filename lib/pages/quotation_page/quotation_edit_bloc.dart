import 'dart:async';

import 'package:flutter/material.dart';
import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class QuotationEditBloc {
  StreamController<ResponseOb> quotationEditStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getQuotationEditStream() =>
      quotationEditStreamController.stream; // Quotation Edit Stream Controller

  StreamController<ResponseOb> updateQuotationStatusStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getUpdateQuotationStatusStream() =>
      updateQuotationStatusStreamController
          .stream; //updateQuotationStatusStreamController

  StreamController<ResponseOb> updateQuotationPickingIdsStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getUpdateQuotationPickingIdsStream() =>
      updateQuotationPickingIdsStreamController
          .stream; //updateQuotationPickingIdsStreamController

  StreamController<ResponseOb> updateQuotationOrderLineStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getUpdateQuotationOrderLineStream() =>
      updateQuotationOrderLineStreamController
          .stream; //updateQuotationOrderLineStreamController

  late Odoo odoo;

  editQuotationData(
      {ids,
      partnerId,
      dateOrder,
      currencyId,
      exchangeRate,
      priceListId,
      paymentTermId,
      zoneId,
      segmentId,
      regionId}) {
    print('EnterEdittQuotationData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    quotationEditStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('sale.order', [
          ids
        ], {
          'partner_id': partnerId,
          'date_order': dateOrder,
          'currency_id': currencyId,
          'exchange_rate': exchangeRate,
          'pricelist_id': priceListId,
          paymentTermId == 0 ? null : 'payment_term_id': paymentTermId,
          'zone_id': zoneId,
          'segment_id': segmentId,
          'region_id': regionId
        });
        if (!res.hasError()) {
          print('result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          quotationEditStreamController.sink.add(responseOb);
        } else {
          print('error');
          print('EditquoError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          quotationEditStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        quotationEditStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        quotationEditStreamController.sink.add(responseOb);
      }
    }
  } // Edit Quotation Data

  updateQuotationStatusData(ids, state) {
    print('EnterupdateQuotationStatusData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    updateQuotationStatusStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('sale.order', [ids],
            {'state': state, 'invoice_status': 'to invoice'});
        if (!res.hasError()) {
          print('result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          updateQuotationStatusStreamController.sink.add(responseOb);
        } else {
          print('error');
          print(
              'updateQuotationStatusError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          updateQuotationStatusStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        updateQuotationStatusStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        updateQuotationStatusStreamController.sink.add(responseOb);
      }
    }
  } // updateQuotationStatus Data

  updateQuotationPickingIdsData({ids, pickingIds}) {
    print('EnterupdateQuotationPickingIdsData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    updateQuotationPickingIdsStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('sale.order', [
          ids
        ], {
          'picking_ids': [pickingIds]
        });
        if (!res.hasError()) {
          print('result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          updateQuotationPickingIdsStreamController.sink.add(responseOb);
        } else {
          print('error');
          print('updateQuotationPickingidsError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          updateQuotationPickingIdsStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        updateQuotationPickingIdsStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        updateQuotationPickingIdsStreamController.sink.add(responseOb);
      }
    }
  } // updateQuotationPickingIds Data

  updateQuotationOrderLineData({ids, orderline}) {
    print('EnterupdateQuotationorderlineData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    updateQuotationOrderLineStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.write('sale.order', [ids], {'order_line': orderline});
        if (!res.hasError()) {
          print('result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          updateQuotationOrderLineStreamController.sink.add(responseOb);
        } else {
          print('error');
          print('updateQuotationOrderlineError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          updateQuotationOrderLineStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        updateQuotationOrderLineStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        updateQuotationOrderLineStreamController.sink.add(responseOb);
      }
    }
  } // updateQuotationOrderline Data

  dispose() {
    quotationEditStreamController.close();
    updateQuotationStatusStreamController.close();
    updateQuotationPickingIdsStreamController.close();
    updateQuotationOrderLineStreamController.close();
  }
}
