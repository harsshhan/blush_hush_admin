import 'package:flutter/material.dart';

class DashboardWidget extends StatelessWidget {
  final String title;
  final int count;
  const DashboardWidget({super.key, required this.count,required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 95,
      padding: EdgeInsets.only(left: 8,top: 8,bottom: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color.fromRGBO(217,217,217,1)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,style: TextStyle(fontSize: 13),),
          Text(count.toString(),style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}