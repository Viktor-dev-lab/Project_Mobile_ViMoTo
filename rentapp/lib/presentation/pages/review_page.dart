import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:rentapp/data/models/moto.dart';

class ReviewPage extends StatefulWidget {
  final Moto moto;
  const ReviewPage({super.key, required this.moto});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String? _currentUserId;
  String? _editingReviewId;
  double _avgRating = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN');
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref('reviews')
          .orderByChild('motoId')
          .equalTo(widget.moto.id)
          .get();

      final List<Map<String, dynamic>> loaded = [];

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final r = value as Map<dynamic, dynamic>;
          loaded.add({
            'id': key,
            'userId': r['userId']?.toString(),
            'userName': r['userName']?.toString() ?? 'Anonymous',
            'rating': (r['rating'] as num?)?.toInt() ?? 0,
            'comment': r['comment']?.toString() ?? '',
            'createdAt': r['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
          });
        });
      }

      loaded.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));

      if (loaded.isNotEmpty) {
        final total = loaded.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
        _avgRating = total / loaded.length;
      } else {
        _avgRating = 0;
      }

      setState(() {
        _reviews = loaded;
        _isLoading = false;
      });
    } catch (e) {
      print("ERROR LOADING REVIEWS: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = {
        'motoId': widget.moto.id,
        'userId': user.uid,
        'userName': user.displayName ?? 'Người dùng',
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (_editingReviewId != null) {
        await FirebaseDatabase.instance.ref('reviews/$_editingReviewId').update(data);
        _editingReviewId = null;
      } else {
        final ref = FirebaseDatabase.instance.ref('reviews').push();
        await ref.set(data);
      }

      await _loadReviews();
      _commentController.clear();
      setState(() => _rating = 0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_editingReviewId != null ? 'Đã cập nhật!' : 'Cảm ơn bạn đã đánh giá!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi gửi đánh giá')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteReview(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đánh giá?'),
        content: const Text('Bạn có chắc muốn xóa đánh giá này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: TextStyle(color: Colors.red.shade600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseDatabase.instance.ref('reviews/$id').remove();
      await _loadReviews();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa đánh giá')),
      );
    }
  }

  Widget _buildStar(int index) {
    return IconButton(
      onPressed: () => setState(() => _rating = index.toDouble()),
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber.shade600,
        size: 40,
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final date = DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(review['createdAt']));
    final isOwner = review['userId'] == _currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(2, 2), blurRadius: 8),
          BoxShadow(color: Colors.white.withOpacity(0.8), offset: const Offset(-2, -2), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green.shade100,
                child: Icon(Icons.person, size: 18, color: Colors.green.shade700),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review['userName'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              _buildStars(review['rating']),
              if (isOwner) ...[
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade600),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                    const PopupMenuItem(value: 'delete', child: Text('Xóa', style: TextStyle(color: Colors.red))),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      setState(() {
                        _editingReviewId = review['id'];
                        _rating = review['rating'].toDouble();
                        _commentController.text = review['comment'];
                      });
                    } else if (value == 'delete') {
                      _deleteReview(review['id']);
                    }
                  },
                ),
              ],
            ],
          ),
          if (review['comment'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '“${review['comment']}”',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            date,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star : Icons.star_border,
        size: 18,
        color: Colors.amber.shade600,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Đánh giá ${widget.moto.model}',
          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.green.shade700),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            // TRUNG BÌNH SAO + SỐ LƯỢNG
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green.shade50,
                    child: Text(
                      _avgRating > 0 ? _avgRating.toStringAsFixed(1) : '0',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(5, (i) => Icon(
                            i < _avgRating.round() ? Icons.star : Icons.star_border,
                            color: Colors.amber.shade600,
                            size: 20,
                          )),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_reviews.length} đánh giá',
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // PHẦN GỬI / SỬA ĐÁNH GIÁ
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: Column(
                children: [
                  Text(
                    _editingReviewId != null ? 'Chỉnh sửa đánh giá' : 'Bạn đã thuê xe này',
                    style: TextStyle(fontSize: 16, color: Colors.green.shade700, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) => _buildStar(i + 1)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Chia sẻ trải nghiệm của bạn (không bắt buộc)',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (_editingReviewId != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _editingReviewId = null;
                              _rating = 0;
                              _commentController.clear();
                            });
                          },
                          child: const Text('Hủy', style: TextStyle(color: Colors.red)),
                        ),
                      const Spacer(),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: _isSubmitting
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.send, color: Colors.white),
                          label: Text(_isSubmitting ? 'Đang gửi...' : (_editingReviewId != null ? 'Cập nhật' : 'Gửi đánh giá')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _isSubmitting ? null : _submitReview,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DANH SÁCH ĐÁNH GIÁ – CUỘN ĐƯỢC
            _reviews.isEmpty
                ? Center(
              child: Column(
                children: [
                  Icon(Icons.rate_review_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Chưa có đánh giá nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const Text('Hãy là người đầu tiên!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _reviews.length,
              itemBuilder: (context, index) => _buildReviewCard(_reviews[index]),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}