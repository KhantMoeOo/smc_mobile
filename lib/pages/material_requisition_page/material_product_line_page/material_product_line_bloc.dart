import 'dart:async';
import 'dart:developer';

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

  StreamController<ResponseOb> getDeleteMaterialProductLineStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getDeleteMaterialProductLineStream() =>
      getDeleteMaterialProductLineStreamController.stream;

  StreamController<ResponseOb> getEditMaterialProductLineStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getEditMaterialProductLineStream() =>
      getEditMaterialProductLineStreamController.stream;

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

  editMaterialProductLineData(
      {ids, materialproductId, productId, productName, qty, uomId}) {
    print('EntereditMaterialProductLineData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    getEditMaterialProductLineStreamController.sink.add(responseOb);

    Sharef.getOdooClientInstance().then((value) async {
      try {
        print('Try Edit Material Product Line');
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('material.product.line', [
          ids
        ], {
          'material_porduct_id': materialproductId,
          'product_id': productId,
          'product_code': productName,
          'qty': qty,
          'product_uom_id': uomId,
        });
        if (!res.hasError()) {
          print('Edit MaterialProductLine result');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          !getEditMaterialProductLineStreamController.isClosed
              ? getEditMaterialProductLineStreamController.sink.add(responseOb)
              : null;
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('Get Edit Material Product Line Error: ${map['message']}');
              }
            },
          );
          print('Get Edit Material Product Line Error:' +
              res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          getEditMaterialProductLineStreamController.sink.add(responseOb);
        }
      } catch (e) {
        print('Edit MaterialProductLine catch');
        if (e.toString().contains("SocketException")) {
          responseOb.data = "Internet Connection Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.noConnection;
          getEditMaterialProductLineStreamController.sink.add(responseOb);
        } else {
          responseOb.data = "Unknown Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          getEditMaterialProductLineStreamController.sink.add(responseOb);
        }
      }
    });
  }

  deleteMaterialProductLineData(ids) {
    print('Enter Delete MaterialProductLine Data');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    getDeleteMaterialProductLineStreamController.sink.add(responseOb);

    Sharef.getOdooClientInstance().then((value) async {
      try {
        print('Try Delete Material Product Line');
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.unlink('material.product.line', [ids]);
        if (!res.hasError()) {
          print('Delete MaterialProductLine result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          getDeleteMaterialProductLineStreamController.sink.add(responseOb);
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('Get Delete Material Product Line Error: ${map['message']}');
              }
            },
          );
          print('Get Delete Material Product Line Error:' +
              res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          getDeleteMaterialProductLineStreamController.sink.add(responseOb);
        }
      } catch (e) {
        print('MaterialProductLine Delete catch');
        if (e.toString().contains("SocketException")) {
          responseOb.data = "Internet Connection Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.noConnection;
          getDeleteMaterialProductLineStreamController.sink.add(responseOb);
        } else {
          responseOb.data = "Unknown Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          getDeleteMaterialProductLineStreamController.sink.add(responseOb);
        }
      }
    });
  }

  void dispose() {
    createMaterialProductLineStreamController.close();
    getMaterialProductLineListStreamController.close();
    getDeleteMaterialProductLineStreamController.close();
  }
}
