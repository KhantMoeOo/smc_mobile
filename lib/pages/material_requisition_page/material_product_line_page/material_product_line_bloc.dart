import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../services/odoo.dart';
import '../../../utils/app_const.dart';

class MaterialProductLineBloc {
  StreamController<ResponseOb> createMaterialProductLineStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getMaterialProductLineCreateStream() =>
      createMaterialProductLineStreamController.stream;

  StreamController<ResponseOb> getMaterialProductLineListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getMaterialProductLineListStream() =>
      getMaterialProductLineListStreamController.stream;

  late Odoo odoo;

  getMaterialProductLineListData(id) {
    print('EntergetMaterialProductLineListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    getMaterialProductLineListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'material.product.line',
            [
              ['material_porduct_id', '=', id]
            ],
            [
              'id',
              'material_porduct_id',
              'product_id',
              'product_code',
              'qty',
              'product_uom_id',
            ],
            order: 'product_id asc');
        if (!res.hasError()) {
          print('result');
          print('MaterialProductLineListResult:' +
              res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          getMaterialProductLineListStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print('GetMaterialProductLineListError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          getMaterialProductLineListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        getMaterialProductLineListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        getMaterialProductLineListStreamController.sink.add(responseOb);
      }
    }
  }

  createMaterialProductLine({
    materialproductId,
    productId,
    productName,
    qty,
    uomId,
  }) async {
    print('Create MaterialProductLine');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createMaterialProductLineStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('material.product.line', {
          'material_porduct_id': materialproductId,
          'product_id': productId,
          'product_code': productName,
          'qty': qty,
          'product_uom_id': uomId,
        });
        if (!res.hasError()) {
          print('MaterialProductLine Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          !createMaterialProductLineStreamController.isClosed
              ? createMaterialProductLineStreamController.sink.add(responseOb)
              : null;
        } else {
          print('GetMaterialProductLineCreateError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createMaterialProductLineStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createMaterialProductLineStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createMaterialProductLineStreamController.sink.add(responseOb);
      }
    }
  } // Create Material Product Line Bloc

  void dispose() {
    createMaterialProductLineStreamController.close();
    getMaterialProductLineListStreamController.close();
  }
}
