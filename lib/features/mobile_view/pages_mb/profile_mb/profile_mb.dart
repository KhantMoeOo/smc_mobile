import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../obs/response_ob.dart';
import '../../../../pages/profile_page/profile_bloc.dart';
import '../../../../utils/app_const.dart';
import '../menu_mb/menu_list_mb.dart';

class ProfileMB extends StatefulWidget {
  const ProfileMB({Key? key}) : super(key: key);

  @override
  State<ProfileMB> createState() => _ProfileMBState();
}

class _ProfileMBState extends State<ProfileMB> {
  final profileBloc = ProfileBloc();
  List<dynamic> profileList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileBloc.getProfileData();
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
        initialData: ResponseOb(msgState: MsgState.loading),
        stream: profileBloc.getProfileStream(),
        builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
          ResponseOb? responseOb = snapshot.data;
          if (responseOb!.msgState == MsgState.data) {
            profileList = responseOb.data;
            return Scaffold(
                backgroundColor: Colors.grey[200],
                appBar: AppBar(
                  backgroundColor: AppColors.appBarColor,
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return const MenuListMB();
                      }));
                    },
                    icon: const Icon(Icons.menu),
                  ),
                  title: const Text("My Profile"),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                      itemCount: profileList.length,
                      itemBuilder: (context, i) {
                        return Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 0),
                                    blurRadius: 2)
                              ]),
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Center(
                              //   child: Container(
                              //     width: 100,
                              //     height: 100,
                              //     decoration: BoxDecoration(
                              //         shape: BoxShape.circle,
                              //         image: DecorationImage(
                              //             isAntiAlias: true,
                              //             image: MemoryImage(base64Decode(
                              //                 profileList[i]['image_128'])))),
                              //   ),
                              // ),
                              profileList[i]['image_128'] == false
                                  ? Container(
                                      width: 100,
                                      height: 100,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/imgs/person_icon.png'))),
                                    )
                                  : Center(
                                      child: SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: CircleAvatar(
                                        backgroundImage: MemoryImage(
                                            base64Decode(
                                                profileList[i]['image_128'])),
                                      ),
                                    )),
                              const SizedBox(height: 50),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Name',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ': ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                          profileList[i]['name'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        )
                                      ])),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Work Mobile',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ': ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                          profileList[i]['mobile_phone'] ==
                                                  false
                                              ? ''
                                              : profileList[i]['mobile_phone'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        )
                                      ])),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Work Phone',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ': ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                          profileList[i]['work_phone'] == false
                                              ? ''
                                              : profileList[i]['work_phone'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        )
                                      ])),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Work Email',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ': ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                          profileList[i]['work_email'] == false
                                              ? ''
                                              : profileList[i]['work_email'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        )
                                      ])),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Work Location',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ': ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                          profileList[i]['work_location_id'] ==
                                                  false
                                              ? ''
                                              : profileList[i]
                                                  ['work_location_id'][1],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        )
                                      ])),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Department',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ': ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                          profileList[i]['department_id'] ==
                                                  false
                                              ? ''
                                              : profileList[i]['department_id']
                                                  [1],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        )
                                      ])),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Job Position',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ': ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                          profileList[i]['job_id'] == false
                                              ? ''
                                              : profileList[i]['job_id'][1],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        )
                                      ])),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'SSB Registration No',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ': ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                          profileList[i]['ssb_register_no'] ==
                                                  false
                                              ? ''
                                              : profileList[i]
                                                  ['ssb_register_no'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        )
                                      ])),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Manager',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const Text(
                                    ': ',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(
                                          profileList[i]['parent_id'] == false
                                              ? ''
                                              : profileList[i]['parent_id'][1],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18),
                                        )
                                      ])),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                ));
          } else if (responseOb.msgState == MsgState.error) {
            return const Center(
              child: Text('Error'),
            );
          } else {
            return Container(
                color: Colors.white,
                child: Center(
                  child: Image.asset(
                    'assets/gifs/loading.gif',
                    width: 100,
                    height: 100,
                  ),
                ));
          }
        },
      )),
    );
  }
}
