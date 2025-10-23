class Moto {
  final String id;
  final String model;
  final double fuelCapacity;
  final double distance;
  final double pricePerHour;
  final String status;

  Moto({
    required this.id,
    required this.model,
    required this.fuelCapacity,
    required this.distance,
    required this.pricePerHour,
    required this.status,
  });

  // Factory để convert từ Map (Firebase data)
  factory Moto.fromMap(String id, Map<String, dynamic> data) {
    return Moto(
      id: id,
      model: data['model'] ?? '',
      fuelCapacity: (data['fuelCapacity'] as num?)?.toDouble() ?? 0.0,
      distance: (data['distance'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: (data['pricePerHour'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'available',
    );
  }

  // Method để convert thành Map (để update Firebase)
  Map<String, dynamic> toMap() {
    return {
      'model': model,
      'fuelCapacity': fuelCapacity,
      'distance': distance,
      'pricePerHour': pricePerHour,
      'status': status,
    };
  }
}