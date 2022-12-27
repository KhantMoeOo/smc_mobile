import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../features/mobile_view/pages_mb/product_mb/product_detail_mb.dart';
import '../../pages/product_page/product_detail_page.dart';
import '../../utils/app_const.dart';

class ProductCardWidget extends StatefulWidget {
  int productid;
  String productName;
  String productCode;
  bool saleOk;
  bool purchaseOk;
  double listPrice;
  String qtyAvailable;
  List<dynamic> uomId;
  ProductCardWidget({
    Key? key,
    required this.productid,
    required this.productName,
    required this.productCode,
    required this.saleOk,
    required this.purchaseOk,
    required this.listPrice,
    required this.qtyAvailable,
    required this.uomId,
  }) : super(key: key);

  @override
  State<ProductCardWidget> createState() => _ProductCardWidgetState();
}

class _ProductCardWidgetState extends State<ProductCardWidget> {
  final slidableController = SlidableController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        //padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.circular(10),
          // boxShadow: const [
          //   BoxShadow(
          //     color: Colors.black,
          //     offset: Offset(0, 0),
          //     blurRadius: 2,
          //   )
          // ]
        ),
        child: Slidable(
          controller: slidableController,
          actionPane: const SlidableBehindActionPane(),
          secondaryActions: [
            IconSlideAction(
              color: AppColors.appBarColor,
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return ProductDetailMB(productId: widget.productid, stockonhand: widget.qtyAvailable,);
                }));
              },
              iconWidget: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.read_more,
                    size: 25,
                    color: Colors.white,
                  ),
                  Text(
                    "View Details",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            )
          ],
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.circular(10),
              // boxShadow: const [
              //   BoxShadow(
              //     color: Colors.black,
              //     offset: Offset(0, 0),
              //     blurRadius: 3,
              //   )]
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.productCode),
                      RichText(
                          text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                            const TextSpan(text: "Price: "),
                            TextSpan(text: "${widget.listPrice}"),
                            const TextSpan(text: "K")
                          ])),
                      RichText(
                          text: TextSpan(
                              style: const TextStyle(color: Colors.black),
                              children: [
                            const TextSpan(text: "On hand: "),
                            TextSpan(
                              text: widget.qtyAvailable,
                            ),
                            // TextSpan(
                            //     text:
                            //         "${widget.uomId.isEmpty ? '' : widget.uomId[1]}")
                          ]))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
