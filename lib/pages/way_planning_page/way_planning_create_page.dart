import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../dbs/database_helper.dart';
import '../../dbs/sharef.dart';
import '../../obs/hr_employee_line_ob.dart';
import '../../obs/response_ob.dart';
import '../../widgets/drawer_widget.dart';
import '../../widgets/way_planning_widgets/delivery_widget/delivery_create_widget.dart';
import '../../widgets/way_planning_widgets/sale_team_widget/sale_team_create_widget.dart';
import '../../widgets/way_planning_widgets/schedule_widget/schedule_create_widget.dart';
import '../home_page/home_page.dart';
import '../profile_page/profile_bloc.dart';
import '../quotation_page/quotation_bloc.dart';
import '../quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import 'way_planning_bloc.dart';
import 'way_planning_create_bloc.dart';
import 'way_planning_delete_bloc.dart';
import 'way_planning_edit_bloc.dart';
import 'way_planning_page.dart';

class WayPlanningCreatePage extends StatefulWidget {
  int neworedit;
  int tripId;
  String tripSeq;
  List<dynamic> tripconfigList;
  List<dynamic> zoneList;
  List<dynamic> userList;
  String fromDate;
  String toDate;
  List<dynamic> leaderId;
  List<dynamic> hremployeelineList;
  WayPlanningCreatePage({
    Key? key,
    required this.neworedit,
    required this.tripId,
    required this.tripSeq,
    required this.tripconfigList,
    required this.zoneList,
    required this.userList,
    required this.fromDate,
    required this.toDate,
    required this.leaderId,
    required this.hremployeelineList,
  }) : super(key: key);

  @override
  State<WayPlanningCreatePage> createState() => _WayPlanningCreatePageState();
}

