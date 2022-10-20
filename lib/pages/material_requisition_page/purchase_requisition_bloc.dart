import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class PurchaseRequisitionBloc {
  StreamController<ResponseOb> createPurchaseRequisitionStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCreatePurchaseRequisitionStream() =>
      createPurchaseRequisitionStreamController.stream;

  StreamController<ResponseOb> createPurchaseProductLineStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCreatePurchaseProductLineStream() =>
      createPurchaseProductLineStreamController.stream;

  late Odoo odoo;

  createPurchaseRequisition(
      {refno,
      requestPerson,
      departmentId,
      locationId,
      invoiceId,
      priority,
      orderdate,
      scheduledDate,
      multiMRId,
      description}) {
    print('Create Purchase Requisition');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createPurchaseRequisitionStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('purchase.requisition', {
          //'ref_no': refno,
          'request_person': requestPerson,
          'department_id': departmentId,
          'location_id': locationId,
          'invoice_ids': invoiceId,
          'priority': priority,
          'order_date': orderdate,
          'scheduled_date': scheduledDate,
          'multi_mr_id': multiMRId,
          'desc': description,
        });
        if (!res.hasError()) {
          print('PurchaseRequisition Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createPurchaseRequisitionStreamController.sink.add(responseOb);
        } else {
          print('GetCreatePurchaseRequisitionError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createPurchaseRequisitionStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createPurchaseRequisitionStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createPurchaseRequisitionStreamController.sink.add(responseOb);
      }
    }
  }

  createPurchaseProductLine({
    purchaseproductId,
    productId,
    productName,
    categId,
    qty,
    uomId,
  }) {
    print('Create MaterialProductLine');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createPurchaseProductLineStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('purchase.product.line', {
          'purchase_porduct_id': purchaseproductId,
          'product_id': productId,
          'product_code': productName,
          'categ_id': categId,
          'qty': qty,
          'product_uom_id': uomId,
        });
        if (!res.hasError()) {
          print('MaterialProductLine Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          !createPurchaseProductLineStreamController.isClosed
              ? createPurchaseProductLineStreamController.sink.add(responseOb)
              : null;
        } else {
          print('GetMaterialProductLineCreateError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createPurchaseProductLineStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createPurchaseProductLineStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createPurchaseProductLineStreamController.sink.add(responseOb);
      }
    }
  } // Create Material Product Line Bloc

  dispose() {
    createPurchaseRequisitionStreamController.close();
    createPurchaseProductLineStreamController.close();
  }
}
