import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentapp/presentation/pages/onboarding_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'package:rentapp/presentation/pages/login_page.dart';
import 'package:rentapp/presentation/widgets/Auth/Signup/neumorphic_text.dart';
import 'package:rentapp/presentation/widgets/Auth/Signup/neumorphic_button.dart';

// Lớp xử lý CSDL, giữ nguyên từ code của bạn
class DatabaseMethods {
  Future addUserDetails(Map<String, dynamic> userInfoMap, String uid) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(userInfoMap);
  }
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> registration() async {
    if (passwordController.text != confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Passwords do not match.", style: TextStyle(fontSize: 16)),
        ));
      }
      return; 
    }

    if (passwordController.text.isNotEmpty && nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Registered successfully", style: TextStyle(fontSize: 16),
              ),
            )
          );
        }

        Map<String, dynamic> userInfoMap = {
          "name": nameController.text,
          "email": emailController.text,
        };
        
        await DatabaseMethods().addUserDetails(userInfoMap, userCredential.user!.uid);
        User? user = FirebaseAuth.instance.currentUser;

        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OnboardingPage(user: user!)));
        }
      } on FirebaseAuthException catch (e) {
        String message = "An error occurred.";
        if (e.code == 'weak-password') {
          message = "The password provided is too weak.";
        } else if (e.code == 'email-already-in-use') {
          message = "The account already exists for that email.";
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(message, style: const TextStyle(fontSize: 16)),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE8F5E9), Color(0xFFA5D6A7),],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/eco_illustration.png',
              height: screenSize.height * 0.45,
              width: screenSize.width,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: screenSize.height * 0.3,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.7),],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28.0, 36.0, 28.0, 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Create Account", style: TextStyle( fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), ),),
                        const SizedBox(height: 8),
                        Text("Start your eco-friendly journey today!", style: TextStyle(fontSize: 14, color: Colors.grey[700]), ),
                        const SizedBox(height: 30),
                        NeumorphicTextField(controller: nameController, hintText: 'Full Name', icon: Icons.person_outline_rounded,),
                        const SizedBox(height: 20),
                        NeumorphicTextField(controller: emailController, hintText: 'Email', icon: Icons.email_outlined,),
                        const SizedBox(height: 20),
                        NeumorphicTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 20), 
                        NeumorphicTextField(
                          controller: confirmPasswordController,
                          hintText: 'Confirm Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          obscureText: _obscureConfirmPassword,
                          onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        const SizedBox(height: 30),
                        NeumorphicButton(onTap: registration, text: "Sign Up",),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ", style: TextStyle(color: Colors.grey[700]),),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement( context, MaterialPageRoute(builder: (context) => const Login()), );
                              },
                              child: const Text("Sign In",  style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold,),
                              ),
                            ),
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
}

