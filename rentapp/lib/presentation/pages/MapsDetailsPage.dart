import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentapp/data/models/moto.dart'; // <<< ĐÃ SỬA

class MapsDetailsPage extends StatelessWidget {
  final Moto moto; // <<< ĐÃ SỬA

  const MapsDetailsPage({super.key, required this.moto}); // <<< ĐÃ SỬA

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            // LƯU Ý: Bạn cần sửa lại code FlutterMap cho phiên bản mới
            options: MapOptions(
              center: const LatLng(10.8231, 106.6297), // Ví dụ: TP. HCM
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
            ],
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: motoDetailsCard(moto: moto) // <<< ĐÃ SỬA
          )
        ],
      ),
    );
  }
}

Widget motoDetailsCard({required Moto moto}) { // <<< ĐÃ SỬA
  return SizedBox(
    height: 350,
    child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: double.infinity,
          decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10)
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              Text(moto.model, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),), // <<< ĐÃ SỬA
              const SizedBox(height: 10,),
              Row(
                children: [
                  const Icon(Icons.two_wheeler, color: Colors.white, size: 16,), // Thay icon cho phù hợp
                  const SizedBox(width: 5,),
                  Text(
                    '> ${moto.distance} km', // <<< ĐÃ SỬA
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(width: 10,),
                  const Icon(Icons.local_gas_station, color: Colors.white, size: 14,), // Thay icon cho phù hợp
                  const SizedBox(width: 5,),
                  Text(
                    moto.fuelCapacity.toString(), // <<< ĐÃ SỬA
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              )
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Features", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                featureIcons(),
                const SizedBox(height: 20,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${moto.pricePerHour}/day', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),), // <<< ĐÃ SỬA
                    ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                        child: const Text('Book Now', style: TextStyle(color: Colors.white),))
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
            top: 50,
            right: 20,
            // Thay ảnh xe máy nếu cần
            child: Image.asset('assets/white_car.png'))
      ],
    ),
  );
}

Widget featureIcons() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      featureIcon(Icons.local_gas_station, 'Petrol', '4-stroke'), // Sửa cho phù hợp
      featureIcon(Icons.speed, 'Max Speed', '120 km/h'),
      featureIcon(Icons.two_wheeler, 'Type', 'Scooter'),
    ],
  );
}

Widget featureIcon(IconData icon, String title, String subtitle) {
  return Container(
    width: 100,
    height: 100,
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 1)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
      children: [
        Icon(icon, size: 28,),
        const SizedBox(height: 4),
        Text(title),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center, // Căn giữa text
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        )
      ],
    ),
  );
}
