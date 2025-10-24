import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rentapp/data/models/moto.dart';
import 'dart:ui';

class PaymentPage extends StatefulWidget {
  final Moto moto;
  const PaymentPage({super.key, required this.moto});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isPaid = false;
  bool _isProcessing = false;

  // === PAYMENT INFO ===
  static const String receiverPhone = '0393578347';
  static const String receiverName = 'Phúc Như Xuân';
  static const String transferNote = 'Payment for bike rental';

  int get _amountInVND => (widget.moto.pricePerHour * 100).toInt();
  String get _amountDisplay => '\$${widget.moto.pricePerHour.toStringAsFixed(2)}';

  Future<void> _payWithMomo() async {
    if (_isProcessing || _isPaid) return;
    setState(() => _isProcessing = true);

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    final momoDeepLink = Uri.parse(
      'momo://payment?'
          'action=transfer'
          '&receiver=$receiverPhone'
          '&amount=$_amountInVND'
          '&note=${Uri.encodeComponent(transferNote)}'
          '&orderId=$orderId'
          '&requestId=$orderId'
          '&partnerCode=MOMO'
          '&partnerName=RentApp'
          '&version=2',
    );

    try {
      final canLaunch = await canLaunchUrl(momoDeepLink);
      if (!canLaunch) {
        _showManualGuide();
        setState(() => _isProcessing = false);
        return;
      }

      final launched = await launchUrl(momoDeepLink, mode: LaunchMode.externalApplication);

      if (launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: const Row(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(width: 16),
                Expanded(child: Text('Opening MoMo... Tap "Pay" to confirm')),
              ],
            ),
            duration: const Duration(seconds: 6),
          ),
        );

        await Future.delayed(const Duration(seconds: 4)); // Simulate

        setState(() => _isPaid = true);
        await _savePaymentInfo(orderId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.shade600,
              content: const Text('Payment successful!'),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        _showManualGuide();
      }
    } catch (e) {
      _showManualGuide();
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showManualGuide() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white.withOpacity(0.95),
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.orange),
            SizedBox(width: 8),
            Text('Open MoMo Manually', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please open MoMo and transfer:', style: TextStyle(fontWeight: FontWeight.w500)),
            const Divider(height: 20),
            _copyableField('Recipient:', receiverName),
            _copyableField('Phone:', receiverPhone),
            _copyableField('Amount:', _amountDisplay),
            _copyableField('Note:', transferNote),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy Phone'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: receiverPhone));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone number copied!')),
              );
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  Widget _copyableField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
          Expanded(child: SelectableText(value, style: const TextStyle(fontFamily: 'monospace'))),
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Colors.green),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value.replaceAll(r'$', '')));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _savePaymentInfo(String orderId) async {
    final ref = FirebaseDatabase.instance.ref("payments/$orderId");
    await ref.set({
      "motoId": widget.moto.id,
      "model": widget.moto.model,
      "amount": widget.moto.pricePerHour,
      "receiverName": receiverName,
      "receiverPhone": receiverPhone,
      "note": transferNote,
      "method": "MoMo Quick Transfer",
      "status": "success",
      "paidAt": DateTime.now().toIso8601String(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. GRADIENT BACKGROUND (XANH LÁ)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9),
                  Color(0xFFA5D6A7),
                ],
              ),
            ),
          ),

          // 2. BLUR GLASS PANEL
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 36, 28, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Title
                        const Text(
                          "Confirm Payment",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Pay with MoMo in one tap",
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 36),

                        // Bike Info Card
                        _buildNeumorphicCard(
                          child: ListTile(
                            leading: Icon(Icons.motorcycle, color: Colors.green.shade700, size: 32),
                            title: Text(widget.moto.model, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Text('Price/hour: $_amountDisplay', style: TextStyle(color: Colors.grey[700])),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Payment Details
                        _buildNeumorphicCard(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Quick Transfer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 12),
                                _infoRow('Recipient', receiverName),
                                _infoRow('Phone', receiverPhone),
                                _infoRow('Amount', _amountDisplay),
                                _infoRow('Note', transferNote),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Pay Button
                        if (!_isPaid)
                          _buildNeumorphicButton(
                            onTap: _isProcessing ? null : _payWithMomo,
                            text: _isProcessing ? "Opening MoMo..." : "Pay Now",
                            isLoading: _isProcessing,
                          ),

                        // Success
                        if (_isPaid)
                          Column(
                            children: [
                              Icon(Icons.check_circle, size: 80, color: Colors.green.shade600),
                              const SizedBox(height: 16),
                              const Text(
                                'Payment Successful!',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              Text('$_amountDisplay has been transferred'),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEUMORPHIC CARD
  Widget _buildNeumorphicCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(4, 4), blurRadius: 12),
          BoxShadow(color: Colors.white.withOpacity(0.7), offset: const Offset(-4, -4), blurRadius: 12),
        ],
      ),
      child: child,
    );
  }

  // NEUMORPHIC BUTTON
  Widget _buildNeumorphicButton({
    required VoidCallback? onTap,
    required String text,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: const Color(0xFF388E3C).withOpacity(0.2), offset: const Offset(5, 5), blurRadius: 15),
            BoxShadow(color: const Color(0xFFC8E6C9).withOpacity(0.2), offset: const Offset(-5, -5), blurRadius: 15),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)))),
          Expanded(child: Text(value, style: const TextStyle(fontFamily: 'monospace', color: Colors.black87))),
        ],
      ),
    );
  }
}