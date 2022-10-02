import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class ProfileBloc {
  StreamController<ResponseOb> profileStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getProfileStream() =>
      profileStreamController.stream; // Get Profile Stream Controller

  StreamController<ResponseOb> hremployeeStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getHrEmployeeStream() =>
      hremployeeStreamController.stream; // Get Hr Employee Stream Controller

  StreamController<ResponseOb> resusersStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getResUsersStream() =>
      resusersStreamController.stream; // Get Res Users Stream Controller

  late Odoo odoo;

  getProfileData() async {
    String userId = '';
    print('EntergetProfileData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    profileStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        userId = value['uid'];
        OdooResponse res = await odoo.searchRead(
            'hr.employee',
            [
              ['user_id', '=', int.parse(userId)]
            ],
            [
              'id',
              'name',
              'job_title',
              'department_id',
              'mobile_phone',
              'work_location_id',
              'parent_id',
              'ssb_register_no',
              'image_128',
              'emp_id',
              'user_id',
              'mobile_phone',
              'work_phone',
              'work_email',
              'job_id',
              'home_address',
              'marital',
              'nrc_no',
              'nrc_code',
              'nrc_number',
              'nrc_desc',
              'passport_id',
              'gender',
              'birthday',
              'age',
            ],
            order: 'name asc');
        if (res.getResult() != null) {
          print('Get Profile result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          profileStreamController.sink.add(responseOb);
        } else {
          print('Get Profileerror');
          data = null;
          print('GetProfileError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          profileStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        profileStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        profileStreamController.sink.add(responseOb);
      }
    }
  } // get Profile

  getHrEmployeeData() async {
    String userId = '';
    print('EntergetHrEmployeeData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    hremployeeStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
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
              // 'job_title',
              'department_id',
              // 'mobile_phone',
              // 'image_128',
              // 'emp_id',
              // 'user_id',
              // 'mobile_phone',
              // 'work_phone',
              // 'work_email',
              'job_id',
              // 'home_address',
              // 'marital',
              // 'nrc_no',
              // 'nrc_code',
              // 'nrc_number',
              // 'nrc_desc',
              // 'passport_id',
              // 'gender',
              // 'birthday',
              // 'age',
            ],
            order: 'name asc');
        if (res.getResult() != null) {
          print('Get hr employee result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          hremployeeStreamController.sink.add(responseOb);
        } else {
          print('Get hr employee error');
          data = null;
          print('GetHrEmployeeError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          hremployeeStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        hremployeeStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        hremployeeStreamController.sink.add(responseOb);
      }
    }
  } // get HR Employee

  getResUsersData() async {
    String userId = '';
    print('EntergetResUsersData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    resusersStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        userId = value['uid'];
        OdooResponse res = await odoo.searchRead(
            'res.users',
            [
              ['id', '=', int.parse(userId)]
            ],
            ['id', 'name', 'zone_id'],
            order: 'name asc');
        if (res.getResult() != null) {
          print('Get ResUsers result: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          resusersStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('GetResUsersError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          resusersStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('ResUsers catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        resusersStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        resusersStreamController.sink.add(responseOb);
      }
    }
  } // get ResUsers

  dispose() {
    profileStreamController.close();
    hremployeeStreamController.close();
    resusersStreamController.close();
  }
}
