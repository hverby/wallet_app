import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.alias,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  transaction.ticker,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '€ ${_formatEuro(transaction.amount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_formatCrypto(transaction.cryptoAmount)} ${transaction.ticker}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    final color = _getCryptoColor(transaction.ticker);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          transaction.ticker.length >= 2
              ? transaction.ticker.substring(0, 2)
              : transaction.ticker,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  static Color _getCryptoColor(String ticker) {
    final colors = {
      'XRP': const Color(0xFF23292F),
      'ETH': const Color(0xFF627EEA),
      'SOL': const Color(0xFF00FFA3),
      'DOGE': const Color(0xFFC2A633),
      'BTC': const Color(0xFFF7931A),
      'ADA': const Color(0xFF0033AD),
      'DOT': const Color(0xFFE6007A),
      'LINK': const Color(0xFF2A5ADA),
      'LTC': const Color(0xFF345D9D),
      'XLM': const Color(0xFF08B5E5),
      'UNI': const Color(0xFFFF007A),
      'AVAX': const Color(0xFFE84142),
      'MATIC': const Color(0xFF8247E5),
      'ATOM': const Color(0xFF2E3148),
      'ALGO': const Color(0xFF000000),
    };
    return colors[ticker] ?? Colors.grey;
  }

  String _formatEuro(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$intPart.${parts[1]}';
  }

  String _formatCrypto(double amount) {
    if (amount >= 1000) {
      return amount.toStringAsFixed(0);
    } else if (amount >= 1) {
      return amount.toStringAsFixed(6);
    } else {
      return amount.toStringAsFixed(6);
    }
  }
}
