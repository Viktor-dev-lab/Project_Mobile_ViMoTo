import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:rentapp/data/models/moto.dart';
import 'package:rentapp/presentation/widgets/rental_confirmation_dialog.dart'; // Import widget dialog (cần tạo)

class MapsDetailsPage extends StatelessWidget {
  final Moto moto;

  const MapsDetailsPage({super.key, required this.moto});

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
            child: motoDetailsCard(context, moto: moto), // Truyền context vào
          ),
        ],
      ),
    );
  }

  Widget motoDetailsCard(BuildContext context, {required Moto moto}) {
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
                BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  moto.model,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.two_wheeler, color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      '> ${moto.distance.toStringAsFixed(0)} km',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.local_gas_station, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${moto.fuelCapacity.toStringAsFixed(1)} L',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
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
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Features", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  featureIcons(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${moto.pricePerHour}/day',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (moto.status == 'rented') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('This bike is already rented!')),
                            );
                            return;
                          }
                          showDialog(
                            context: context,
                            builder: (context) => RentalConfirmationDialog(
                              moto: moto,
                              parentContext: context,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Book Now', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Image.asset('assets/white_car.png'),
          ),
        ],
      ),
    );
  }

  Widget featureIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        featureIcon(Icons.local_gas_station, 'Petrol', '4-stroke'),
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
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 4),
          Text(title),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}