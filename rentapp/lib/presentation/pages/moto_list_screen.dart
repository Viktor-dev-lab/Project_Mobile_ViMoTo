import 'package:flutter/material.dart';
import 'package:rentapp/data/models/moto.dart';
import 'package:rentapp/presentation/widgets/moto_card.dart';

class MotoListScreen extends StatelessWidget {
  final List<Moto> motos = [
    Moto(
      model: 'Honda Vision',
      fuelCapacity: 5.5,    // Dung tích bình nhiên liệu (lít)
      distance: 10.0,       // Quãng đường đã đi (km)
      pricePerHour: 8.0,    // Giá thuê mỗi giờ (USD)
    ),
    // 2. Honda PCX 160 (Thương hiệu Honda)
    Moto(
      model: 'Honda PCX 160',
      fuelCapacity: 8.0,
      distance: 15.0,
      pricePerHour: 10.0,
    ),
    // 3. Yamaha Aerox 155 (Thương hiệu Yamaha)
    Moto(
      model: 'Yamaha Aerox 155',
      fuelCapacity: 5.5,
      distance: 20.0,
      pricePerHour: 12.0,
    ),
    // 4. Yamaha MT-03 (Thương hiệu Yamaha)
    Moto(
      model: 'Yamaha MT-03',
      fuelCapacity: 14.0,
      distance: 25.0,
      pricePerHour: 15.0,
    ),
    // 5. Vespa Sprint (Thương hiệu Vespa)
    Moto(
      model: 'Vespa Sprint',
      fuelCapacity: 7.0,
      distance: 12.0,
      pricePerHour: 10.0,
    ),
    // 6. Vespa GTS 300 (Thương hiệu Vespa)
    Moto(
      model: 'Vespa GTS 300',
      fuelCapacity: 9.0,
      distance: 18.0,
      pricePerHour: 13.0,
    ),
    // 7. Suzuki Gixxer (Thương hiệu Suzuki)
    Moto(
      model: 'Suzuki Gixxer',
      fuelCapacity: 12.0,
      distance: 30.0,
      pricePerHour: 14.0,
    ),
    // 8. Suzuki Hayabusa (Thương hiệu Suzuki)
    Moto(
      model: 'Suzuki Hayabusa',
      fuelCapacity: 21.0,
      distance: 40.0,
      pricePerHour: 20.0,
    ),
    // 9. Kawasaki Ninja 250 (Thương hiệu Kawasaki)
    Moto(
      model: 'Kawasaki Ninja 250',
      fuelCapacity: 17.0,
      distance: 25.0,
      pricePerHour: 18.0,
    ),
    // 10. Kawasaki Z900 (Thương hiệu Kawasaki)
    Moto(
      model: 'Kawasaki Z900',
      fuelCapacity: 17.0,
      distance: 35.0,
      pricePerHour: 22.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: motos.length,
        itemBuilder: (context, index){
          return MotoCard(moto: motos[index]);
        },
      ),
    );
  }
}