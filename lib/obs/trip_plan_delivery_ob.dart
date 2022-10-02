class TripPlanDeliveryOb {
  int? id;
  int tripline;
  int teamId;
  String? teamName;
  int assignPersonId;
  String? assignPerson;
  int zoneId;
  String? zoneName;
  int invoiceId;
  String? invoiceName;
  int orderId;
  String? orderName;
  String state;
  String invoiceStatus;
  String remark;

  TripPlanDeliveryOb(
      {this.id,
      required this.tripline,
      required this.teamId,
      this.teamName,
      this.assignPerson,
      required this.assignPersonId,
      required this.zoneId,
      this.zoneName,
      required this.invoiceId,
      this.invoiceName,
      required this.orderId,
      this.orderName,
      required this.state,
      required this.invoiceStatus,
      required this.remark});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'team_id': teamId,
      'team_name': teamName,
      'assign_person_id': assignPersonId,
      'assign_person': assignPerson,
      'zone_id': zoneId,
      'zone_name': zoneName,
      'invoice_id': invoiceId,
      'invoice_name': invoiceName,
      'state': state,
      'invoice_status': invoiceStatus,
      'order_id': orderId,
      'order_name': orderName,
      'remark': remark,
      'trip_line': tripline
    };
  }
}
