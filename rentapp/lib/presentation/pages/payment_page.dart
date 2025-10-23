import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rentapp/data/models/moto.dart';

class PaymentPage extends StatefulWidget {
  final Moto moto;
  const PaymentPage({super.key, required this.moto});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isPaid = false;

  Future<void> _payWithMomo() async {
    final amount = widget.moto.pricePerHour.toInt();
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Đây là ví dụ deep link để mở MoMo app (chế độ demo)
    final momoUrl = Uri.parse(
      "momo://app?action=payWithApp"
          "&partner=merchant123456"
          "&amount=$amount"
          "&description=Thanh%20toan%20thue%20xe%20${widget.moto.model}"
          "&orderId=$orderId"
          "&merchantName=Rent%20App"
          "&packageId=com.example.rentapp"
          "&callbackUrl=momoflutterdemo://callback",
    );

    if (await canLaunchUrl(momoUrl)) {
      await launchUrl(momoUrl, mode: LaunchMode.externalApplication);

      // Khi quay lại app, bạn có thể kiểm tra thanh toán (ở đây demo là giả định thành công)
      setState(() => _isPaid = true);
      await _savePaymentInfo(amount, orderId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán MoMo thành công!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng MoMo')),
      );
    }
  }

  Future<void> _savePaymentInfo(int amount, String orderId) async {
    final ref = FirebaseDatabase.instance.ref("payments/$orderId");

    await ref.set({
      "motoId": widget.moto.id,
      "model": widget.moto.model,
      "amount": amount,
      "status": "success",
      "method": "MoMo",
      "paidAt": DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Model: ${widget.moto.model}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Rental Price per Hour: \$${widget.moto.pricePerHour.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            if (!_isPaid)
              ElevatedButton(
                onPressed: _payWithMomo,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text('Thanh toán bằng MoMo'),
              ),
            if (_isPaid)
              const Text(
                'Đã thanh toán bằng MoMo!',
                style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
