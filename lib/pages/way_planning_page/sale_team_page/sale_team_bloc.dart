import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../services/odoo.dart';
import '../../../utils/app_const.dart';

class SaleTeamBloc {
  StreamController<ResponseOb> saleteamListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getSaleTeamListStream() =>
      saleteamListStreamController
          .stream; // sale team List Stream Controller

  StreamController<ResponseOb> hrdepartmentListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getHrDeparmentListStream() =>
      hrdepartmentListStreamController
          .stream; // Hr Department List Stream Controller

  StreamController<ResponseOb> hrJobListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getHrJobListStream() =>
      hrJobListStreamController.stream; // HrJob List Stream Controller

  late Odoo odoo;

  getSaleTeamListData() {
    print('Enterget Hr Department ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    saleteamListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'hr.employee.line',
            [],
            [
              'id',
              'trip_line',
              'emp_name',
              'department_id',
              'job_id',
              'mr_responsible'
            ],
            order: 'emp_name asc');
        if (res.getResult() != null) {
          print(
              'Hr Employee line Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          saleteamListStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print('Get Hr Department Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          saleteamListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Hr Departmentcatch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        saleteamListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        saleteamListStreamController.sink.add(responseOb);
      }
    }
  } // Get Hr Employee Line List Data

  getHrDeparmentListData() {
    print('Enterget Hr Department ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    hrdepartmentListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'hr.department',
            [
              // ['name', 'ilike', name],
              // ['trip_id', 'ilike', tripId],
              // ['leader_id', 'ilike', leaderId]
            ],
            [
              'id',
              'name',
              'company_id'
              // 'trip_id',
              // 'zone_id',
              // 'from_date',
              // 'to_date',
              // 'state',
              // 'leader_id'
            ],
            order: 'name asc');
        if (res.getResult() != null) {
          print('Hr Departmentresult');
          print(
              'Hr department Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          hrdepartmentListStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print('Get Hr Department Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          hrdepartmentListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Hr Departmentcatch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        hrdepartmentListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        hrdepartmentListStreamController.sink.add(responseOb);
      }
    }
  } // Get Hr Department List Data

  getHrJobListData() {
    print('Enterget Hr Job ListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    hrJobListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'hr.job',
            [
              // ['name', 'ilike', name],
              // ['trip_id', 'ilike', tripId],
              // ['leader_id', 'ilike', leaderId]
            ],
            [
              'id',
              'name',
              'company_id'
              // 'trip_id',
              // 'zone_id',
              // 'from_date',
              // 'to_date',
              // 'state',
              // 'leader_id'
            ],
            order: 'name asc');
        if (res.getResult() != null) {
          print('Hr Job result');
          print('Hr Job Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          hrJobListStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print('Get Hr Department Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          hrJobListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Hr Departmentcatch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        hrJobListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        hrJobListStreamController.sink.add(responseOb);
      }
    }
  } // Get Hr Job List Data

  dispose() {
    saleteamListStreamController.close();
    hrdepartmentListStreamController.close();
    hrJobListStreamController.close();
  }
}
