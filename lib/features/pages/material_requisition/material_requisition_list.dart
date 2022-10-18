import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smc_mobile/pages/material_requisition_page/material_requisition_create_page.dart';

import '../../../dbs/database_helper.dart';
import '../../../dbs/sharef.dart';
import '../../../obs/response_ob.dart';
import '../../../pages/material_requisition_page/material_requisition_bloc.dart';
import '../../../pages/profile_page/profile_bloc.dart';
import '../../../utils/app_const.dart';
import '../menu/menu_list.dart';
import 'material_requisition_detail.dart';

class MaterialRequisitionList extends StatefulWidget {
  const MaterialRequisitionList({Key? key}) : super(key: key);

  @override
  State<MaterialRequisitionList> createState() =>
      _MaterialRequisitionListState();
}

class _MaterialRequisitionListState extends State<MaterialRequisitionList> {
  final materialRequisitionBloc = MaterialRequisitionBloc();
  final profileBloc = ProfileBloc();
  final databaseHelper = DatabaseHelper();
  final searchController = TextEditingController();
  List<dynamic> userList = [];
  List<dynamic> materialrequisitionList = [];
  final slidableController = SlidableController();

  bool isSearch = false;
  bool searchDone = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      // DeviceOrientation.portraitUp,
      // DeviceOrientation.portraitDown,
    ]);
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    deleteDatabases();
    materialRequisitionBloc
        .getMaterialRequisitionListStream()
        .listen(getMaterialRequisitionListen);
  }

  void deleteDatabases() async {
    await databaseHelper.deleteAllMaterialProductLine();
    await SharefCount.clearCount();
  }

  void getMaterialRequisitionListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      materialrequisitionList = responseOb.data;
    }
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      print('User Zone Id: ${userList[0]['zone_id']}');
      materialRequisitionBloc.getMaterialRequisitionListData(
          ['zone_id.id', '=', userList[0]['zone_id'][0]], ['id', 'ilike', '']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Do you want to exit?"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        exit(0);
                      },
                      child: const Text('OK'))
                ],
              );
            });
        return true;
      },
      child: SafeArea(
          child: StreamBuilder<ResponseOb>(
        initialData: materialrequisitionList.isNotEmpty
            ? null
            : ResponseOb(msgState: MsgState.loading),
        stream: materialRequisitionBloc.getMaterialRequisitionListStream(),
        builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
          ResponseOb? responseOb = snapshot.data;
          if (responseOb?.msgState == MsgState.loading) {
            return Container(
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/gifs/loading.gif',
                  width: 100,
                  height: 100,
                ),
              ),
            );
          } else if (responseOb?.msgState == MsgState.error) {
            return Container(
              color: Colors.white,
              child: const Center(child: Text('Error')),
            );
          } else {
            return Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                backgroundColor: AppColors.appBarColor,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return MenuList();
                    }));
                  },
                  icon: const Icon(Icons.menu),
                ),
                title: const Text('Material Requisition'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return MaterialRequisitionCreatePage(
                              name: '',
                              neworedit: 0,
                              userId: userList[0]['zone_id'][0]);
                        }));
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ))
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(
                          top: 5, bottom: 5, left: 8, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          SizedBox(
                              width: 100,
                              child: Text('Sequence No.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 150,
                              child: Text('Request Person',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 150,
                              child: Text('Department',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 150,
                              child: Text('Order Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          SizedBox(
                              width: 150,
                              child: Text('Scheduled Date',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 2,
                          ),
                          Expanded(
                              child: Text('Description',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: materialrequisitionList.length,
                        itemBuilder: (c, i) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return MaterialRequisitionDetail(
                                      mrList: materialrequisitionList[i],
                                    );
                                  })).then((value) {
                                    SystemChrome.setPreferredOrientations([
                                      DeviceOrientation.landscapeRight,
                                      DeviceOrientation.landscapeLeft,
                                      // DeviceOrientation.portraitUp,
                                      // DeviceOrientation.portraitDown,
                                    ]);
                                    profileBloc.getResUsersData();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${materialrequisitionList[i]['name']}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${materialrequisitionList[i]['request_person'] == false ? '' : materialrequisitionList[i]['request_person'][1]}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${materialrequisitionList[i]['department_id'] == false ? '' : materialrequisitionList[i]['department_id'][1]}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${materialrequisitionList[i]['order_date']}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${materialrequisitionList[i]['scheduled_date'] == false ? '' : materialrequisitionList[i]['scheduled_date']}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                  '${materialrequisitionList[i]['desc']}',
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15))
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      )),
    );
  }
}
