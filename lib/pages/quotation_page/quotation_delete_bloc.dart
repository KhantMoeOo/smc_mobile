import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class DeleteQuoBloc {
  StreamController<ResponseOb> quotationDeleteStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> deleteQuoStream() => quotationDeleteStreamController
      .stream; // QuotationDelete Stream Controller

  StreamController<ResponseOb> saleorderlineDeleteStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> deleteSaleOrderLineStream() =>
      saleorderlineDeleteStreamController
          .stream; // SaleOrderLine Delete Stream Controller

  late Odoo odoo;

  deleteQuotationData(ids) {
    print('Enter Delete Quotation Data');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    quotationDeleteStreamController.sink.add(responseOb);

    try {
      print('Quotation Delete Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.unlink('sale.order', [ids]);
        if (res.getResult() != null) {
          print('quodelete result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          quotationDeleteStreamController.sink.add(responseOb);
        } else {
          print('Delete quo error');
          print('DeletequoError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          quotationDeleteStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('Quotaion Delete catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        quotationDeleteStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        quotationDeleteStreamController.sink.add(responseOb);
      }
    }
  } // Delete Quotation records

  deleteSaleOrderLineData(ids) {
    print('Enter Delete SaleOrderLine Data');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    saleorderlineDeleteStreamController.sink.add(responseOb);

    try {
      print('SaleOrderLine Delete Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.unlink('sale.order.line', [ids]);
        if (res.getResult() != null) {
          print('SaleOrderLinedelete result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          saleorderlineDeleteStreamController.sink.add(responseOb);
        } else {
          print('DeleteSaleOrderLineError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          saleorderlineDeleteStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('SaleOrderLine Delete catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        saleorderlineDeleteStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        saleorderlineDeleteStreamController.sink.add(responseOb);
      }
    }
  } // Delete SaleOrderLine records

  dispose() {
    quotationDeleteStreamController.close();
    saleorderlineDeleteStreamController.close();
  }
}
