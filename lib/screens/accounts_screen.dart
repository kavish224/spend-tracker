import 'package:flutter/cupertino.dart';
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                const _AccountItem(
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  title: 'Cash',
                  subtitle: 'Track wallet and physical cash expenses',
                ),
                const SizedBox(height: 14),
                const _AccountItem(
                  icon: CupertinoIcons.qrcode,
                  title: 'UPI',
                  subtitle: 'Monitor instant payments across UPI apps',
                ),
                const SizedBox(height: 14),
                const _AccountItem(
                  icon: CupertinoIcons.creditcard_fill,
                  title: 'Credit Cards',
                  subtitle: 'Manage card-based spending and bill cycles',
                ),
                const SizedBox(height: 14),
                const _AccountItem(
                  icon: CupertinoIcons.building_2_fill,
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
