import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smc_mobile/features/mobile_view/pages_mb/customer_mb/customer_detail_mb.dart';

import '../../pages/profile_page/profile_bloc.dart';
import '../../utils/app_const.dart';

class CustomerCardWidget extends StatefulWidget {
  int customerId;
  String customerName;
  String code;
  String address;
  String companyType;
  int zoneId;
  CustomerCardWidget({
    Key? key,
    required this.customerId,
    required this.customerName,
    required this.code,
    required this.address,
    required this.companyType,
    required this.zoneId,
  }) : super(key: key);

  @override
  State<CustomerCardWidget> createState() => _CustomerCardWidgetState();
}

class _CustomerCardWidgetState extends State<CustomerCardWidget> {
  final profileBloc = ProfileBloc();
  final slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Slidable(
        controller: slidableController,
        actionPane: const SlidableBehindActionPane(),
        secondaryActions: [
          IconSlideAction(
            color: AppColors.appBarColor,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return CustomerDetailMB(
                  customerId: widget.customerId,
                  zoneId: widget.zoneId,
                );
              })).then((value) {
                setState(() {
                  profileBloc.getResUsersData();
                });
              });
            },
            iconWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.read_more,
                  size: 25,
                  color: Colors.white,
                ),
                Text(
                  "View Details",
                  style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width > 400.0 ? 18 : 12,
                      color: Colors.white),
                ),
              ],
            ),
          )
        ],
        child: Container(
          padding: const EdgeInsets.all(5),
          color: Colors.white,
          child: Row(
            children: [
              widget.companyType == 'person' ? Image.asset("assets/imgs/person_icon.png", width: 100, height: 100) :
              Image.asset("assets/imgs/business_icon.png", width: 100, height: 100),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 10,),
                    Text(widget.code,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                        )),
                    Text('[${widget.address}]',
                        style: const TextStyle(
                          fontSize: 15,
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
