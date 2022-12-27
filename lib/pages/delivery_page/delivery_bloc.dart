import 'dart:async';
import 'dart:developer';

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

  StreamController<ResponseOb> stockmoveStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getStockMoveStream() =>
      stockmoveStreamController.stream; // Stock Move Stream Controller

  late Odoo odoo;

  getStockPickingData(name) async {
    print('EntergetStockPickingData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    stockpickingStreamController.sink.add(responseOb);
    List<dynamic>? data;

    Sharef.getOdooClientInstance().then((value) async {
        try{
          print('Try Get Stock Picking');
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
              'department_id',
              'scheduled_date',
              'material_id',
                  'origin',
              'is_ncr_complaint',
              'sale_id',
            ],
            order: 'id desc');
        if (!res.hasError()) {
          print('Stock Picking Result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !stockpickingStreamController.isClosed
              ? stockpickingStreamController.sink.add(responseOb)
              : null;
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('Get Stock Picking Error: ${map['message']}');
              }
            },
          );
          print(
              'Get Stock Picking Error:' + res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.severErr;
          stockpickingStreamController.sink.add(responseOb);
        }
        }catch (e) {
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
      });
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
        if (!res.hasError()) {
          print('Stock Picking Type Result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !stockpickingtypeStreamController.isClosed
              ? stockpickingtypeStreamController.sink.add(responseOb)
              : null;
        } else {
          data = null;
          print(
              'GetStockPicking Type Error:' + res.getErrorMessage().toString());
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

  getStockMoveData(pickingId) async {
    print('EntergetStockMoveData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    stockmoveStreamController.sink.add(responseOb);
    List<dynamic>? data;

    Sharef.getOdooClientInstance().then((value) async {
        try{
          print('Try Get Stock Move Data');
          odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'stock.move',
            [
              ['picking_id', '=', pickingId],
            ],
            [
              'id',
              'name',
              'picking_id',
              'product_id',
              'product_uom_qty',
              'quantity_done',
              'product_uom',
              'location_id',
              'location_dest_id',
              'remaining_qty',
              'damage_qty',
              //'picking_id',
              'origin',
            ],
            order: 'id desc');
        if (!res.hasError()) {
          print('Stock Move Result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !stockmoveStreamController.isClosed
              ? stockmoveStreamController.sink.add(responseOb)
              : null;
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('Get Stock Move Error: ${map['message']}');
              }
            },
          );
          print(
              'Get Stock Move Error:' + res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.severErr;
          stockmoveStreamController.sink.add(responseOb);
        }
        }catch (e) {
      print('Stock Move catch: $e');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        stockmoveStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        stockmoveStreamController.sink.add(responseOb);
      }
    }
      });
  } // get Stock Move List

  dispose() {
    stockpickingStreamController.close();
    stockpickingtypeStreamController.close();
    stockmoveStreamController.close();
  }
}
