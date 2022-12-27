import 'dart:convert';
import 'dart:io';

import 'package:dropdown_search2/dropdown_search2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:smc_mobile/features/mobile_view/pages_mb/way_plan_mb/call-visit_mb/call_visit_list_mb.dart';
import 'package:smc_mobile/pages/profile_page/profile_bloc.dart';
import 'package:smc_mobile/pages/quotation_page/quotation_bloc.dart';
import 'package:smc_mobile/pages/way_planning_page/schedule_page/schedule_bloc.dart';

import '../../../../../obs/response_ob.dart';
import '../../../../../pages/way_planning_page/way_planning_bloc.dart';
import '../../../../../pages/way_planning_page/way_planning_create_bloc.dart';
import '../../../../../utils/app_const.dart';

class CallVisitCreateMB extends StatefulWidget {
  bool isNew;
  Map<String, dynamic> callvisitList;
  CallVisitCreateMB({
    Key? key,
    required this.isNew,
    required this.callvisitList,
  }) : super(key: key);

  @override
  State<CallVisitCreateMB> createState() => _CallVisitCreateMBState();
}

class _CallVisitCreateMBState extends State<CallVisitCreateMB> {
  final scheduleBloc = ScheduleBloc();
  final quotationBloc = QuotationBloc();
  final profileBloc = ProfileBloc();
  final wayplanningBloc = WayPlanningBloc();
  final tripplancreateBloc = TripPlanCreateBloc();
  final remarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool hasNotTownship = true;
  bool hasTownshipData = false;
  int townshipId = 0;
  String townshipName = '';
  List<dynamic> townshipList = [];

  List<dynamic> wayplanList = [];
  bool hasNotWayPlan = true;
  bool hasWayPlanData = false;
  int wayplanId = 0;
  String wayplanName = '';

  bool hasNotCustomer = true;
  bool hasCustomerData = false;
  int customerId = 0;
  String customerName = '';
  List<dynamic> customerList = [];

  List<dynamic> userList = [];

  List<dynamic> locationIdList = [];

  bool hasNotOrderDate = true;
  String dateOrder = '';
  final dateOrderController = TextEditingController();
  File? arrivalimage;
  File? dptimage;

  String arrivaltime = '';
  String arrivalInterFaceTime = '';
  String dpttime = '';
  String dptInterFaceTime = '';

  String latitude = '';
  String longitude = '';

  bool hasFleetVehicle = false;
  String fleetvehicleName = '';
  int fleetvehicleId = 0;
  List<dynamic> fleetvehicleList = [];

  bool hasDriverList = false;
  String driverName = '';
  int driverId = 0;
  List<dynamic> driverList = [];

  // final interfaceFormat = DateFormat('hh:mm a');

