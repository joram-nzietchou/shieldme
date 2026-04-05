import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../providers/auth_provider.dart';

class WalletTab extends StatefulWidget {
  const WalletTab({super.key});

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  bool _isWithdrawLoading = false;

  final List<Map<String, dynamic>> _transactions = [
    {
      'type': 'income',
      'title': 'Marie Ndong s\'est abonnée',
      'amount': 200,
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'description': 'Commission mensuelle parrainage',
    },
    {
      'type': 'income',
      'title': 'Paul Biya a rejoint',
      'amount': 100,
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'description': 'Bonus parrainage',
    },
    {
      'type': 'income',
      'title': 'Bonus bienvenue',
      'amount': 100,
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'description': 'Bienvenue sur ShieldMe',
    },
    {
      'type': 'expense',
      'title': 'Retrait MoMo',
      'amount': 3000,
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'description': 'Retrait vers compte Mobile Money',
    },
  ];

  final Map<String, dynamic> _referralStats = {
    'totalInvited': 23,
    'subscribed': 11,
    'monthlyEarnings': 2200,
    'referralCode': 'SHIELD-NW01',
  };

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer sur MoMo'),
        content:const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Montant disponible: 4,200 FCFA'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Montant à retirer',
                hintText: '0 FCFA',
                prefixIcon: Icon(Icons.money),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Numéro Mobile Money',
                hintText: '+237 6XX XXX XXX',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isWithdrawLoading = true;
              });
              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  _isWithdrawLoading = false;
                });
                _showToast('Demande de retrait envoyée !');
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
            ),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareReferralCode() {
    _showToast('Code copié !');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final walletBalance = user?.walletBalance ?? 4200;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.successGreen, Color(0xFF0B8A60)],
              ),
              borderRadius:BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'MON PORTEFEUILLE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$walletBalance',
                  style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'FCFA',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showWithdrawDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isWithdrawLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('💸 Retirer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.successGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('⭐ Premium'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryBlue,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'MON CODE DE PARRAINAGE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.grayLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _referralStats['referralCode'],
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBlue,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '${AppConstants.referralBonus} FCFA par inscription · ${AppConstants.monthlyCommission} FCFA/mois si abonné',
                    style:TextStyle(
                      fontSize: 11,
                      color: AppTheme.grayLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _shareReferralCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('📤 Partager sur WhatsApp'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _referralStats['totalInvited'].toString(),
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const Text(
                          'Amis invités',
                          style: TextStyle(fontSize: 11, color: AppTheme.grayLight),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _referralStats['subscribed'].toString(),
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.successGreen,
                          ),
                        ),
                        const Text(
                          'Abonnés',
                          style: TextStyle(fontSize: 11, color: AppTheme.grayLight),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _referralStats['monthlyEarnings'].toString(),
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.warningOrange,
                          ),
                        ),
                        const Text(
                          'FCFA/mois',
                          style: TextStyle(fontSize: 11, color: AppTheme.grayLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HISTORIQUE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.grayLight,
                    letterSpacing: 0.8,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Voir tout', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            child: Column(
              children: _transactions.map((tx) => _buildTransactionItem(tx)).toList(),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> tx) {
    final isIncome = tx['type'] == 'income';
    final amountColor = isIncome ? AppTheme.successGreen : AppTheme.dangerRed;
    final amountPrefix = isIncome ? '+' : '-';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderLight)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isIncome ? AppTheme.successGreen : AppTheme.dangerRed).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? AppTheme.successGreen : AppTheme.dangerRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tx['description'],
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.grayLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(tx['date']),
                  style:const TextStyle(
                    fontSize: 10,
                    color: AppTheme.grayLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amountPrefix${tx['amount']} FCFA',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}