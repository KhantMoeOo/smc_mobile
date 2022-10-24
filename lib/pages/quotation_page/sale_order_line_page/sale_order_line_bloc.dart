import 'dart:async';

import 'package:odoo_api/odoo_api_connector.dart';
import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../services/odoo.dart';
import '../../../utils/app_const.dart';

class SaleOrderLineBloc {
  StreamController<ResponseOb> saleOrderLineStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getproductlineListStream() =>
      saleOrderLineStreamController.stream; // SaleOrderline Stream Controller

  StreamController<ResponseOb> saleOrderLineCreateStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> createproductlineListStream() =>
      saleOrderLineCreateStreamController
          .stream; // Create SaleOrderline Stream Controller

  StreamController<ResponseOb> saleOrderLineWaitingStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> waitingproductlineListStream() =>
      saleOrderLineWaitingStreamController
          .stream; // Waiting SaleOrderline Stream Controller

  StreamController<ResponseOb> saleOrderLineUpdateStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> updateproductlineListStream() =>
      saleOrderLineUpdateStreamController
          .stream; // Update SaleOrderline Stream Controller

  StreamController<ResponseOb> productProductStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getProductProductListStream() =>
      productProductStreamController
          .stream; // Product Product Stream Controller

  StreamController<ResponseOb> productProductWithFilterStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getProductProductWithFilterListStream() =>
      productProductWithFilterStreamController
          .stream; // Product Product With Filter Stream Controller

  StreamController<ResponseOb> productCategoryStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getProductCategoryListStream() =>
      productCategoryStreamController
          .stream; // Product Category Stream Controller

  StreamController<ResponseOb> uomStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getUOMListStream() =>
      uomStreamController.stream; // UOM Stream Controller

  StreamController<ResponseOb> salepricelistproductlineStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getSalePricelistProductLineListStream() =>
      salepricelistproductlineStreamController
          .stream; // SalePricelistProductLine Stream Controller

  StreamController<ResponseOb>
      salepricelistproductlinewithfilterStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getSalePricelistProductLineListWithFilterStream() =>
      salepricelistproductlinewithfilterStreamController
          .stream; // SalePricelistProductLineWithFilter Stream Controller

  StreamController<ResponseOb>
      salepricelistproductlinebyregionStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getSalePricelistProductLineListByRegionStream() =>
      salepricelistproductlinebyregionStreamController
          .stream; // salepricelistproductlinebyregionStreamController

  StreamController<ResponseOb> salepricelistStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getSalePricelistListStream() =>
      salepricelistStreamController.stream; // SalePricelist Stream Controller

  StreamController<ResponseOb> salediscountlistStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getSaleDiscountlistListStream() =>
      salediscountlistStreamController.stream; // SaleDiscount Stream Controller

  StreamController<ResponseOb> accounttaxeslistStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getAccountTaxeslistListStream() =>
      accounttaxeslistStreamController.stream; // AccountTaxes Stream Controller

  StreamController<ResponseOb> getUnitPriceStreamController =
      StreamController<ResponseOb>.broadcast();
  Stream<ResponseOb> getUnitPriceListStream() =>
      getUnitPriceStreamController.stream; // getUnitPriceStreamController

  late Odoo odoo;

