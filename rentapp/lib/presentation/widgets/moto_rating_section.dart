import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MotoRatingSection extends StatefulWidget {
  final String motoId;
  final bool showAverageOnly; // true nếu chỉ muốn hiển thị trung bình sao

  const MotoRatingSection({
    super.key,
    required this.motoId,
    this.showAverageOnly = false,
  });

  @override
  State<MotoRatingSection> createState() => _MotoRatingSectionState();
}

class _MotoRatingSectionState extends State<MotoRatingSection> {
  final _commentController = TextEditingController();
  double _rating = 0;
  double _averageRating = 0;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final ref = FirebaseDatabase.instance.ref('reviews/${widget.motoId}');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      double total = 0;
      final reviews = data.entries.map((e) {
        final val = Map<String, dynamic>.from(e.value);
        total += (val['rating'] as num).toDouble();
        return {'rating': val['rating'], 'comment': val['comment']};
      }).toList();

      setState(() {
        _reviews = reviews;
        _averageRating = total / reviews.length;
      });
    } else {
      setState(() {
        _reviews = [];
        _averageRating = 0;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_rating == 0 || _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao và nhập nhận xét!')),
      );
      return;
    }

    final ref = FirebaseDatabase.instance.ref('reviews/${widget.motoId}');
    await ref.push().set({
      'rating': _rating,
      'comment': _commentController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });

    _commentController.clear();
    setState(() => _rating = 0);
    await _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAverageOnly) {
      // 👉 Chỉ hiển thị số sao trung bình (trên đầu trang)
      return Row(
        children: [
          const Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            _averageRating > 0
                ? _averageRating.toStringAsFixed(1)
                : 'Chưa có đánh giá',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      );
    }

    // 👉 Giao diện đầy đủ khi ở phần "Đánh giá"
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá xe',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            return IconButton(
              onPressed: () => setState(() => _rating = starIndex.toDouble()),
              icon: Icon(
                Icons.star,
                color: _rating >= starIndex ? Colors.amber : Colors.grey,
              ),
            );
          }),
        ),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(
            hintText: 'Nhập nhận xét của bạn...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _submitReview,
          child: const Text('Gửi đánh giá'),
        ),
        const SizedBox(height: 15),
        if (_reviews.isNotEmpty)
          const Text('Các đánh giá gần đây:', style: TextStyle(fontWeight: FontWeight.bold)),
        ..._reviews.map((r) => ListTile(
          leading: Icon(Icons.star, color: Colors.amber),
          title: Text('${r['rating']} sao'),
          subtitle: Text(r['comment']),
        )),
      ],
    );
  }
}
