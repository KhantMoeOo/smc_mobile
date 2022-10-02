class TripPlanScheduleOb {
  int? id;
  int tripId;
  String fromDate;
  String toDate;
  int locationId;
  String? locationName;
  String remark;

  TripPlanScheduleOb(
      {this.id,
      required this.tripId,
      required this.fromDate,
      required this.toDate,
      required this.locationId,
      this.locationName,
      required this.remark});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'from_date': fromDate,
      'to_date': toDate,
      'location_id': locationId,
      'location_name': locationName,
      'remark': remark,
    };
  }
}
