import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/core/extensions/navigator.dart';
import 'package:rentora_app/services/local_storage/preference_handler.dart';
import 'package:rentora_app/services/notification/onesignal_legacy.dart';
import 'package:rentora_app/views/auth/login_screen.dart';
import 'package:rentora_app/views/user_account/account_setting_screen.dart';
import 'package:rentora_app/widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: Text(
          "Pengaturan",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              text: "Pengaturan Akun",
              isOutlined: true,
              onPressed: () {
                context.push(const AccountSettingScreen());
              },
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: "Keluar",
              isOutlined: true,
              onPressed: () async {
                try {
                  await removeOneSignalExternalId();
                } catch (_) {}

                await PreferenceHandler().deleteIsLogin();
                context.pushAndRemoveAll(LoginScreen());
              },
            ),
          ],
        ),
      ),
    );
  }
}
