import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:odoo_api/odoo_api_connector.dart';
import 'package:odoo_api/odoo_user_response.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class CustomerCreateBloc {
  StreamController<ResponseOb> customerCreateStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCustomemrCreateStream() => customerCreateStreamController.stream; // customerCreateStreamController

  late Odoo odoo;

  customerCreate({@required name, code, partnerCity, partnerTownship, stateId, countryId, street, street2,
  segmentId, zoneId, email, phone, mobile, categoryId, website}) async {
    print('Create Quotation');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    customerCreateStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('res.partner', {
              // 'name' : name,
              // 'code' : code == ''? null: code,
              // 'partner_city': partnerCity == 0 ? null : partnerCity,
              // 'partner_township' : partnerTownship == 0 ? null : partnerTownship,
              // stateId == 0 ? null: 'state_id': stateId,
              // countryId == 0 ? null : 'country_id': countryId,
              // street == '' ? null: 'street': street,
              // street2 == '' ? null : 'street2': street2,
              // segmentId == 0? null : 'segment_id': segmentId,
              // zoneId == 0 ? null : 'zone_id': zoneId,
              // email == '' ? null : 'email': email,
              // phone == '' ? null : 'phone': phone,
              // mobile == '' ? null : 'mobile': mobile,
              // categoryId == 0 ? null : 'category_id': categoryId,
              // website == ''? null : 'website': website,
              'customer_rank': 1,
              'name' : name,
              'code' : code == ''? null: code,
              'partner_city': partnerCity == 0 ? null : partnerCity,
              'partner_township' : partnerTownship == 0 ? null : partnerTownship,
              'state_id': stateId == 0 ? null: stateId,
              'country_id': countryId == 0 ? null : countryId,
              'street': street == '' ? null: street,
              'street2': street2 == '' ? null : street2,
              'segment_id': segmentId == 0? null : segmentId,
              'zone_id': zoneId == 0 ? null : zoneId,
              'email': email == '' ? null : email,
              'phone': phone == '' ? null : phone,
              'mobile': mobile == '' ? null : mobile,
              'category_id': categoryId == 0 ? null : categoryId,
              'website': website == ''? null : website,
        });
        if (res.getResult() != null) {
          print('Customer Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          customerCreateStreamController.sink.add(responseOb);
        } else {
          print('GetCreateCustomerError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          customerCreateStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        customerCreateStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        customerCreateStreamController.sink.add(responseOb);
      }
    }
  }// Create Customer Record

  dispose() {
    customerCreateStreamController.close();
  }
}