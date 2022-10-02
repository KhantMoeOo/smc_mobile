import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../../../dbs/database_helper.dart';
import '../../../obs/hr_employee_line_ob.dart';
import '../../../obs/response_ob.dart';
import '../../../utils/app_const.dart';
import '../../profile_page/profile_bloc.dart';
import 'sale_team_bloc.dart';

class SaleTeamCreatePage extends StatefulWidget {
  int tripLine;
  int? hremployeelineId;
  int newOrEdit;
  int neworeditHEL;
  int empId;
  int departmentId;
  String? departmentName;
  int jobId;
  String? jobName;
  int? responsible;
  SaleTeamCreatePage({Key? key,
  required this.tripLine,
  required this.hremployeelineId,
  required this.newOrEdit,
  required this.neworeditHEL,
  required this.empId,
  required this.departmentId,
  required this.departmentName,
  required this.jobId,
  required this.jobName,
  required this.responsible,
  }) : super(key: key);

  @override
  State<SaleTeamCreatePage> createState() => _SaleTeamCreatePageState();
}

class _SaleTeamCreatePageState extends State<SaleTeamCreatePage> {
  final profileBloc = ProfileBloc();
  final saleTeamBloc = SaleTeamBloc();
  final databaseHelper = DatabaseHelper();

  List<dynamic> hremployeeList = [];
  int hremployeeId = 0;
  String hremployeeName = '';
  bool hasNotHrEmployee = true;

  bool hasNotHrDepartment = true;
  List<dynamic> hrDepartmentList = [];
  int hrDepartmentId = 0;
  String hrDeparmentName = '';

  bool hasNotHrJob = true;
  int hrJobInt = 0;
  String hrJobName = '';
  List<dynamic> hrJobList = [];

  bool isCheck = false;

