import 'dart:async';

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

  late Odoo odoo;

  getWayPlanningListData({name}) {
    print('Enterget Way Planning ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    wayPlanningListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'trip.plan',
            [
              name
              // ['name', 'ilike', name],
              // ['trip_id', 'ilike', tripId],
              // ['leader_id', 'ilike', leaderId]
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
        if (res.getResult() != null) {
          print('result');
          print('Way Planning Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          wayPlanningListStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print('Get Way Planning Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          wayPlanningListStreamController.sink.add(responseOb);
        }
      });
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
        if (res.getResult() != null) {
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

  dispose() {
    wayPlanningListStreamController.close();
    tripconfigListStreamController.close();
  }
}
