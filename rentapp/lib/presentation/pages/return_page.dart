import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rentapp/data/models/moto.dart';
import 'package:rentapp/presentation/pages/review_page.dart';

class ReturnPage extends StatefulWidget {
  final Moto moto;
  const ReturnPage({super.key, required this.moto});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> {
  bool _isReturning = false;

  Future<void> _returnMoto() async {
    setState(() => _isReturning = true);

    try {
      // Cập nhật trạng thái xe trong Firebase
      final motoRef = FirebaseDatabase.instance.ref("motos/${widget.moto.id}");
      await motoRef.update({"status": "available"});

      setState(() => _isReturning = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trả xe thành công!')),
      );

      // Sau khi trả xe -> chuyển sang trang đánh giá
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewPage(moto: widget.moto),
        ),
      );
    } catch (e) {
      setState(() => _isReturning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi trả xe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final moto = widget.moto;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trả xe'),
        backgroundColor: Colors.green.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bạn đang trả xe:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moto.model,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('Dung tích bình xăng: ${moto.fuelCapacity} L'),
                    Text('Quãng đường đã đi: ${moto.distance} km'),
                    Text('Giá thuê: \$${moto.pricePerHour.toStringAsFixed(2)}/giờ'),
                    const SizedBox(height: 10),
                    Chip(
                      label: Text(
                        moto.status == 'rented' ? 'Đang thuê' : 'Trạng thái: ${moto.status}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor:
                      moto.status == 'rented' ? Colors.orange : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isReturning ? null : _returnMoto,
                icon: const Icon(Icons.assignment_turned_in),
                label: Text(_isReturning ? 'Đang xử lý...' : 'Xác nhận trả xe'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
