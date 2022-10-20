class SaleOrderLineOb {
  int? id;
  int isSelect;
  int? quotationId;
  String productCodeName;
  int productCodeId;
  String description;
  String fullName;
  String quantity = '0.0';
  String? qtyDelivered = '0.0';
  String? qtyInvoiced = '0.0';
  String uomName;
  int uomId;
  String unitPrice = '0.0';
  int? discountId = 0;
  String? discountName = '';
  int? promotionId = 0;
  String? promotionName = '';
  String? saleDiscount = '';
  String? promotionDiscount = '';
  String taxId = '[]';
  String taxName;
  int? isFOC = 0;
  String subTotal;

  SaleOrderLineOb({
    this.id,
    required this.isSelect,
    this.quotationId,
    required this.productCodeName,
    required this.productCodeId,
    required this.description,
    required this.fullName,
    required this.quantity,
    this.qtyDelivered,
    this.qtyInvoiced,
    required this.uomName,
    required this.uomId,
    required this.unitPrice,
    this.discountId,
    this.discountName,
    this.promotionId,
    this.promotionName,
    this.saleDiscount,
    this.promotionDiscount,
    required this.taxId,
    required this.taxName,
    this.isFOC,
    required this.subTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isSelect': isSelect,
      'quotation_id': quotationId,
      'product_code_name': productCodeName,
      'product_code_id': productCodeId,
      'description': description,
      'full_name': fullName,
      'quantity': quantity,
      'qty_delivered': qtyDelivered,
      'qty_invoiced': qtyInvoiced,
      'uom_name': uomName,
      'uom_id': uomId,
      'unit_price': unitPrice,
      'price_subtotal': subTotal,
      'discount_id': discountId,
      'discount_name': discountName,
      'promotion_id': promotionId,
      'promotion_name': promotionName,
      'sale_discount': saleDiscount,
      'promotion_discount': promotionDiscount,
      'tax_id': taxId,
      'tax_name': taxName,
      'is_foc': isFOC,
    };
  }
}
