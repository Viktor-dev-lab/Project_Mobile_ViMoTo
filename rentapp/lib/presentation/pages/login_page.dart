import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentapp/presentation/pages/onboarding_page.dart';
import 'package:rentapp/presentation/pages/signup_page.dart';
import 'package:rentapp/presentation/pages/forgotpassword_page.dart';
import 'package:rentapp/core/services/GoogleAuthService.dart';

import 'dart:ui';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      User? user = FirebaseAuth.instance.currentUser;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingPage(user: user!)),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'Email không tồn tại. Vui lòng đăng ký tài khoản mới.';
          break;
        case 'wrong-password':
          message = 'Mật khẩu không chính xác. Vui lòng thử lại.';
          break;
        case 'invalid-email':
          message = 'Địa chỉ email không hợp lệ.';
          break;
        case 'user-disabled':
          message = 'Tài khoản này đã bị vô hiệu hóa.';
          break;
        case 'too-many-requests':
          message = 'Bạn đăng nhập sai quá nhiều lần. Vui lòng thử lại sau.';
          break;
        case 'network-request-failed':
          message = 'Không thể kết nối đến máy chủ. Kiểm tra lại Internet.';
          break;
        default:
          message = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              message,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. NỀN VỚI GRADIENT XANH LÁ
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F5E9), // Xanh lá rất nhạt
                  Color(0xFFA5D6A7), // Xanh lá nhạt
                ],
              ),
            ),
          ),

          // 2. HÌNH ẢNH MINH HỌA TRÀN VIỀN
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/eco_illustration.png',
              height:
                  screenSize.height * 0.45, // Chiều cao chiếm gần nửa màn hình
              width: screenSize.width, // Chiều rộng bằng màn hình
              fit: BoxFit.cover, // SỬA: Dãn ảnh để lấp đầy, có thể cắt bớt
            ),
          ),

          // 3. KHUNG ĐĂNG NHẬP KÍNH MỜ (HIỆU ỨNG MỚI)
          Positioned(
            top: screenSize.height *
                0.4, // SỬA: Cập nhật vị trí bắt đầu của khung
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(40)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25), // Tăng độ mờ
                child: Container(
                  decoration: BoxDecoration(
                    // Thêm viền nhẹ để tạo hiệu ứng cạnh kính
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(
                            alpha: 0.5), // Giảm độ trong suốt ở trên
                        Colors.white.withValues(
                            alpha: 0.7), // Tăng độ trong suốt ở dưới
                      ],
                    ),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28.0, 36.0, 28.0, 40.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Welcome Back!",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sign in to continue your eco-friendly ride",
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 36),

                        // Các trường nhập liệu và nút bấm giữ nguyên style 3D
                        _buildNeumorphicTextField(
                          controller: emailController,
                          hintText: 'Email',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 20),
                        _buildNeumorphicTextField(
                          controller: passwordController,
                          hintText: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPasswordPage()),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xFF388E3C),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildNeumorphicButton(
                          onTap: userLogin,
                          text: "Sign In",
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[400])),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text("Or continue with",
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                            ),
                            Expanded(child: Divider(color: Colors.grey[400])),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildNeumorphicSocialButton(
                                icon: Icons.g_mobiledata,
                                color: const Color(0xFFDB4437),
                                onTap: () async {
                                  print("Google clicked");
                                  // Gọi đăng nhập Google ở đây
                                  User? user = await GoogleAuthService()
                                      .signInWithGoogle();
                                  if (user != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              OnboardingPage(user: user)),
                                    );
                                  }
                                }),
                            const SizedBox(width: 24),
                            _buildNeumorphicSocialButton(
                                icon: Icons.facebook,
                                color: const Color(0xFF1877F2),
                                onTap: () async {
                                  print("Facebook clicked");
                                  // Gọi đăng nhập Facebook ở đây
                                }),
                          ],
                        ),
                        const SizedBox(
                            height: 30), // Khoảng cách trước nút đăng ký

                        // THÊM NÚT ĐĂNG KÝ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignUp()),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.bold,
                                ),
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

  // WIDGET HELPER CHO HIỆU ỨNG 3D (NEUMORPHISM)
  Widget _buildNeumorphicTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Nền xanh rất nhạt
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Bóng tối ở dưới
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(4, 4),
            blurRadius: 10,
          ),
          // Ánh sáng ở trên
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(-4, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontSize: 15,
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.grey[500],
                      size: 22),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildNeumorphicButton(
      {required VoidCallback onTap, required String text}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // Bóng tối
            BoxShadow(
              color: const Color(0xFF388E3C).withOpacity(0.1),
              offset: const Offset(5, 5),
              blurRadius: 15,
            ),
            // Ánh sáng
            BoxShadow(
              color: const Color(0xFFC8E6C9).withOpacity(0.1),
              offset: const Offset(-5, -5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphicSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double size = 56,
    Color backgroundColor = const Color(0xFFE8F5E9),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(4, 4),
              blurRadius: 10,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              offset: const Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: icon == Icons.g_mobiledata ? 38 : 28,
          ),
        ),
      ),
    );
  }
}
