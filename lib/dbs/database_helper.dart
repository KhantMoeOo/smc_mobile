import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../obs/hr_employee_line_ob.dart';
import '../obs/invoice_line_ob.dart';
import '../obs/product_line_ob.dart';
import '../obs/sale_order_line_ob.dart';
import '../obs/stock_move_ob.dart';
import '../obs/trip_plan_delivery_ob.dart';
import '../obs/trip_plan_schedule_ob.dart';

class DatabaseHelper {
  Future<Database> database() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'smc_uat_db.db');
    return openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE sale_order_line(id INTEGER PRIMARY KEY, isSelect INTEGER, quotation_id INTEGER, product_code_id INTEGER, product_code_name TEXT, description TEXT, full_name TEXT, quantity TEXT, qty_delivered TEXT, qty_invoiced TEXT, uom_id INTEGER, uom_name TEXT, unit_price TEXT,discount_id INTEGER, discount_name TEXT,promotion_id INTEGER, promotion_name TEXT,sale_discount TEXT,promotion_discount TEXT,tax_id INTEGER,tax_name TEXT,is_foc INTEGER, price_subtotal TEXT)');
      await db.execute(
          'CREATE TABLE sale_order_line_update(id INTEGER PRIMARY KEY, isSelect INTEGER,quotation_id INTEGER, product_code_id INTEGER, product_code_name TEXT, description TEXT, full_name TEXT, quantity TEXT, qty_delivered TEXT, qty_invoiced TEXT, uom_id INTEGER, uom_name TEXT, unit_price TEXT,discount_id INTEGER, discount_name TEXT,promotion_id INTEGER, promotion_name TEXT,sale_discount TEXT,promotion_discount TEXT,tax_id INTEGER,tax_name TEXT,is_foc INTEGER, price_subtotal TEXT)');
      await db.execute(
          'CREATE TABLE sale_order_line_multi_select(id INTEGER PRIMARY KEY, isSelect INTEGER,quotation_id INTEGER, product_code_id INTEGER, product_code_name TEXT, description TEXT, full_name TEXT, quantity TEXT, qty_delivered TEXT, qty_invoiced TEXT, uom_id INTEGER, uom_name TEXT, unit_price TEXT,discount_id INTEGER, discount_name TEXT,promotion_id INTEGER, promotion_name TEXT,sale_discount TEXT,promotion_discount TEXT,tax_id INTEGER,tax_name TEXT,is_foc INTEGER, price_subtotal TEXT)');
      await db.execute(
          'CREATE TABLE material_product_line(id INTEGER PRIMARY KEY, isSelect INTEGER, material_product_id INTEGER, product_code_id INTEGER, product_code_name TEXT, description TEXT, full_name TEXT, quantity TEXT, uom_id INTEGER, uom_name TEXT)');
      await db.execute(
          'CREATE TABLE material_product_line_update(id INTEGER PRIMARY KEY, isSelect INTEGER, material_product_id INTEGER, product_code_id INTEGER, product_code_name TEXT, description TEXT, full_name TEXT, quantity TEXT, uom_id INTEGER, uom_name TEXT)');
      await db.execute(
          'CREATE TABLE material_product_line_multi_select(id INTEGER PRIMARY KEY, isSelect INTEGER, material_product_id INTEGER, product_code_id INTEGER, product_code_name TEXT, description TEXT, full_name TEXT, quantity TEXT, uom_id INTEGER, uom_name TEXT)');
      await db.execute(
          'CREATE TABLE stock_move(id INTEGER PRIMARY KEY, isSelect INTEGER, picking_id INTEGER, product_code_id INTEGER, product_code_name TEXT, description TEXT, full_name TEXT, quantity TEXT, reserved TEXT, done TEXT, remaining_stock TEXT, damage_qty TEXT, uom_id INTEGER, uom_name TEXT)');
      await db.execute(
          'CREATE TABLE stock_move_update(id INTEGER PRIMARY KEY, isSelect INTEGER, picking_id INTEGER, product_code_id INTEGER, product_code_name TEXT, description TEXT, full_name TEXT, quantity TEXT, reserved TEXT, done TEXT, remaining_stock TEXT, damage_qty TEXT, uom_id INTEGER, uom_name TEXT)');
      await db.execute(
          'CREATE TABLE hr_employee_line(id INTEGER PRIMARY KEY,trip_line INTEGER, emp_id INTEGER, emp_name TEXT, department_id INTEGER, department_name TEXT, job_id INTEGER, job_name TEXT, responsible INTEGER)');
      await db.execute(
          'CREATE TABLE hr_employee_line_update(id INTEGER PRIMARY KEY,trip_line INTEGER, emp_id INTEGER, emp_name TEXT, department_id INTEGER, department_name TEXT, job_id INTEGER, job_name TEXT, responsible INTEGER)');
      await db.execute(
          'CREATE TABLE trip_plan_delivery(id INTEGER PRIMARY KEY,trip_line INTEGER, team_id INTEGER, team_name TEXT, assign_person_id INTEGER, assign_person TEXT, zone_id INTEGER, zone_name TEXT, invoice_id INTEGER, invoice_name TEXT, order_id INTEGER, order_name TEXT, state TEXT, invoice_status TEXT, remark TEXT)');
      await db.execute(
          'CREATE TABLE trip_plan_delivery_update(id INTEGER PRIMARY KEY,trip_line INTEGER, team_id INTEGER, team_name TEXT, assign_person_id INTEGER, assign_person TEXT, zone_id INTEGER, zone_name TEXT, invoice_id INTEGER, invoice_name TEXT, order_id INTEGER, order_name TEXT, state TEXT, invoice_status TEXT, remark TEXT)');
      await db.execute(
          'CREATE TABLE trip_plan_schedule(id INTEGER PRIMARY KEY,trip_id INTEGER, from_date TEXT, to_date TEXT, location_id INTEGER, location_name TEXT, remark TEXT)');
      await db.execute(
          'CREATE TABLE trip_plan_schedule_update(id INTEGER PRIMARY KEY,trip_id INTEGER, from_date TEXT, to_date TEXT, location_id INTEGER, location_name TEXT, remark TEXT)');
      await db.execute(
          'CREATE TABLE account_move_line(id INTEGER PRIMARY KEY,invoice_id INTEGER, product_code_id INTEGER, product_code_name TEXT, label TEXT, quantity TEXT, uom_id INTEGER, uom_name TEXT, unit_price TEXT,asset_category_id INTEGER, asset_category_name TEXT, account_id INTEGER, account_name TEXT, sale_discount TEXT, analytic_account_id INTEGER, analytic_account_name TEXT,tax_id INTEGER,tax_name TEXT, price_subtotal TEXT)');
      await db.execute(
          'CREATE TABLE account_move_line_update(id INTEGER PRIMARY KEY,invoice_id INTEGER, product_code_id INTEGER, product_code_name TEXT, label TEXT, quantity TEXT, uom_id INTEGER, uom_name TEXT, unit_price TEXT,asset_category_id INTEGER, asset_category_name TEXT, account_id INTEGER, account_name TEXT, sale_discount TEXT, analytic_account_id INTEGER, analytic_account_name TEXT,tax_id INTEGER,tax_name TEXT, price_subtotal TEXT)');
      await db.execute(
          'CREATE TABLE tax_ids(id INTEGER PRIMARY KEY, line_id INTEGER, tax_id INTEGER)');
      await db.execute(
          'CREATE TABLE sol_tax_ids(id INTEGER PRIMARY KEY, line_id INTEGER, tax_id INTEGER)');
      // return db;
    });
  }

  Future<int> insertOrderLine(SaleOrderLineOb saleOrderLineOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('sale_order_line', saleOrderLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to sale_order_line table

  Future<int> insertOrderLineUpdate(SaleOrderLineOb saleOrderLineOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('sale_order_line_update', saleOrderLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to sale_order_line_update table

  Future<int> insertMaterialProductLine(ProductLineOb productLineOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('material_product_line', productLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to material_product_line table

  Future<int> insertMaterialProductLineUpdate(
      ProductLineOb productLineOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('material_product_line_update', productLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to material_product_line_update table

  Future<int> insertProductLineMultiSelect(ProductLineOb productLineOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('material_product_line_multi_select', productLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to material_product_line_multi_select table

  Future<int> insertOrderLineMultiSelect(
      SaleOrderLineOb saleOrderLineOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('sale_order_line_multi_select', saleOrderLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to sale_order_line_multi_select table

  Future<int> insertStockMove(StockMoveOb stockMoveOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('stock_move', stockMoveOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to stock_move table

  Future<int> insertStockMoveUpdate(StockMoveOb stockMoveOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('stock_move_update', stockMoveOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to stock_move_update table

  Future<int> insertHrEmployeeLine(HrEmployeeLineOb hrEmployeeLineOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('hr_employee_line', hrEmployeeLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to hr_employee_line table

  Future<int> insertHrEmployeeLineUpdate(
      HrEmployeeLineOb hrEmployeeLineOb) async {
    print("InsertHrEmployeeLineWorked");
    int id = 0;
    Database db = await database();
    await db
        .insert('hr_employee_line_update', hrEmployeeLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to hr_employee_line_update table

  Future<int> insertTripPlanDelivery(
      TripPlanDeliveryOb tripPlanDeliveryOb) async {
    print("InsertTripPlanDeliveryWorked");
    int id = 0;
    Database db = await database();
    await db
        .insert('trip_plan_delivery', tripPlanDeliveryOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to trip_plan_delivery table

  Future<int> insertTripPlanDeliveryUpdate(
      TripPlanDeliveryOb tripPlanDeliveryOb) async {
    print("InsertTripPlanDeliveryUpdateWorked");
    int id = 0;
    Database db = await database();
    await db
        .insert('trip_plan_delivery_update', tripPlanDeliveryOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to trip_plan_delivery_update table

  Future<int> insertTripPlanSchedule(
      TripPlanScheduleOb tripPlanScheduleOb) async {
    print("InsertTripPlanScheduleWorked");
    int id = 0;
    Database db = await database();
    await db
        .insert('trip_plan_schedule', tripPlanScheduleOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to trip_plan_schedule table

  Future<int> insertTripPlanScheduleUpdate(
      TripPlanScheduleOb tripPlanScheduleOb) async {
    print("InsertTripPlanScheduleUpdateWorked");
    int id = 0;
    Database db = await database();
    await db
        .insert('trip_plan_schedule_update', tripPlanScheduleOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to trip_plan_schedule_update table

  Future<int> insertaccountmoveline(InvoiceLineOb invoiceLineOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('account_move_line', invoiceLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to account_move_line table

  Future<int> insertTaxIDs(TaxesOb taxesOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('tax_ids', taxesOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to tax_ids table

  Future<int> insertSOLTaxIDs(TaxesOb taxesOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('sol_tax_ids', taxesOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to sol_tax_ids table

  Future<int> insertaccountmovelineupdate(InvoiceLineOb invoiceLineOb) async {
    int id = 0;
    Database db = await database();
    await db
        .insert('account_move_line_update', invoiceLineOb.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace)
        .then((value) => id = value);
    return id;
  } // insert datas to account_move_line_update table

  Future<List<SaleOrderLineOb>> insertTable2Table() async {
    print('Worked');
    Database db = await database();
    await db.rawInsert(
        'INSERT INTO sale_order_line(id,isSelect, quotation_id,product_code_name,product_code_id,description, full_name ,quantity,qty_delivered,qty_invoiced,uom_name,uom_id,unit_price,discount_id , discount_name ,promotion_id , promotion_name ,sale_discount,promotion_discount ,tax_id ,tax_name ,is_foc,price_subtotal) SELECT id,isSelect,quotation_id,product_code_name,product_code_id,description,full_name,quantity,qty_delivered,qty_invoiced,uom_name,uom_id,unit_price,discount_id, discount_name ,promotion_id , promotion_name ,sale_discount ,promotion_discount,tax_id ,tax_name,is_foc ,price_subtotal FROM sale_order_line_update WHERE isSelect = 1');

    List<Map<String, dynamic>> saleorderlineMap =
        await db.query('sale_order_line');
    return List.generate(saleorderlineMap.length, (i) {
      return SaleOrderLineOb(
          id: saleorderlineMap[i]['id'],
          isSelect: saleorderlineMap[i]['isSelect'],
          quotationId: saleorderlineMap[i]['quotation_id'],
          productCodeName: saleorderlineMap[i]['product_code_name'],
          productCodeId: saleorderlineMap[i]['product_code_id'],
          description: saleorderlineMap[i]['description'],
          fullName: saleorderlineMap[i]['full_name'],
          quantity: saleorderlineMap[i]['quantity'],
          qtyDelivered: saleorderlineMap[i]['qty_delivered'],
          qtyInvoiced: saleorderlineMap[i]['qty_invoiced'],
          uomName: saleorderlineMap[i]['uom_name'],
          uomId: saleorderlineMap[i]['uom_id'],
          unitPrice: saleorderlineMap[i]['unit_price'],
          discountId: saleorderlineMap[i]['discount_id'],
          discountName: saleorderlineMap[i]['discount_name'],
          promotionId: saleorderlineMap[i]['promotion_id'],
          promotionName: saleorderlineMap[i]['promotion_name'],
          saleDiscount: saleorderlineMap[i]['sale_discount'],
          promotionDiscount: saleorderlineMap[i]['promotion_discount'],
          taxId: saleorderlineMap[i]['tax_id'],
          taxName: saleorderlineMap[i]['tax_name'],
          isFOC: saleorderlineMap[i]['is_foc'],
          subTotal: saleorderlineMap[i]['price_subtotal']);
    });
  } // insert datas list from sale_order_line_update table to sale_order_line table

  Future<List<SaleOrderLineOb>> updateSOLSelect() async {
    print('Worked');
    Database db = await database();
    await db.rawInsert(
        'INSERT INTO sale_order_line(isSelect, quotation_id,product_code_name,product_code_id,description, full_name ,quantity,qty_delivered,qty_invoiced,uom_name,uom_id,unit_price,discount_id , discount_name ,promotion_id , promotion_name ,sale_discount,promotion_discount ,tax_id ,tax_name ,is_foc,price_subtotal) SELECT isSelect,quotation_id,product_code_name,product_code_id,description,full_name,quantity,qty_delivered,qty_invoiced,uom_name,uom_id,unit_price,discount_id, discount_name ,promotion_id , promotion_name ,sale_discount ,promotion_discount,tax_id ,tax_name,is_foc ,price_subtotal FROM sale_order_line_multi_select WHERE isSelect = 1');

    List<Map<String, dynamic>> saleorderlineMap =
        await db.query('sale_order_line');
    return List.generate(saleorderlineMap.length, (i) {
      return SaleOrderLineOb(
          id: saleorderlineMap[i]['id'],
          isSelect: saleorderlineMap[i]['isSelect'],
          quotationId: saleorderlineMap[i]['quotation_id'],
          productCodeName: saleorderlineMap[i]['product_code_name'],
          productCodeId: saleorderlineMap[i]['product_code_id'],
          description: saleorderlineMap[i]['description'],
          fullName: saleorderlineMap[i]['full_name'],
          quantity: saleorderlineMap[i]['quantity'],
          qtyDelivered: saleorderlineMap[i]['qty_delivered'],
          qtyInvoiced: saleorderlineMap[i]['qty_invoiced'],
          uomName: saleorderlineMap[i]['uom_name'],
          uomId: saleorderlineMap[i]['uom_id'],
          unitPrice: saleorderlineMap[i]['unit_price'],
          discountId: saleorderlineMap[i]['discount_id'],
          discountName: saleorderlineMap[i]['discount_name'],
          promotionId: saleorderlineMap[i]['promotion_id'],
          promotionName: saleorderlineMap[i]['promotion_name'],
          saleDiscount: saleorderlineMap[i]['sale_discount'],
          promotionDiscount: saleorderlineMap[i]['promotion_discount'],
          taxId: saleorderlineMap[i]['tax_id'],
          taxName: saleorderlineMap[i]['tax_name'],
          isFOC: saleorderlineMap[i]['is_foc'],
          subTotal: saleorderlineMap[i]['price_subtotal']);
    });
  } // insert datas list from sale_order_line_multi_select table to sale_order_line table

  Future<List<ProductLineOb>> updateMPLSelect() async {
    print('Worked');
    Database db = await database();
    await db.rawInsert(
        'INSERT INTO material_product_line(isSelect, material_product_id, product_code_id, product_code_name, description, full_name, quantity, uom_id, uom_name) SELECT isSelect, material_product_id, product_code_id, product_code_name, description, full_name, quantity, uom_id, uom_name FROM material_product_line_multi_select WHERE isSelect = 1');

    List<Map<String, dynamic>> productlineMap =
        await db.query('material_product_line');
    return List.generate(productlineMap.length, (i) {
      return ProductLineOb(
        id: productlineMap[i]['id'],
        isSelect: productlineMap[i]['isSelect'],
        materialproductId: productlineMap[i]['material_product_id'],
        productCodeName: productlineMap[i]['product_code_name'],
        productCodeId: productlineMap[i]['product_code_id'],
        description: productlineMap[i]['description'],
        fullName: productlineMap[i]['full_name'],
        quantity: productlineMap[i]['quantity'],
        uomName: productlineMap[i]['uom_name'],
        uomId: productlineMap[i]['uom_id'],
      );
    });
  } // insert datas list from material_product_line table to sale_order_line table

  Future<List<InvoiceLineOb>>
      insertAccountMoveLineTable2AccountMoveLineUpdateTable() async {
    print('Worked');
    Database db = await database();
    await db.rawInsert(
        'INSERT INTO acccount_move_line(id, invoice_id, product_code_id, product_code_name, label, quantity, uom_id, uom_name, unit_price, asset_category_id, asset_category_name, account_id, account_name, sale_discount, analytic_account_id, analytic_account_name, tax_id, tax_name, price_subtotal) SELECT id, invoice_id, product_code_id, product_code_name, label, quantity, uom_id, uom_name, unit_price, asset_category_id, asset_category_name, account_id, account_name, sale_discount, analytic_account_id, analytic_account_name, tax_id, tax_name, price_subtotal FROM account_move_line_update');

    List<Map<String, dynamic>> accountmovelineMap =
        await db.query('account_move_line');
    return List.generate(accountmovelineMap.length, (i) {
      return InvoiceLineOb(
          id: accountmovelineMap[i]['id'],
          invoiceId: accountmovelineMap[i]['invoice_id'],
          productCodeName: accountmovelineMap[i]['product_code_name'],
          productCodeId: accountmovelineMap[i]['product_code_id'],
          label: accountmovelineMap[i]['label'],
          assetCategoryId: accountmovelineMap[i]['asset_category_id'],
          assetCategoryName: accountmovelineMap[i]['asset_category_name'],
          accountId: accountmovelineMap[i]['account_id'],
          accountName: accountmovelineMap[i]['account_name'],
          quantity: accountmovelineMap[i]['quantity'],
          uomName: accountmovelineMap[i]['uom_name'],
          uomId: accountmovelineMap[i]['uom_id'],
          unitPrice: accountmovelineMap[i]['unit_price'],
          analyticAccountId: accountmovelineMap[i]['analytic_account_id'],
          analyticAccountName: accountmovelineMap[i]['analytic_account_name'],
          saleDiscount: accountmovelineMap[i]['sale_discount'],
          subTotal: accountmovelineMap[i]['price_subtotal']);
    });
  } // insert datas list from sale_order_line_update table to sale_order_line table

  Future<List<HrEmployeeLineOb>> insertTable2TableHrEmployeeLine() async {
    print('Worked');
    Database db = await database();
    await db.rawInsert(
        'INSERT INTO hr_employee_line(id,trip_line,emp_name,emp_id,department_id,department_name,job_id,job_name,responsible) SELECT id,trip_line,emp_name,emp_id,department_id,department_name,job_id,job_name,responsible FROM hr_employee_line_update');

    List<Map<String, dynamic>> hremployeelineMap =
        await db.query('hr_employee_line');
    return List.generate(hremployeelineMap.length, (i) {
      return HrEmployeeLineOb(
        id: hremployeelineMap[i]['id'],
        tripLine: hremployeelineMap[i]['trip_line'],
        empName: hremployeelineMap[i]['emp_name'],
        empId: hremployeelineMap[i]['emp_id'],
        departmentId: hremployeelineMap[i]['department_id'],
        departmentName: hremployeelineMap[i]['department_name'],
        jobId: hremployeelineMap[i]['job_id'],
        jobName: hremployeelineMap[i]['job_name'],
        responsible: hremployeelineMap[i]['responsible'],
      );
    });
  } // insert datas list from hr_employee_line_update table to hr_employee_line table

  Future<List<TripPlanScheduleOb>> insertTable2TableTripPlanSchedule() async {
    print('Worked');
    Database db = await database();
    await db.rawInsert(
        'INSERT INTO trip_plan_schedule(id,trip_id,from_date,to_date,location_id,location_name,remark) SELECT id,trip_id,from_date,to_date,location_id,location_name,remark FROM trip_plan_schedule_update');

    List<dynamic> list =
        await db.rawQuery('SELECT id FROM trip_plan_schedule_update');
    print('TripPlanScheduleUpdateList: ${list.length}');
    List<Map<String, dynamic>> tripPlanScheduleMap =
        await db.query('trip_plan_schedule');
    return List.generate(tripPlanScheduleMap.length, (i) {
      return TripPlanScheduleOb(
        id: tripPlanScheduleMap[i]['id'],
        tripId: tripPlanScheduleMap[i]['trip_id'],
        fromDate: tripPlanScheduleMap[i]['from_date'],
        toDate: tripPlanScheduleMap[i]['to_date'],
        locationId: tripPlanScheduleMap[i]['location_id'],
        locationName: tripPlanScheduleMap[i]['location_name'],
        remark: tripPlanScheduleMap[i]['remark'],
      );
    });
  } // insert datas list from TripPlanSchedule_update table to TripPlanSchedule table

  Future<List<TripPlanDeliveryOb>> insertTable2TableTripPlanDelivery() async {
    print('Worked');
    Database db = await database();
    await db.rawInsert(
        'INSERT INTO trip_plan_delivery(id,trip_line,team_id,team_name,assign_person_id,assign_person,zone_id,zone_name,invoice_id,invoice_name,order_id,order_name,state,invoice_status,remark) SELECT id,trip_line,team_id,team_name,assign_person_id,assign_person,zone_id,zone_name,invoice_id,invoice_name,order_id,order_name,state,invoice_status,remark FROM trip_plan_delivery_update');

    List<dynamic> list = await db.rawQuery('SELECT id FROM trip_plan_delivery');
    print('TripPlanDeliList: ${list.length}');
    List<Map<String, dynamic>> tripPlanDeliveryMap =
        await db.query('trip_plan_delivery');
    return List.generate(tripPlanDeliveryMap.length, (i) {
      return TripPlanDeliveryOb(
          id: tripPlanDeliveryMap[i]['id'],
          tripline: tripPlanDeliveryMap[i]['trip_line'],
          teamId: tripPlanDeliveryMap[i]['team_id'],
          teamName: tripPlanDeliveryMap[i]['team_name'],
          assignPersonId: tripPlanDeliveryMap[i]['assign_person_id'],
          assignPerson: tripPlanDeliveryMap[i]['assign_person'],
          zoneId: tripPlanDeliveryMap[i]['zone_id'],
          zoneName: tripPlanDeliveryMap[i]['zone_name'],
          invoiceId: tripPlanDeliveryMap[i]['invoice_id'],
          invoiceName: tripPlanDeliveryMap[i]['invoice_name'],
          orderId: tripPlanDeliveryMap[i]['order_id'],
          orderName: tripPlanDeliveryMap[i]['order_name'],
          state: tripPlanDeliveryMap[i]['state'],
          invoiceStatus: tripPlanDeliveryMap[i]['invoice_status'],
          remark: tripPlanDeliveryMap[i]['remark']);
    });
  } // insert datas list from trip_plan_delivery_update table to trip_plan_delivery table

  Future<List<SaleOrderLineOb>>? searchProductName(String keyword) async {
    Database db = await database();
    List<Map<String, dynamic>> saleorderlineMap = await db.query(
        'sale_order_line_multi_select',
        where: 'full_name LIKE ?',
        whereArgs: ['%$keyword%']);
    return List.generate(saleorderlineMap.length, (i) {
      return SaleOrderLineOb(
          id: saleorderlineMap[i]['id'],
          isSelect: saleorderlineMap[i]['isSelect'],
          quotationId: saleorderlineMap[i]['quotation_id'],
          productCodeName: saleorderlineMap[i]['product_code_name'],
          productCodeId: saleorderlineMap[i]['product_code_id'],
          description: saleorderlineMap[i]['description'],
          fullName: saleorderlineMap[i]['full_name'],
          quantity: saleorderlineMap[i]['quantity'],
          qtyDelivered: saleorderlineMap[i]['qty_delivered'],
          qtyInvoiced: saleorderlineMap[i]['qty_invoiced'],
          uomName: saleorderlineMap[i]['uom_name'],
          uomId: saleorderlineMap[i]['uom_id'],
          unitPrice: saleorderlineMap[i]['unit_price'],
          discountId: saleorderlineMap[i]['discount_id'],
          discountName: saleorderlineMap[i]['discount_name'],
          promotionId: saleorderlineMap[i]['promotion_id'],
          promotionName: saleorderlineMap[i]['promotion_name'],
          saleDiscount: saleorderlineMap[i]['sale_discount'],
          promotionDiscount: saleorderlineMap[i]['promotion_discount'],
          taxId: saleorderlineMap[i]['tax_id'],
          taxName: saleorderlineMap[i]['tax_name'],
          isFOC: saleorderlineMap[i]['is_foc'],
          subTotal: saleorderlineMap[i]['price_subtotal']);
    });
  } // search product name in sale_order_line_multi_select table

  Future<List<ProductLineOb>>? searchProductLineName(String keyword) async {
    Database db = await database();
    List<Map<String, dynamic>> productlineMap = await db.query(
        'material_product_line_multi_select',
        where: 'full_name LIKE ?',
        whereArgs: ['%$keyword%']);
    return List.generate(productlineMap.length, (i) {
      return ProductLineOb(
        id: productlineMap[i]['id'],
        isSelect: productlineMap[i]['isSelect'],
        materialproductId: productlineMap[i]['material_product_id'],
        productCodeName: productlineMap[i]['product_code_name'],
        productCodeId: productlineMap[i]['product_code_id'],
        description: productlineMap[i]['description'],
        fullName: productlineMap[i]['full_name'],
        quantity: productlineMap[i]['quantity'],
        uomName: productlineMap[i]['uom_name'],
        uomId: productlineMap[i]['uom_id'],
      );
    });
  } // search product name in material_product_line_multi_select table

  Future<List<SaleOrderLineOb>>? getproductlineList() async {
    Database db = await database();
    List<Map<String, dynamic>> saleorderlineMap =
        await db.query('sale_order_line');
    return List.generate(saleorderlineMap.length, (i) {
      return SaleOrderLineOb(
          id: saleorderlineMap[i]['id'],
          isSelect: saleorderlineMap[i]['isSelect'],
          quotationId: saleorderlineMap[i]['quotation_id'],
          productCodeName: saleorderlineMap[i]['product_code_name'],
          productCodeId: saleorderlineMap[i]['product_code_id'],
          description: saleorderlineMap[i]['description'],
          fullName: saleorderlineMap[i]['full_name'],
          quantity: saleorderlineMap[i]['quantity'],
          qtyDelivered: saleorderlineMap[i]['qty_delivered'],
          qtyInvoiced: saleorderlineMap[i]['qty_invoiced'],
          uomName: saleorderlineMap[i]['uom_name'],
          uomId: saleorderlineMap[i]['uom_id'],
          unitPrice: saleorderlineMap[i]['unit_price'],
          discountId: saleorderlineMap[i]['discount_id'],
          discountName: saleorderlineMap[i]['discount_name'],
          promotionId: saleorderlineMap[i]['promotion_id'],
          promotionName: saleorderlineMap[i]['promotion_name'],
          saleDiscount: saleorderlineMap[i]['sale_discount'],
          promotionDiscount: saleorderlineMap[i]['promotion_discount'],
          taxId: saleorderlineMap[i]['tax_id'],
          taxName: saleorderlineMap[i]['tax_name'],
          isFOC: saleorderlineMap[i]['is_foc'],
          subTotal: saleorderlineMap[i]['price_subtotal']);
    });
  } // get datas list from sale_order_line table

  Future<List<SaleOrderLineOb>> getSaleOrderLineUpdateList() async {
    Database db = await database();
    List<Map<String, dynamic>> saleorderlineMap =
        await db.query('sale_order_line_update');
    return List.generate(saleorderlineMap.length, (i) {
      return SaleOrderLineOb(
          id: saleorderlineMap[i]['id'],
          isSelect: saleorderlineMap[i]['isSelect'],
          quotationId: saleorderlineMap[i]['quotation_id'],
          productCodeName: saleorderlineMap[i]['product_code_name'],
          productCodeId: saleorderlineMap[i]['product_code_id'],
          description: saleorderlineMap[i]['description'],
          fullName: saleorderlineMap[i]['full_name'],
          quantity: saleorderlineMap[i]['quantity'],
          qtyDelivered: saleorderlineMap[i]['qty_delivered'],
          qtyInvoiced: saleorderlineMap[i]['qty_invoiced'],
          uomName: saleorderlineMap[i]['uom_name'],
          uomId: saleorderlineMap[i]['uom_id'],
          unitPrice: saleorderlineMap[i]['unit_price'],
          discountId: saleorderlineMap[i]['discount_id'],
          discountName: saleorderlineMap[i]['discount_name'],
          promotionId: saleorderlineMap[i]['promotion_id'],
          promotionName: saleorderlineMap[i]['promotion_name'],
          saleDiscount: saleorderlineMap[i]['sale_discount'],
          promotionDiscount: saleorderlineMap[i]['promotion_discount'],
          taxId: saleorderlineMap[i]['tax_id'],
          taxName: saleorderlineMap[i]['tax_name'],
          isFOC: saleorderlineMap[i]['is_foc'],
          subTotal: saleorderlineMap[i]['price_subtotal']);
    });
  } // get datas list from sale_order_line_update table

  Future<List<ProductLineOb>>? getMaterialProductLineList() async {
    Database db = await database();
    List<Map<String, dynamic>> productlineMap =
        await db.query('material_product_line');
    return List.generate(productlineMap.length, (i) {
      return ProductLineOb(
          id: productlineMap[i]['id'],
          isSelect: productlineMap[i]['isSelect'],
          materialproductId: productlineMap[i]['material_product_id'],
          productCodeName: productlineMap[i]['product_code_name'],
          productCodeId: productlineMap[i]['product_code_id'],
          description: productlineMap[i]['description'],
          fullName: productlineMap[i]['full_name'],
          quantity: productlineMap[i]['quantity'],
          uomName: productlineMap[i]['uom_name'],
          uomId: productlineMap[i]['uom_id']);
    });
  } // get datas list from sale_order_line table

  Future<List<ProductLineOb>>? getMaterialProductLineUpdateList() async {
    Database db = await database();
    List<Map<String, dynamic>> productlineMap =
        await db.query('material_product_line_update');
    return List.generate(productlineMap.length, (i) {
      return ProductLineOb(
          id: productlineMap[i]['id'],
          isSelect: productlineMap[i]['isSelect'],
          materialproductId: productlineMap[i]['material_product_id'],
          productCodeName: productlineMap[i]['product_code_name'],
          productCodeId: productlineMap[i]['product_code_id'],
          description: productlineMap[i]['description'],
          fullName: productlineMap[i]['full_name'],
          quantity: productlineMap[i]['quantity'],
          uomName: productlineMap[i]['uom_name'],
          uomId: productlineMap[i]['uom_id']);
    });
  } // get datas list from sale_order_line_update table

  Future<List<SaleOrderLineOb>> getSaleOrderLineMultiSelectList() async {
    Database db = await database();
    List<Map<String, dynamic>> saleorderlineMap =
        await db.query('sale_order_line_multi_select');
    return List.generate(saleorderlineMap.length, (i) {
      return SaleOrderLineOb(
          id: saleorderlineMap[i]['id'],
          isSelect: saleorderlineMap[i]['isSelect'],
          quotationId: saleorderlineMap[i]['quotation_id'],
          productCodeName: saleorderlineMap[i]['product_code_name'],
          productCodeId: saleorderlineMap[i]['product_code_id'],
          description: saleorderlineMap[i]['description'],
          fullName: saleorderlineMap[i]['full_name'],
          quantity: saleorderlineMap[i]['quantity'],
          qtyDelivered: saleorderlineMap[i]['qty_delivered'],
          qtyInvoiced: saleorderlineMap[i]['qty_invoiced'],
          uomName: saleorderlineMap[i]['uom_name'],
          uomId: saleorderlineMap[i]['uom_id'],
          unitPrice: saleorderlineMap[i]['unit_price'],
          discountId: saleorderlineMap[i]['discount_id'],
          discountName: saleorderlineMap[i]['discount_name'],
          promotionId: saleorderlineMap[i]['promotion_id'],
          promotionName: saleorderlineMap[i]['promotion_name'],
          saleDiscount: saleorderlineMap[i]['sale_discount'],
          promotionDiscount: saleorderlineMap[i]['promotion_discount'],
          taxId: saleorderlineMap[i]['tax_id'],
          taxName: saleorderlineMap[i]['tax_name'],
          isFOC: saleorderlineMap[i]['is_foc'],
          subTotal: saleorderlineMap[i]['price_subtotal']);
    });
  } // get datas list from sale_order_line_multi_select table

  Future<List<ProductLineOb>> getMaterialProductLineMultiSelectList() async {
    Database db = await database();
    List<Map<String, dynamic>> saleorderlineMap =
        await db.query('material_product_line_multi_select');
    return List.generate(saleorderlineMap.length, (i) {
      return ProductLineOb(
        id: saleorderlineMap[i]['id'],
        isSelect: saleorderlineMap[i]['isSelect'],
        materialproductId: saleorderlineMap[i]['material_product_id'],
        productCodeName: saleorderlineMap[i]['product_code_name'],
        productCodeId: saleorderlineMap[i]['product_code_id'],
        description: saleorderlineMap[i]['description'],
        fullName: saleorderlineMap[i]['full_name'],
        quantity: saleorderlineMap[i]['quantity'],
        uomName: saleorderlineMap[i]['uom_name'],
        uomId: saleorderlineMap[i]['uom_id'],
      );
    });
  } // get datas list from material_product_line_multi_select table

  Future<List<StockMoveOb>> getStockMoveList() async {
    Database db = await database();
    List<Map<String, dynamic>> stockmoveMap = await db.query('stock_move');
    return List.generate(stockmoveMap.length, (i) {
      return StockMoveOb(
        id: stockmoveMap[i]['id'],
        isSelect: stockmoveMap[i]['isSelect'],
        pickigId: stockmoveMap[i]['picking_id'],
        productCodeName: stockmoveMap[i]['product_code_name'],
        productCodeId: stockmoveMap[i]['product_code_id'],
        description: stockmoveMap[i]['description'],
        fullName: stockmoveMap[i]['full_name'],
        demand: stockmoveMap[i]['quantity'],
        uomName: stockmoveMap[i]['uom_name'],
        uomId: stockmoveMap[i]['uom_id'],
        reserved: stockmoveMap[i]['reserved'],
        done: stockmoveMap[i]['done'],
        remainingstock: stockmoveMap[i]['remaining_stock'],
        damageQty: stockmoveMap[i]['damage_qty'],
      );
    });
  } // get datas list from stock_move table

  Future<List<StockMoveOb>> getStockMoveUpdateList() async {
    Database db = await database();
    List<Map<String, dynamic>> stockmoveMap =
        await db.query('stock_move_update');
    return List.generate(stockmoveMap.length, (i) {
      return StockMoveOb(
        id: stockmoveMap[i]['id'],
        isSelect: stockmoveMap[i]['isSelect'],
        pickigId: stockmoveMap[i]['picking_id'],
        productCodeName: stockmoveMap[i]['product_code_name'],
        productCodeId: stockmoveMap[i]['product_code_id'],
        description: stockmoveMap[i]['description'],
        fullName: stockmoveMap[i]['full_name'],
        demand: stockmoveMap[i]['quantity'],
        uomName: stockmoveMap[i]['uom_name'],
        uomId: stockmoveMap[i]['uom_id'],
        reserved: stockmoveMap[i]['reserved'],
        done: stockmoveMap[i]['done'],
        remainingstock: stockmoveMap[i]['remaining_stock'],
        damageQty: stockmoveMap[i]['damage_qty'],
      );
    });
  } // get datas list from stock_move_update table

  Future<List<HrEmployeeLineOb>> getHrEmployeeLineList() async {
    Database db = await database();
    List<Map<String, dynamic>> hremployeelineMap =
        await db.query('hr_employee_line');
    return List.generate(hremployeelineMap.length, (i) {
      return HrEmployeeLineOb(
        id: hremployeelineMap[i]['id'],
        tripLine: hremployeelineMap[i]['trip_line'],
        empName: hremployeelineMap[i]['emp_name'],
        empId: hremployeelineMap[i]['emp_id'],
        departmentId: hremployeelineMap[i]['department_id'],
        departmentName: hremployeelineMap[i]['department_name'],
        jobId: hremployeelineMap[i]['job_id'],
        jobName: hremployeelineMap[i]['job_name'],
        responsible: hremployeelineMap[i]['responsible'],
      );
    });
  } // get datas list from hr_employee_line table

  Future<List<HrEmployeeLineOb>> getHrEmployeeLineUpdateList() async {
    print('HREmployeeline Get Work');

    Database db = await database();
    List<Map<String, dynamic>> hremployeelineMap =
        await db.query('hr_employee_line_update');
    return List.generate(hremployeelineMap.length, (i) {
      return HrEmployeeLineOb(
        id: hremployeelineMap[i]['id'],
        tripLine: hremployeelineMap[i]['trip_line'],
        empName: hremployeelineMap[i]['emp_name'],
        empId: hremployeelineMap[i]['emp_id'],
        departmentId: hremployeelineMap[i]['department_id'],
        departmentName: hremployeelineMap[i]['department_name'],
        jobId: hremployeelineMap[i]['job_id'],
        jobName: hremployeelineMap[i]['job_name'],
        responsible: hremployeelineMap[i]['responsible'],
      );
    });
  } // get datas list from hr_employee_line_update table

  Future<List<TripPlanDeliveryOb>> getTripPlanDeliveryList() async {
    print('TripPlanDelivery Get Work');

    Database db = await database();
    List<dynamic> list = await db.rawQuery('SELECT id FROM trip_plan_delivery');
    print('TripPlanDeliList: ${list.length}');
    List<Map<String, dynamic>> tripPlanDeliveryMap =
        await db.query('trip_plan_delivery');
    return List.generate(tripPlanDeliveryMap.length, (i) {
      return TripPlanDeliveryOb(
          id: tripPlanDeliveryMap[i]['id'],
          tripline: tripPlanDeliveryMap[i]['trip_line'],
          teamId: tripPlanDeliveryMap[i]['team_id'],
          teamName: tripPlanDeliveryMap[i]['team_name'],
          assignPersonId: tripPlanDeliveryMap[i]['assign_person_id'],
          assignPerson: tripPlanDeliveryMap[i]['assign_person'],
          zoneId: tripPlanDeliveryMap[i]['zone_id'],
          zoneName: tripPlanDeliveryMap[i]['zone_name'],
          invoiceId: tripPlanDeliveryMap[i]['invoice_id'],
          invoiceName: tripPlanDeliveryMap[i]['invoice_name'],
          orderId: tripPlanDeliveryMap[i]['order_id'],
          orderName: tripPlanDeliveryMap[i]['order_name'],
          state: tripPlanDeliveryMap[i]['state'],
          invoiceStatus: tripPlanDeliveryMap[i]['invoice_status'],
          remark: tripPlanDeliveryMap[i]['remark']);
    });
  } // get datas list from trip_plan_delivery table

  Future<List<TripPlanDeliveryOb>> getTripPlanDeliveryListUpdate() async {
    print('TripPlanDeliveryUpdate Get Work');

    Database db = await database();
    List<dynamic> list =
        await db.rawQuery('SELECT id FROM trip_plan_delivery_update');
    print('TripPlanDeliUpdateList: ${list.length}');
    List<Map<String, dynamic>> tripPlanDeliveryMap =
        await db.query('trip_plan_delivery_update');
    return List.generate(tripPlanDeliveryMap.length, (i) {
      return TripPlanDeliveryOb(
          id: tripPlanDeliveryMap[i]['id'],
          tripline: tripPlanDeliveryMap[i]['trip_line'],
          teamId: tripPlanDeliveryMap[i]['team_id'],
          teamName: tripPlanDeliveryMap[i]['team_name'],
          assignPersonId: tripPlanDeliveryMap[i]['assign_person_id'],
          assignPerson: tripPlanDeliveryMap[i]['assign_person'],
          zoneId: tripPlanDeliveryMap[i]['zone_id'],
          zoneName: tripPlanDeliveryMap[i]['zone_name'],
          invoiceId: tripPlanDeliveryMap[i]['invoice_id'],
          invoiceName: tripPlanDeliveryMap[i]['invoice_name'],
          orderId: tripPlanDeliveryMap[i]['order_id'],
          orderName: tripPlanDeliveryMap[i]['order_name'],
          state: tripPlanDeliveryMap[i]['state'],
          invoiceStatus: tripPlanDeliveryMap[i]['invoice_status'],
          remark: tripPlanDeliveryMap[i]['remark']);
    });
  } // get datas list from trip_plan_delivery_update table

  Future<List<TripPlanScheduleOb>> getTripPlanScheduleList() async {
    print('TripPlanSchedule Get Work');

    Database db = await database();
    List<dynamic> list = await db.rawQuery('SELECT id FROM trip_plan_schedule');
    print('TripPlanScheduleList: ${list.length}');
    List<Map<String, dynamic>> tripPlanScheduleMap =
        await db.query('trip_plan_schedule');
    return List.generate(tripPlanScheduleMap.length, (i) {
      return TripPlanScheduleOb(
        id: tripPlanScheduleMap[i]['id'],
        tripId: tripPlanScheduleMap[i]['trip_id'],
        fromDate: tripPlanScheduleMap[i]['from_date'],
        toDate: tripPlanScheduleMap[i]['to_date'],
        locationId: tripPlanScheduleMap[i]['location_id'],
        locationName: tripPlanScheduleMap[i]['location_name'],
        remark: tripPlanScheduleMap[i]['remark'],
      );
    });
  } // get datas list from trip_plan_schedule table

  Future<List<TripPlanScheduleOb>> getTripPlanScheduleListUpdate() async {
    print('TripPlanScheduleUpdate Get Work');

    Database db = await database();
    List<dynamic> list =
        await db.rawQuery('SELECT id FROM trip_plan_schedule_update');
    print('TripPlanScheduleUpdateList: ${list.length}');
    List<Map<String, dynamic>> tripPlanScheduleMap =
        await db.query('trip_plan_schedule_update');
    return List.generate(tripPlanScheduleMap.length, (i) {
      return TripPlanScheduleOb(
        id: tripPlanScheduleMap[i]['id'],
        tripId: tripPlanScheduleMap[i]['trip_id'],
        fromDate: tripPlanScheduleMap[i]['from_date'],
        toDate: tripPlanScheduleMap[i]['to_date'],
        locationId: tripPlanScheduleMap[i]['location_id'],
        locationName: tripPlanScheduleMap[i]['location_name'],
        remark: tripPlanScheduleMap[i]['remark'],
      );
    });
  } // get datas list from trip_plan_schedule_update table

  Future<List<InvoiceLineOb>>? getAccountMoveLineList() async {
    Database db = await database();
    List<Map<String, dynamic>> accountmovelineMap =
        await db.query('account_move_line');
    return List.generate(accountmovelineMap.length, (i) {
      return InvoiceLineOb(
          id: accountmovelineMap[i]['id'],
          invoiceId: accountmovelineMap[i]['invoice_id'],
          productCodeName: accountmovelineMap[i]['product_code_name'],
          productCodeId: accountmovelineMap[i]['product_code_id'],
          label: accountmovelineMap[i]['label'],
          assetCategoryId: accountmovelineMap[i]['asset_category_id'],
          assetCategoryName: accountmovelineMap[i]['asset_category_name'],
          accountId: accountmovelineMap[i]['account_id'],
          accountName: accountmovelineMap[i]['account_name'],
          quantity: accountmovelineMap[i]['quantity'],
          uomName: accountmovelineMap[i]['uom_name'],
          uomId: accountmovelineMap[i]['uom_id'],
          unitPrice: accountmovelineMap[i]['unit_price'],
          analyticAccountId: accountmovelineMap[i]['analytic_account_id'],
          analyticAccountName: accountmovelineMap[i]['analytic_account_name'],
          saleDiscount: accountmovelineMap[i]['sale_discount'],
          subTotal: accountmovelineMap[i]['price_subtotal']);
    });
  } // get datas list from account_move_line table

  Future<List<InvoiceLineOb>>? getAccountMoveLineListUpdate() async {
    Database db = await database();
    List<Map<String, dynamic>> accountmovelineMap =
        await db.query('account_move_line_update');
    return List.generate(accountmovelineMap.length, (i) {
      return InvoiceLineOb(
          id: accountmovelineMap[i]['id'],
          invoiceId: accountmovelineMap[i]['invoice_id'],
          productCodeName: accountmovelineMap[i]['product_code_name'],
          productCodeId: accountmovelineMap[i]['product_code_id'],
          label: accountmovelineMap[i]['label'],
          assetCategoryId: accountmovelineMap[i]['asset_category_id'],
          assetCategoryName: accountmovelineMap[i]['asset_category_name'],
          accountId: accountmovelineMap[i]['account_id'],
          accountName: accountmovelineMap[i]['account_name'],
          quantity: accountmovelineMap[i]['quantity'],
          uomName: accountmovelineMap[i]['uom_name'],
          uomId: accountmovelineMap[i]['uom_id'],
          unitPrice: accountmovelineMap[i]['unit_price'],
          analyticAccountId: accountmovelineMap[i]['analytic_account_id'],
          analyticAccountName: accountmovelineMap[i]['analytic_account_name'],
          saleDiscount: accountmovelineMap[i]['sale_discount'],
          subTotal: accountmovelineMap[i]['price_subtotal']);
    });
  } // get datas list from account_move_line table

  Future<List<TaxesOb>>? getTaxIDS(lineId) async {
    Database db = await database();
    List<Map<String, dynamic>> taxIdsMap =
        await db.rawQuery('SELECT * FROM tax_ids WHERE line_id = $lineId');
    return List.generate(taxIdsMap.length, (i) {
      return TaxesOb(
        id: taxIdsMap[i]['id'],
        lineId: taxIdsMap[i]['line_id'],
        taxId: taxIdsMap[i]['tax_id'],
      );
    });
  } // get datas list from tax_ids table with line_id

  Future<List<TaxesOb>>? getSOLTaxIDS(lineId) async {
    Database db = await database();
    List<Map<String, dynamic>> taxIdsMap =
        await db.rawQuery('SELECT * FROM sol_tax_ids WHERE line_id = $lineId');
    return List.generate(taxIdsMap.length, (i) {
      return TaxesOb(
        id: taxIdsMap[i]['id'],
        lineId: taxIdsMap[i]['line_id'],
        taxId: taxIdsMap[i]['tax_id'],
      );
    });
  } // get datas list from sol_tax_ids table with line_id

  Future<void> updateSaleOrderLineOrderId(int? id, int? orderId) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE sale_order_line SET quotation_id = '$orderId' WHERE id = '$id'");
  }

  Future<void> updateSaleOrderLine(
      {int? id,
      int? quotationId,
      int? isSelect,
      int? productCodeId,
      String? productCodeName,
      String? description,
      String? quantity,
      int? uomId,
      String? uomName,
      String? unitPrice,
      int? taxId,
      String? taxName,
      String? subTotal}) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE sale_order_line SET quotation_id = $quotationId, isSelect = $isSelect, product_code_id = $productCodeId, product_code_name = '$productCodeName', description = '$description', quantity = '$quantity', uom_id = $uomId, uom_name = '$uomName', unit_price = '$unitPrice',tax_id = '$taxId',tax_name = '$taxName', price_subtotal = '$subTotal' WHERE id = $id");
  } // Update datas to sale_order_line table

  Future<void> updateSaleOrderLineUpdate(
      {int? id,
      int? quotationId,
      int? isSelect,
      int? productCodeId,
      String? productCodeName,
      String? description,
      String? quantity,
      int? uomId,
      String? uomName,
      String? unitPrice,
      int? taxId,
      String? taxName,
      String? subTotal}) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE sale_order_line_update SET quotation_id = $quotationId, isSelect = $isSelect, product_code_id = $productCodeId, product_code_name = '$productCodeName', description = '$description', quantity = '$quantity', uom_id = $uomId, uom_name = '$uomName', unit_price = '$unitPrice',tax_id = '$taxId',tax_name = '$taxName', price_subtotal = '$subTotal' WHERE id = $id");
  } // Update datas to sale_order_line_update table

  Future<void> updateSaleOrderLineMultiSelect(
      {int? id,
      int? quotationId,
      int? isSelect,
      int? productCodeId,
      String? productCodeName,
      String? description,
      String? quantity,
      int? uomId,
      String? uomName,
      String? unitPrice,
      int? taxId,
      String? taxName,
      String? subTotal}) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE sale_order_line_multi_select SET quotation_id = $quotationId, isSelect = $isSelect, product_code_id = $productCodeId, product_code_name = '$productCodeName', description = '$description', quantity = '$quantity', uom_id = $uomId, uom_name = '$uomName', unit_price = '$unitPrice',tax_id = '$taxId',tax_name = '$taxName', price_subtotal = '$subTotal' WHERE id = $id");
  } // Update datas to sale_order_line_multi_select table

  Future<void> updateProductLineMultiSelect({
    int? id,
    int? isSelect,
    int? materialproductId,
    int? productCodeId,
    String? productCodeName,
    String? description,
    String? quantity,
    int? uomId,
    String? uomName,
  }) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE material_product_line_multi_select SET isSelect = $isSelect, material_product_id = $materialproductId, product_code_id = $productCodeId, product_code_name = '$productCodeName', description = '$description',  quantity = $quantity, uom_id = $uomId, uom_name = '$uomName' WHERE id = $id");
  } // Update datas to material_product_line_multi_select table

  Future<void> updateSaleOrderLineMultiSelectIsSelect({int? id}) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE sale_order_line_multi_select SET isSelect = 0 WHERE id = $id");
  } // Update datas to sale_order_line_multi_select isSelect table

  Future<void> updateMaterialProductLineMultiSelectIsSelect({int? id}) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE material_product_line_multi_select SET isSelect = 0 WHERE id = $id");
  } // Update datas to material_product_line_multi_select isSelect table

  Future<void> updateHrEmployeeLine(
      int? id,
      int? tripLine,
      int? empId,
      String? empName,
      int? departmentId,
      String? departmentName,
      int? jobId,
      String? jobName,
      int? responsible) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE hr_employee_line SET trip_line = $tripLine, emp_id =$empId, emp_name = '$empName', department_id = $departmentId, department_name = '$departmentName', job_id = $jobId, job_name = '$jobName', responsible = $responsible WHERE id = $id");
  } // Update datas to hr_employee_line table

  Future<void> updateTripPlanSchedule(
      int? id,
      int? tripId,
      String fromDate,
      String? toDate,
      int locationId,
      String locationName,
      String? remark) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE trip_plan_schedule SET trip_id = $tripId, from_date = '$fromDate', to_date = '$toDate', location_id = $locationId, location_name = '$locationName', remark = '$remark' WHERE id = $id");
  } // Update datas to trip_plan_schedule table

  Future<void> updateTripPlanDelivery(
      int? id,
      int? tripline,
      int teamId,
      String teamName,
      int assignPersonId,
      String assignPersonName,
      int zoneId,
      String zoneName,
      int invoiceId,
      String invoiceName,
      int orderId,
      String orderName,
      String state,
      String invoiceStatus,
      String? remark) async {
    Database _db = await database();
    await _db.rawUpdate(
        "UPDATE trip_plan_delivery SET trip_line = $tripline, team_id = $teamId, team_name = '$teamName', assign_person_id = $assignPersonId, assign_person = '$assignPersonName', zone_id = $zoneId, zone_name = '$zoneName', invoice_id = $invoiceId, invoice_name = '$invoiceName', order_id = $orderId, order_name = '$orderName', state = '$state', invoice_status = '$invoiceStatus', remark = '$remark' WHERE id = $id");
  } // Update datas to trip_plan_delivery table

  Future<void> deleteAllSaleOrderLine() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM sale_order_line");
    print('Delete Sale Order line Successfully');
  }

  Future<void> deleteSaleOrderLineManul(int? id) async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM sale_order_line WHERE id = $id");
    print('Delete Sale Order line $id Successfully');
  }

  Future<void> deleteAllSaleOrderLineUpdate() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM sale_order_line_update");
    print('Delete Sale Order line Update Successfully');
  }

  Future<void> deleteAllSaleOrderLineMultiSelect() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM sale_order_line_multi_select");
    print('Delete Sale Order line Multi Select Successfully');
  }

  Future<void> deleteAllMaterialProductLine() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM material_product_line");
    print('Delete Material Product line Successfully');
  }

  Future<void> deleteAllMaterialProductLineUpdate() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM material_product_line_update");
    print('Delete Material Product line Successfully');
  }

  Future<void> deleteAllProductLineMultiSelect() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM material_product_line_multi_select");
    print('Delete Material Product line Multi Select Successfully');
  }

  Future<void> deleteAllStockMove() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM stock_move");
    print('Delete Stock Move Successfully');
  }

  Future<void> deleteAllStockMoveUpdate() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM stock_move_update");
    print('Delete Stock Move Update Successfully');
  }

  Future<void> deleteMaterialProductLineManul(int? id) async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM material_product_line WHERE id = $id");
    print('Delete material_product_line $id Successfully');
  }

  Future<void> deleteAllHrEmployeeLine() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM hr_employee_line");
    print('Delete HR Employee Line Successfully');
  }

  Future<void> deleteHrEmployeeLineManul(int? id) async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM hr_employee_line WHERE id = $id");
    print('Delete hr_employee_line $id Successfully');
  }

  Future<void> deleteAllHrEmployeeLineUpdate() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM hr_employee_line_update");
    print('Delete HR Employee Line Update Successfully');
  }

  Future<void> deleteAllTripPlanDelivery() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM trip_plan_delivery");
    print('Delete Trip Plan Delivery Successfully');
  }

  Future<void> deleteTripPlanDeliveryManual(int? id) async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM trip_plan_delivery WHERE id = $id");
    print('Delete Trip Plan Delivery $id Successfully');
  }

  Future<void> deleteAllTripPlanDeliveryUpdate() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM trip_plan_delivery_update");
    print('Delete Trip Plan Delivery Update Successfully');
  }

  Future<void> deleteAllTripPlanSchedule() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM trip_plan_schedule");
    print('Delete Trip Plan Schedule Successfully');
  }

  Future<void> deleteTripPlanScheduleManul(int? id) async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM trip_plan_schedule WHERE id = $id");
    print('Delete trip_plan_schedule $id Successfully');
  }

  Future<void> deleteAllTripPlanScheduleUpdate() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM trip_plan_schedule_update");
    print('Delete Trip Plan Schedule Update Successfully');
  }

  Future<void> deleteAllAccountMoveLine() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM account_move_line");
    print('Delete account_move_line Update Successfully');
  }

  Future<void> deleteAllAccountMoveLineUpdate() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM account_move_line_update");
    print('Delete account_move_line_update Successfully');
  }

  Future<void> deleteAllTaxIds() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM tax_ids");
    print('Delete Tax Ids Successfully');
  }

  Future<void> deleteAllSOLTaxIds() async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM sol_tax_ids");
    print('Delete SOL Tax Ids Successfully');
  }
}
