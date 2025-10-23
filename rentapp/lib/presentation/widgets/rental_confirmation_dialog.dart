import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rentapp/data/models/moto.dart';
import 'package:rentapp/presentation/pages/payment_page.dart';

class RentalConfirmationDialog extends StatelessWidget {
  final Moto moto;
  final BuildContext parentContext;

  const RentalConfirmationDialog({
    super.key,
    required this.moto,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and Title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.two_wheeler,
              size: 50,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Confirm Rental',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review the information',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Bike Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.motorcycle,
                  'Model',
                  moto.model,
                  Colors.green.shade700,
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  Icons.attach_money,
                  'Price per Hour',
                  '\$${moto.pricePerHour.toStringAsFixed(2)}',
                  Colors.green.shade700,
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  Icons.speed,
                  'Distance',
                  '${moto.distance.toStringAsFixed(0)} km',
                  Colors.green.shade700,
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  Icons.local_gas_station,
                  'Fuel Capacity',
                  '${moto.fuelCapacity.toStringAsFixed(1)} L',
                  Colors.green.shade700,
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  Icons.access_time,
                  'Start Time',
                  DateTime.now().toString().split('.')[0],
                  Colors.green.shade700,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.green.shade300, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmRental(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green.shade600,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmRental(BuildContext context) {
    final DatabaseReference motoRef =
    FirebaseDatabase.instance.ref('motos/${moto.id}');

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
              ),
              const SizedBox(height: 16),
              const Text('Processing...'),
            ],
          ),
        ),
      ),
    );

    motoRef.update({'status': 'rented'}).then((_) {
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close confirmation dialog
      Navigator.pushReplacement(
        parentContext,
        MaterialPageRoute(builder: (context) => PaymentPage(moto: moto)),
      );
    }).catchError((error) {
      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Close confirmation dialog
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(
          content: const Text('Failed to rent bike. Please try again!'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    });
  }
}