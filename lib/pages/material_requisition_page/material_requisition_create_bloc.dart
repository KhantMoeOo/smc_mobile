import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import 'package:odoo_api/odoo_user_response.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class MaterialRequisitionCreateBloc {
  StreamController<ResponseOb> createMaterialRequisitionStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCreateMaterialRequisitionStream() =>
      createMaterialRequisitionStreamController.stream;

  StreamController<ResponseOb> updateMaterialRequisitionStatusStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getUpdateMaterialRequisitionStatusStream() =>
      updateMaterialRequisitionStatusStreamController.stream;

  StreamController<ResponseOb> callActionConfirmStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCallActionConfirmStream() =>
      callActionConfirmStreamController.stream;

  late Odoo odoo;

  createMaterialRequisition(
      {
      //refno,
      zoneId,
      requestPerson,
      departmentId,
      locationId,
      //invoiceId,
      priority,
      orderdate,
      scheduledDate,
      description}) async {
    print('Create MaterialRequisition');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createMaterialRequisitionStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('material.requisition', {
          'multi_config': 'sale',
          //'ref_no': refno,
          'zone_id': zoneId,
          'request_person': requestPerson,
          'department_id': departmentId,
          'location_id': locationId,
          //'invoice_id': invoiceId,
          'priority': priority,
          'order_date': orderdate,
          'scheduled_date': scheduledDate,
          'desc': description,
        });
        if (!res.hasError()) {
          print('MaterialRequisition Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createMaterialRequisitionStreamController.sink.add(responseOb);
        } else {
          print('GetCreateMaterialRequisitionError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createMaterialRequisitionStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createMaterialRequisitionStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createMaterialRequisitionStreamController.sink.add(responseOb);
      }
    }
  }

  updateMaterialRequisitionStatusData(ids, state) {
    print('EnterupdateQuotationStatusData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    updateMaterialRequisitionStatusStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.write('material.requisition', [ids], {'state': state});
        if (!res.hasError()) {
          print('result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          updateMaterialRequisitionStatusStreamController.sink.add(responseOb);
        } else {
          print('error');
          print(
              'updateQuotationStatusError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          updateMaterialRequisitionStatusStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        updateMaterialRequisitionStatusStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        updateMaterialRequisitionStatusStreamController.sink.add(responseOb);
      }
    }
  } // updateMaterial RequisitionStatus Data

  // callActionConfirm(ids) {
  //   print('EntercallActionConfirm');
  //   ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
  //   callActionConfirmStreamController.sink.add(responseOb);

  //   try {
  //     print('Try');
  //     Sharef.getOdooClientInstance().then((value) async {
  //       odoo = Odoo(BASEURL);
  //       odoo.setSessionId(value['session_id']);
  //       OdooResponse res =
  //           await odoo.callKW('material.requisition', 'action_confirm', [ids]);
  //       if (!res.hasError()) {
  //         print('callActionConfirmresult');
  //         // data = res.getResult()['records'];
  //         responseOb.msgState = MsgState.data;
  //         responseOb.data = res.getResult();
  //         callActionConfirmStreamController.sink.add(responseOb);
  //       } else {
  //         print('error');
  //         print('callActionConfirmError:' + res.getErrorMessage().toString());
  //         responseOb.msgState = MsgState.error;
  //         responseOb.errState = ErrState.unKnownErr;
  //         callActionConfirmStreamController.sink.add(responseOb);
  //       }
  //     });
  //   } catch (e) {
  //     print('catch');
  //     if (e.toString().contains("SocketException")) {
  //       responseOb.data = "Internet Connection Error";
  //       responseOb.msgState = MsgState.error;
  //       responseOb.errState = ErrState.noConnection;
  //       callActionConfirmStreamController.sink.add(responseOb);
  //     } else {
  //       responseOb.data = "Unknown Error";
  //       responseOb.msgState = MsgState.error;
  //       responseOb.errState = ErrState.unKnownErr;
  //       callActionConfirmStreamController.sink.add(responseOb);
  //     }
  //   }
  // } // callActionConfirm

  callActionConfirm(id) async {
    print('callActionConfirm');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    callActionConfirmStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.callKW('material.requisition', 'action_confirm', [id]);
        if (!res.hasError()) {
          print('callActionConfirm Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          callActionConfirmStreamController.sink.add(responseOb);
        } else {
          print(
              'GetcallActionConfirmError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          callActionConfirmStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
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
  } // callActionConfirm

  dispose() {
    createMaterialRequisitionStreamController.close();
    updateMaterialRequisitionStatusStreamController.close();
    callActionConfirmStreamController.close();
  }
}
