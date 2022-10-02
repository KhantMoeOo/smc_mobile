class HrEmployeeLineOb {
  int? id;
  int? tripLine;
  String empName;
  int empId;
  int departmentId;
  String? departmentName;
  int jobId;
  String? jobName;
  int? responsible;

  HrEmployeeLineOb(
      {
      this.id,
      this.tripLine,
      required this.empName,
      required this.empId,
      required this.departmentId,
      this.departmentName,
      required this.jobId,
      this.jobName,
      required this.responsible,});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_line': tripLine,
      'emp_name': empName,
      'emp_id': empId,
      'department_id': departmentId,
      'department_name': departmentName,
      'job_id': jobId,
      'job_name': jobName,
      'responsible': responsible,
    };
  }
}
