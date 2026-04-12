import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coin_provider.dart';
import '../theme/app_theme.dart';

class CoinDisplay extends StatelessWidget {
  const CoinDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final coins = context.watch<CoinProvider>().coins;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.monetization_on, color: AppColors.coin, size: 20),
          const SizedBox(width: 4),
          Text(
            '$coins',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
