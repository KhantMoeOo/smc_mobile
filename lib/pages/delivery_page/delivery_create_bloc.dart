import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import 'package:odoo_api/odoo_user_response.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class StockPickingCreateBloc {
  StreamController<ResponseOb> createStockPickingStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCreateStockPickingStream() =>
      createStockPickingStreamController
          .stream; // Create Stocking Picking Stream Controller

  StreamController<ResponseOb> updateStockPickingStatusStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getUpdateStockPickingStatusStream() =>
      updateStockPickingStatusStreamController
          .stream; // Update Stocking Picking Status Stream Controller

  StreamController<ResponseOb> createStockMoveStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCreateStockMoveStream() =>
      createStockMoveStreamController
          .stream; // Create Stocking Move Stream Controller

  late Odoo odoo;

  stockpickingCreate(
      {partnerId,
      refNo,
      pickingtypeId,
      locationId,
      locationDestId,
      scheduledDate,
      origin,
      saleId,
      state}) async {
    print('Create Stocking Picking');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createStockPickingStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('stock.picking', {
          'partner_id': partnerId,
          'ref_no': refNo,
          'picking_type_id': pickingtypeId,
          'location_id': locationId,
          'location_dest_id': locationDestId,
          'scheduled_date': scheduledDate,
          'origin': origin,
          'sale_id': saleId,
          'state': 'confirmed',
        });
        if (res.getResult() != null) {
          print('Create Stock Picking Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createStockPickingStreamController.sink.add(responseOb);
        } else {
          print('GetCreate Stock Picking Error:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createStockPickingStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createStockPickingStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createStockPickingStreamController.sink.add(responseOb);
      }
    }
  } // Create Stock Picking

  stockpickingUpdateStatus({ids, state}) async {
    print('Update Stocking Picking Status');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    updateStockPickingStatusStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('stock.picking', [
          ids
        ], {
          'state': state,
        });
        if (res.getResult() != null) {
          print('Update Stock Picking Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          updateStockPickingStatusStreamController.sink.add(responseOb);
        } else {
          print(
              'GetUpdateStockPickingError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          updateStockPickingStatusStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        updateStockPickingStatusStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        updateStockPickingStatusStreamController.sink.add(responseOb);
      }
    }
  } // Update Stock Picking Status

  createStockMove({description,productId, qty, productuom,locationId,locationdestId,pickingId,origin}) async {
    print('Create Stocking Move');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createStockMoveStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('stock.move', {
          'name': description,
          'product_id': productId,
          'product_uom_qty': qty,
          'product_uom': productuom,
          'location_id': locationId,
          'location_dest_id': locationdestId,
          'picking_id': pickingId,
          'origin': origin,
        });
        if (res.getResult() != null) {
          print('Create Stock Move Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createStockMoveStreamController.sink.add(responseOb);
        } else {
          print(
              'GetCreate Stock Move Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createStockMoveStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createStockMoveStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createStockMoveStreamController.sink.add(responseOb);
      }
    }
  } // Create Stock Picking

  dispose() {
    createStockPickingStreamController.close();
    updateStockPickingStatusStreamController.close();
    createStockMoveStreamController.close();
  }
}
