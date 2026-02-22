import 'package:flutter/material.dart';
import '../widgets/dashboard_card.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Accounts',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 18),
            _AccountItem(
              icon: Icons.payments_rounded,
              title: 'Cash',
              subtitle: 'Track wallet and physical cash expenses',
            ),
            SizedBox(height: 14),
            _AccountItem(
              icon: Icons.qr_code_scanner_rounded,
              title: 'UPI',
              subtitle: 'Monitor instant payments across UPI apps',
            ),
            SizedBox(height: 14),
            _AccountItem(
              icon: Icons.credit_card_rounded,
              title: 'Credit Cards',
              subtitle: 'Manage card-based spending and bill cycles',
            ),
            SizedBox(height: 14),
            _AccountItem(
              icon: Icons.account_balance_rounded,
              title: 'Bank',
              subtitle: 'Track spending linked to bank accounts',
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  const _AccountItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF202020),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFFE3E3E3)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9A9A9A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
