import 'package:flutter/material.dart';

import '../../widgets/drawer_widget.dart';
import '../quotation_page/quotation_page.dart';
import '../way_planning_page/way_planning_page.dart';

class SMCHomePage extends StatefulWidget {
  SMCHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<SMCHomePage> createState() => _SMCHomePageState();
}

class _SMCHomePageState extends State<SMCHomePage> {
  String pageName = 'Quotation';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DrawerWidgetState.pageController.addListener(() {
      print('Page' + DrawerWidgetState.pageController.page.toString());
      if (DrawerWidgetState.pageController.page == 0.0) {
        setState(() {
          pageName = 'Quotation';
        });
      } else if (DrawerWidgetState.pageController.page == 2.0) {
        setState(() {
          pageName = 'Production';
        });
      } else if (DrawerWidgetState.pageController.page == 1.0) {
        setState(() {
          pageName = 'Way Planning';
        });
      } else {
        setState(() {
          pageName = 'My Profile';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const DrawerWidget(),
        appBar: AppBar(
          title: Text(pageName),
        ),
        body: PageView(
          controller: DrawerWidgetState.pageController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            QuotationListPage(),
            WayPlanningListPage(),
            // ProductListPage(),
            // ProfilePage(),
            // LogoutPage(),
          ],
        ),
      ),
    );
  }
}
