import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smc_mobile/features/mobile_view/pages_mb/way_plan_mb/call-visit_mb/call_visit_create_mb.dart';

class CallVisitDetailMB extends StatefulWidget {
  Map<String, dynamic> callvisitList;
  CallVisitDetailMB({
    Key? key,
    required this.callvisitList,
  }) : super(key: key);

  @override
  State<CallVisitDetailMB> createState() => _CallVisitDetailMBState();
}

class _CallVisitDetailMBState extends State<CallVisitDetailMB>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('WayPlanId: ${widget.callvisitList['id']}');
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              backgroundColor: Color.fromARGB(255, 12, 41, 92),
              title: Text(widget.callvisitList['customer_id'][1]),
              actions: [
                TextButton(onPressed: () {
                  Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return CallVisitCreateMB(
                                          isNew: false,
                                          callvisitList: widget.callvisitList,
                                        );
                                      })).then((value) {
                                        setState(() {});
                                      });
                }, child: const Text('Edit'))
              ],
            ),
            body: Stack(
              children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Text(
                          widget.callvisitList['customer_id'][1],
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 4,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 10))
                                ],
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: widget.callvisitList['action_image'] ==
                                          false
                                      ? const AssetImage(
                                              'assets/imgs/camera_icon.png')
                                          as ImageProvider
                                      : MemoryImage(base64Decode(widget
                                          .callvisitList['action_image'])),
                                ),
                              ),
                            )),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 4,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 2,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                      offset: const Offset(0, 10))
                                ],
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: widget.callvisitList[
                                              'action_image_out'] ==
                                          false
                                      ? const AssetImage(
                                              'assets/imgs/camera_icon.png')
                                          as ImageProvider
                                      : MemoryImage(base64Decode(widget
                                          .callvisitList['action_image_out'])),
                                ),
                              ),
                            )),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Way Plan',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['way_id'][1],
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Township ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['township_id'] ==
                                                false
                                            ? ''
                                            : widget.callvisitList[
                                                'township_id'][1],
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Customer ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['customer_id'] ==
                                                false
                                            ? ''
                                            : widget.callvisitList[
                                                'customer_id'][1],
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Date ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['date'] == false
                                            ? ''
                                            : widget.callvisitList['date'],
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Arrival Time ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getTimeStringFromDouble(
                                            widget.callvisitList['arl_time']),
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Departure Time ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        getTimeStringFromDouble(
                                            widget.callvisitList['dept_time']),
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Latitude ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['lt'].toString(),
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Longitude ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['lg'].toString(),
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Zone ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['zone_id'] == false
                                            ? ''
                                            : widget.callvisitList['zone_id']
                                                [1],
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Vehicle ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['fleet_id'] ==
                                                false
                                            ? ''
                                            : widget.callvisitList['fleet_id']
                                                    [1]
                                                .toString(),
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Driver ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['driver_id'] ==
                                                false
                                            ? ''
                                            : widget.callvisitList['driver_id']
                                                [1],
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 200,
                              child: Text(
                                'Remark ',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                            const Text(
                              ':  ',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Expanded(
                                flex: 2,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.callvisitList['remark'] == false
                                            ? ''
                                            : widget.callvisitList['remark'],
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                      )
                                    ]))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ],
    );
  }
}
