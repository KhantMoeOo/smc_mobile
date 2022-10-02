import 'package:flutter/material.dart';

class CustomerCardWidget extends StatefulWidget {
  String customerName;
  String code;
  String address;
  String companyType;
  CustomerCardWidget({
    Key? key,
    required this.customerName,
    required this.code,
    required this.address,
    required this.companyType,
  }) : super(key: key);

  @override
  State<CustomerCardWidget> createState() => _CustomerCardWidgetState();
}

class _CustomerCardWidgetState extends State<CustomerCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
    );
  }
}