  getSaleOrderLineData(orderId) {
    print('EntergetSaleOrderLineData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    saleOrderLineStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Sale order line Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'sale.order.line',
            [
              ['order_id', '=', orderId]
              // ['name', 'ilike', name],
              // ['user_id', 'ilike', userId],
              // ['partner_id', 'ilike', partnerId]
            ],
            [
              'id',
              'name',
              'order_id',
              'product_id',
              'product_name',
              'product_uom_qty',
              'invoice_status',
              'qty_delivered',
              'qty_invoiced',
              'product_uom',
              'product_uom_category_id',
              'price_unit',
              'company_id',
              'discount_id',
              'discount_ids',
              'promotion_ids',
              'sale_discount',
              'promotion_discount',
              'tax_id',
              'is_foc',
              'price_subtotal',
              'invoice_lines'
            ],
            order: 'id desc');
        if (!res.hasError()) {
          print('sale order line result');
          print('Sale Order Line Result:' +
              res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          !saleOrderLineStreamController.isClosed
              ? saleOrderLineStreamController.sink.add(responseOb)
              : null;
        } else {
          print('sale order line error');
          data = null;
          print(
              'Get Sale Order line Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          saleOrderLineStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        saleOrderLineStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        saleOrderLineStreamController.sink.add(responseOb);
      }
    }
  } // Sale Order line List Data

  waitingSaleOrderLineData() async {
    print('EnterWaitingSaleOrderLineData');
    int? count = 0;
    int? total = await SharefCount.getTotal();
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    saleOrderLineWaitingStreamController.sink.add(responseOb);

    try {
      print('Try');
      SharefCount.getCount().then((value) async {
        print('Value: $value');
        if (value == null) {
          count = 1;
          await SharefCount.setCount(count);
        } else {
          count = value + 1;
          await SharefCount.setCount(count);
        }
        print('Total: ${total}');
        print('count: $count');
        if (count == total) {
          responseOb.msgState = MsgState.data;
          saleOrderLineWaitingStreamController.sink.add(responseOb);
        } else {
          print('Waiting error');
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          saleOrderLineWaitingStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        saleOrderLineWaitingStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        saleOrderLineWaitingStreamController.sink.add(responseOb);
      }
    }
  } // Sale Order line Waiting Data

  saleOrderLineCreate(
      {orderId,
      currencyId,
      dateorder,
      productId,
      productName,
      productUOMQty,
      uomId,
      priceUnit,
      taxesId,
      subtotal}) async {
    print('Create SaleOrderLine');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    saleOrderLineCreateStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.create('sale.order.line', {
          'order_id': orderId,
          'partner_id': currencyId,
          'date_order': dateorder,
          'product_id': productId,
          'product_name': productName,
          'product_uom_qty': productUOMQty,
          'product_uom': uomId,
          'price_unit': priceUnit,
          'tax_id': taxesId,
          'price_subtotal': subtotal
        });
        if (!res.hasError()) {
          print('Created Sale Order Line');
          print('Sale Order Line Create Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          !saleOrderLineCreateStreamController.isClosed
              ? saleOrderLineCreateStreamController.sink.add(responseOb)
              : null;
        } else {
          print('Sale Order Line Create error');
          print('GetSale Order LineCreateError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          saleOrderLineCreateStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        saleOrderLineCreateStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        saleOrderLineCreateStreamController.sink.add(responseOb);
      }
    }
  } // Create Sale Order Line Bloc

  editSaleOrderLineData(
      {ids,
      orderId,
      currencyId,
      dateorder,
      productId,
      productName,
      productUOMQty,
      uomId,
      priceUnit,
      taxesId,
      subtotal}) {
    print('EnterEdittSaleOrderLineData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    saleOrderLineUpdateStreamController.sink.add(responseOb);

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.write('sale.order.line', [
          ids
        ], {
          'order_id': orderId,
          'partner_id': currencyId,
          'date_order': dateorder,
          'product_id': productId,
          'product_name': productName,
          'product_uom_qty': productUOMQty,
          'product_uom': uomId,
          'price_unit': priceUnit,
          'tax_id': taxesId,
          'price_subtotal': subtotal
        });
        if (!res.hasError()) {
          print('result');
          // data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          !saleOrderLineUpdateStreamController.isClosed
              ? saleOrderLineUpdateStreamController.sink.add(responseOb)
              : null;
        } else {
          print('error');
          print('EditSaleOrderLineError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          saleOrderLineUpdateStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        saleOrderLineUpdateStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        saleOrderLineUpdateStreamController.sink.add(responseOb);
      }
    }
  } // Edit Sale Order Line Data

  getProductProductData() {
    print('EntergetProductProductData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    productProductStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'product.product',
            [
              ['sale_ok', '=', true]
            ],
            [
              'id',
              'name',
              'sale_ok',
              'company_id',
              'uom_id',
              'categ_id',
              'product_code'
            ],
            order: 'name asc');
        if (!res.hasError()) {
          print('result');
          print('Product Product Result:' +
              res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          productProductStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print(
              'Get Product Product Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          productProductStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        productProductStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        productProductStreamController.sink.add(responseOb);
      }
    }
  } // Product Product List Data

  getProductProductDataWithFilter(name) {
    print('EntergetProductProductDataWithFilter');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    productProductWithFilterStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'product.product',
            [
              name,
            ],
            [
              'id',
              'name',
              'sale_ok',
              'company_id',
              'uom_id',
              'categ_id',
              'product_code'
            ],
            order: 'name asc');
        if (!res.hasError()) {
          print('result');
          print('ProductProductDataWithFilter Result:' +
              res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          productProductWithFilterStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print('Get ProductProductDataWithFilter Error:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          productProductWithFilterStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        productProductWithFilterStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        productProductWithFilterStreamController.sink.add(responseOb);
      }
    }
  } // ProductProductDataWithFilter List Data

  getProductCategoryData() {
    print('EntergetProductCategoryData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    productCategoryStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'product.category',
            [],
            [
              'id',
              'name',
              'property_account_income_categ_id',
            ],
            order: 'name asc');
        if (!res.hasError()) {
          print('result');
          print('Product Category Result:' +
              res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          productCategoryStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print(
              'Get Product Category Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          productCategoryStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        productCategoryStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        productCategoryStreamController.sink.add(responseOb);
      }
    }
  } // Product Category List Data

  getUOMListData() {
    print('EntergetUOMData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    uomStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'uom.uom',
            [
              // ['name', 'ilike', name],
              // ['user_id', 'ilike', userId],
              // ['partner_id', 'ilike', partnerId]
            ],
            ['id', 'name', 'category_id', 'factor'],
            order: 'name asc');
        if (!res.hasError()) {
          print('result');
          print('UOM Result:' + res.getResult()['records'].toString());
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          uomStreamController.sink.add(responseOb);
        } else {
          print('error');
          data = null;
          print('Get UOM Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          uomStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        uomStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        uomStreamController.sink.add(responseOb);
      }
    }
  } // UOM List Data

  getSalePricelistProductLineListData() async {
    print('EntergetSalePricelistProductLineListData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    salepricelistproductlineStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'sale.pricelist.product.line',
            [
              ['state', '=', 'approved']
            ],
            [
              'id',
              'product_id',
              'pricelist_id',
              'code',
              'currency_id',
              'pricelist_type',
              'customer_ids',
              'zone_ids',
              'segment_id',
              'region_ids',
              'state',
              'priority',
              'price',
              'ctn_price',
              'custom_price',
              'uom_id',
              'formula',
            ],
            order: 'priority desc');
        if (!res.hasError()) {
          print(
              'SalePricelistProductLineListresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          salepricelistproductlineStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('GeSalePricelistProductLinelistError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          salepricelistproductlineStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        salepricelistproductlineStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        salepricelistproductlineStreamController.sink.add(responseOb);
      }
    }
  } // Get SalePricelistProductLine Data

  getSalePricelistProductLineListDataWithFilter(id, segmentId) async {
    print('EntergetSalePricelistProductLineListWith FilterData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    salepricelistproductlinewithfilterStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'sale.pricelist.product.line',
            [
              id,
              segmentId,
              ['state', '=', 'approved']
            ],
            [
              'id',
              'product_id',
              'pricelist_id',
              'code',
              'currency_id',
              'pricelist_type',
              'customer_ids',
              'zone_ids',
              'segment_id',
              'region_ids',
              'state',
              'priority',
              'price',
              'ctn_price',
              'custom_price',
              'uom_id',
              'formula',
            ],
            order: 'priority desc');
        if (!res.hasError()) {
          print(
              'SalePricelistProductLineListwithfilterresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          salepricelistproductlinewithfilterStreamController.sink
              .add(responseOb);
        } else {
          data = null;
          print('GeSalePricelistProductLinelistwithFilterError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          salepricelistproductlinewithfilterStreamController.sink
              .add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        salepricelistproductlinewithfilterStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        salepricelistproductlinewithfilterStreamController.sink.add(responseOb);
      }
    }
  } // Get SalePricelistProductLine With Filter Data

  getSalePricelistProductLineListByRegion({zoneId, type, filter}) async {
    print('getSalePricelistProductLineListByRegion FilterData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    salepricelistproductlinebyregionStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'sale.pricelist.product.line',
            [
              zoneId,
              type,
              filter,
              ['state', '=', 'approved']
            ],
            [
              'id',
              'product_id',
              'pricelist_id',
              'code',
              'currency_id',
              'pricelist_type',
              'customer_ids',
              'zone_ids',
              'segment_id',
              'region_ids',
              'state',
              'priority',
              'price',
              'ctn_price',
              'custom_price',
              'uom_id',
              'formula',
            ],
            order: 'priority desc');
        if (!res.hasError()) {
          print(
              'getSalePricelistProductLineListByRegionresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          salepricelistproductlinebyregionStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('getSalePricelistProductLineListByRegionError:' +
              res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          salepricelistproductlinebyregionStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        salepricelistproductlinebyregionStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        salepricelistproductlinebyregionStreamController.sink.add(responseOb);
      }
    }
  } // getSalePricelistProductLineListByRegion

  getSalePricelistData(name) async {
    print('EntergetSalePricelistData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    salepricelistStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'sale.pricelist',
            [
              name,
              ['state', '=', 'approved']
            ],
            [
              'id',
              'currency_id',
              'pricelist_type',
              'zone_id',
              'state',
              'region_ids',
              'priority'
            ],
            order: 'priority desc');
        if (!res.hasError()) {
          print('SalePricelistresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          salepricelistStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('GeSalePricelisError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          salepricelistStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        salepricelistStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        salepricelistStreamController.sink.add(responseOb);
      }
    }
  } // Get SalePricelist Data

  getSaleDiscountlistData() async {
    print('EntergetSaleDiscountlistData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    salediscountlistStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
            'sale.discount',
            [
              ['sale_type', '=', 'discount']
            ],
            ['id', 'name', 'sale_type'],
            order: 'priority desc');
        if (!res.hasError()) {
          print('SaleDiscountlistresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          salediscountlistStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('GeSaleDiscountlisError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          salediscountlistStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        salediscountlistStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        salediscountlistStreamController.sink.add(responseOb);
      }
    }
  } // Get SaleDiscount Data

  getAccountTaxeslistData() async {
    print('EntergetAccountTaxestlistData');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    accounttaxeslistStreamController.sink.add(responseOb);
    List<dynamic>? data;

    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.searchRead(
          'account.tax',
          [
            ['type_tax_use', '=', 'sale']
          ],
          ['id', 'name', 'type_tax_use', 'company_id'],
        );
        if (!res.hasError()) {
          print('AccountTaxeslistresult: ${res.getResult()['records']}');
          data = res.getResult()['records'];
          responseOb.msgState = MsgState.data;
          responseOb.data = data;
          accounttaxeslistStreamController.sink.add(responseOb);
        } else {
          data = null;
          print('GeAccountTaxeslisError:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          accounttaxeslistStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        accounttaxeslistStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        accounttaxeslistStreamController.sink.add(responseOb);
      }
    }
  } // Get AccountTaxes Data

  getUnitPrice(
      {id,
      productId,
      currencyId,
      zoneId,
      segmentId,
      regionId,
      partnerId,
      productuom}) async {
    print('Get Unit Pirce');
    ResponseOb responseOb = ResponseOb(msgState: MsgState.loading);
    getUnitPriceStreamController.sink.add(responseOb);
    try {
      print('Try');
      Sharef.getOdooClientInstance().then((value) async {
        odoo = Odoo(BASEURL);
        odoo.setSessionId(value['session_id']);
        OdooResponse res = await odoo.callKW(
            'sale.order.line', 'define_product_price_with_args', [
          id,
          productId,
          currencyId,
          zoneId,
          segmentId,
          regionId,
          partnerId,
          productuom
        ]);
        if (!res.hasError()) {
          print('Get Unit Price Result: ${res.getResult()}');
          responseOb.msgState = MsgState.data;
          responseOb.data = res.getResult();
          getUnitPriceStreamController.sink.add(responseOb);
        } else {
          print('Get Unit Price Error:' + res.getErrorMessage().toString());
          responseOb.msgState = MsgState.error;
          responseOb.errState = ErrState.unKnownErr;
          getUnitPriceStreamController.sink.add(responseOb);
        }
      });
    } catch (e) {
      print('catch');
      if (e.toString().contains("SocketException")) {
        responseOb.data = "Internet Connection Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.noConnection;
        getUnitPriceStreamController.sink.add(responseOb);
      } else {
        responseOb.data = "Unknown Error";
        responseOb.msgState = MsgState.error;
        responseOb.errState = ErrState.unKnownErr;
        getUnitPriceStreamController.sink.add(responseOb);
      }
    }
  } // Get Unit Price

  dispose() {
    saleOrderLineStreamController.close();
    saleOrderLineCreateStreamController.close();
    saleOrderLineUpdateStreamController.close();
    productProductStreamController.close();
    productProductWithFilterStreamController.close();
    productCategoryStreamController.close();
    uomStreamController.close();
    saleOrderLineWaitingStreamController.close();
    salepricelistproductlineStreamController.close();
    salepricelistproductlinewithfilterStreamController.close();
    salepricelistStreamController.close();
    salediscountlistStreamController.close();
    accounttaxeslistStreamController.close();
    salepricelistproductlinebyregionStreamController.close();
    getUnitPriceStreamController.close();
  }
}
