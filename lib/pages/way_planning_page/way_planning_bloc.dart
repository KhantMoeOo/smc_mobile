import 'dart:async';
import 'dart:developer';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class WayPlanningBloc {
  StreamController<ResponseOb> wayPlanningListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getWayPlanningListStream() =>
      wayPlanningListStreamController
          .stream; // Way Planning List Stream Controller

  StreamController<ResponseOb> tripconfigListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getTripConfigListStream() => tripconfigListStreamController
      .stream; // Trip Configurataion List Stream Controller

  StreamController<ResponseOb> callvisitListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCallVisitListStream() =>
      callvisitListStreamController.stream; // callvisitListStreamController

  StreamController<ResponseOb> getfleetvehicleListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getfleetvehicleListStream() =>
      getfleetvehicleListStreamController
          .stream; // getfleetvehicleListStreamController

  StreamController<ResponseOb> getDriverListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getdriverListStream() =>
      getDriverListStreamController.stream; // getDriverListStreamController

  late Odoo odoo;

  getWayPlanningListData({name, filter}) {
    print('Enterget Way Planning ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    wayPlanningListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    Sharef.getOdooClientInstance().then((value) async {
      try {
        print('Try Get Way Plan List');
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'trip.plan',
            [
              name,
              filter,
            ],
            [
              'id',
              'name',
              'trip_id',
              'zone_id',
              'from_date',
              'to_date',
              'state',
              'leader_id'
            ],
            order: 'trip_id asc');
        if (!res.hasError()) {
          print('result');
          print('Way Planning Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          wayPlanningListStreamController.sink.add(responseOb);
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('Get Way Plan List Error: ${map['message']}');
              }
            },
          );
          print('Get Way Plan List Error:' + res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.severErr;
          wayPlanningListStreamController.sink.add(responseOb);
        }
      } catch (e) {
        print('catch');
        if (e.toString().contains("SocketException")) {
          responseOb.data = "Internet Connection Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.noConnection;
          wayPlanningListStreamController.sink.add(responseOb);
        } else {
          responseOb.data = "Unknown Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          wayPlanningListStreamController.sink.add(responseOb);
        }
      }
    });
  } // Get Way Planning List Data

  getTripConfigListData() {
    print('Enterget Trip Configuration ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    tripconfigListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'trip.configuration',
            [
              // ['name', 'ilike', name],
              // ['trip_id', 'ilike', tripId],
              // ['leader_id', 'ilike', leaderId]
            ],
            ['id', 'name', 'leader_id'],
            order: 'name asc');
        if (!res.hasError()) {
          print('Trip result');
          print('Trip Config Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          tripconfigListStreamController.sink.add(responseOb);
        } else {
          print('Trip configerror');
          data = null;
          print('Get Trip confige error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          tripconfigListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Trip Configcatch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        tripconfigListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        tripconfigListStreamController.sink.add(responseOb);
      }
    }
  } // Get Way Planning List Data

  getCallVisitList({zone, filter}) async {
    print('EntergetCall-Visit List');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    callvisitListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    Sharef.getOdooClientInstance().then((value) async {
      try {
        print('try getCall-Visit List');
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'call.visit',
            [
              zone,
              filter,
            ],
            [
              'id',
              'customer_id',
              'zone_id',
              'arl_time',
              'dept_time',
              'fleet_id',
              'driver_id',
              'remark',
              'state',
              'lt',
              'lg',
              'action_image',
              'action_image_out',
              'way_id',
              'township_id',
              'date'
            ],
            order: 'id desc');
        if (!res.hasError()) {
          print('getCall-Visit ListResult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !callvisitListStreamController.isClosed
              ? callvisitListStreamController.sink.add(responseOb)
              : null;
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('getCall-Visit List Error: ${map['message']}');
              }
            },
          );
          print('getCall-Visit List Error:' + res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.severErr;
          callvisitListStreamController.sink.add(responseOb);
        }
      } catch (e) {
        print('getCall-Visit List catch: $e');
        if (e.toString().contains("SocketException")) {
          responseOb.data = "Internet Connection Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.noConnection;
          callvisitListStreamController.sink.add(responseOb);
        } else {
          responseOb.data = "Unknown Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          callvisitListStreamController.sink.add(responseOb);
        }
      }
    });
  } // Call-Visit list

  getFleetList() async {
    print('Enter get Fleet Vehicle List');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    getfleetvehicleListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    Sharef.getOdooClientInstance().then((value) async {
      try {
        print('try get Fleet Vehicle List');
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'fleet.vehicle',
            [],
            [
              // 'id',
              // 'customer_id',
              // 'zone_id',
              // 'arl_time',
              // 'dept_time',
              // 'fleet_id',
              // 'driver_id',
              // 'remark',
              // 'state'
            ],
            order: 'id desc');
        if (!res.hasError()) {
          print('get Fleet Vehicle List Result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !getfleetvehicleListStreamController.isClosed
              ? getfleetvehicleListStreamController.sink.add(responseOb)
              : null;
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('get Fleet Vehicle List Error: ${map['message']}');
              }
            },
          );
          print(
              'get Fleet Vehicle List Error:' + res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.severErr;
          getfleetvehicleListStreamController.sink.add(responseOb);
        }
      } catch (e) {
        print('get Fleet Vehicle List catch: $e');
        if (e.toString().contains("SocketException")) {
          responseOb.data = "Internet Connection Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.noConnection;
          getfleetvehicleListStreamController.sink.add(responseOb);
        } else {
          responseOb.data = "Unknown Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          getfleetvehicleListStreamController.sink.add(responseOb);
        }
      }
    });
  } // get Fleet Vehicle list

  getDriverList() async {
    print('Enter getDriverList');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    getDriverListStreamController.sink.add(responseOb);
    List<dynamic>? data;
    String userId = '';

    Sharef.getOdooClientInstance().then((value) async {
      try {
        print('try getDriverList');
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        userId = value['uid'];
        OdooResponse res = await odoo.searchRead(
            'hr.employee',
            [
              // ['user_id', '=', int.parse(userId)]
            ],
            [
              'id',
              'name',
              // 'zone_id',
              // 'arl_time',
              // 'dept_time',
              // 'fleet_id',
              // 'driver_id',
              // 'remark',
              // 'state'
            ],
            order: 'id desc');
        if (!res.hasError()) {
          print('getDriverList Result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !getDriverListStreamController.isClosed
              ? getDriverListStreamController.sink.add(responseOb)
              : null;
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('getDriverList Error: ${map['message']}');
              }
            },
          );
          print('getDriverList Error:' + res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.severErr;
          getDriverListStreamController.sink.add(responseOb);
        }
      } catch (e) {
        print('getDriverList catch: $e');
        if (e.toString().contains("SocketException")) {
          responseOb.data = "Internet Connection Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.noConnection;
          getDriverListStreamController.sink.add(responseOb);
        } else {
          responseOb.data = "Unknown Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          getDriverListStreamController.sink.add(responseOb);
        }
      }
    });
  } // getDriverList

  dispose() {
    wayPlanningListStreamController.close();
    tripconfigListStreamController.close();
    callvisitListStreamController.close();
    getfleetvehicleListStreamController.close();
    getDriverListStreamController.close();
  }
}
