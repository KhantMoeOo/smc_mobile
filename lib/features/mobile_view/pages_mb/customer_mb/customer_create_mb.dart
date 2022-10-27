import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../obs/response_ob.dart';
import '../../../../pages/customer_page/customer_bloc.dart';
import '../../../../pages/customer_page/customer_create_bloc.dart';
import '../../../../pages/quotation_page/quotation_bloc.dart';
import '../../../../pages/way_planning_page/schedule_page/schedule_bloc.dart';
import '../../../../utils/app_const.dart';
import 'customer_list_mb.dart';

class CustomerCreateMB extends StatefulWidget {
  const CustomerCreateMB({Key? key}) : super(key: key);

  @override
  State<CustomerCreateMB> createState() => _CustomerCreateMBState();
}

class _CustomerCreateMBState extends State<CustomerCreateMB> {
  final customerNameController = TextEditingController();
  final customerCodeController = TextEditingController();
  final phoneController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final websiteLinkController = TextEditingController();
  final streetController = TextEditingController();
  final street2Controller = TextEditingController();
  final customercreateBloc = CustomerCreateBloc();
  final customerBloc = CustomerBloc();
  final scheduleBloc = ScheduleBloc();
  final quotationBloc = QuotationBloc();
  List<dynamic> rescitiesList = [];
  String rescitiesName = '';
  int rescitiesId = 0;
  List<dynamic> townshipList = [];
  int townshipId = 0;
  String townshipName = '';
  bool hasNotTownship = true;
  bool hasTownshipData = false;
  List<dynamic> zoneList = [];
  String zoneName = '';
  int zoneId = 0;
  bool hasNotZone = true;
  bool hasZoneData = false;
  List<dynamic> segmentList = [];
  String segmentName = '';
  int segmentId = 0;
  List<dynamic> rescountrystateList = [];
  String rescountrystateName = '';
  int rescountrystateId = 0;
  bool hasNotResCountryState = true;
  bool hasResCountryStateData = false;
  List<dynamic> rescountryList = [];
  String rescountryName = '';
  String rescountryCode = '';
  int rescountryId = 0;
  bool hasNotResCountry = true;
  bool hasResCountryData = false;
  bool hasNotSegment = true;
  bool hasSegmentData = false;
  bool hasNotCustomer = true;
  bool hasNotCity = true;
  bool hasCityData = false;
  final _formKey = GlobalKey<FormState>();
  bool isCreateCustomer = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    quotationBloc.getRegionListStream().listen(getResCitiesListen);
    quotationBloc.getZoneListData();
    quotationBloc.getZoneListStream().listen(getZonelist);
    quotationBloc.getSegmenListData();
    quotationBloc.getSegmentListStream().listen(getSegmentlist);
    scheduleBloc.getTownshipListStream().listen(getTownshipListListen);
    customerBloc
        .getResCountryStateListStream()
        .listen(getResCountryStateListListen);
    customerBloc.getResCountryList();
    customerBloc.getResCountryListStream().listen(getResCountryListListen);
    customercreateBloc.getCustomemrCreateStream().listen(createCustomerListen);
  }

  void getResCitiesListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      rescitiesList = responseOb.data;
      hasCityData = false;
    } else if (responseOb.msgState == MsgState.error) {
      print('No Res Cities List');
    }
  } // Get Res Cities Listen

  void getTownshipListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      townshipList = responseOb.data;
      hasTownshipData = false;
      // setLocationNameMethod();
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

  void getResCountryStateListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      rescountrystateList = responseOb.data;
      hasResCountryStateData = false;
      for (var element in rescountrystateList) {
        element['country_code'] = rescountryCode;
      }
      print('Final ResCountryState: ${rescountrystateList}');
      // setLocationNameMethod();
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoResCountryStateList");
    }
  } // listen to get Res Country State List

  void getResCountryStateListId(String? v) {
    if (v != null) {
      setState(() {
        rescountrystateId = int.parse(v.toString().split(',')[0]);
        hasNotResCountryState = false;
        hasCityData = true;
        for (var element in rescountrystateList) {
          if (element['id'] == rescountrystateId) {
            rescountrystateName = '${element['name']} ($rescountryCode)';
            rescountrystateId = element['id'];
            quotationBloc.getRegionListData(rescountrystateId);

            print('rescountrystateName: $rescountrystateName');
            print('rescountrystateId: $rescountrystateId');
          }
        }
      });
    } else {
      hasNotResCountryState = true;
    }
  } // get ResCountryState Id from ResCountryStateListSelection

  void getResCountryListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      rescountryList = responseOb.data;
      // setLocationNameMethod();
      // getTripConfigListId();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoResCountryList");
    }
  } // listen to get Res Country  List

  void getResCountryListId(String? v) {
    if (v != null) {
      setState(() {
        rescountryId = int.parse(v.toString().split(',')[0]);
        hasNotResCountry = false;
        hasResCountryStateData = true;
        for (var element in rescountryList) {
          if (element['id'] == rescountryId) {
            rescountryName = element['name'];
            rescountryCode = element['code'];
            rescountryId = element['id'];
            customerBloc.getResCountryStateList(rescountryId);
            print('rescountryName: $rescountryName');
            print('rescountryId: $rescountryId');
          }
        }
      });
    } else {
      hasNotResCountry = true;
    }
  } // get ResCountry Id from ResCountryListSelection

  void getZonelist(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      zoneList = responseOb.data;
      hasZoneData = true;
      // setZoneListNameMethod();
      // setZoneFilterNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoZoneList");
    }
  } // listen to get Zone List

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
            print('zoneId:$zoneId');
          }
        }
      });
    } else {
      hasNotZone = true;
    }
  } // get ZoneListId from ZoneListSelection

  void getSegmentlist(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      segmentList = responseOb.data;
      hasSegmentData = true;
      // setSegmnetNameMethod();
      // setSegmentFilterNameMethod();
    } else if (responseOb.msgState == MsgState.error) {
      print("NoSegmentList");
    }
  } // listen to get Segment List

  void getSegmentListId(String? v) {
    if (v != null) {
      setState(() {
        segmentId = int.parse(v.toString().split(',')[0]);
        hasNotSegment = false;
        for (var element in segmentList) {
          if (element['id'] == segmentId) {
            segmentName = element['name'];
            segmentId = element['id'];
            print('SegmentListName:$segmentName');
            print('SegmentListId:$segmentId');
          }
        }
      });
    } else {
      hasNotSegment = true;
    }
  } // get SegmentListId from SegmentListSelection

  void getResCitiesListId(String? v) {
    if (v != null) {
      setState(() {
        rescitiesId = int.parse(v.toString().split(',')[0]);
        hasNotCity = false;
        hasTownshipData = true;
        for (var element in rescitiesList) {
          if (element['id'] == rescitiesId) {
            rescitiesName = element['name'];
            rescitiesId = element['id'];
            scheduleBloc.getTownshipListData(rescitiesId);
            print('rescitiesName: $rescitiesName');
            print('rescitiesId: $rescitiesId');
          }
        }
      });
    } else {
      hasNotCity = true;
    }
  } // get RegionListId from RegionListSelection

  void createCustomerListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      final snackbar = SnackBar(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          content: const Text('Create Quo Successfully!',
              textAlign: TextAlign.center));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) {
        return CustomerListMB();
      }), (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  createCustomer() async {
    bool isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        isCreateCustomer = true;
        print('isCreateCustomer: $isCreateCustomer');
      });
      await customercreateBloc.customerCreate(
          name: customerNameController.text,
          code: customerCodeController.text,
          partnerCity: rescitiesId,
          partnerTownship: townshipId,
          stateId: rescountrystateId,
          countryId: rescountryId,
          street: streetController.text,
          street2: street2Controller.text,
          segmentId: segmentId,
          zoneId: zoneId,
          email: emailController.text,
          phone: phoneController.text,
          mobile: mobileController.text,
          categoryId: 0,
          website: websiteLinkController.text);
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    customerNameController.dispose();
    phoneController.dispose();
    mobileController.dispose();
    emailController.dispose();
    websiteLinkController.dispose();
    street2Controller.dispose();
    streetController.dispose();
    quotationBloc.dipose();
    scheduleBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
              backgroundColor: Colors.grey[200],
              appBar: AppBar(
                backgroundColor: AppColors.appBarColor,
                title: const Text("New"),
                actions: [
                  TextButton(
                      onPressed: createCustomer,
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ))
                ],
              ),
              body: Form(
                key: _formKey,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 20, top: 20),
                      sliver: SliverList(
                          delegate: SliverChildListDelegate([
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Customer Name*:",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: hasNotCustomer == true
                                  ? Colors.red
                                  : Colors.black),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            color: Colors.white,
                            height: 40,
                            child: TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please Enter Customer Name';
                                  }
                                  return null;
                                },
                                onChanged: (customer) {
                                  setState(() {
                                    if (customer.isEmpty) {
                                      hasNotCustomer = true;
                                    } else {
                                      hasNotCustomer = false;
                                    }
                                  });
                                },
                                controller: customerNameController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ))),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Customer Code:",
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
                            child: TextFormField(
                                controller: customerCodeController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ))),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Address:",
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
                            child: TextFormField(
                                controller: streetController,
                                decoration: const InputDecoration(
                                  hintText: 'Street...',
                                  border: OutlineInputBorder(),
                                ))),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            color: Colors.white,
                            height: 40,
                            child: TextFormField(
                                controller: street2Controller,
                                decoration: const InputDecoration(
                                  hintText: 'Street 2...',
                                  border: OutlineInputBorder(),
                                ))),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: Colors.white,
                          height: 40,
                          child: StreamBuilder<ResponseOb>(
                              initialData: hasCityData == true
                                  ? ResponseOb(msgState: MsgState.loading)
                                  : null,
                              stream: quotationBloc.getRegionListStream(),
                              builder: (context,
                                  AsyncSnapshot<ResponseOb> snapshot) {
                                ResponseOb? responseOb = snapshot.data;
                                if (responseOb?.msgState == MsgState.loading) {
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
                                      label: 'Cities',
                                      // dropdownSearchDecoration: const InputDecoration(
                                      //   border: OutlineInputBorder(),
                                      //   helperText: 'Cities',
                                      // ),
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
                                      showClearButton: !hasNotCity,
                                      items: rescitiesList
                                          .map((e) => '${e['id']},${e['name']}')
                                          .toList(),
                                      onChanged: getResCitiesListId,
                                      selectedItem: rescitiesName);
                                }
                              }),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: Colors.white,
                          height: 40,
                          child: StreamBuilder<ResponseOb>(
                              initialData: hasTownshipData == false
                                  ? null
                                  : ResponseOb(msgState: MsgState.loading),
                              stream: scheduleBloc.getTownshipListStream(),
                              builder: (context,
                                  AsyncSnapshot<ResponseOb> snapshot) {
                                ResponseOb? responseOb = snapshot.data;
                                if (responseOb?.msgState == MsgState.loading) {
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
                                    label: 'Township',
                                    popupItemBuilder:
                                        (context, item, isSelected) {
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
                        Container(
                          color: Colors.white,
                          height: 40,
                          child: StreamBuilder<ResponseOb>(
                              initialData: hasResCountryData == false
                                  ? null
                                  : ResponseOb(msgState: MsgState.loading),
                              stream:
                                  customerBloc.getResCountryStateListStream(),
                              builder: (context,
                                  AsyncSnapshot<ResponseOb> snapshot) {
                                ResponseOb? responseOb = snapshot.data;
                                if (responseOb?.msgState == MsgState.loading) {
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
                                    label: 'State',
                                    popupItemBuilder:
                                        (context, item, isSelected) {
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
                                    showClearButton: !hasNotResCountryState,
                                    items: rescountrystateList
                                        .map((e) =>
                                            '${e['id']},${e['name']} (${e['country_code']})')
                                        .toList(),
                                    onChanged: getResCountryStateListId,
                                    selectedItem: rescountrystateName,
                                  );
                                }
                              }),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: Colors.white,
                          height: 40,
                          child: StreamBuilder<ResponseOb>(
                              initialData: hasResCountryData == true
                                  ? null
                                  : ResponseOb(msgState: MsgState.loading),
                              stream: customerBloc.getResCountryListStream(),
                              builder: (context,
                                  AsyncSnapshot<ResponseOb> snapshot) {
                                ResponseOb? responseOb = snapshot.data;
                                if (responseOb?.msgState == MsgState.loading) {
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
                                    label: 'Country',
                                    popupItemBuilder:
                                        (context, item, isSelected) {
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
                                    showClearButton: !hasNotResCountry,
                                    items: rescountryList
                                        .map((e) => '${e['id']},${e['name']}')
                                        .toList(),
                                    onChanged: getResCountryListId,
                                    selectedItem: rescountryName,
                                  );
                                }
                              }),
                        ),
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
                          color: Colors.white,
                          height: 40,
                          child: StreamBuilder<ResponseOb>(
                              initialData: hasZoneData == false
                                  ? ResponseOb(msgState: MsgState.loading)
                                  : null,
                              stream: quotationBloc.getZoneListStream(),
                              builder: (context,
                                  AsyncSnapshot<ResponseOb> snapshot) {
                                ResponseOb? responseOb = snapshot.data;
                                if (responseOb?.msgState == MsgState.loading) {
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
                                            Text(item.toString().split(',')[1]),
                                            const Divider(),
                                          ],
                                        ),
                                      );
                                    },
                                    showSearchBox: true,
                                    showSelectedItems: true,
                                    showClearButton: !hasNotZone,
                                    items: zoneList
                                        .map((e) => '${e['id']},${e['name']}')
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
                          "Segment:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          color: Colors.white,
                          height: 40,
                          child: StreamBuilder<ResponseOb>(
                              initialData: hasSegmentData == false
                                  ? ResponseOb(msgState: MsgState.loading)
                                  : null,
                              stream: quotationBloc.getSegmentListStream(),
                              builder: (context,
                                  AsyncSnapshot<ResponseOb> snapshot) {
                                ResponseOb? responseOb = snapshot.data;
                                if (responseOb?.msgState == MsgState.loading) {
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
                                            Text(item.toString().split(',')[1]),
                                            const Divider(),
                                          ],
                                        ),
                                      );
                                    },
                                    showSearchBox: true,
                                    showSelectedItems: true,
                                    showClearButton: !hasNotSegment,
                                    items: segmentList
                                        .map((e) => '${e['id']},${e['name']}')
                                        .toList(),
                                    onChanged: getSegmentListId,
                                    selectedItem: segmentName,
                                  );
                                }
                              }),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Phone:",
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
                            child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ))),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Mobile:",
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
                            child: TextFormField(
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: mobileController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ))),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Email:",
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
                            child: TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ))),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Website Link:",
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
                            child: TextFormField(
                                controller: websiteLinkController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ))),
                      ])),
                    )
                  ],
                ),
              )),
          isCreateCustomer == false
              ? Container()
              : StreamBuilder<ResponseOb>(
                  initialData: ResponseOb(msgState: MsgState.loading),
                  stream: customercreateBloc.getCustomemrCreateStream(),
                  builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
                    ResponseOb responseOb = snapshot.data!;
                    if (responseOb.msgState == MsgState.loading) {
                      return Container(
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: Image.asset(
                            'assets/gifs/loading.gif',
                            width: 100,
                            height: 100,
                          ),
                        ),
                      );
                    }
                    return Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Image.asset(
                          'assets/gifs/loading.gif',
                          width: 100,
                          height: 100,
                        ),
                      ),
                    );
                  })
        ],
      ),
    );
  }
}
