import 'dart:async';

import 'package:flutter/material.dart';
import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class WayPlanningEditBloc {
  StreamController<ResponseOb> wayplanningEditStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getWayPlanningEditStream() =>
      wayplanningEditStreamController
          .stream; // Way Planning Edit Stream Controller

  StreamController<ResponseOb> hremployeelineEditStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getHrEmployeeLineEditStream() =>
      hremployeelineEditStreamController
          .stream; // Hr Employee Line Edit Stream Controller

  StreamController<ResponseOb> tripplanscheduleEditStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getTripPlanScheduleEditStream() =>
      tripplanscheduleEditStreamController
          .stream; // tripplanschedule Edit Stream Controller

  StreamController<ResponseOb> tripplandeliveryEditStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getTripPlanDeliveryEditStream() =>
      tripplandeliveryEditStreamController
          .stream; // tripplandelivery Edit Stream Controller

  late Odoo odoo;

  editWayPlanningData(ids, tripName, zoneId, fromDate, toDate, leaderId) {
    print('EnterEditWay PlanningData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    wayplanningEditStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('trip.plan', [
          ids
        ], {
          'name': tripName,
          'zone_id': zoneId,
          'from_date': fromDate,
          'to_date': toDate,
          'leader_id': leaderId
        });
        if (res.getResult() != null) {
          print('Way Plannin edit result: ${res.getResult()}');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          wayplanningEditStreamController.sink.add(responseOb);
        } else {
          print('Way Plannin edit Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          wayplanningEditStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        wayplanningEditStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        wayplanningEditStreamController.sink.add(responseOb);
      }
    }
  } // Edit Way Plannig Data

  editHrEmployeeLineData(
      ids, tripId, empNameId, departmentId, jobId, mrResponsible) {
    print('EnterEditHrEmployeeLineData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    hremployeelineEditStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('hr.employee.line', [
          ids
        ], {
          'trip_line': tripId,
          'emp_name': empNameId,
          'department_id': departmentId,
          'job_id': jobId,
          'mr_responsible': mrResponsible
        });
        if (res.getResult() != null) {
          print('HrEmployeeLine edit result: ${res.getResult()}');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          hremployeelineEditStreamController.sink.add(responseOb);
        } else {
          print(
              'HrEmployeeLine edit Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          hremployeelineEditStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        hremployeelineEditStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        hremployeelineEditStreamController.sink.add(responseOb);
      }
    }
  } // Edit HrEmployeeLine Data

  editTripPlanScheduleData(ids, tripId, fromDate, toDate, locationId, remark) {
    print('EnterEditTripPlanScheduleData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    tripplanscheduleEditStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('trip.plan.schedule', [
          ids
        ], {
          'trip_id': tripId,
          'from_date': fromDate,
          'to_date': toDate,
          'location_id': locationId,
          'remark': remark
        });
        if (res.getResult() != null) {
          print('TripPlanSchedule edit result: ${res.getResult()}');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          tripplanscheduleEditStreamController.sink.add(responseOb);
        } else {
          print('TripPlanSchedule edit Error:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          tripplanscheduleEditStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        tripplanscheduleEditStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        tripplanscheduleEditStreamController.sink.add(responseOb);
      }
    }
  } // Edit TripPlanSchedule Data

  editTripPlanDeliveryData(ids, tripId, teamId, assignPerson, zoneId, invoiceId,
      orderId, state, invoiceStatus, remark) {
    print('EnterEditTripPlanDeliveryData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    tripplandeliveryEditStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('trip.plan.delivery', [
          ids
        ], {
          'trip_id': tripId,
          'team_id': teamId,
          'assign_person': assignPerson,
          'zone_id': zoneId,
          'invoice_id': invoiceId,
          'order_id': orderId,
          'state': state,
          'invoice_status': invoiceStatus,
          'remark': remark
        });
        if (res.getResult() != null) {
          print('TripPlanDelivery edit result: ${res.getResult()}');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          tripplandeliveryEditStreamController.sink.add(responseOb);
        } else {
          print('TripPlanDelivery edit Error:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          tripplandeliveryEditStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        tripplandeliveryEditStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        tripplandeliveryEditStreamController.sink.add(responseOb);
      }
    }
  } // Edit TripPlanDelivery Data

  dispose() {
    wayplanningEditStreamController.close();
    hremployeelineEditStreamController.close();
    tripplanscheduleEditStreamController.close();
    tripplandeliveryEditStreamController.close();
  }
}
