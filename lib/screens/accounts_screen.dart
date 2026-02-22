import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import '../widgets/dashboard_card.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverSafeArea(
          top: false,
          sliver: SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                const _AccountItem(
                  icon: Icons.payments_rounded,
                  title: 'Cash',
                  subtitle: 'Track wallet and physical cash expenses',
                ),
                const SizedBox(height: 14),
                const _AccountItem(
                  icon: Icons.qr_code_rounded,
                  title: 'UPI',
                  subtitle: 'Monitor instant payments across UPI apps',
                ),
                const SizedBox(height: 14),
                const _AccountItem(
                  icon: Icons.credit_card_rounded,
                  title: 'Credit Cards',
                  subtitle: 'Manage card-based spending and bill cycles',
                ),
                const SizedBox(height: 14),
                const _AccountItem(
                  icon: Icons.account_balance_rounded,
                  title: 'Bank',
                  subtitle: 'Track spending linked to bank accounts',
                ),
              ]),
            ),
          ),
        ),
      ],
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
              color: CupertinoColors.tertiarySystemFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: CupertinoColors.secondaryLabel,
                    fontSize: 13,
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
