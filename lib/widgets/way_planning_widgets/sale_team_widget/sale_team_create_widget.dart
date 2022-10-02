import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/hr_employee_line_ob.dart';
import '../../../obs/response_ob.dart';
import '../../../pages/profile_page/profile_bloc.dart';
import '../../../pages/way_planning_page/sale_team_page/sale_team_create_page.dart';
import '../../../utils/app_const.dart';

class SaleTeamWidget extends StatefulWidget {
  String leaderId;
  int neworedit;
  List<dynamic> hremployeelineList;
  int tripId;
  SaleTeamWidget({
    Key? key,
    required this.leaderId,
    required this.neworedit,
    required this.hremployeelineList,
    required this.tripId,
  }) : super(key: key);

  @override
  State<SaleTeamWidget> createState() => SaleTeamWidgetState();
}

class SaleTeamWidgetState extends State<SaleTeamWidget> {
  final profileBloc = ProfileBloc();
  final databaseHelper = DatabaseHelper();
  final slidableController = SlidableController();
  List<dynamic> hremployeeList = [];
  static List<HrEmployeeLineOb>? hremployeelineList = [];
  static List<dynamic> hremployeelineListInt = [];
  int hremployeeId = 0;
  static List<HrEmployeeLineOb>? hremployeelineListUpdate = [];
  String hremployeeName = '';
  bool hasNotHrEmployee = true;
  int newPage = 0;
  static List<dynamic> hremployeelineDeleteList = [];

