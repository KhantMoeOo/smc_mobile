import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class MaterialIssuesBloc {
  StreamController<ResponseOb> stockpickingStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getStockPickingStream() =>
      stockpickingStreamController.stream; // Stock Picking Stream Controller

  StreamController<ResponseOb> purchaserequisitionListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getPurchaseRequisitionListStream() =>
      purchaserequisitionListStreamController
          .stream; // Purchase Requisiton List Stream Controller

  StreamController<ResponseOb> callactionconfirmStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCallActionConfirmStream() =>
      callactionconfirmStreamController.stream;

  StreamController<ResponseOb> callactionconfirmissueStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCallActionConfirmIssueStream() =>
      callactionconfirmissueStreamController.stream;

  StreamController<ResponseOb> callactionprocessStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCallActionProcessStream() =>
      callactionprocessStreamController.stream;

  late Odoo odoo;

  getPurchaseRequisitionListData(mrId) {
    print('EntergetPurchaseRequisitionListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    purchaserequisitionListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'purchase.requisition',
            [
              ['multi_mr_id', 'in', mrId]
            ],
            [
              'id',
              'name',
              'multi_mr_id',
            ],
            order: 'id asc');
        if (!res.hasError()) {
          print('PurchaseRequisitionResult:' +
              res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          purchaserequisitionListStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('GetPurchaseRequisitionError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          purchaserequisitionListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        purchaserequisitionListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        purchaserequisitionListStreamController.sink.add(responseOb);
      }
    }
  }

  getStockPickingData(materialId, state) async {
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
              materialId,
              state,
              ['picking_type_id.code', '=', 'internal']
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
  }

  callActionConfirm(id) async {
    print('callActionConfirm');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    callactionconfirmStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.callKW('stock.picking', 'button_validate', [id]);
        if (!res.hasError()) {
          print('callActionConfirm Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          callactionconfirmStreamController.sink.add(responseOb);
        } else {
          print(
              'GetcallActionConfirmError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          callactionconfirmStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        callactionconfirmStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        callactionconfirmStreamController.sink.add(responseOb);
      }
    }
  }

  callActionConfirmIssues(id) async {
    print('callActionConfirmIssue');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    callactionconfirmissueStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.callKW('stock.picking', 'action_confirm_issue', [id]);
        if (!res.hasError()) {
          print('callActionConfirmIssue Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          callactionconfirmissueStreamController.sink.add(responseOb);
        } else {
          print('GetcallActionConfirmIssueError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          callactionconfirmissueStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        callactionconfirmissueStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        callactionconfirmissueStreamController.sink.add(responseOb);
      }
    }
  }

  callActionProcess(id) async {
    print('callActionProcess');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    callactionprocessStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.callKW('stock.immediate.transfer', 'process', [id]);
        if (!res.hasError()) {
          print('callActionProcess Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          callactionprocessStreamController.sink.add(responseOb);
        } else {
          print(
              'GetcallActionProcessError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          callactionprocessStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        callactionprocessStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        callactionprocessStreamController.sink.add(responseOb);
      }
    }
  }

  dispose() {
    purchaserequisitionListStreamController.close();
    stockpickingStreamController.close();
    callactionconfirmStreamController.close();
    callactionconfirmissueStreamController.close();
    callactionprocessStreamController.close();
  }
}
