import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../dbs/sharef.dart';
import '../../obs/response_ob.dart';
import '../../services/odoo.dart';
import '../../utils/app_const.dart';

class ProductBloc {
  StreamController<ResponseOb> productListStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getProductListStream() =>
      productListStreamController.stream; // ProductList Stream Controller

  StreamController<ResponseOb> stockquantStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getStockQuantStream() =>
      stockquantStreamController.stream; // Stock Quant Stream Controller

  StreamController<ResponseOb> stockwarehouseStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getStockWarehouseStream() =>
      stockwarehouseStreamController.stream; // StockWarehouse Stream Controller

  late Odoo odoo;

  getProductListData({name}) {
    print('EntergetProductListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    productListStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'product.template',
            [
              name,
              ['sale_ok', '=', true]
            ],
            [
              'id',
              'name',
              'product_code',
              'sale_ok',
              'purchase_ok',
              'list_price',
              'qty_available',
              'uom_id',
              'main_category_id',
              'categ_id'
            ],
            order: 'name asc');
        if (res.getResult() != null) {
          print('result');
          print('ProductResult:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          productListStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print('GetProductError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          productListStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        productListStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        productListStreamController.sink.add(responseOb);
      }
    }
  }

  getStockQuantData({locationId, productId}) {
    print('EntergetStockQuantData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    stockquantStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'stock.quant',
            [
              ['location_id.id', '=', locationId],
            ],
            [
              'id',
              'detail_qty',
              'product_id',
              'location_id',
            ],
            order: 'id asc');
        if (!res.hasError()) {
          print('StockQuantResult:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          stockquantStreamController.sink.add(responseOb);
        } else {
          print('GetStockQuantError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          stockquantStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        stockquantStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        stockquantStreamController.sink.add(responseOb);
      }
    }
  }

  getStockWarehouseData({zoneId}) {
    print('EntergetStockWarehouseData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    stockwarehouseStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'stock.warehouse',
            [
              ['zone_id.id', '=', zoneId],
            ],
            [
              'id',
              'name',
              'lot_stock_id',
            ],
            order: 'id asc');
        if (!res.hasError()) {
          print(
              'StockWarehouseResult:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          stockwarehouseStreamController.sink.add(responseOb);
        } else {
          print('GetStockWarehouseError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          stockwarehouseStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        stockwarehouseStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        stockwarehouseStreamController.sink.add(responseOb);
      }
    }
  }

  dispose() {
    productListStreamController.close();
    stockquantStreamController.close();
    stockwarehouseStreamController.close();
  }
}
