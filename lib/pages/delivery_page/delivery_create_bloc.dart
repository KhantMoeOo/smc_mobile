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
  Stream<ResponseOb> getCreateStockPickingStream() => createStockPickingStreamController.stream; // Create Stocking Picking Stream Controller

  late Odoo odoo;

  stockpickingCreate({partnerId, refNo, pickingtypeId, locationId, locationDestId, scheduledDate, origin, saleId, state}) async {
    print('Create Stocking Picking');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createStockPickingStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('stock.picking', {
              'partner_id' : partnerId,
              'ref_no' : refNo,
              'picking_type_id': pickingtypeId,
              'location_id': locationId,
              'location_dest_id': locationDestId,
              'scheduled_date' : scheduledDate,
              'origin' : origin,
              'sale_id' : saleId,
              'state': state,
        });
        if (res.getResult() != null) {
          print('Invoice Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createStockPickingStreamController.sink.add(responseOb);
        } else {
          print('GetCreateInvoiceError:' + res.getErrorMessage().toString());
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

  dispose() {
    createStockPickingStreamController.close();
  }
}