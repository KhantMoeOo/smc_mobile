class StockMoveOb {
  int? id;
  int isSelect;
  int pickigId;
  //int? invoiceId;
  //String? invoiceName;
  String productCodeName;
  int productCodeId;
  String description;
  String fullName;
  String demand;
  String? reserved;
  String? done;
  String? damageQty;
  String? remainingstock;
  String uomName;
  int uomId;

  StockMoveOb({
    this.id,
    required this.isSelect,
    required this.pickigId,
    //this.invoiceId,
    //this.invoiceName,
    required this.productCodeName,
    required this.productCodeId,
    required this.description,
    required this.fullName,
    required this.demand,
    this.reserved,
    this.done,
    this.remainingstock,
    this.damageQty,
    required this.uomName,
    required this.uomId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isSelect': isSelect,
      'picking_id': pickigId,
      //'invoice_id': invoiceId,
      //'invoice_name': invoiceName,
      'product_code_name': productCodeName,
      'product_code_id': productCodeId,
      'description': description,
      'full_name': fullName,
      'quantity': demand,
      'reserved': reserved,
      'remaining_stock': remainingstock,
      'damage_qty': damageQty,
      'done': done,
      'uom_name': uomName,
      'uom_id': uomId,
    };
  }
}
