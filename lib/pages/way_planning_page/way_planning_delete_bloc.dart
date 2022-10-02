import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class DeleteWayPlanBloc {
  StreamController<ResponseOb> wayPlanDeleteStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> deleteWayPlanStream() =>
      wayPlanDeleteStreamController.stream; // WayPlanDelete Stream Controller

  StreamController<ResponseOb> hremployeelineDeleteStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> deleteHrEmployeeLineStream() =>
      hremployeelineDeleteStreamController
          .stream; // HrEmployeelineDelete Stream Controller

  StreamController<ResponseOb> tripplanscheduleDeleteStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> deleteTripPlanScheduleStream() =>
      tripplanscheduleDeleteStreamController
          .stream; // tripplanscheduleDeleteStreamController

  StreamController<ResponseOb> tripplandeliveryDeleteStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> deleteTripPlanDeliveryStream() =>
      tripplandeliveryDeleteStreamController
          .stream; // tripplandeliveryDeleteStreamController

  late Odoo odoo;

  deleteWayPlanData(ids) {
    print('Enter Delete Quotation Data');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    wayPlanDeleteStreamController.sink.add(responseOb);

    try {
      print('Quotation Delete Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.unlink('trip.plan', [ids]);
        if (res.getResult() != null) {
          print('Way Plan delete result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          wayPlanDeleteStreamController.sink.add(responseOb);
        } else {
          print('DeleteWay PlanError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          wayPlanDeleteStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Way Plan Delete catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        wayPlanDeleteStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        wayPlanDeleteStreamController.sink.add(responseOb);
      }
    }
  } // Delete Way Plan records

  deleteHrEmployeeLineData(ids) {
    print('Enter Delete HrEmployeeLine Data');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    hremployeelineDeleteStreamController.sink.add(responseOb);

    try {
      print('HrEmployeeLine Delete Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.unlink('hr.employee.line', [ids]);
        if (res.getResult() != null) {
          print('HrEmployeeLine delete result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          hremployeelineDeleteStreamController.sink.add(responseOb);
        } else {
          print(
              'DeleteHrEmployeeLineError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          hremployeelineDeleteStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('HrEmployeeLine Delete catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        hremployeelineDeleteStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        hremployeelineDeleteStreamController.sink.add(responseOb);
      }
    }
  } // Delete HrEmployeeLine records

  deleteTripPlanScheduleData(ids) {
    print('Enter Delete TripPlanSchedule Data');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    tripplanscheduleDeleteStreamController.sink.add(responseOb);

    try {
      print('TripPlanSchedule Delete Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.unlink('trip.plan.schedule', [ids]);
        if (res.getResult() != null) {
          print('TripPlanSchedule delete result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          tripplanscheduleDeleteStreamController.sink.add(responseOb);
        } else {
          print(
              'DeleteTripPlanScheduleError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          tripplanscheduleDeleteStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('TripPlanSchedule Delete catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        tripplanscheduleDeleteStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        tripplanscheduleDeleteStreamController.sink.add(responseOb);
      }
    }
  } // Delete TripPlanSchedule records

  deleteTripPlanDeliveryData(ids) {
    print('Enter Delete TripPlanDelivery Data');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    tripplandeliveryDeleteStreamController.sink.add(responseOb);

    try {
      print('TripPlanDelivery Delete Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.unlink('trip.plan.delivery', [ids]);
        if (res.getResult() != null) {
          print('TripPlanDelivery delete result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          tripplandeliveryDeleteStreamController.sink.add(responseOb);
        } else {
          print(
              'DeleteTripPlanDeliveryError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          tripplandeliveryDeleteStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('TripPlanDelivery Delete catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        tripplandeliveryDeleteStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        tripplandeliveryDeleteStreamController.sink.add(responseOb);
      }
    }
  } // Delete TripPlanDelivery records

  dispose() {
    wayPlanDeleteStreamController.close();
    hremployeelineDeleteStreamController.close();
    tripplanscheduleDeleteStreamController.close();
    tripplandeliveryDeleteStreamController.close();
  }
}
