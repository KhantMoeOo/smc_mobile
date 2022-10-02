import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';

import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../services/odoo.dart';
import '../../../utils/app_const.dart';

class StockPickingBloc {
  StreamController<ResponseOb> stockpickingStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getStockPickingStream() =>
      stockpickingStreamController.stream; // Stock Picking Stream Controller

  StreamController<ResponseOb> stockpickingtypeStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getStockPickingTypeStream() =>
      stockpickingtypeStreamController
          .stream; // Stock Picking Type Stream Controller

  late Odoo odoo;

  getStockPickingData(name) async {
    print('EntergetStockPickingData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    stockpickingStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'stock.picking',
            [
              name,
            ],
            [
              'id',
              'name',
              'state',
              'partner_id',
              'ref_no',
              'picking_type_id',
              'location_id',
              'location_dest_id',
              'scheduled_date',
              'origin',
              'is_ncr_complaint',
              'sale_id',
            ],
            order: 'id desc');
        if (res.getResult() != null) {
          print('Stock Picking Result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !stockpickingStreamController.isClosed
              ? stockpickingStreamController.sink.add(responseOb)
              : null;
        } else {
          data = null;
          print('GetStockPickingError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          stockpickingStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Stock Picking catch: $e');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        stockpickingStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        stockpickingStreamController.sink.add(responseOb);
      }
    }
  } // get Stock Picking List

  getStockPickingTypeData(name) async {
    print('EntergetStockPickingTypeData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    stockpickingtypeStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'stock.picking.type',
            [
              name,
            ],
            [
              'id',
              'name',
              'default_location_src_id',
              'default_location_dest_id'
            ],
            order: 'id desc');
        if (res.getResult() != null) {
          print('Stock Picking Type Result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !stockpickingtypeStreamController.isClosed
              ? stockpickingtypeStreamController.sink.add(responseOb)
              : null;
        } else {
          data = null;
          print('GetStockPicking Type Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          stockpickingtypeStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Stock Picking Type catch: $e');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        stockpickingtypeStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        stockpickingtypeStreamController.sink.add(responseOb);
      }
    }
  } // get Stock Picking Type List

  dispose() {
    stockpickingStreamController.close();
    stockpickingtypeStreamController.close();
  }
}
