import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/widgets/custom_button.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), Color(0xFFB3E5FC)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                const Spacer(),
                Lottie.asset("assets/animations/Success.json"),
                const SizedBox(height: 28),
                const Text(
                  'Pembayaran Berhasil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Terima kasih, pesanan kamu sudah kami terima dan sedang diproses oleh penjual.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColor.textSecondary,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                CustomButton(
                  text: 'Lihat Riwayat Transaksi',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  backgroundColor: AppColor.primary,
                  textColor: AppColor.surface,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Kembali',
                  isOutlined: true,
                  borderColor: AppColor.primary,
                  textColor: AppColor.primary,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
