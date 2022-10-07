import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smc_mobile/pages/sale_pricelist_page/customer_type_page.dart';

import '../../utils/app_const.dart';
import '../../widgets/drawer_widget.dart';
import 'region_type_page.dart';
import 'segment_type_page.dart';

class SalePricelistTypePage extends StatefulWidget {
  const SalePricelistTypePage({Key? key}) : super(key: key);

  @override
  State<SalePricelistTypePage> createState() => _SalePricelistTypePageState();
}

class _SalePricelistTypePageState extends State<SalePricelistTypePage> {
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
        child: Scaffold(
            backgroundColor: Colors.grey[200],
            drawer: const DrawerWidget(),
            appBar: AppBar(
              backgroundColor: AppColors.appBarColor,
              title: const Text('Select Pricelist Type'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 50,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.appBarColor,
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return CustomerTypePage();
                          }));
                        },
                        child: const Text('Special Pricelists',
                            style: TextStyle(color: Colors.white))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 50,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.appBarColor,
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return SegmentTypePage();
                          }));
                        },
                        child: const Text('Segment',
                            style: TextStyle(color: Colors.white))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 50,
                    child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.appBarColor,
                        ),
                        onPressed: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return RegionTypePage();
                          }));
                        },
                        child: const Text('Region',
                            style: TextStyle(color: Colors.white))),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
