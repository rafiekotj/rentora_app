import 'package:flutter/material.dart';
import 'package:rentora_app/controllers/user_controller.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/extensions/navigator.dart';
import 'package:rentora_app/views/auth/register_screen.dart';
import 'package:rentora_app/views/navigation/bottom_navbar.dart';
import 'package:rentora_app/services/notification/onesignal_legacy.dart';
import 'package:rentora_app/widgets/custom_button.dart';
import 'package:rentora_app/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UserController _userController = UserController();

  bool isVisibility = true;
  bool _isLoading = false;

  void visibilityOnOff() {
    setState(() {
      isVisibility = !isVisibility;
    });
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
                          Center(
                            child: Image.asset(
                              "assets/icons/rentora_logo.png",
                              width: 200,
                            ),
                          ),
                          const SizedBox(height: 64),
                          const Text(
                            "Masuk ke Rentora",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
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
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  "Lupa Kata Sandi?",
                                  style: TextStyle(
                                    color: AppColor.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          CustomButton(
                            text: "Masuk",
                            isLoading: _isLoading,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isLoading = true);

                                final bool isSuccess = await _userController
                                    .login(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );
                                if (!mounted) return;
                                if (isSuccess) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Login Berhasil"),
                                    ),
                                  );
                                  try {
                                    final user = await _userController
                                        .getCurrentUser();
                                    if (user?.uid != null) {
                                      await setOneSignalExternalId(user!.uid);
                                    }
                                  } catch (_) {}
                                  context.pushAndRemoveAll(
                                    const BottomNavbar(),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Login Gagal, email atau password salah",
                                      ),
                                    ),
                                  );
                                }
                                setState(() => _isLoading = false);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(
                            width: double.infinity,
                            child: Text(
                              "atau masuk dengan",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColor.textHint,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: "Google",
                            isOutlined: true,
                            iconAsset: "assets/icons/google.png",
                            onPressed: () {},
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Belum punya akun? ",
                                style: TextStyle(color: AppColor.textHint),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.push(const RegisterScreen());
                                },
                                child: const Text(
                                  "Daftar sekarang",
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
