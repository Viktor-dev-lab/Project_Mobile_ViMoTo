import 'package:flutter/material.dart';
import 'package:rentapp/data/models/moto.dart'; // <<< ĐÃ SỬA: Import Moto model
import 'package:rentapp/presentation/pages/MapsDetailsPage.dart'; // <<< ĐÃ SỬA: Đổi tên file nếu cần
import 'package:rentapp/presentation/widgets/moto_card.dart'; // <<< ĐÃ SỬA: Sử dụng MotoCard
import 'package:rentapp/presentation/widgets/more_card.dart'; // <<< ĐÃ SỬA: Cần đảm bảo MoreCard hỗ trợ Moto

class MotoDetailsPage extends StatefulWidget { // <<< ĐÃ SỬA: Đổi tên class cho phù hợp
  final Moto moto; // <<< ĐÃ SỬA: Sử dụng Moto

  const MotoDetailsPage({super.key, required this.moto}); // <<< ĐÃ SỬA

  @override
  State<MotoDetailsPage> createState() => _MotoDetailsPageState(); // <<< ĐÃ SỬA
}

class _MotoDetailsPageState extends State<MotoDetailsPage> with SingleTickerProviderStateMixin { // <<< ĐÃ SỬA
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this
    );

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });

    _controller!.forward();
  }

  @override
  void dispose() {
    _controller?.dispose(); // <<< SỬA LỖI: Gọi dispose() thay vì forward()
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [ // Thêm const để tối ưu
            Icon(Icons.info_outline),
            Text(' Information')
          ],
        ),
      ),
      // Bọc bằng SingleChildScrollView để tránh lỗi overflow khi xoay màn hình hoặc trên màn hình nhỏ
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Truyền trực tiếp widget.moto
            MotoCard(moto: widget.moto), // <<< ĐÃ SỬA
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: const Color(0xffF3F3F3),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [ // Thêm const
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 5)
                          ]),
                      child: Column(
                        children: const [ // Thêm const
                          CircleAvatar(radius: 40, backgroundImage: AssetImage('assets/user.png')),
                          SizedBox(height: 10),
                          Text('Jane Cooper', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('\$4,253', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MapsDetailsPage(moto: widget.moto)) // <<< ĐÃ SỬA
                        );
                      },
                      child: Container(
                        height: 170,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [ // Thêm const
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 5)
                            ]),
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
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // <<< ĐÃ SỬA: Cần đảm bảo MoreCard nhận được đối tượng Moto
                  MoreCard(moto: Moto(model: "${widget.moto.model}-1", distance: widget.moto.distance + 100, fuelCapacity: widget.moto.fuelCapacity + 100, pricePerHour: widget.moto.pricePerHour + 10)),
                  const SizedBox(height: 5),
                  MoreCard(moto: Moto(model: "${widget.moto.model}-2", distance: widget.moto.distance + 200, fuelCapacity: widget.moto.fuelCapacity + 200, pricePerHour: widget.moto.pricePerHour + 20)),
                  const SizedBox(height: 5),
                  MoreCard(moto: Moto(model: "${widget.moto.model}-3", distance: widget.moto.distance + 300, fuelCapacity: widget.moto.fuelCapacity + 300, pricePerHour: widget.moto.pricePerHour + 30)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
