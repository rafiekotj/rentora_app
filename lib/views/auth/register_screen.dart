import 'package:flutter/material.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/extensions/navigator.dart';
import 'package:rentora_app/views/auth/login_screen.dart';
import 'package:rentora_app/views/home/bottom_navbar.dart';
import 'package:rentora_app/widgets/custom_button.dart';
import 'package:rentora_app/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();

  bool isVisibility = true;
  bool _isLoading = false;

  void visibilityOnOff() {
    isVisibility = !isVisibility;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),

                          // ===== LOGO =====
                          Center(
                            child: Image.asset(
                              "assets/icons/rentora_logo.png",
                              width: 200,
                            ),
                          ),

                          const SizedBox(height: 64),

                          // ===== JUDUL =====
                          const Text(
                            "Daftar di Rentora",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ===== USERNAME =====
                          CustomTextField(
                            controller: usernameController,
                            hintText: "Username",
                          ),
                          const SizedBox(height: 8),

                          // ===== EMAIL =====
                          CustomTextField(
                            controller: emailController,
                            hintText: "Email",
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email tidak boleh kosong";
                              } else if (!value.contains("@")) {
                                return "Email tidak valid";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          // ===== PASSWORD =====
                          CustomTextField(
                            controller: passwordController,
                            hintText: "Kata Sandi",
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            isVisibility: isVisibility,
                            onVisibilityToggle: visibilityOnOff,
                            validator: (value) {
                              final password = value ?? "";
                              if (password.isEmpty) {
                                return "Password tidak boleh kosong";
                              }
                              if (password.length < 6) {
                                return "Password minimal 6 karakter";
                              }
                              if (!RegExp(r'[A-Z]').hasMatch(password)) {
                                return "Minimal 1 huruf besar";
                              }
                              if (!RegExp(r'[a-z]').hasMatch(password)) {
                                return "Minimal 1 huruf kecil";
                              }
                              if (!RegExp(r'\d').hasMatch(password)) {
                                return "Minimal 1 angka";
                              }
                              if (!RegExp(
                                r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\];\`~+=]',
                              ).hasMatch(password)) {
                                return "Minimal 1 karakter spesial";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 8),

                          // ===== NOMOR TELEPON =====
                          CustomTextField(
                            controller: phoneController,
                            hintText: "Nomor Telepon",
                            prefixIcon: Icons.phone,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final phone = (value ?? '').trim();
                              if (phone.isEmpty) {
                                return "Nomor telepon tidak boleh kosong";
                              }
                              if (!RegExp(r'^\d+$').hasMatch(phone)) {
                                return "Nomor telepon hanya boleh angka";
                              }
                              if (phone.length < 9) {
                                return "Nomor telepon minimal 9 digit";
                              }
                              if (phone.length > 15) {
                                return "Nomor telepon maksimal 15 digit";
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // ===== BUTTON DAFTAR =====
                          CustomButton(
                            text: "Daftar",
                            isLoading: _isLoading,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });

                                await _userController.register(
                                  email: emailController.text,
                                  password: passwordController.text,
                                  phone: phoneController.text,
                                  username: usernameController.text.isNotEmpty
                                      ? usernameController.text
                                      : null,
                                );

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Pendaftaran Berhasil"),
                                  ),
                                );

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const BottomNavbar(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          // ===== ATAU TEXT =====
                          const SizedBox(
                            width: double.infinity,
                            child: Text(
                              "atau daftar dengan",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColor.textHint,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ===== GOOGLE =====
                          CustomButton(
                            text: "Google",
                            isOutlined: true,
                            iconAsset: "assets/icons/google.png",
                            onPressed: () {},
                          ),

                          const Spacer(),

                          // ===== LOGIN =====
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Sudah punya akun? ",
                                style: TextStyle(color: AppColor.textHint),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.push(const LoginScreen());
                                },
                                child: const Text(
                                  "Masuk sekarang",
                                  style: TextStyle(
                                    color: AppColor.primary,
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
            );
          },
        ),
      ),
    );
  }
}
