// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rentapp/presentation/pages/moto_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingPage extends StatelessWidget {
  final User user;
  const OnboardingPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Xin chào\n'
          '${user.displayName ?? 'Người dùng'}\n'
          'Email: ${user.email ?? 'Không có email'}\n'
          'UID: ${user.uid}\n'
          '${user.photoURL != null ? 'Ảnh: ${user.photoURL}' : ''}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
      backgroundColor: Color(0xFFE8F5E9),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/onboarding.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Renting easily. \nEnjoy your travel!',
                    style: TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  Text(
                    'Choose your favorite motobike for renting \nExperience the travel with a lower price',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(
                    width: 320,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MotoListScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'Let\'s go!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