class _WayPlanningCreatePageState extends State<WayPlanningCreatePage>
    with SingleTickerProviderStateMixin {
  final wayplanningBloc = WayPlanningBloc();
  final quotationBloc = QuotationBloc();
  final profileBloc = ProfileBloc();
  final tripplancreateBloc = TripPlanCreateBloc();
  final tripplaneditBloc = WayPlanningEditBloc();
  final tripplandeleteBloc = DeleteWayPlanBloc();
  final saleorderlineBloc = SaleOrderLineBloc();
  final databaseHelper = DatabaseHelper();
  late final _tabController;
  bool hasNotTrip = true;
  bool hasNotFromDate = true;
  bool hasNotZone = true;
  bool hasNotToDate = true;

  bool initialStart = true;

  int tripId = 0;

  List<dynamic> tripconfigList = [];
  int tripconfigId = 0;
  String tripconfigName = '';

  List<dynamic> zoneList = [];
  int zoneId = 0;
  String zoneName = '';

  List<dynamic> userIdList = [];
  int userId = 0;
  String userName = '';
  final resusersController = TextEditingController();

  final fromDateController = TextEditingController();
  String fromDate = '';

  final toDateController = TextEditingController();
  String toDate = '';

  final leaderController = TextEditingController();

  int leaderId = 0;
  String leaderName = '';

  final _formKey = GlobalKey<FormState>();

  List<HrEmployeeLineOb>? hremployeelineList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('WayPlanId: ${widget.tripId}');
    _tabController = TabController(length: 3, vsync: this);
    wayplanningBloc.getTripConfigListData();
    wayplanningBloc.getTripConfigListStream().listen(getTripConfigListListen);
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersListListen);
    quotationBloc.getZoneListData();
    quotationBloc.getZoneListStream().listen(getZonelistListen);
    tripplancreateBloc.createTripPlanStream().listen(createTripPlanListen);
    tripplancreateBloc
        .createHrEmployeeLineStream()
        .listen(hremployeelineListen);
    tripplancreateBloc
        .createTripPlanScheduleStream()
        .listen(tripplanscheduleListen);
    tripplancreateBloc
        .createTripPlanDeliveryStream()
        .listen(tripplandeliveryListen);
    tripplaneditBloc.getWayPlanningEditStream().listen(updatetripPlanListen);
    tripplaneditBloc
        .getHrEmployeeLineEditStream()
        .listen(hremployeelineUpdateListen);
    tripplaneditBloc
        .getTripPlanScheduleEditStream()
        .listen(tripplanscheduleUpdateListen);
    tripplaneditBloc
        .getTripPlanDeliveryEditStream()
        .listen(tripplandeliveryUpdateListen);
    if (widget.neworedit == 1) {
      fromDateController.text = widget.fromDate;
      fromDate = widget.fromDate;
      toDateController.text = widget.toDate;
      toDate = widget.toDate;
      leaderId = widget.leaderId[0];
      leaderName = widget.leaderId[1];
    }
    saleorderlineBloc.waitingproductlineListStream().listen(listenCreateorNot);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    quotationBloc.dipose();
    wayplanningBloc.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    profileBloc.dispose();
    leaderController.dispose();
    tripplancreateBloc.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print('DidchangeDepend');
    initialStart = false;
    print('initialStart: $initialStart');
  }

  @override
  void didUpdateWidget(covariant WayPlanningCreatePage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print('DIdupdateWidget');
  }

  void getTripConfigListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      tripconfigList = responseOb.data;
      setTripConfigNameMethod();
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoTripCOnfigList");
    }
  } // listen to get Trip Config List

  void setTripConfigNameMethod() {
    print('set work');
    if (widget.neworedit == 1) {
      print('its 1');
      for (var element in tripconfigList) {
        if (element['id'] == widget.tripconfigList[0]) {
          hasNotTrip = false;
          tripconfigId = element['id'];
          tripconfigName = element['name'];
          print('TripConfigId: $tripconfigId');
          print('SetTripConfigName: $tripconfigName');
        }
      }
    }
  } // Set Trip Config Name to Update Way Plan Page

  void getResUsersListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userIdList = responseOb.data;
      getResUsersListId();
      // setCustomerNameMethod();
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoUserList");
    }
  } // listen to get User List

  void getZonelistListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      zoneList = responseOb.data;
      setZoneListNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoZoneList");
    }
  } // listen to get Zone List

  void setZoneListNameMethod() {
    if (widget.neworedit == 1) {
      if (widget.zoneList.isNotEmpty) {
        for (var element in zoneList) {
          if (element['id'] == widget.zoneList[0]) {
            hasNotZone = false;
            print('HasNotzone:  $hasNotZone');
            zoneId = element['id'];
            zoneName = element['name'];
            print('ZoneListId: $zoneId');
            print('SetZoneName: $zoneName');
          }
        }
      }
    }
  } // Set ZoneList Name to Update Quotation Page

  void getTripConfigListId(String? v) {
    if (v != null) {
      setState(() {
        tripconfigId = int.parse(v.toString().split(',')[0]);
        hasNotTrip = false;
        for (var element in tripconfigList) {
          if (element['id'] == tripconfigId) {
            tripconfigName = element['name'];
            tripconfigId = element['id'];
            leaderId =
                element['leader_id'] == false ? 0 : element['leader_id'][0];
            leaderName =
                element['leader_id'] == false ? '' : element['leader_id'][1];
            print('TripConfigName:$tripconfigName');
            print('TripConfigListId:$tripconfigId');
            print("LeaderName : $leaderId");
          }
        }
      });
    } else {
      hasNotTrip = true;
    }
  } // get Trip Config ListId from Trip ConfigListSelection

  void getResUsersListId() {
    setState(() {
      for (var element in userIdList) {
        userId = element['id'];
        userName = element['name'];
        resusersController.text = element['name'];
        print('UserName:$userName');
      }
    });
  } // get User Name

  void getZoneListId(String? v) {
    if (v != null) {
      setState(() {
        zoneId = int.parse(v.toString().split(',')[0]);
        hasNotZone = false;
        for (var element in zoneList) {
          if (element['id'] == zoneId) {
            zoneName = element['name'];
            zoneId = element['id'];
            print('ZoneListName:$zoneName');
            print('ZoneListId:$zoneId');
          }
        }
      });
    } else {
      hasNotZone = true;
    }
  } // get ZoneListId from ZoneListSelection

  createTripPlan() async {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      await tripplancreateBloc.createTripPlan(
          tripconfigId, zoneId, userId, fromDate, toDate, leaderId);
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
  } // Create Trip Plan to Odoo Server

  updateTripPlan() async {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      await tripplaneditBloc.editWayPlanningData(
          widget.tripId, tripconfigId, zoneId, fromDate, toDate, leaderId);
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

  void createTripPlanListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      tripId = responseOb.data;
      for (var element in SaleTeamWidgetState.hremployeelineList!) {
        print(
            'Start work hremployeelinecreate: ${SaleTeamWidgetState.hremployeelineList?.length}');
        if (element.tripLine == 0) {
          print('founded');
          await tripplancreateBloc.createHrEmployeeLine(tripId, element.empId,
              element.departmentId, element.jobId, element.responsible);
        }
      }
      for (var element in ScheduleCreateWidgetState.tripplanscheduleList!) {
        print(
            'Start work TripPlanSchedulecreate: ${ScheduleCreateWidgetState.tripplanscheduleList?.length}');
        await tripplancreateBloc.createTripPlanSchedule(
            tripId,
            element.fromDate,
            element.toDate,
            element.locationId,
            element.remark);
      }
      for (var element in DeliveryCreateWidgetState.tripplandeliveryList!) {
        print(
            'Start work TripPlanDeliverycreate: ${DeliveryCreateWidgetState.tripplandeliveryList?.length}');
        await tripplancreateBloc.createTripPlanDelivery(
            tripId,
            element.teamId,
            element.assignPersonId,
            element.zoneId,
            element.invoiceId,
            element.orderId,
            element.state,
            element.invoiceStatus,
            element.remark);
      }
      if (SaleTeamWidgetState.hremployeelineList!.isEmpty &&
          ScheduleCreateWidgetState.tripplanscheduleList!.isEmpty &&
          DeliveryCreateWidgetState.tripplandeliveryList!.isEmpty) {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
            content: const Text('Create Trip Plan Successfully!',
                textAlign: TextAlign.center));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return WayPlanningListPage();
        }), (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
      // await databaseHelper.deleteAllHrEmployeeLine();
      // await databaseHelper.deleteAllHrEmployeeLineUpdate();
      // await databaseHelper.deleteAllSaleOrderLine();
      // await databaseHelper.deleteAllSaleOrderLineUpdate();
      // await databaseHelper.deleteAllTripPlanDelivery();
      // await databaseHelper.deleteAllTripPlanDeliveryUpdate();
      // await databaseHelper.deleteAllTripPlanSchedule();
      // await databaseHelper.deleteAllTripPlanScheduleUpdate();
      // await SharefCount.clearCount();
      print('Create Trip Plan Successfully!');
    } else if (responseOb.msgState == MsgState.error) {
      print('Create Trip Plan Error!');
    }
  } // Listen Trip Plan Create or not

  void updatetripPlanListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      if (SaleTeamWidgetState.hremployeelineDeleteList.isNotEmpty) {
        for (var element in SaleTeamWidgetState.hremployeelineDeleteList) {
          bool saleteamDeleteFound =
              SaleTeamWidgetState.hremployeelineListInt.contains(element);
          if (saleteamDeleteFound) {
            await tripplandeleteBloc.deleteHrEmployeeLineData(element);
          }
        }
      }
      if (ScheduleCreateWidgetState.tripplanscheduleDeleteList.isNotEmpty) {
        for (var element
            in ScheduleCreateWidgetState.tripplanscheduleDeleteList) {
          bool scheduleDeleteFound =
              ScheduleCreateWidgetState.tripplanscheduleInt.contains(element);
          if (scheduleDeleteFound) {
            await tripplandeleteBloc.deleteTripPlanScheduleData(element);
          }
        }
      }
      for (var element in SaleTeamWidgetState.hremployeelineList!) {
        print('DataFromHrEmployeeline: ${element.id}');
        bool found =
            SaleTeamWidgetState.hremployeelineListInt.contains(element.id);
        if (found) {
          print('Found: ${element.id}');
          print('TripId: ${element.tripLine}');
          await tripplaneditBloc.editHrEmployeeLineData(
              element.id,
              element.tripLine,
              element.empId,
              element.departmentId,
              element.jobId,
              element.responsible);
        } else if (!found) {
          print('TripId: ${widget.tripId}');
          await tripplancreateBloc.createHrEmployeeLine(
              widget.tripId,
              element.empId,
              element.departmentId,
              element.jobId,
              element.responsible);
        }
      }
      for (var element in ScheduleCreateWidgetState.tripplanscheduleList!) {
        print('DataFromTripPlanSchedule: ${element.id}');
        bool found =
            ScheduleCreateWidgetState.tripplanscheduleInt.contains(element.id);
        if (found) {
          await tripplaneditBloc.editTripPlanScheduleData(
              element.id,
              element.tripId,
              element.fromDate,
              element.toDate,
              element.locationId,
              element.remark);
        } else if (!found) {
          await tripplancreateBloc.createTripPlanSchedule(
              widget.tripId,
              element.fromDate,
              element.toDate,
              element.locationId,
              element.remark);
        }
      }
      for (var element in DeliveryCreateWidgetState.tripplandeliveryList!) {
        print('DataFromTripPlanSchedule: ${element.id}');
        bool found =
            DeliveryCreateWidgetState.tripplandeliveryInt.contains(element.id);
        if (found) {
          await tripplaneditBloc.editTripPlanDeliveryData(
              element.id,
              element.tripline,
              element.teamId,
              element.assignPersonId,
              element.zoneId,
              element.invoiceId == 0 ? null : element.invoiceId,
              element.orderId == 0 ? null : element.orderId,
              element.state,
              element.invoiceStatus,
              element.remark);
        } else if (!found) {
          await tripplancreateBloc.createTripPlanDelivery(
              widget.tripId,
              element.teamId,
              element.assignPersonId,
              element.zoneId,
              element.invoiceId,
              element.orderId,
              element.state,
              element.invoiceStatus,
              element.remark);
        }
      }
      if (SaleTeamWidgetState.hremployeelineList!.isEmpty) {
        final snackbar = SnackBar(
            elevation: 0.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green,
            content: const Text('Update Trip Plan Successfully!',
                textAlign: TextAlign.center));
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return WayPlanningListPage();
        }), (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
      // await databaseHelper.deleteAllHrEmployeeLine();
      // await databaseHelper.deleteAllHrEmployeeLineUpdate();
      // await databaseHelper.deleteAllSaleOrderLine();
      // await databaseHelper.deleteAllSaleOrderLineUpdate();
      // await databaseHelper.deleteAllTripPlanDelivery();
      // await databaseHelper.deleteAllTripPlanDeliveryUpdate();
      // await databaseHelper.deleteAllTripPlanSchedule();
      // await databaseHelper.deleteAllTripPlanScheduleUpdate();
      // await SharefCount.clearCount();
    } else if (responseOb.msgState == MsgState.error) {
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.red,
          content:
              const Text('Something went wrong!', textAlign: TextAlign.center));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  void hremployeelineListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      print(
          'hremployeelinelistlength: ${SaleTeamWidgetState.hremployeelineList!.length}');
      SharefCount.setTotal(SaleTeamWidgetState.hremployeelineList!.length +
          ScheduleCreateWidgetState.tripplanscheduleList!.length +
          DeliveryCreateWidgetState.tripplandeliveryList!.length);
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Create Hr Employee line list successfully');
    } else if (responseOb.msgState == MsgState.error) {
      print('Error Creating Hr Employee Line');
    }
  }

  void hremployeelineUpdateListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      print(
          'hremployeelinelistlength: ${SaleTeamWidgetState.hremployeelineList!.length}');
      SharefCount.setTotal(SaleTeamWidgetState.hremployeelineList!.length +
          ScheduleCreateWidgetState.tripplanscheduleList!.length +
          DeliveryCreateWidgetState.tripplandeliveryList!.length);
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Create Hr Employee line list Update successfully');
    } else if (responseOb.msgState == MsgState.error) {
      print('Error Creating Hr Employee Update Line');
    }
  }

  void tripplanscheduleListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      print(
          'TripplanSchedulelistlength: ${ScheduleCreateWidgetState.tripplanscheduleList!.length}');
      SharefCount.setTotal(SaleTeamWidgetState.hremployeelineList!.length +
          ScheduleCreateWidgetState.tripplanscheduleList!.length +
          DeliveryCreateWidgetState.tripplandeliveryList!.length);
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Create Trip Plan Schedule successfully');
    } else if (responseOb.msgState == MsgState.error) {
      print('Error Creating Trip Plan Schedule');
    }
  }

  void tripplanscheduleUpdateListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      print(
          'TripplanScheduleUpdatelistlength: ${ScheduleCreateWidgetState.tripplanscheduleList!.length}');
      SharefCount.setTotal(SaleTeamWidgetState.hremployeelineList!.length +
          ScheduleCreateWidgetState.tripplanscheduleList!.length +
          DeliveryCreateWidgetState.tripplandeliveryList!.length);
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Create Trip Plan Schedule Update successfully');
    } else if (responseOb.msgState == MsgState.error) {
      print('Error Creating Trip Plan Update Schedule');
    }
  }

  void tripplandeliveryListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      print(
          'TripplanDeliverylistlength: ${DeliveryCreateWidgetState.tripplandeliveryList!.length}');
      SharefCount.setTotal(SaleTeamWidgetState.hremployeelineList!.length +
          ScheduleCreateWidgetState.tripplanscheduleList!.length +
          DeliveryCreateWidgetState.tripplandeliveryList!.length);
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Create Trip Plan Delivery successfully');
    } else if (responseOb.msgState == MsgState.error) {
      print('Error Creating Trip Plan Delivery');
    }
  }

  void tripplandeliveryUpdateListen(ResponseOb responseOb) async {
    if (responseOb.msgState == MsgState.data) {
      print(
          'TripplanDeliveryUpdatelistlength: ${DeliveryCreateWidgetState.tripplandeliveryList!.length}');
      SharefCount.setTotal(SaleTeamWidgetState.hremployeelineList!.length +
          ScheduleCreateWidgetState.tripplanscheduleList!.length +
          DeliveryCreateWidgetState.tripplandeliveryList!.length);
      await saleorderlineBloc.waitingSaleOrderLineData();
      print('Create Trip Plan Delivery Update successfully');
    } else if (responseOb.msgState == MsgState.error) {
      print('Error Creating Trip Plan Delivery Update');
    }
  }

  // Future<void> transferData() async {
  //   print('TransferData');
  //   hremployeelineList = await databaseHelper.getHrEmployeeLineList();
  //   for (var element in hremployeelineList!) {
  //     print('Initial Hr Employee line list: ${element.empName}');
  //   }
  //   setState(() {});
  // }

  void listenCreateorNot(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          content:
              const Text('Create Successfully!', textAlign: TextAlign.center));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return WayPlanningListPage();
      }), (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Build');
    return WillPopScope(
      onWillPop: () async {
        await databaseHelper.deleteAllHrEmployeeLine();
        await databaseHelper.deleteAllTripPlanSchedule();
        await databaseHelper.deleteAllTripPlanDelivery();
        return true;
      },
      child: StreamBuilder<ResponseOb>(
          stream: saleorderlineBloc.waitingproductlineListStream(),
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
            }
            return SafeArea(
              child: Scaffold(
                  backgroundColor: Colors.grey[200],
                  appBar: AppBar(
                    backgroundColor: Color.fromARGB(255, 12, 41, 92),
                    title: Text(widget.neworedit == 1 ? widget.tripSeq : 'New'),
                    centerTitle: true,
                    actions: [
                      TextButton(
                          onPressed: widget.neworedit == 1
                              ? updateTripPlan
                              : createTripPlan,
                          child: Text(
                            widget.neworedit == 1 ? 'Update' : "Create",
                            style: const TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                  body: Form(
                    key: _formKey,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10, top: 10),
                          sliver: SliverList(
                              delegate: SliverChildListDelegate([
                            Text(
                              "Trip*:",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: hasNotTrip == true
                                      ? Colors.red
                                      : Colors.black),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              height: 40,
                              color: Colors.white,
                              // decoration: const BoxDecoration(
                              //     color: Colors.white,
                              //     // borderRadius: BorderRadius.circular(5),
                              //     // boxShadow: const [
                              //     //   BoxShadow(
                              //     //     color: Colors.black,
                              //     //     offset: Offset(0, 0),
                              //     //     blurRadius: 2,
                              //     //   )
                              //     // ]
                              //     ),
                              child: StreamBuilder<ResponseOb>(
                                  initialData: hasNotTrip == false
                                      ? null
                                      : ResponseOb(msgState: MsgState.loading),
                                  stream:
                                      wayplanningBloc.getTripConfigListStream(),
                                  builder: (context,
                                      AsyncSnapshot<ResponseOb> snapshot) {
                                    ResponseOb? responseOb = snapshot.data;
                                    if (responseOb?.msgState ==
                                        MsgState.loading) {
                                      return Center(
                                        child: Image.asset(
                                          'assets/gifs/loading.gif',
                                          width: 100,
                                          height: 100,
                                        ),
                                      );
                                    } else if (responseOb?.msgState ==
                                        MsgState.error) {
                                      return const Center(
                                        child: Text("Something went Wrong!"),
                                      );
                                    } else {
                                      return DropdownSearch<String>(
                                        popupItemBuilder:
                                            (context, item, isSelected) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item
                                                    .toString()
                                                    .split(',')[1]),
                                                const Divider(),
                                              ],
                                            ),
                                          );
                                        },
                                        autoValidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select Trip Name';
                                          }
                                          return null;
                                        },
                                        showSearchBox: true,
                                        showSelectedItems: true,
                                        showClearButton: !hasNotTrip,
                                        items: tripconfigList
                                            .map((e) =>
                                                '${e['id']},${e['name']}')
                                            .toList(),
                                        onChanged: getTripConfigListId,
                                        selectedItem: tripconfigName,
                                      );
                                    }
                                  }),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "From Date*:",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: hasNotFromDate == true
                                      ? Colors.red
                                      : Colors.black),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                                height: 40,
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
                                child: TextFormField(
                                    readOnly: true,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select From Date';
                                      }
                                      return null;
                                    },
                                    controller: fromDateController,
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          onPressed: () async {
                                            final DateTime? selected =
                                                await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(2023));

                                            if (selected != null) {
                                              setState(() {
                                                fromDate = selected
                                                    .toString()
                                                    .split(' ')[0];
                                                fromDateController.text =
                                                    selected
                                                        .toString()
                                                        .split(' ')[0];
                                                hasNotFromDate = false;
                                                print("From Date: $fromDate");
                                              });
                                            }
                                          },
                                        )))),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "Zone:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
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
                              child: StreamBuilder<ResponseOb>(
                                  initialData: hasNotZone == false
                                      ? null
                                      : ResponseOb(msgState: MsgState.loading),
                                  stream: quotationBloc.getZoneListStream(),
                                  builder: (context,
                                      AsyncSnapshot<ResponseOb> snapshot) {
                                    ResponseOb? responseOb = snapshot.data;
                                    if (responseOb?.msgState ==
                                        MsgState.loading) {
                                      return Center(
                                        child: Image.asset(
                                          'assets/gifs/loading.gif',
                                          width: 100,
                                          height: 100,
                                        ),
                                      );
                                    } else if (responseOb?.msgState ==
                                        MsgState.error) {
                                      return const Center(
                                        child: Text("Something went Wrong!"),
                                      );
                                    } else {
                                      return DropdownSearch<String>(
                                        popupItemBuilder:
                                            (context, item, isSelected) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(item
                                                    .toString()
                                                    .split(',')[1]),
                                                const Divider(),
                                              ],
                                            ),
                                          );
                                        },
                                        showSearchBox: true,
                                        showSelectedItems: true,
                                        showClearButton: !hasNotZone,
                                        items: zoneList
                                            .map((e) =>
                                                '${e['id']},${e['name']}')
                                            .toList(),
                                        onChanged: getZoneListId,
                                        selectedItem: zoneName,
                                      );
                                    }
                                  }),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "User:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
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
                                controller: resusersController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "To Date*:",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: hasNotToDate == true
                                      ? Colors.red
                                      : Colors.black),
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
                                child: TextFormField(
                                    readOnly: true,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select To Date';
                                      }
                                      return null;
                                    },
                                    controller: toDateController,
                                    decoration: InputDecoration(
                                        border: const OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          onPressed: () async {
                                            final DateTime? selected =
                                                await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(2023));

                                            if (selected != null) {
                                              setState(() {
                                                toDate = selected
                                                    .toString()
                                                    .split(' ')[0];
                                                toDateController.text = selected
                                                    .toString()
                                                    .split(' ')[0];
                                                hasNotToDate = false;
                                                print("From Date: $toDate");
                                              });
                                            }
                                          },
                                        )))),
                          ])),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 50),
                        ),
                        SliverFillRemaining(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50,
                                child: TabBar(
                                    unselectedLabelColor: Colors.black,
                                    indicator: const BoxDecoration(
                                      color: Color.fromARGB(255, 12, 41, 92),
                                      // boxShadow: const [
                                      //   BoxShadow(
                                      //     offset: Offset(0,0),
                                      //     blurRadius: 3,
                                      //   )
                                      // ],
                                      // borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    labelColor: Colors.white,
                                    controller: _tabController,
                                    tabs: const [
                                      Tab(
                                        height: 50,
                                        child: Text("Sale Team"),
                                      ),
                                      Tab(
                                        height: 50,
                                        child: Text("Schedule"),
                                      ),
                                      Tab(
                                        height: 50,
                                        child: Text("Delivery"),
                                      ),
                                    ]),
                              ),
                              Expanded(
                                child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      SaleTeamWidget(
                                        neworedit: widget.neworedit,
                                        leaderId: leaderName,
                                        hremployeelineList:
                                            widget.hremployeelineList,
                                        tripId: widget.tripId,
                                      ),
                                      ScheduleCreateWidget(
                                        neworedit: widget.neworedit,
                                        tripId: widget.tripId,
                                      ),
                                      DeliveryCreateWidget(
                                        neworedit: widget.neworedit,
                                        tripId: widget.tripId,
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            );
          }),
    );
  }
}
