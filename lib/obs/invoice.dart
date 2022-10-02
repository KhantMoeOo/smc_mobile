import 'customer.dart';
import 'supplier.dart';

class Invoice {
  final InvoiceInfo info;
  final Supplier supplier;
  final Customer customer;
  final List<InvoiceItem> items;

  const Invoice({
    required this.info,
    required this.supplier,
    required this.customer,
    required this.items,
  });
}

class InvoiceInfo {
  final String? description;
  final String number;
  final String date;
  final DateTime? dueDate;

  const InvoiceInfo({
    this.description,
    required this.number,
    required this.date,
    this.dueDate,
  });
}

class InvoiceItem {
  final String description;
  final String uomName;
  final double quantity;
  final double unitPrice;
  final String subtotal;
  final int isFOC;

  const InvoiceItem({
    required this.description,
    required this.uomName,
    required this.quantity,
    required this.subtotal,
    required this.unitPrice,
    required this.isFOC,
  });
}
