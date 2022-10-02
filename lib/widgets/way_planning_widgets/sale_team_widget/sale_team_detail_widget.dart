import 'package:flutter/material.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/hr_employee_line_ob.dart';

class SaleTeamDetailWidget extends StatefulWidget {
  int wayplanId;
  String leaderName;
  List<dynamic> hremployeelineList;
  SaleTeamDetailWidget({
    Key? key,
    required this.wayplanId,
    required this.leaderName,
    required this.hremployeelineList,
  }) : super(key: key);

  @override
  State<SaleTeamDetailWidget> createState() => _SaleTeamDetailWidgetState();
}

class _SaleTeamDetailWidgetState extends State<SaleTeamDetailWidget> {
  final _databaseHelper = DatabaseHelper();
  List<HrEmployeeLineOb>? hremployeelineListDB = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('WayplanID: ${widget.wayplanId}');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 200,
                    child: Text(
                      'Leader ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  const Text(
                    ':  ',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Expanded(
                      flex: 2,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.leaderName,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            )
                          ]))
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: FutureBuilder<List<HrEmployeeLineOb>>(
                  future: _databaseHelper.getHrEmployeeLineUpdateList(),
                  builder: (context, snapshot) {
                    Widget saleteamWidget = const SliverToBoxAdapter();
                    if (snapshot.hasData) {
                      hremployeelineListDB = snapshot.data;
                      saleteamWidget = SliverList(
                          delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          print('TriplineId: ${hremployeelineListDB!.length}');
                          print(
                              'TripLine: ${hremployeelineListDB![i].tripLine}');
                          return hremployeelineListDB![i].tripLine !=
                                  widget.wayplanId
                              ? Container()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        // borderRadius: BorderRadius.circular(10),
                                        // boxShadow: const [
                                        //   BoxShadow(
                                        //     color: Colors.black,
                                        //     offset: Offset(0, 0),
                                        //     blurRadius: 2,
                                        //   )
                                        // ]
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text(
                                                  'Member ',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              const Text(
                                                ':  ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          hremployeelineListDB![
                                                                  i]
                                                              .empName,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 18),
                                                        )
                                                      ]))
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text(
                                                  'Department ',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              const Text(
                                                ':  ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          hremployeelineListDB![
                                                                  i]
                                                              .departmentName!,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 18),
                                                        )
                                                      ]))
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text(
                                                  'Job ',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              const Text(
                                                ':  ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          hremployeelineListDB![
                                                                  i]
                                                              .jobName!,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 18),
                                                        )
                                                      ]))
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                width: 200,
                                                child: Text(
                                                  'Responsible ',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              const Text(
                                                ':  ',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(hremployeelineListDB![
                                                                        i]
                                                                    .responsible ==
                                                                1
                                                            ? Icons.check_box
                                                            : Icons
                                                                .check_box_outline_blank),
                                                      ]))
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                );
                        },
                        childCount: hremployeelineListDB!.length,
                      ));
                    } else {
                      saleteamWidget = const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return CustomScrollView(
                      slivers: [
                        saleteamWidget,
                        const SliverToBoxAdapter(
                            child: SizedBox(
                          height: 100,
                        ))
                      ],
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