  final leaderController = TextEditingController();
  int neworeditHEL = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.leaderId);
    profileBloc.getHrEmployeeData();
    profileBloc.getHrEmployeeStream().listen(getHrEmployeeListListen);
    transferData();
  }

  void getHrEmployeeListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      hremployeeList = responseOb.data;
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
            print('HrEmployeeListName:$hremployeeName');
            print('HrEmployeeId:$hremployeeId');
          }
        }
      });
    } else {
      hasNotHrEmployee = true;
    }
  } // get HrEmployee ListId from HrEmployeeListSelection

  Future<void> transferData() async {
    hremployeelineListUpdate =
        await databaseHelper.getHrEmployeeLineUpdateList();
    for (var element in hremployeelineListUpdate!) {
      hremployeelineListInt.add(element.id);
      print('HrEmployeeLineListIDs: ${element.id}');
    }
    if (widget.neworedit == 1) {
      print('TransferData');
      print('TripPlanId: ${widget.tripId}');
      hremployeelineList =
          await databaseHelper.insertTable2TableHrEmployeeLine();
      print('HrEmployeeLineListLength: ${hremployeelineList?.length}');
    }
    if(mounted){
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    leaderController.text = widget.leaderId;
    return Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
        child: FutureBuilder<List<HrEmployeeLineOb>>(
            future: databaseHelper.getHrEmployeeLineList(),
            builder: (context, snapshot) {
              hremployeelineList = snapshot.data;
              Widget saleteamWidget = SliverToBoxAdapter();
              if (snapshot.hasData) {
                saleteamWidget = SliverList(
                    delegate: SliverChildBuilderDelegate(((context, i) {
                  print(
                      "hremployeelineList__________: ${hremployeelineList!.length}");
                  print('HRemplineId: ${hremployeelineList![i].id}');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slidable(
                        controller: slidableController,
                        actionPane: const SlidableBehindActionPane(),
                        actions: [
                          IconSlideAction(
                            onTap: (){
                              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                return SaleTeamCreatePage(tripLine: widget.tripId, hremployeelineId: hremployeelineList![i].id, newOrEdit: widget.neworedit, neworeditHEL: 1, empId: hremployeelineList![i].empId, departmentId: hremployeelineList![i].departmentId, departmentName: hremployeelineList![i].departmentName, jobId: hremployeelineList![i].jobId, jobName: hremployeelineList![i].jobName, responsible: hremployeelineList![i].responsible);
                              })).then((value) {
                                setState(() {
                                  
                                });
                              });
                            },
                            color: Colors.yellow,
                            iconWidget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.edit,
                                  size: 25,
                                ),
                                Text(
                                  "Edit",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                        secondaryActions: [
                          IconSlideAction(
                            onTap: () async {
                              await databaseHelper.deleteHrEmployeeLineManul(
                                  hremployeelineList![i].id);
                              hremployeelineDeleteList
                                  .add(hremployeelineList![i].id);
                              setState(() {
                                
                              });
                            },
                            color: Colors.red,
                            iconWidget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.delete,
                                  size: 25,
                                ),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                              ],
                            ),
                          )
                        ],
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            // borderRadius:
                            //     BorderRadius.circular(10),
                            // boxShadow: const [
                            //   BoxShadow(
                            //     color: Colors.black,
                            //     offset: Offset(0, 0),
                            //     blurRadius: 2,
                            //   )
                            // ]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                  text: TextSpan(children: [
                                const TextSpan(
                                  text: 'Member: ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                TextSpan(
                                    text: hremployeelineList![i].empName,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 18))
                              ])),
                              RichText(
                                  text: TextSpan(children: [
                                const TextSpan(
                                  text: 'Department: ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                TextSpan(
                                    text: hremployeelineList![i].departmentName,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 18))
                              ])),
                              RichText(
                                  text: TextSpan(children: [
                                const TextSpan(
                                  text: 'Job: ',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                                TextSpan(
                                    text: hremployeelineList![i].jobName,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 18))
                              ])),
                              // RichText(
                              //     text: TextSpan(children: [
                              //   const TextSpan(
                              //     text: 'Responsible: ',
                              //     style: TextStyle(
                              //         fontSize: 20,
                              //         fontWeight: FontWeight.bold,
                              //         color: Colors.black),
                              //   ),
                              //   TextSpan(
                              //       text: hremployeelineList![i]
                              //           .responsible
                              //           .toString(),
                              //       style: const TextStyle(
                              //           color: Colors.black, fontSize: 18))
                              // ])),
                              Row(
                                children: [
                                  const Text("Responsible For MR: ",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                                  Icon(hremployeelineList![i]
                                    .responsible == 1? Icons.check_box: Icons.check_box_outline_blank),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                }), childCount: hremployeelineList!.length));
              } else {
                print(snapshot.hasError.toString());
                saleteamWidget = const SliverToBoxAdapter(
                    child: Center(
                  child: CircularProgressIndicator(),
                ));
              }
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Leader:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
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
                            controller: leaderController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // SizedBox(
                        //   height: 40,
                        //   child: StreamBuilder<ResponseOb>(
                        //       // initialData: ResponseOb(
                        //       //     msgState: MsgState.loading),
                        //       stream: profileBloc.getHrEmployeeStream(),
                        //       builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                        //         ResponseOb? responseOb = snapshot.data;
                        //         if (responseOb?.msgState == MsgState.loading) {
                        //           return const Center(
                        //             child: CircularProgressIndicator(),
                        //           );
                        //         } else if (responseOb?.msgState == MsgState.error) {
                        //           return const Center(
                        //             child: Text("Something went Wrong!"),
                        //           );
                        //         } else {
                        //           return DropdownSearch<String>(
                        //             popupItemBuilder: (context, item, isSelected) {
                        //               return Padding(
                        //                 padding: const EdgeInsets.all(8.0),
                        //                 child: Column(
                        //                   crossAxisAlignment: CrossAxisAlignment.start,
                        //                   children: [
                        //                     Text(item.toString().split(',')[1]),
                        //                     const Divider(),
                        //                   ],
                        //                 ),
                        //               );
                        //             },
                        //             showSearchBox: true,
                        //             showSelectedItems: true,
                        //             showClearButton: !hasNotHrEmployee,
                        //             items: hremployeeList
                        //                 .map((e) => '${e['id']},${e['name']}')
                        //                 .toList(),
                        //             onChanged: getHrEmployeeListId,
                        //             selectedItem: hremployeeName,
                        //           );
                        //         }
                        //       }),
                        // ),
                        Container(
                          width: 130,
                          decoration: const BoxDecoration(
                            color: AppColors.appBarColor,
                            // boxShadow: const [
                            //   BoxShadow(
                            //     offset: Offset(0, 0),
                            //     blurRadius: 2,
                            //   )
                            // ],
                            // borderRadius: BorderRadius.circular(10)
                          ),
                          child: TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(builder: (context) {
                                  return SaleTeamCreatePage(
                                    newOrEdit: widget.neworedit,
                                    neworeditHEL: 0,
                                    tripLine: 0,
                                    hremployeelineId: 0,
                                    empId: 0,
                                    departmentId: 0,
                                    departmentName: '',
                                    jobId: 0,
                                    jobName: '',
                                    responsible: 0,
                                  );
                                })).then((value) {
                                  setState(() {
                                    newPage = -1;
                                  });
                                });
                              },
                              child: const Text(
                                "Add a Sale Team",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  saleteamWidget,
                ],
              );
            }));
  }
}
