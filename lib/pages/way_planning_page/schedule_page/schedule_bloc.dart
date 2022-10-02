import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';

import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../services/odoo.dart';
import '../../../utils/app_const.dart';

class ScheduleBloc {
  StreamController<ResponseOb> scheduleListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getScheduleListStream() =>
      scheduleListStreamController.stream; // Schedule List Stream Controller

  StreamController<ResponseOb> townshipListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getTownshipListStream() =>
      townshipListStreamController.stream; // Township List Stream Controller

  late Odoo odoo;

  getScheduleListData() {
    print('Enterget Schedule ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    scheduleListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
          'trip.plan.schedule',
          [],
          ['id', 'trip_id', 'from_date', 'to_date', 'location_id', 'remark'],
          // order: 'emp_name asc'
        );
        if (res.getResult() != null) {
          print('Trip Plan Schedule Result:' +
              res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          scheduleListStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('Get Trip Plan Schedule Error:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          scheduleListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Trip Plan Schedule catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        scheduleListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        scheduleListStreamController.sink.add(responseOb);
      }
    }
  } // Get Trip Plan Schedule List Data

  getTownshipListData(cityId) {
    print('Enterget Township ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    townshipListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
          'res.township',
          [
            ['city_id.id', '=', cityId]
          ],
          ['id', 'name','city_id'],
          // order: 'emp_name asc'
        );
        if (res.getResult() != null) {
          print('Township Result:' +
              res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          townshipListStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('Get township Error:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          townshipListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Township catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        townshipListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        townshipListStreamController.sink.add(responseOb);
      }
    }
  } // Get Township List Data

  dispose() {
    scheduleListStreamController.close();
    townshipListStreamController.close();
  }
}
