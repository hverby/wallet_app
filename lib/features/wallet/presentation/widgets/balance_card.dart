import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/balance.dart';

class BalanceCard extends StatefulWidget {
  final Balance balance;

  const BalanceCard({super.key, required this.balance});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isHidden = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Wallet Balance',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => setState(() => _isHidden = !_isHidden),
                child: Icon(
                  _isHidden ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isHidden ? '••••••' : _formatAmount(widget.balance.amount),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimaryColor,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          _buildAccountPill(),
          const SizedBox(height: 6),
          Text(
            'Virtual Account',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAccountPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFF8F4FC),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              //color: Colors.white,
              /*borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],*/
            ),
            child: const Text(
              'UBA Bank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: '0123456789'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account number copied'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '0123456789',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.copy_rounded, size: 16, color: AppTheme.accentColor),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    final intPart = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '${intPart}F';
  }
}
