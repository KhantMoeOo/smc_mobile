import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import 'package:odoo_api/odoo_user_response.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class QuotationCreateBloc {
  StreamController<ResponseOb> createNewStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCreateNewStream() => createNewStreamController.stream;

  StreamController<ResponseOb> callDiscountandPromotionController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCallDiscountandPromotionStream() =>
      callDiscountandPromotionController.stream;

  late Odoo odoo;

  quotationCreate(
      {warehouseId,
      partnerId,
      customerId,
      currencyId,
      exchangeRate,
      dateOrder,
      priceListId,
      paymentTermId,
      zoneId,
      segmentId,
      regionId,
      customFilter,
      zoneFilter,
      segFilter}) async {
    print('Create Quotation');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    createNewStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('sale.order', {
          'warehouse_id': warehouseId,
          'currency_id': currencyId,
          'partner_id': partnerId,
          'exchange_rate': exchangeRate,
          'date_order': dateOrder,
          'pricelist_id': priceListId,
          'payment_term_id': paymentTermId,
          'zone_id': zoneId,
          'segment_id': segmentId,
          'region_id': regionId,
          'customer_filter': customFilter,
          'zone_filter_id': zoneFilter,
          'seg_filter_id': segFilter,
        });
        if (!res.hasError()) {
          print('Createresult');
          print('Quo Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          createNewStreamController.sink.add(responseOb);
        } else {
          print('Create error');
          print('GetCreateError:' + res.getError().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          createNewStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        createNewStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        createNewStreamController.sink.add(responseOb);
      }
    }
  }

  getDiscountandPromo({id}) async {
    print('Get Call Promo and Disocunt');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    callDiscountandPromotionController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo
            .callKW('sale.order', 'constrains_customer_credit_limit', [id]);
        if (!res.hasError()) {
          print('Get Call Promo and Disocunt Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          callDiscountandPromotionController.sink.add(responseOb);
        } else {
          print('Get Call Promo and Disocunt Error:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          callDiscountandPromotionController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        callDiscountandPromotionController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        callDiscountandPromotionController.sink.add(responseOb);
      }
    }
  } // Get Call Promo and Disocunt

  dispose() {
    createNewStreamController.close();
    callDiscountandPromotionController.close();
  }
}