  final departmentController = TextEditingController();
  final jobController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileBloc.getHrEmployeeData();
    profileBloc.getHrEmployeeStream().listen(getHrEmployeeListListen);
    saleTeamBloc.getHrDeparmentListData();
    saleTeamBloc.getHrDeparmentListStream().listen(getHrDepartmentListListen);
    saleTeamBloc.getHrJobListData();
    saleTeamBloc.getHrJobListStream().listen(getHrJobListListen);
  }

  void getHrEmployeeListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      hremployeeList = responseOb.data;
      setHrEmployeeNameMethod();
      print('hremployee: ${hremployeeList.length}');
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoHremployeeList");
    }
  } // listen to get Hr Employee List

  void getHrEmployeeListId(String? v) {
    if (v != null) {
      setState(() {
        hremployeeId = int.parse(v.toString().split(',')[0]);
        hasNotHrEmployee = false;
        for (var element in hremployeeList) {
          if (element['id'] == hremployeeId) {
            hremployeeName = element['name'];
            hremployeeId = element['id'];
            departmentController.text = element['department_id'] == false
                ? ''
                : element['department_id'][1];
            hrDepartmentId = element['department_id'] == false
                ? 0
                : element['department_id'][0];
            hrJobInt = element['job_id'] == false ? 0 : element['job_id'][0];
            jobController.text =
                element['job_id'] == false ? '' : element['job_id'][1];
            print('HrEmployeeName:$hremployeeName');
            print('HrEmployeeId:$hremployeeId');
            print('HrDepartment: ${departmentController.text}');
            print('HrJob: ${jobController.text}');
          }
        }
      });
    } else {
      hasNotHrEmployee = true;
    }
  } // get HrEmployee ListId from HrEmployeeListSelection

  void setHrEmployeeNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.empId != 0) {
        for (var element in hremployeeList) {
          if (element['id'] == widget.empId) {
            hasNotHrEmployee = false;
            hremployeeId = element['id'];
            hremployeeName = element['name'];
            departmentController.text = widget.departmentName!;
            hrDepartmentId = widget.departmentId;
            hrJobInt = widget.jobId;
            jobController.text = widget.jobName!;
            print('hremployeeId: $hremployeeId');
            print('hremployeeName: $hremployeeName');
          }
        }
      }
    }
  }  

  void getHrDepartmentListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      hrDepartmentList = responseOb.data;
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoHrDeparmentList");
    }
  } // listen to get Hr Department List

  void getHrDepartmentListId(String? v) {
    if (v != null) {
      setState(() {
        hrDepartmentId = int.parse(v.toString().split(',')[0]);
        hasNotHrDepartment = false;
        for (var element in hrDepartmentList) {
          if (element['id'] == hrDepartmentId) {
            hrDeparmentName = element['name'];
            hremployeeId = element['id'];
            print('hrDeparmentName:$hrDeparmentName');
            print('hremployeeId:$hremployeeId');
          }
        }
      });
    } else {
      hasNotHrDepartment = true;
    }
  } // get HrDepartment ListId from HrDepartmentListSelection

  void getHrJobListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      hrJobList = responseOb.data;
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoHrJobList");
    }
  } // listen to get Hr Job List

  void getHrJobListId(String? v) {
    if (v != null) {
      setState(() {
        hrJobInt = int.parse(v.toString().split(',')[0]);
        hasNotHrJob = false;
        for (var element in hrJobList) {
          if (element['id'] == hrJobInt) {
            hrJobName = element['name'];
            hrJobInt = element['id'];
            print('hrJobName:$hrJobName');
            print('hrJobId:$hrJobInt');
          }
        }
      });
    } else {
      hasNotHrJob = true;
    }
  } // get HrJob ListId from HrJobListSelection

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text("Sale Team"),
          backgroundColor: AppColors.appBarColor,
          actions: [
            TextButton(
                onPressed: () async {
                  if(widget.newOrEdit == 1){
                    if(widget.neworeditHEL == 1){
                    await databaseHelper.updateHrEmployeeLine(widget.hremployeelineId, widget.tripLine, hremployeeId, hremployeeName, hrDepartmentId, departmentController.text, hrJobInt, jobController.text, isCheck == true ? 1 : 0);
                    Navigator.of(context).pop();
                  }else{
                    HrEmployeeLineOb hremployeelineOb = HrEmployeeLineOb(
                      tripLine: widget.tripLine,
                      empName: hremployeeName,
                      empId: hremployeeId,
                      departmentId: hrDepartmentId,
                      departmentName: departmentController.text,
                      jobId: hrJobInt,
                      jobName: jobController.text,
                      responsible: isCheck == true ? 1 : 0);
                  int isCreated = await databaseHelper
                      .insertHrEmployeeLine(hremployeelineOb);
                  if (isCreated > 0) {
                    print('Success Created a member');
                    Navigator.of(context).pop();
                  } else {
                    print('Error');
                  }
                  }
                  }
                  else{
                    HrEmployeeLineOb hremployeelineOb = HrEmployeeLineOb(
                      tripLine: 0,
                      empName: hremployeeName,
                      empId: hremployeeId,
                      departmentId: hrDepartmentId,
                      departmentName: departmentController.text,
                      jobId: hrJobInt,
                      jobName: jobController.text,
                      responsible: isCheck == true ? 1 : 0);
                  int isCreated = await databaseHelper
                      .insertHrEmployeeLine(hremployeelineOb);
                  if (isCreated > 0) {
                    print('Success Created a member');
                    Navigator.of(context).pop();
                  } else {
                    print('Error');
                  }
                  }
                },
                child:
                    Text(widget.newOrEdit == 1? "Update": "Create", style: const TextStyle(color: Colors.white)))
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                children: [
                  const Text(
                    "Member:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(5),
                        // boxShadow: const [
                        //   BoxShadow(
                        //     color: Colors.black,
                        //     offset: Offset(0, 0),
                        //     blurRadius: 2,
                        //   )
                        // ]
                        ),
                    height: 40,
                    child: StreamBuilder<ResponseOb>(
                        initialData: ResponseOb(msgState: MsgState.loading),
                        stream: profileBloc.getHrEmployeeStream(),
                        builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                          ResponseOb? responseOb = snapshot.data;
                          if (responseOb?.msgState == MsgState.loading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (responseOb?.msgState == MsgState.error) {
                            return const Center(
                              child: Text("Something went Wrong!"),
                            );
                          } else {
                            return DropdownSearch<String>(
                              popupItemBuilder: (context, item, isSelected) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(item.toString().split(',')[1]),
                                      const Divider(),
                                    ],
                                  ),
                                );
                              },
                              showSearchBox: true,
                              showSelectedItems: true,
                              showClearButton: !hasNotHrEmployee,
                              items: hremployeeList
                                  .map((e) => '${e['id']},${e['name']}')
                                  .toList(),
                              onChanged: getHrEmployeeListId,
                              selectedItem: hremployeeName,
                            );
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Department:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(5),
                        // boxShadow: const [
                        //   BoxShadow(
                        //     color: Colors.black,
                        //     offset: Offset(0, 0),
                        //     blurRadius: 2,
                        //   )
                        // ]
                        ),
                    height: 40,
                    child: TextField(
                      readOnly: true,
                      controller: departmentController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Job:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        // borderRadius: BorderRadius.circular(5),
                        // boxShadow: const [
                        //   BoxShadow(
                        //     color: Colors.black,
                        //     offset: Offset(0, 0),
                        //     blurRadius: 2,
                        //   )
                        // ]
                        ),
                    height: 40,
                    child: TextField(
                      readOnly: true,
                      controller: jobController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      const Text(
                        "Responsible For MR: ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Checkbox(
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                          value: isCheck,
                          onChanged: (value) {
                            setState(() {
                              isCheck = !isCheck;
                            });
                          }),
                    ],
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // TextButton(
                  //     style: TextButton.styleFrom(
                  //       backgroundColor: Colors.purple,
                  //     ),
                  //     onPressed: () async {

                  //     },
                  //     child: const Text(
                  //       "Add a Member",
                  //       style: TextStyle(color: Colors.white),
                  //     ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