  bool isCreateCallVisit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isNew == false) {
      dateOrderController.text = widget.callvisitList['date'];
      arrivaltime = widget.callvisitList['arl_time'].toString();
      arrivalInterFaceTime =
          getTimeStringFromDouble(widget.callvisitList['arl_time']);
      // arrivalimage = widget.callvisitList['action_image'];
      dptInterFaceTime =
          getTimeStringFromDouble(widget.callvisitList['dept_time']);
      dpttime = widget.callvisitList['dept_time'].toString();
      latitude = widget.callvisitList['lt'].toString();
      longitude = widget.callvisitList['lg'].toString();
      remarkController.text = widget.callvisitList['remark'] == false ? '': widget.callvisitList['remark'];
    }
    scheduleBloc.getTownshipListStream().listen(getTownshipListListen);
    scheduleBloc.getScheduleListStream().listen(getTripPlanScheduleListen);
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    quotationBloc.getCustomerStream().listen(getCustomerListListen);
    wayplanningBloc.getWayPlanningListStream().listen(getWayPlanListListen);
    wayplanningBloc.getFleetList();
    wayplanningBloc
        .getfleetvehicleListStream()
        .listen(getFleetVehicleListListen);
    wayplanningBloc.getDriverList();
    wayplanningBloc.getdriverListStream().listen(getDriverListListen);
    tripplancreateBloc.createCallVisitStream().listen(createCallVisitListen);
    dateOrderController.text = DateTime.now().toString().split(' ')[0];
    hasNotOrderDate = false;
    _determinePosition().then((value) {
      print('Position: $value');
    });
  }

  String getTimeStringFromDouble(double value) {
    if (value < 0) return 'Invalid Value';
    int flooredValue = value.floor();
    double decimalValue = value - flooredValue;
    String hourValue = getHourString(flooredValue);
    String minuteString = getMinuteString(decimalValue);

    return '$hourValue:$minuteString';
  }

  String getMinuteString(double decimalValue) {
    return '${(decimalValue * 60).toInt()}'.padLeft(2, '0');
  }

  String getHourString(int flooredValue) {
    return '${flooredValue % 24}'.padLeft(2, '0');
  }

  Future takeArrivalImage() async {
    try {
      final takeimage = await ImagePicker.pickImage(source: ImageSource.camera);
      if (takeimage == null) return;
      final imageTemporary = File(takeimage.path);
      if (dptimage != null) {
        dptimage = null;
        print('DPTimage is Not Empty $dptimage');
      }
      setState(() {
        dpttime = '';
        arrivalInterFaceTime = getTimeStringFromDouble((Duration(
                    hours: DateTime.now().hour,
                    minutes: DateTime.now().minute,
                    seconds: DateTime.now().second)
                .inMinutes) /
            60);
        print('ArrivalTime: $arrivalInterFaceTime');
        arrivaltime = ((Duration(
                        hours: DateTime.now().hour,
                        minutes: DateTime.now().minute,
                        seconds: DateTime.now().second)
                    .inMinutes) /
                60)
            .toString();
        arrivalimage = imageTemporary;
      });
      _determinePosition().then((value) {
        setState(() {
          latitude = value.latitude.toString();
          longitude = value.longitude.toString();
        });
        print('Position: $value');
      });
    } on PlatformException catch (e) {
      print('Fail to take arrival image $e');
    }
  }

  Future takeDptImage() async {
    try {
      final takeimage = await ImagePicker.pickImage(source: ImageSource.camera);
      if (takeimage == null) return;
      final imageTemporary = File(takeimage.path);
      setState(() {
        dptInterFaceTime = getTimeStringFromDouble((Duration(
                    hours: DateTime.now().hour,
                    minutes: DateTime.now().minute,
                    seconds: DateTime.now().second)
                .inMinutes) /
            60);
        dpttime = ((Duration(
                        hours: DateTime.now().hour,
                        minutes: DateTime.now().minute,
                        seconds: DateTime.now().second)
                    .inMinutes) /
                60)
            .toString();
        dptimage = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('Fail to take dpt image');
    }
  }

  Future<Position> _determinePosition() async {
    print('Get Location Permission');
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   // Location services are not enabled don't continue
    //   // accessing the position and request users of the
    //   // App to enable the location services.
    //   return Future.error('Location services are disabled.');
    // }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      // forceAndroidLocationManager: true
    );
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      if (userList.isNotEmpty) {
        wayplanningBloc.getWayPlanningListData(
            name: ['id', 'ilike', ''],
            filter: ['zone_id', '=', userList[0]['zone_id'][0]]);
      }
    }
  }

  void getWayPlanListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        hasWayPlanData = true;
        wayplanList = responseOb.data;
      });
    }
  }

  void getCustomerListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        hasCustomerData = true;
        customerList = responseOb.data;
      });
    }
  }

  void getTripPlanScheduleListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      for (var element in responseOb.data) {
        locationIdList.add(element['location_id'][0]);
      }
      print('Location_id: $locationIdList');
      quotationBloc.getCustomerList(
        ['id', 'ilike', ''],
        ['partner_city', 'in', locationIdList],
      );
      scheduleBloc
          .getTownshipListData(filter: ['city_id', 'in', locationIdList]);
    }
  }

  void getFleetVehicleListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      fleetvehicleList = responseOb.data;
      hasFleetVehicle = true;
    }
  }

  void getDriverListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      driverList = responseOb.data;
      hasDriverList = true;
    }
  }

  void getWayPlanId(String? v) {
    if (v != null) {
      setState(() {
        wayplanId = int.parse(v.toString().split(',')[0]);
        hasNotWayPlan = false;
        for (var element in wayplanList) {
          if (element['id'] == wayplanId) {
            wayplanName = element['trip_id'];
            wayplanId = element['id'];
            print('wayplanName: $wayplanName');
            print('wayplanId: $wayplanId');
          }
        }
        scheduleBloc.getScheduleListData(filter: ['trip_id', '=', wayplanId]);
      });
    } else {
      hasNotWayPlan = true;
    }
  }

  void getCustomerId(String? v) {
    if (v != null) {
      setState(() {
        customerId = int.parse(v.toString().split(',')[0]);
        hasNotCustomer = false;
        for (var element in customerList) {
          if (element['id'] == customerId) {
            customerName = element['name'];
            customerId = element['id'];
            print('customerName:$customerName');
            print('customerId:$customerId');
          }
        }
      });
    } else {
      hasNotCustomer = true;
    }
  }

  void getTownshipListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      setState(() {
        hasTownshipData = true;
        townshipList = responseOb.data;
      });
    }
  }

  void getTownshipId(String? v) {
    if (v != null) {
      setState(() {
        townshipId = int.parse(v.toString().split(',')[0]);
        hasNotTownship = false;
        for (var element in townshipList) {
          if (element['id'] == townshipId) {
            townshipName = element['name'];
            townshipId = element['id'];
            print('townshipName:$townshipName');
            print('townshipId:$townshipId');
          }
        }
      });
    } else {
      hasNotTownship = true;
    }
  }

  void getFleetVehicleId(String? v) {
    if (v != null) {
      setState(() {
        fleetvehicleId = int.parse(v.toString().split(',')[0]);
        for (var element in fleetvehicleList) {
          if (element['id'] == fleetvehicleId) {
            fleetvehicleName = element['mechine_name'];
            fleetvehicleId = element['id'];
            print('fleetvehicleName:$fleetvehicleName');
            print('fleetvehicleId:$fleetvehicleId');
          }
        }
      });
    }
  }

  void getDriverListId(String? v) {
    if (v != null) {
      setState(() {
        driverId = int.parse(v.toString().split(',')[0]);
        for (var element in driverList) {
          if (element['id'] == driverId) {
            driverName = element['name'];
            driverId = element['id'];
            print('driverName:$driverName');
            print('driverId:$driverId');
          }
        }
      });
    }
  }

  createCallVisit() {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      final arrivalimageBytes = File(arrivalimage!.path).readAsBytesSync();
      String arrivalimage64 = base64Encode(arrivalimageBytes);
      tripplancreateBloc.createCallVisit(
          arrivalImage: arrivalimage64,
          townshipId: townshipId,
          wayplanId: wayplanId,
          customerId: customerId,
          date: dateOrderController.text,
          arlTime: arrivaltime,
          deptTime: dpttime,
          lt: latitude,
          lg: longitude,
          zoneId: userList[0]['zone_id'][0],
          fleetId: fleetvehicleId,
          driverId: driverId,
          remark: remarkController.text);
    } else {
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
          content: const Text('Please fill first required fields!',
              textAlign: TextAlign.center));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  void createCallVisitListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          content: const Text('Create Call Visit Successfully!',
              textAlign: TextAlign.center));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return CallVisitListMB(
          userList: userList,
        );
      }), (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } else if (responseOb.msgState == MsgState.error) {
      setState(() {
        isCreateCallVisit = false;
      });
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          content: const Text('Create Call Visit Error!',
              textAlign: TextAlign.center));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return CallVisitListMB(
          userList: userList,
        );
      }), (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DPTimage is Not Empty $dptimage');
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            backgroundColor: AppColors.appBarColor,
            title: const Text('New'),
            actions: [
              TextButton(onPressed: createCallVisit, child: const Text('Save'))
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(padding: const EdgeInsets.all(10.0), children: [
              Row(children: [
                arrivalimage != null
                    ? Expanded(
                        child: InkWell(
                            onTap: takeArrivalImage,
                            child: Column(
                              children: [
                                Container(
                                  child: Image.file(arrivalimage!,
                                      fit: BoxFit.cover),
                                ),
                                const Text('Take Arrival Photo'),
                              ],
                            )),
                      )
                    : Expanded(
                        child: InkWell(
                          onTap: takeArrivalImage,
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                child: const Icon(Icons.image),
                                color: Colors.white,
                              ),
                              const Text('Take Arrival Photo'),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(
                  width: 10,
                ),
                dptimage != null
                    ? Expanded(
                        child: InkWell(
                            onTap: takeDptImage,
                            child: Column(
                              children: [
                                Container(
                                  child:
                                      Image.file(dptimage!, fit: BoxFit.cover),
                                ),
                                const Text('Take Departure Photo'),
                              ],
                            )),
                      )
                    : Expanded(
                        child: InkWell(
                          onTap: takeDptImage,
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                child: const Icon(Icons.image),
                                color: Colors.white,
                              ),
                              const Text('Take Departure Photo'),
                            ],
                          ),
                        ),
                      ),
              ]),
              const SizedBox(height: 10),
              Text(
                "Way Plan*:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: hasNotWayPlan == true ? Colors.red : Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 40,
                child: StreamBuilder<ResponseOb>(
                    initialData: hasWayPlanData == false
                        ? ResponseOb(msgState: MsgState.loading)
                        : null,
                    stream: wayplanningBloc.getWayPlanningListStream(),
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
                        if (responseOb?.errState == ErrState.severErr) {
                          return Container(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                      child: Text('${responseOb?.data}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        wayplanningBloc.getWayPlanningListData(
                                            name: [
                                              'id',
                                              'ilike',
                                              ''
                                            ],
                                            filter: [
                                              'user_id',
                                              '=',
                                              userList[0]['id']
                                            ]);
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else if (responseOb?.errState ==
                            ErrState.noConnection) {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('No Internet Connection!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        wayplanningBloc.getWayPlanningListData(
                                            name: [
                                              'id',
                                              'ilike',
                                              ''
                                            ],
                                            filter: [
                                              'user_id',
                                              '=',
                                              userList[0]['id']
                                            ]);
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('Unknown Error!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        wayplanningBloc.getWayPlanningListData(
                                            name: [
                                              'id',
                                              'ilike',
                                              ''
                                            ],
                                            filter: [
                                              'user_id',
                                              '=',
                                              userList[0]['id']
                                            ]);
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        }
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
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select Way Plan Name';
                            }
                            return null;
                          },
                          showSearchBox: true,
                          showSelectedItems: true,
                          // showClearButton: !hasNotCustomer,
                          items: wayplanList.map((e) {
                            return '${e['id']},${e['trip_id']}';
                          }).toList(),
                          onChanged: getWayPlanId,
                          dropdownBuilder: (c, i) {
                            return Text(i == null
                                ? ''
                                : i.contains(',')
                                    ? i.toString().split(',')[1]
                                    : i);
                          },
                          selectedItem: wayplanName,
                        );
                      }
                    }),
              ),
              const SizedBox(height: 10),
              Text(
                "Township*:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: hasNotTownship == true ? Colors.red : Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 40,
                child: StreamBuilder<ResponseOb>(
                    // initialData: hasTownshipData == false
                    //     ? ResponseOb(msgState: MsgState.loading)
                    //     : null,
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
                        if (responseOb?.errState == ErrState.severErr) {
                          return Container(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                      child: Text('${responseOb?.data}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        scheduleBloc.getTownshipListData(
                                            filter: ['id', 'ilike', '']);
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else if (responseOb?.errState ==
                            ErrState.noConnection) {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('No Internet Connection!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        scheduleBloc.getTownshipListData(
                                            filter: ['id', 'ilike', '']);
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('Unknown Error!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        scheduleBloc.getTownshipListData(
                                            filter: ['id', 'ilike', '']);
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        }
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
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select Township Name';
                            }
                            return null;
                          },
                          showSearchBox: true,
                          showSelectedItems: true,
                          // showClearButton: !hasNotCustomer,
                          items: townshipList.map((e) {
                            return '${e['id']},${e['name']}';
                          }).toList(),
                          onChanged: getTownshipId,
                          dropdownBuilder: (c, i) {
                            return Text(i == null
                                ? ''
                                : i.contains(',')
                                    ? i.toString().split(',')[1]
                                    : i);
                          },
                          selectedItem: townshipName,
                        );
                      }
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Customer*:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: hasNotCustomer == true ? Colors.red : Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 40,
                child: StreamBuilder<ResponseOb>(
                    // initialData: ResponseOb(msgState: MsgState.loading),
                    stream: quotationBloc.getCustomerStream(),
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
                        if (responseOb?.errState == ErrState.severErr) {
                          return Container(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                      child: Text('${responseOb?.data}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        quotationBloc.getCustomerList(
                                          ['id', 'ilike', ''],
                                          [
                                            'zone_id.id',
                                            '=',
                                            userList[0]['zone_id'][0]
                                          ],
                                        );
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else if (responseOb?.errState ==
                            ErrState.noConnection) {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('No Internet Connection!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        quotationBloc.getCustomerList(
                                          ['id', 'ilike', ''],
                                          [
                                            'zone_id.id',
                                            '=',
                                            userList[0]['zone_id'][0]
                                          ],
                                        );
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('Unknown Error!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        quotationBloc.getCustomerList(
                                          ['id', 'ilike', ''],
                                          [
                                            'zone_id.id',
                                            '=',
                                            userList[0]['zone_id'][0]
                                          ],
                                        );
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        }
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
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select Customer Name';
                            }
                            return null;
                          },
                          showSearchBox: true,
                          showSelectedItems: true,
                          // showClearButton: !hasNotCustomer,
                          items: customerList.map((e) {
                            return '${e['id']},${e['name']}';
                          }).toList(),
                          onChanged: getCustomerId,
                          dropdownBuilder: (c, i) {
                            return Text(i == null
                                ? ''
                                : i.contains(',')
                                    ? i.toString().split(',')[1]
                                    : i);
                          },
                          selectedItem: customerName,
                        );
                      }
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Date*:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: hasNotOrderDate == true ? Colors.red : Colors.black),
              ),
              const SizedBox(height: 10),
              Container(
                  color: Colors.white,
                  height: 40,
                  child: TextFormField(
                      readOnly: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select Quotation Date';
                        }
                        return null;
                      },
                      controller: dateOrderController,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_drop_down),
                            onPressed: () async {
                              final DateTime? selected = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2023));

                              if (selected != null) {
                                setState(() {
                                  dateOrder =
                                      '${selected.toString().split(' ')[0]}}';
                                  dateOrderController.text =
                                      '${selected.toString().split(' ')[0]}}';
                                  hasNotOrderDate = false;
                                  print(dateOrder);
                                });
                              }
                            },
                          )))),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Arrival Time:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Expanded(
                      child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            color: Colors.white,
                          ),
                          child: Center(child: Text(arrivalInterFaceTime)))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Departure Time:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Expanded(
                      child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            color: Colors.white,
                          ),
                          child: Center(child: Text(dptInterFaceTime)))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Latitude:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Expanded(
                      child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            color: Colors.white,
                          ),
                          child: Center(child: Text(latitude)))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Longitude:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Expanded(
                      child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            color: Colors.white,
                          ),
                          child: Center(child: Text(longitude)))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Zone:",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Expanded(
                      child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                            color: Colors.white,
                          ),
                          child: Center(
                              child: Text(
                                  '${userList.isEmpty ? '' : userList[0]['zone_id'][1]}')))),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Vehicle:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 40,
                child: StreamBuilder<ResponseOb>(
                    initialData: hasFleetVehicle == false
                        ? ResponseOb(msgState: MsgState.loading)
                        : null,
                    stream: wayplanningBloc.getfleetvehicleListStream(),
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
                        if (responseOb?.errState == ErrState.severErr) {
                          return Container(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                      child: Text('${responseOb?.data}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        wayplanningBloc.getFleetList();
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else if (responseOb?.errState ==
                            ErrState.noConnection) {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('No Internet Connection!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        wayplanningBloc.getFleetList();
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('Unknown Error!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        wayplanningBloc.getFleetList();
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        }
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
                            autoValidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select fleet vehicle Name';
                              }
                              return null;
                            },
                            showSearchBox: true,
                            showSelectedItems: true,
                            // showClearButton: !hasNotCustomer,
                            items: fleetvehicleList.map((e) {
                              return '${e['id']},${e['license_plate'] == false ? '' : e['license_plate']}';
                            }).toList(),
                            onChanged: getFleetVehicleId,
                            dropdownBuilder: (c, i) {
                              return Text(i == null
                                  ? ''
                                  : i.contains(',')
                                      ? i.toString().split(',')[1]
                                      : i);
                            },
                            selectedItem: fleetvehicleName);
                      }
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Driver:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 40,
                child: StreamBuilder<ResponseOb>(
                    initialData: hasDriverList == false
                        ? ResponseOb(msgState: MsgState.loading)
                        : null,
                    stream: wayplanningBloc.getdriverListStream(),
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
                        if (responseOb?.errState == ErrState.severErr) {
                          return Container(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                      child: Text('${responseOb?.data}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        wayplanningBloc.getDriverList();
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else if (responseOb?.errState ==
                            ErrState.noConnection) {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('No Internet Connection!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        wayplanningBloc.getDriverList();
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        } else {
                          return SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Center(
                                      child: Text('Unknown Error!',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red))),
                                  IconButton(
                                      onPressed: () {
                                        wayplanningBloc.getDriverList();
                                      },
                                      icon: const Icon(Icons.refresh))
                                ],
                              ));
                        }
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
                            autoValidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select Driver Name';
                              }
                              return null;
                            },
                            showSearchBox: true,
                            showSelectedItems: true,
                            // showClearButton: !hasNotCustomer,
                            items: driverList.map((e) {
                              return '${e['id']},${e['name']}';
                            }).toList(),
                            onChanged: getDriverListId,
                            dropdownBuilder: (c, i) {
                              return Text(i == null
                                  ? ''
                                  : i.contains(',')
                                      ? i.toString().split(',')[1]
                                      : i);
                            },
                            selectedItem: driverName);
                      }
                    }),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Remark:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                child: TextField(
                  controller: remarkController,
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
                ),
              )
            ]),
          ),
        ),
        isCreateCallVisit == false
            ? Container()
            : Positioned(
                child: StreamBuilder<ResponseOb>(
                initialData: ResponseOb(msgState: MsgState.loading),
                stream: tripplancreateBloc.createCallVisitStream(),
                builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                  ResponseOb? responseOb = snapshot.data;
                  if (responseOb?.msgState == MsgState.loading) {
                    return Container(
                      color: Colors.white,
                      child: Center(
                        child: Image.asset(
                          'assets/gifs/loading.gif',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    );
                  } else if (responseOb?.msgState == MsgState.error) {
                    if (responseOb?.errState == ErrState.severErr) {
                      return Scaffold(
                        body: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${responseOb?.data}'),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      isCreateCallVisit = true;
                                      createCallVisit();
                                    },
                                    child: const Text('Try Again')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return CallVisitListMB(
                                          userList: userList,
                                        );
                                      }));
                                    },
                                    child:
                                        const Text('Back To Direct Sale Page')),
                              ],
                            )
                          ],
                        )),
                      );
                    } else if (responseOb?.errState == ErrState.noConnection) {
                      return Scaffold(
                        body: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/imgs/no_internet_connection_icon.png',
                              width: 100,
                              height: 100,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text('No Internet Connection!'),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      isCreateCallVisit = true;
                                      createCallVisit();
                                    },
                                    child: const Text('Try Again')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return CallVisitListMB(
                                          userList: userList,
                                        );
                                      }));
                                    },
                                    child:
                                        const Text('Back To Direct Sale Page')),
                              ],
                            )
                          ],
                        )),
                      );
                    } else {
                      return Scaffold(
                        body: Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Unknown Error'),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      isCreateCallVisit = true;
                                      createCallVisit();
                                    },
                                    child: const Text('Try Again')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return CallVisitListMB(
                                          userList: userList,
                                        );
                                      }));
                                    },
                                    child:
                                        const Text('Back To Direct Sale Page')),
                              ],
                            )
                          ],
                        )),
                      );
                    }
                  } else {
                    return Container();
                  }
                },
              )),
      ],
    );
  }
}
