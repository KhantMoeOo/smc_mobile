import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';

import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../services/odoo.dart';
import '../../../utils/app_const.dart';

class DeliveryBloc{
  StreamController<ResponseOb> deliveryListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getDeliveryListStream() =>
      deliveryListStreamController
          .stream; // Delivery List Stream Controller

  StreamController<ResponseOb> crmTeamListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCRMTeamListStream() =>
      crmTeamListStreamController
          .stream; // CRM Team List Stream Controller

  StreamController<ResponseOb> accountmoveListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getAccountMoveListStream() =>
      accountmoveListStreamController
          .stream; // Account Move List Stream Controller

  StreamController<ResponseOb> orderListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getOrderListStream() =>
      orderListStreamController
          .stream; // Order List Stream Controller

  late Odoo odoo;

  getDeliveryListData() {
    print('Enterget Delivery ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    deliveryListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'trip.plan.delivery',
            [],
            [
              'id',
              'trip_id',
              'team_id',
              'assign_person',
              'zone_id',
              'invoice_id',
              'order_id',
              'state',
              'invoice_status',
              'remark'
            ],
            // order: 'emp_name asc'
            );
        if (res.getResult() != null) {
          print(
              'Trip Plan Delivery Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          deliveryListStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('Get Trip Plan Delivery Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          deliveryListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Trip Plan Delivery catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        deliveryListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        deliveryListStreamController.sink.add(responseOb);
      }
    }
  } // Get Trip Plan Delivery List Data

  getCRMTeamListData() {
    print('Enterget CRM Team ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    crmTeamListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'crm.team',
            [],
            [
              'id',
              'name',
              'zone_id'
            ],
            // order: 'emp_name asc'
            );
        if (res.getResult() != null) {
          print(
              'CRM Team Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          crmTeamListStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('Get CRM Team Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          crmTeamListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('CRM Team catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        crmTeamListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        crmTeamListStreamController.sink.add(responseOb);
      }
    }
  } // Get CRM Team List Data

  getAccountMoveListData() {
    print('Enterget Account Move ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    accountmoveListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'account.move',
            [['type', '=', 'out_invoice']],
            [
              'id',
              'name',
              'invoice_origin',
              'type'
            ],
            // order: 'emp_name asc'
            );
        if (res.getResult() != null) {
          print(
              'Account move Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          accountmoveListStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('Get account move Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          accountmoveListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('account move catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        accountmoveListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        accountmoveListStreamController.sink.add(responseOb);
      }
    }
  } // Get account move List Data

  getOrderListData() {
    print('Enterget Order ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    orderListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'sale.order',
            [],
            [
              'id',
              'name',
              'state',
              'invoice_status'
            ],
            // order: 'emp_name asc'
            );
        if (res.getResult() != null) {
          print(
              'Order Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          orderListStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('Get Order Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          orderListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Order catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        orderListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        orderListStreamController.sink.add(responseOb);
      }
    }
  } // Get Order List Data

  dispose(){
    deliveryListStreamController.close();
    crmTeamListStreamController.close();
    accountmoveListStreamController.close();
    orderListStreamController.close();
  }
}