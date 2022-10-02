class ProductLineOb {
  int? id;
  int isSelect;
  int? materialproductId;
  //int? invoiceId;
  //String? invoiceName;
  String productCodeName;
  int productCodeId;
  String description;
  String fullName;
  String quantity;
  String uomName;
  int uomId;

  ProductLineOb({
    this.id,
    required this.isSelect,
    this.materialproductId,
    //this.invoiceId,
    //this.invoiceName,
    required this.productCodeName,
    required this.productCodeId,
    required this.description,
    required this.fullName,
    required this.quantity,
    required this.uomName,
    required this.uomId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isSelect': isSelect,
      'material_product_id': materialproductId,
      //'invoice_id': invoiceId,
      //'invoice_name': invoiceName,
      'product_code_name': productCodeName,
      'product_code_id': productCodeId,
      'description': description,
      'full_name': fullName,
      'quantity': quantity,
      'uom_name': uomName,
      'uom_id': uomId,
    };
  }
}
