import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/extensions/navigator_extension.dart';
import 'package:rentora_app/models/user_model.dart';
import 'package:rentora_app/services/database/db_helper.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';
import 'package:rentora_app/views/auth/register_screen.dart';
import 'package:rentora_app/views/home/bottom_navbar.dart';
import 'package:rentora_app/widgets/custom_button.dart';
import 'package:rentora_app/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isVisibility = true;

  void visibilityOnOff() {
    isVisibility = !isVisibility;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColor.backgroundLight,
      body: SingleChildScrollView(
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewInsets.bottom,
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final UserModel? login = await DBHelper.loginUser(
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        if (login != null) {
                          PreferenceHandler().storingIsLogin(true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Login Berhasil")),
                          );
                          await Future.delayed(Duration(seconds: 2));
                          context.push(BottomNavbar());
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Login Gagal, email atau password salah",
                              ),
                            ),
                          );
                        }
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

                  const SizedBox(height: 8),

                  CustomButton(
                    text: "Facebook",
                    isOutlined: true,
                    iconAsset: "assets/icons/facebook_round.png",
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
                          context.push(RegisterPage());
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
  }
}
