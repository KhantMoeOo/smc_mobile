import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class CustomerBloc {
  StreamController<ResponseOb> customerStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCustomerListStream() =>
      customerStreamController.stream; // CustomerList Stream Controller

  StreamController<ResponseOb> rescountrystateStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getResCountryStateListStream() =>
      rescountrystateStreamController.stream; // rescountrystateStreamController

  StreamController<ResponseOb> rescountryStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getResCountryListStream() =>
      rescountryStreamController.stream; // rescountryStreamController

  late Odoo odoo;

  getCustomerList({name, zoneId}) async {
    print('EntergetCustomerData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    customerStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Get Customer List Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'res.partner',
            [
              ['customer_rank', '>=', '1'],
              ['zone_id.id', '=', zoneId],
              name
            ],
            [
              'id',
              'name',
              'code',
              'contact_address_complete',
              'partner_city',
              'segment_id',
              'zone_id',
              'sale_order_count',
              'email',
              'phone',
              'category_id',
              'user_id',
              'company_type'
            ],
            order: 'name asc');
        if (!res.hasError()) {
          print('CustomerListresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          customerStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('GetCustomerListError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          customerStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        customerStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        customerStreamController.sink.add(responseOb);
      }
    }
  } // get CustomerList

  getResCountryStateList(countryId) async {
    print('EntergetResCountryStateData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    rescountrystateStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Get ResCountryState List Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'res.country.state',
            [
              ['country_id.id', '=?', countryId]
            ],
            ['id', 'name', 'country_id', 'code'],
            order: 'name asc');
        if (!res.hasError()) {
          print('ResCountryStateListresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          rescountrystateStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('GetResCountryStateListError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          rescountrystateStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        rescountrystateStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        rescountrystateStreamController.sink.add(responseOb);
      }
    }
  } // get ResCountryState List

  getResCountryList() async {
    print('EntergetResCountryData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    rescountryStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Get ResCountry List Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'res.country', [], ['id', 'name', 'code'],
            order: 'name asc');
        if (!res.hasError()) {
          print('ResCountryListresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          rescountryStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('GetResCountryListError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          rescountryStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        rescountryStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        rescountryStreamController.sink.add(responseOb);
      }
    }
  } // get ResCountry List

  dispose() {
    customerStreamController.close();
    rescountrystateStreamController.close();
    rescountryStreamController.close();
  }
}
