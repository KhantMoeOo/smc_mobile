import 'dart:async';
import 'dart:developer';

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

  StreamController<ResponseOb> callActionConfirmStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCallActionConfirmStream() =>
      callActionConfirmStreamController
          .stream; // Call Action Confirm Stream Controller

  StreamController<ResponseOb> updateQtyDoneStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getUpdateQtyDoneStream() => updateQtyDoneStreamController
      .stream; // Call Update Done Stream Controller

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
        if (!res.hasError()) {
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
        if (!res.hasError()) {
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

  createStockMove(
      {description,
      productId,
      qty,
      productuom,
      locationId,
      locationdestId,
      pickingId,
      origin}) async {
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
        if (!res.hasError()) {
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

  callActionConfirm({id}) async {
    print('Call Action Confirm');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    callActionConfirmStreamController.sink.add(responseOb);
    Sharef.getOdooClientInstance().then((value) async {
        try{
          print('Try Call Action Confirm');
          odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.callKW('sale.order', 'action_confirm', [id]);
        if (!res.hasError()) {
          print('Call Action Confirm Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          callActionConfirmStreamController.sink.add(responseOb);
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('GetCall Action Confirm Error: ${map['message']}');
              }
            },
          );
          print(
              'GetCall Action Confirm Error:' + res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.severErr;
          callActionConfirmStreamController.sink.add(responseOb);
        }
        }catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        callActionConfirmStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        callActionConfirmStreamController.sink.add(responseOb);
      }
    }
      });
  } // Call Action Confirm

  updateQtyDoneData(ids, qtyDone) {
    print('EnterupdateQtyDoneData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    updateQtyDoneStreamController.sink.add(responseOb);

    Sharef.getOdooClientInstance().then((value) async {
        try{
          print('Try Update Qty Done');
          odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.write('stock.move', [ids], {'quantity_done': qtyDone});
        if (!res.hasError()) {
          print('updateQtyDoneDataresult');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          updateQtyDoneStreamController.sink.add(responseOb);
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('Get Update Qty Done Error: ${map['message']}');
              }
            },
          );
          print(
              'Get Update Qty Done Error:' + res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.severErr;
          updateQtyDoneStreamController.sink.add(responseOb);
        }
        }catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        updateQtyDoneStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        updateQtyDoneStreamController.sink.add(responseOb);
      }
    }
      });
  }

  dispose() {
    createStockPickingStreamController.close();
    updateStockPickingStatusStreamController.close();
    createStockMoveStreamController.close();
    callActionConfirmStreamController.close();
    updateQtyDoneStreamController.close();
  }
}
