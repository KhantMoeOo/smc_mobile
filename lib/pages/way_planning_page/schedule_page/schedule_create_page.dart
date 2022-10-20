import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../../dbs/database_helper.dart';
import '../../../obs/response_ob.dart';
import '../../../obs/trip_plan_schedule_ob.dart';
import '../../../utils/app_const.dart';
import 'schedule_bloc.dart';

class ScheduleCreatePage extends StatefulWidget {
  int newOrEdit;
  int neworeditTPS;
  int tripId;
  int? tripplanscheduleId;
  String fromDate;
  String toDate;
  int locationId;
  String? locationName;
  String remark;
  ScheduleCreatePage({
    Key? key,
    required this.newOrEdit,
    required this.neworeditTPS,
    required this.tripId,
    required this.tripplanscheduleId,
    required this.fromDate,
    required this.toDate,
    required this.locationId,
    required this.locationName,
    required this.remark,
  }) : super(key: key);

  @override
  State<ScheduleCreatePage> createState() => _ScheduleCreatePageState();
}

class _ScheduleCreatePageState extends State<ScheduleCreatePage> {
  final databaseHelper = DatabaseHelper();

  String fromDate = '';
  final fromDateController = TextEditingController();

  String toDate = '';
  final toDateController = TextEditingController();

  List<dynamic> townshipList = [];
  int townshipId = 0;
  String townshipName = '';
  bool hasNotTownship = true;

  final scheduleBloc = ScheduleBloc();

  final remarkController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scheduleBloc.getTownshipListData('');
    scheduleBloc.getTownshipListStream().listen(getTownshipListListen);
    if (widget.newOrEdit == 1) {
      fromDateController.text = widget.fromDate;
      toDateController.text = widget.toDate;
      remarkController.text = widget.remark;
    }
  }

  void getTownshipListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      townshipList = responseOb.data;
      setLocationNameMethod();
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoTownshipList");
    }
  } // listen to get Township List

  void getTownshipListId(String? v) {
    if (v != null) {
      setState(() {
        townshipId = int.parse(v.toString().split(',')[0]);
        hasNotTownship = false;
        for (var element in townshipList) {
          if (element['id'] == townshipId) {
            townshipName = element['name'];
            townshipId = element['id'];
            print('TownshipName:$townshipName');
            print('TownshipId:$townshipId');
          }
        }
      });
    } else {
      hasNotTownship = true;
    }
  } // get Township ListId from TownshipListSelection

  void setLocationNameMethod() {
    if (widget.newOrEdit == 1) {
      if (widget.locationId != 0) {
        for (var element in townshipList) {
          if (element['id'] == widget.locationId) {
            hasNotTownship = false;
            townshipId = element['id'];
            townshipName = element['name'];

            print('townshipId: $townshipId');
            print('townshipName: $townshipName');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text("Schedule"),
          backgroundColor: AppColors.appBarColor,
          actions: [
            TextButton(
                onPressed: () async {
                  if (widget.newOrEdit == 1) {
                    if (widget.neworeditTPS == 1) {
                      await databaseHelper.updateTripPlanSchedule(
                          widget.tripplanscheduleId,
                          widget.tripId,
                          fromDateController.text,
                          toDateController.text,
                          townshipId,
                          townshipName,
                          remarkController.text);
                      Navigator.of(context).pop();
                    } else {
                      final tripplanscheduleOb = TripPlanScheduleOb(
                          tripId: widget.tripId,
                          fromDate: fromDate,
                          toDate: toDate,
                          locationId: townshipId,
                          locationName: townshipName,
                          remark: remarkController.text);
                      int isCreated = await databaseHelper
                          .insertTripPlanSchedule(tripplanscheduleOb);
                      if (isCreated > 0) {
                        print('Success Created a Schedule');
                        Navigator.of(context).pop();
                      } else {
                        print('Error');
                      }
                    }
                  } else {
                    final tripplanscheduleOb = TripPlanScheduleOb(
                        tripId: 0,
                        fromDate: fromDate,
                        toDate: toDate,
                        locationId: townshipId,
                        locationName: townshipName,
                        remark: remarkController.text);
                    int isCreated = await databaseHelper
                        .insertTripPlanSchedule(tripplanscheduleOb);
                    if (isCreated > 0) {
                      print('Success Created a Schedule');
                      Navigator.of(context).pop();
                    } else {
                      print('Error');
                    }
                  }
                },
                child: Text(
                  widget.neworeditTPS == 1 ? 'Update' : "Create",
                  style: const TextStyle(color: Colors.white),
                ))
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            const Text(
              "From Date:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
              color: Colors.white,
              height: 40,
              child: TextField(
                readOnly: true,
                controller: fromDateController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        onPressed: () async {
                          final DateTime? selected = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2023));

                          if (selected != null) {
                            fromDate = selected.toString().split(' ')[0];
                            fromDateController.text =
                                selected.toString().split(' ')[0];
                          }
                        },
                        icon: const Icon(Icons.arrow_drop_down))),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "To Date:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
              color: Colors.white,
              height: 40,
              child: TextField(
                readOnly: true,
                controller: toDateController,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                        onPressed: () async {
                          final DateTime? selected = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2023));

                          if (selected != null) {
                            toDate = selected.toString().split(' ')[0];
                            toDateController.text =
                                selected.toString().split(' ')[0];
                          }
                        },
                        icon: const Icon(Icons.arrow_drop_down))),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "location:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
              color: Colors.white,
              height: 40,
              child: StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: scheduleBloc.getTownshipListStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb? responseOb = snapshot.data;
                    if (responseOb?.msgState == MsgState.loading) {
                      return Center(
                        child: Image.asset(
                          'assets/gifs/loading.gif',
                          width: 100,
                          height: 100,
                        ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.toString().split(',')[1]),
                                const Divider(),
                              ],
                            ),
                          );
                        },
                        showSearchBox: true,
                        showSelectedItems: true,
                        showClearButton: !hasNotTownship,
                        items: townshipList
                            .map((e) => '${e['id']},${e['name']}')
                            .toList(),
                        onChanged: getTownshipListId,
                        selectedItem: townshipName,
                      );
                    }
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Remark:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(
              color: Colors.white,
              height: 100,
              child: TextField(
                controller: remarkController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
