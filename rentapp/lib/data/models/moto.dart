class Moto {
  final String model;           // Kiểu xe (ví dụ: Vespa Justin Bieber, Honda CBR)
  final double fuelCapacity;    // Dung tích bình nhiên liệu (lít)
  final double distance;        // Quãng đường đã đi (km)
  final double pricePerHour;    // Giá thuê mỗi giờ (USD hoặc VND)

  Moto({required this.model, required this.fuelCapacity, required this.distance, required this.pricePerHour});

  factory Moto.fromMap(Map<String, dynamic> map) {
    return Moto(
        model: map['model'],
        distance: map['distance'],
        fuelCapacity: map['fuelCapacity'],
        pricePerHour: map['pricePerHour']
    );
  }
}
