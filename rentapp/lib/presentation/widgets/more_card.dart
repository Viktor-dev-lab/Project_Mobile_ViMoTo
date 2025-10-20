import 'package:flutter/material.dart';
import 'package:rentapp/data/models/moto.dart';

class MoreCard extends StatelessWidget {
  final Moto moto;

  const MoreCard({super.key, required this.moto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
              offset: Offset(0, 4),
            )
          ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                moto.model,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5,),
              Row(
                children: [
                  Icon(Icons.directions_bike, color: Colors.white, size: 16,),
                  SizedBox(width: 5,),
                  Text(
                    '> ${moto.distance} km',
                    style: TextStyle(color: Colors.white, fontSize: 14),

                  ),
                  SizedBox(width: 10,),
                  Icon(Icons.battery_full, color: Colors.white, size: 16,),
                  SizedBox(width: 5,),
                  Text(
                    moto.fuelCapacity.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 14),

                  ),
                ],
              )
            ],
          ),
          Icon(Icons.arrow_forward, color: Colors.white, size: 24,)
        ],
      ),
    );
  }
}
