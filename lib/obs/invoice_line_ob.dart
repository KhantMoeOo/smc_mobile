class InvoiceLineOb {
  int? id;
  int? invoiceId;
  String productCodeName;
  int productCodeId;
  String label;
  int assetCategoryId;
  String assetCategoryName;
  int accountId;
  String accountName;
  String quantity;
  String uomName;
  int uomId;
  String unitPrice;
  int analyticAccountId;
  String analyticAccountName;
  String saleDiscount;
  String subTotal;

  InvoiceLineOb({
    this.id,
    this.invoiceId,
    required this.productCodeName,
    required this.productCodeId,
    required this.label,
    required this.assetCategoryId,
    required this.assetCategoryName,
    required this.accountId,
    required this.accountName,
    required this.quantity,
    required this.uomName,
    required this.uomId,
    required this.unitPrice,
    required this.analyticAccountId,
    required this.analyticAccountName,
    required this.saleDiscount,
    required this.subTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_code_name': productCodeName,
      'product_code_id': productCodeId,
      'label': label,
      'asset_category_id': assetCategoryId,
      'asset_category_name': assetCategoryName,
      'account_id': accountId,
      'account_name': accountName,
      'quantity': quantity,
      'uom_name': uomName,
      'uom_id': uomId,
      'unit_price': unitPrice,
      'analytic_account_id': analyticAccountId,
      'analytic_account_name': analyticAccountName,
      'price_subtotal': subTotal,
      'sale_discount': saleDiscount,
    };
  }
}

class TaxesOb {
  int? id;
  int lineId;
  int taxId;

  TaxesOb({
    this.id,
    required this.lineId,
    required this.taxId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'line_id': lineId,
      'tax_id': taxId,
    };
  }
}
