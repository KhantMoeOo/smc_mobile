import 'dart:async';
import 'dart:developer';

import 'package:odoo_api/odoo_api_connector.dart';
import 'package:odoo_api/odoo_user_response.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class TripPlanCreateBloc {
  StreamController<ResponseOb> createTripPlanStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> createTripPlanStream() =>
      createTripPlanStreamController.stream; // Trip Plan Create Controller

  StreamController<ResponseOb> createHrEmployeeLineStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> createHrEmployeeLineStream() =>
      createHrEmployeeLineStreamController
          .stream; // Hr Employee Line Create Controller

  StreamController<ResponseOb> createTripPlanScheduleStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> createTripPlanScheduleStream() =>
      createTripPlanScheduleStreamController
          .stream; // TripPlanSchedule Create Controller

  StreamController<ResponseOb> createTripPlanDeliveryStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> createTripPlanDeliveryStream() =>
      createTripPlanDeliveryStreamController
          .stream; // TripPlanDelivery Create Controller

  StreamController<ResponseOb> createCallVisitStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> createCallVisitStream() =>
      createCallVisitStreamController.stream; // Call Visit Create Controller

  late Odoo odoo;

  createTripPlan(tripName, zoneId, userId, fromDate, toDate, leaderId) async {
    print('Create Way Plan');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createTripPlanStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('trip.plan', {
          'name': tripName,
          'zone_id': zoneId,
          'user_id': userId,
          'from_date': fromDate,
          'to_date': toDate,
          'leader_id': leaderId
        });
        if (!res.hasError()) {
          print('Trip Plan Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createTripPlanStreamController.sink.add(responseOb);
        } else {
          print('GetCreateTripPlanError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createTripPlanStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createTripPlanStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createTripPlanStreamController.sink.add(responseOb);
      }
    }
  } // Create Trip Plan

  createHrEmployeeLine(
      tripId, empNameId, departmentId, jobId, mrResponsible) async {
    print('Create Hr Employee Line');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createHrEmployeeLineStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('hr.employee.line', {
          'trip_line': tripId,
          'emp_name': empNameId,
          'department_id': departmentId,
          'job_id': jobId,
          'mr_responsible': mrResponsible
        });
        if (!res.hasError()) {
          print('Hr Employee Line Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createHrEmployeeLineStreamController.sink.add(responseOb);
        } else {
          print('GetCreateHr Employee LineError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createHrEmployeeLineStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createHrEmployeeLineStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createHrEmployeeLineStreamController.sink.add(responseOb);
      }
    }
  } // Create Hr Employee Line

  createTripPlanSchedule(tripId, fromDate, toDate, locationId, remark) async {
    print('Create Trip Plan Schedule');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createTripPlanScheduleStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('trip.plan.schedule', {
          'trip_id': tripId,
          'from_date': fromDate,
          'to_date': toDate,
          'location_id': locationId,
          'remark': remark
        });
        if (!res.hasError()) {
          print('Trip Plan Schedule Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createTripPlanScheduleStreamController.sink.add(responseOb);
        } else {
          print('GetCreateTrip Plan ScheduleError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createTripPlanScheduleStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createTripPlanScheduleStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createTripPlanScheduleStreamController.sink.add(responseOb);
      }
    }
  } // Create Trip Plan Schedule

  createTripPlanDelivery(tripId, teamId, assignPerson, zoneId, invoiceId,
      orderId, state, invoiceStatus, remark) async {
    print('Create TripPlanDelivery');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createTripPlanDeliveryStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('trip.plan.delivery', {
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
        if (!res.hasError()) {
          print('TripPlanDelivery Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createTripPlanDeliveryStreamController.sink.add(responseOb);
        } else {
          print('GetCreateTripPlanDeliveryError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createTripPlanDeliveryStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createTripPlanDeliveryStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createTripPlanDeliveryStreamController.sink.add(responseOb);
      }
    }
  } // Create TripPlanDelivery

  createCallVisit(
      {arrivalImage,
        townshipId,
      wayplanId,
      customerId,
      date,
      arlTime,
      deptTime,
      lt,
      lg,
      zoneId,
      fleetId,
      driverId,
      remark}) async {
    print('Create Call Visit');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createCallVisitStreamController.sink.add(responseOb);
    Sharef.getOdooClientInstance().then((value) async {
      try {
        print('Try Create Call Visit');
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('call.visit', {
          'action_image': arrivalImage,
          'way_id': wayplanId,
          'township_id': townshipId,
          'customer_id': customerId,
          'date': date,
          'arl_time': arlTime,
          'dept_time': deptTime,
          'lt': lt,
          'lg': lg,
          'zone_id': zoneId,
          'fleet_id': fleetId,
          'driver_id': driverId,
          'remark': remark
        });
        if (!res.hasError()) {
          print('Create Call Visit Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createCallVisitStreamController.sink.add(responseOb);
        } else {
          res.getError().forEach(
            (key, value) {
              if (key == 'data') {
                Map map = value;
                responseOb.data = map['message'];
                log('Create Call Visit Error: ${map['message']}');
              }
            },
          );
          print('Create Call Visit Error:' + res.getError().keys.toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createCallVisitStreamController.sink.add(responseOb);
        }
      } catch (e) {
        print('catch');
        if (e.toString().contains("SocketException")) {
          responseOb.data = "Internet Connection Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.noConnection;
          createCallVisitStreamController.sink.add(responseOb);
        } else {
          responseOb.data = "Unknown Error";
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createCallVisitStreamController.sink.add(responseOb);
        }
      }
    });
  } // Create Call Visit

  dispose() {
    createTripPlanStreamController.close();
    createHrEmployeeLineStreamController.close();
    createTripPlanScheduleStreamController.close();
    createTripPlanDeliveryStreamController.close();
    createCallVisitStreamController.close();
  }
}
