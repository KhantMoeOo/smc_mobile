import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class QuotationBloc {
  StreamController<ResponseOb> quotationStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getQuotationStream() =>
      quotationStreamController.stream; // Quotation Stream Controller

  StreamController<ResponseOb> quotationWithIdStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getQuotationWithIdStream() =>
      quotationWithIdStreamController.stream; // quotationWithIdStreamController

  StreamController<ResponseOb> customerStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCustomerStream() =>
      customerStreamController.stream; // Customer Stream Controller

  StreamController<ResponseOb> currencyStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getCurrencyStream() =>
      currencyStreamController.stream; // Currency Stream Controller

  StreamController<ResponseOb> pricelistStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getPricelistStream() =>
      pricelistStreamController.stream; // Pricelist Stream Controller

  StreamController<ResponseOb> paymentTermsStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getPaymentTermsStream() =>
      paymentTermsStreamController.stream; // PaymentTerms Stream Controller

  StreamController<ResponseOb> zoneListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getZoneListStream() =>
      zoneListStreamController.stream; // ZoneList Stream Controller

  StreamController<ResponseOb> zoneListWithUserIdStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getZoneListWithUserIdStream() =>
      zoneListWithUserIdStreamController
          .stream; // ZoneListWithUserId Stream Controller

  StreamController<ResponseOb> segmentListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getSegmentListStream() =>
      segmentListStreamController.stream; // SegmentList Stream Controller

  StreamController<ResponseOb> regionListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getRegionListStream() =>
      regionListStreamController.stream; // RegionList Stream Controller

  late Odoo odoo;

  getQuotationData({name, state}) async {
    print('EntergetQuotationData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    quotationStreamController.sink.add(responseOb);
    List<dynamic>? data;

    // name != ''? ['name', 'ilike', name] :
    //           userId != ''? ['user_id', 'ilike', userId] :
    //           partnerId != ''? ['partner_id', 'ilike', partnerId]:
    //           productId != ''? ['order_line.product_id', 'like', productId]:
    //           productName != ''? ['order_line.product_name', '=', productName]:

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'sale.order',
            [
              name,
              state,
            ],
            [
              'id',
              'name',
              'user_id',
              'partner_id',
              'partner_invoice_id',
              'partner_shipping_id',
              'picking_ids',
              'amount_total',
              'order_line',
              'state',
              'invoice_status',
              'discount_id',
              'create_date',
              'commitment_date',
              'expected_date',
              'date_order',
              'validity_date',
              'currency_id',
              'exchange_rate',
              'pricelist_id',
              'payment_term_id',
              'zone_id',
              'segment_id',
              'region_id',
              'customer_filter',
              'zone_filter_id',
              'seg_filter_id',
              'invoice_count',
              'delivery_count',
              'amount_untaxed',
              'amount_discount',
              'amount_tax',
            ],
            order: 'name desc');
        if (!res.hasError()) {
          print('QuotationResult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !quotationStreamController.isClosed
              ? quotationStreamController.sink.add(responseOb)
              : null;
        } else {
          print('Quotation error');
          data = null;
          print('GetquoError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          quotationStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Quotation catch: $e');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        quotationStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        quotationStreamController.sink.add(responseOb);
      }
    }
  } // get Quotation List

  getQuotationWithIdData(id) async {
    print('EntergetQuotationWithIdData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    quotationWithIdStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'sale.order',
            [
              ['id', 'ilike', id],
            ],
            [
              'id',
              'name',
              'user_id',
              'partner_id',
              'partner_invoice_id',
              'partner_shipping_id',
              'picking_ids',
              'amount_total',
              'state',
              'invoice_status',
              'invoice_count',
              'delivery_count',
              'invoice_ids',
              'discount_id',
              'create_date',
              'expected_date',
              'date_order',
              'validity_date',
              'currency_id',
              'exchange_rate',
              'pricelist_id',
              'payment_term_id',
              'zone_id',
              'segment_id',
              'region_id',
              'customer_filter',
              'zone_filter_id',
              'seg_filter_id',
              'amount_untaxed',
              'amount_discount',
              'amount_tax',
              'amount_total',
              'order_line'
            ],
            order: 'name desc');
        if (res.getResult() != null) {
          print('getQuotationWithIdDataResult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !quotationStreamController.isClosed
              ? quotationWithIdStreamController.sink.add(responseOb)
              : null;
        } else {
          print('getQuotationWithIdData error');
          data = null;
          print('GetquoError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          quotationWithIdStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('getQuotationWithIdData catch: $e');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        quotationWithIdStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        quotationWithIdStreamController.sink.add(responseOb);
      }
    }
  } // getQuotationWithIdData List

  getCustomerList(name, zoneId) async {
    String userId = '';
    print('EntergetCustomerData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    customerStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        userId = value['uid'];
        OdooResponse res = await odoo.searchRead(
            'res.partner',
            [
              ['customer_rank', '>=', '1'],
              name,
              zoneId,
              // ['segment_id', 'ilike', segmentId]
            ],
            [
              'id',
              'name',
              'code',
              'contact_address_complete',
              'partner_city',
              'segment_id',
              'zone_id',
              'property_product_pricelist',
              'property_account_receivable_id',
              'property_payment_term_id',
              'property_stock_supplier',
              'property_stock_customer'
            ],
            order: 'name asc');
        if (res.getResult() != null) {
          print('Customerresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          customerStreamController.sink.add(responseOb);
        } else {
          print('Customer error');
          data = null;
          print('GetquoError:' + res.getErrorMessage().toString());
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

  getCurrencyList() async {
    print('EntergetCurrencyData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    currencyStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.searchRead('res.currency', [], ['id', 'name', 'symbol']);
        if (res.getResult() != null) {
          print('Currencyresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          currencyStreamController.sink.add(responseOb);
        } else {
          print('Currency error');
          data = null;
          print('GetCurrencyError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          currencyStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        currencyStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        currencyStreamController.sink.add(responseOb);
      }
    }
  } // get Currency List

  getPricelist() async {
    print('EntergetPricelistData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    pricelistStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead('product.pricelist', [],
            ['id', 'name', 'company_id', 'currency_id']);
        if (res.getResult() != null) {
          print('PriceListresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          pricelistStreamController.sink.add(responseOb);
        } else {
          print('Pricelist error');
          data = null;
          print('GetPricelistError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          pricelistStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        pricelistStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        pricelistStreamController.sink.add(responseOb);
      }
    }
  } // get Pricelist List

  getPaymentTermsData() async {
    print('EntergetPaymentTermsListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    paymentTermsStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'account.payment.term', [], ['id', 'name', 'company_id']);
        if (res.getResult() != null) {
          print('PaymentTermsListresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          paymentTermsStreamController.sink.add(responseOb);
        } else {
          print('PaymentTerms error');
          data = null;
          print('GetPaymentTermslistError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          paymentTermsStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        paymentTermsStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        paymentTermsStreamController.sink.add(responseOb);
      }
    }
  } // get PaymentTerms List

  getZoneListData() async {
    print('EntergetZoneListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    zoneListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.searchRead('zone.zone', [], ['id', 'name']);
        if (res.getResult() != null) {
          print('ZoneListresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          zoneListStreamController.sink.add(responseOb);
        } else {
          print('Zone error');
          data = null;
          print('GetZonelistError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          zoneListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        zoneListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        zoneListStreamController.sink.add(responseOb);
      }
    }
  } // get Zone List

  getZoneListWithUserIdData(id) async {
    print('EntergetZoneListWithUserIdData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    zoneListWithUserIdStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead('zone.zone', [
          ['id', '=', id]
        ], [
          'id',
          'name'
        ]);
        if (res.getResult() != null) {
          print('ZoneListWithUserIdresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          zoneListWithUserIdStreamController.sink.add(responseOb);
        } else {
          print('Zone error');
          data = null;
          print(
              'GetZoneListWithUserIdError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          zoneListWithUserIdStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        zoneListWithUserIdStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        zoneListWithUserIdStreamController.sink.add(responseOb);
      }
    }
  } // get ZoneListWithUserId

  getSegmenListData() async {
    print('EntergetSegmentListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    segmentListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.searchRead('res.partner.segment', [], ['id', 'name']);
        if (res.getResult() != null) {
          print('SegmentListresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          segmentListStreamController.sink.add(responseOb);
        } else {
          print('Segment error');
          data = null;
          print('GetSegmentlistError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          segmentListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        segmentListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        segmentListStreamController.sink.add(responseOb);
      }
    }
  } // get Segment List

  getRegionListData(stateId) async {
    print('EntergetRegionListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    regionListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res =
            await odoo.searchRead('res.cities', [], ['id', 'name', 'state_id']);
        if (res.getResult() != null) {
          print('RegionListresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          regionListStreamController.sink.add(responseOb);
        } else {
          print('Region error');
          data = null;
          print('GetRegionlistError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          regionListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        regionListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        regionListStreamController.sink.add(responseOb);
      }
    }
  } // get Region List

  dipose() {
    quotationStreamController.close();
    customerStreamController.close();
    currencyStreamController.close();
    pricelistStreamController.close();
    paymentTermsStreamController.close();
    zoneListStreamController.close();
    zoneListWithUserIdStreamController.close();
    segmentListStreamController.close();
    regionListStreamController.close();
    quotationWithIdStreamController.close();
  }
}
