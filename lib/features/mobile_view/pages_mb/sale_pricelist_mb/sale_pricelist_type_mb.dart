import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../pages/sale_pricelist_page/customer_type_page.dart';
import '../../../../pages/sale_pricelist_page/region_type_page.dart';
import '../../../../pages/sale_pricelist_page/segment_type_page.dart';
import '../../../../utils/app_const.dart';
import '../menu_mb/menu_list_mb.dart';

class SalePricelistTypeMB extends StatefulWidget {
  const SalePricelistTypeMB({Key? key}) : super(key: key);

  @override
  State<SalePricelistTypeMB> createState() => _SalePricelistTypeMBState();
}

class _SalePricelistTypeMBState extends State<SalePricelistTypeMB> {
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
            // drawer: const DrawerWidget(),
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return MenuListMB();
                  }));
                },
                icon: const Icon(Icons.menu),
              ),
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
