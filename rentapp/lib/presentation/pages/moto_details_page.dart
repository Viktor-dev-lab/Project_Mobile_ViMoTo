import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rentapp/data/models/moto.dart';
import 'package:rentapp/presentation/pages/MapsDetailsPage.dart';
import 'package:rentapp/presentation/pages/review_page.dart';
import 'package:rentapp/presentation/widgets/moto_card.dart';
import 'package:rentapp/presentation/widgets/more_card.dart';
import 'package:rentapp/presentation/widgets/rental_confirmation_dialog.dart';

class MotoDetailsPage extends StatefulWidget {
  final Moto moto;
  const MotoDetailsPage({super.key, required this.moto});

  @override
  State<MotoDetailsPage> createState() => _MotoDetailsPageState();
}

class _MotoDetailsPageState extends State<MotoDetailsPage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  bool _canReview = false;
  bool _hasReviewed = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller!)
      ..addListener(() => setState(() {}));
    _controller!.forward();

    _checkUserAndLoadData();
  }

  Future<void> _checkUserAndLoadData() async {
    final user = FirebaseAuth.instance.currentUser;
    _currentUserId = user?.uid;

    if (_currentUserId != null) {
      await _checkRentalHistory();
      await _checkIfReviewed();
    }
    await _loadReviews();
  }

  Future<void> _checkRentalHistory() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('rentals')
          .orderByChild('motoId')
          .equalTo(widget.moto.id)
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        for (var entry in data.values) {
          final rental = entry as Map;
          if (rental['userId'] == _currentUserId && rental['status'] == 'completed') {
            setState(() => _canReview = true);
            return;
          }
        }
      }
    } catch (e) {
      print("ERROR CHECKING RENTAL: $e");
    }
  }

  Future<void> _checkIfReviewed() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('reviews')
          .orderByChild('motoId')
          .equalTo(widget.moto.id)
          .get();

      if (snapshot.exists && _currentUserId != null) {
        final data = snapshot.value as Map;
        for (var entry in data.values) {
          final review = entry as Map;
          if (review['userId'] == _currentUserId) {
            setState(() => _hasReviewed = true);
            return;
          }
        }
      }
    } catch (e) {
      print("ERROR CHECKING REVIEW: $e");
    }
  }

  Future<void> _loadReviews() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('reviews')
          .orderByChild('motoId')
          .equalTo(widget.moto.id)
          . get();

      final List<Map<String, dynamic>> loaded = [];
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        data.forEach((key, value) {
          final r = value as Map;
          loaded.add({
            'id': key,
            'userName': r['userName']?.toString() ?? 'Anonymous',
            'rating': (r['rating'] is num) ? (r['rating'] as num).toInt() : 0,
            'comment': r['comment']?.toString() ?? '',
            'createdAt': r['createdAt']?.toString() ?? '',
          });
        });
      }

      loaded.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));

      setState(() {
        _reviews = loaded;
        _isLoading = false;
      });
    } catch (e) {
      print("ERROR LOADING REVIEWS: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: _neumorphicIconButton(Icons.arrow_back_ios_new, () => Navigator.pop(context)),
        title: _neumorphicTitle('Bike Details'),
        centerTitle: true,
        actions: [_neumorphicIconButton(Icons.favorite_border, () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: MotoCard(moto: widget.moto)),
            const SizedBox(height: 24),

            // Owner & Map
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [_buildOwnerCard(), const SizedBox(width: 16), _buildMapPreview()]),
            ),

            const SizedBox(height: 24),

            // CUSTOMER REVIEWS – ĐƯA LÊN TRÊN
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ReviewPage(moto: widget.moto)),
                ).then((_) {
                  _loadReviews();
                  if (_currentUserId != null) _checkIfReviewed();
                });
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 2)),
                    BoxShadow(color: Colors.white, blurRadius: 8, offset: Offset(-2, -2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.rate_review, color: Colors.green.shade700, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Customer Reviews',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.green.shade600),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2))
                        : _reviews.isEmpty
                        ? _buildEmptyReviewPreview()
                        : Column(
                      children: _reviews.take(2).map((r) => _buildMiniReview(r)).toList(),
                    ),

                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _reviews.isEmpty ? 'Be the first to review!' : 'View all ${_reviews.length} reviews',
                        style: TextStyle(fontSize: 13, color: Colors.green.shade600, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // NÚT VIẾT ĐÁNH GIÁ
            if (_currentUserId != null && _canReview && !_hasReviewed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ReviewPage(moto: widget.moto)),
                      ).then((_) {
                        _loadReviews();
                        _checkIfReviewed();
                      });
                    },
                    icon: const Icon(Icons.rate_review, color: Colors.white),
                    label: const Text('Write a Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // SIMILAR BIKES – ĐƯA XUỐNG DƯỚI
            _buildSectionHeader('Similar Bikes', 'View All', () {}),
            const SizedBox(height: 12),
            _buildSimilarBikes(),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomRentBar(),
    );
  }

  // === WIDGETS ===
  Widget _buildMiniReview(Map<String, dynamic> r) {
    final date = DateFormat('dd MMM').format(DateTime.parse(r['createdAt']));
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.green.shade100,
            child: Icon(Icons.person, size: 14, color: Colors.green.shade700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(r['userName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Spacer(),
                    _buildStars(r['rating']),
                  ],
                ),
                if (r['comment'].isNotEmpty)
                  Text(
                    r['comment'].length > 50 ? '${r['comment'].substring(0, 50)}...' : r['comment'],
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(date, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviewPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.rate_review_outlined, size: 32, color: Colors.green.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('No reviews yet', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('Be the first to share your experience!', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star : Icons.star_border,
        size: 16,
        color: Colors.amber.shade600,
      )),
    );
  }

  Widget _neumorphicIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: IconButton(icon: Icon(icon, color: Colors.green.shade700), onPressed: onTap),
    );
  }

  Widget _neumorphicTitle(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildOwnerCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.green.shade400, Colors.green.shade600]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.green.shade200, blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: const CircleAvatar(radius: 35, backgroundImage: AssetImage('assets/user.png')),
            ),
            const SizedBox(height: 12),
            const Text('Nhu Phuc Xuan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: const Color(0x4DFFFFFF), borderRadius: BorderRadius.circular(12)),
              child: const Text('\$4,253', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.yellow.shade300, size: 16),
                const SizedBox(width: 4),
                const Text('4.9', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MapsDetailsPage(moto: widget.moto))),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.green.shade200, blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Transform.scale(
              scale: _animation!.value,
              alignment: Alignment.center,
              child: Image.asset('assets/maps.png', fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText, VoidCallback? onAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.green.shade700, size: 24),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            ],
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionText, style: TextStyle(color: Colors.green.shade600, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildSimilarBikes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          MoreCard(moto: _fakeMoto(1, 100, 100, 10)),
          const SizedBox(height: 12),
          MoreCard(moto: _fakeMoto(2, 200, 200, 20)),
          const SizedBox(height: 12),
          MoreCard(moto: _fakeMoto(3, 300, 300, 30)),
        ],
      ),
    );
  }

  Moto _fakeMoto(int index, int dist, int fuel, int price) {
    return Moto(
      id: widget.moto.id,
      model: '${widget.moto.model}-$index',
      distance: widget.moto.distance + dist,
      fuelCapacity: widget.moto.fuelCapacity + fuel,
      pricePerHour: widget.moto.pricePerHour + price,
      status: widget.moto.status,
    );
  }

  Widget _buildBottomRentBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Price', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('\$${widget.moto.pricePerHour.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                    Text('/hour', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _confirmRental(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 24),
                    SizedBox(width: 8),
                    Text('Rent Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRental(BuildContext context) {
    if (widget.moto.status == 'rented') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [Icon(Icons.error_outline, color: Colors.white), SizedBox(width: 12), Text('This bike is already rented!')]),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => RentalConfirmationDialog(moto: widget.moto, parentContext: context),
    );
  }
}