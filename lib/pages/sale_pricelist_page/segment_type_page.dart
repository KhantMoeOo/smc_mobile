import 'package:flutter/material.dart';

import '../../obs/response_ob.dart';
import '../../utils/app_const.dart';
import '../../widgets/drawer_widget.dart';
import '../profile_page/profile_bloc.dart';
import '../quotation_page/quotation_bloc.dart';
import '../quotation_page/sale_order_line_page/sale_order_line_bloc.dart';
import 'sale_pricelist_page.dart';

class SegmentTypePage extends StatefulWidget {
  const SegmentTypePage({Key? key}) : super(key: key);

  @override
  State<SegmentTypePage> createState() => _SegmentTypePageState();
}

class _SegmentTypePageState extends State<SegmentTypePage> {
  final quotationBloc = QuotationBloc();
  final saleorderlineBloc = SaleOrderLineBloc();
  final profileBloc = ProfileBloc();
  List<dynamic> userList = [];
  List<dynamic> salepricelistList = [];
  List<dynamic> segmentList = [];

  int salepricelistId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileBloc.getResUsersData();
    profileBloc.getResUsersStream().listen(getResUsersData);
    saleorderlineBloc
        .getSalePricelistListStream()
        .listen(getSalePricelistListen);
    quotationBloc.getSegmentListStream().listen(getSegmentListListen);
  }

  void getSegmentListListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      segmentList = responseOb.data;
    }
  }

  void getResUsersData(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      userList = responseOb.data;
      saleorderlineBloc
          .getSalePricelistData(['pricelist_type', '=', 'segment']);
    }
  }

  void getSalePricelistListen(ResponseOb responseOb) {
    if (responseOb.msgState == MsgState.data) {
      salepricelistList = responseOb.data;
      for (var salepricelist in salepricelistList) {
        if (userList[0]['zone_id'][0] == salepricelist['zone_id'][0]) {
          salepricelistId = salepricelist['id'];
          print('Sale Pricelist Id: $salepricelistId');
        }
      }
      quotationBloc.getSegmenListData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: StreamBuilder<ResponseOb>(
      initialData: ResponseOb(msgState: MsgState.loading),
      stream: quotationBloc.getSegmentListStream(),
      builder: (context, AsyncSnapshot<ResponseOb> snapshot) {
        ResponseOb? responseOb = snapshot.data;
        if (responseOb?.msgState == MsgState.loading) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Image.asset(
                'assets/gifs/loading.gif',
                width: 100,
                height: 100,
              ),
            ),
          );
        } else if (responseOb?.msgState == MsgState.error) {
          return Container(
            color: Colors.white,
            child: const Center(child: Text('Error')),
          );
        } else {
          return Scaffold(
            backgroundColor: Colors.grey[200],
            appBar: AppBar(
              backgroundColor: AppColors.appBarColor,
              title: Text(
                  'Sale Pricelist (${userList[0]['zone_id'][1]}) By Segment'),
            ),
            body: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Select Segment Name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: segmentList.length,
                      itemBuilder: (c, i) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return SalePricelistPage(
                                        salepricelistId: salepricelistId,
                                        segmentId: segmentList[i]['id'],
                                      );
                                    }));
                                  },
                                  child: Text('${segmentList[i]['name']}')),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ),
          );
        }
      },
    ));
  }
}
