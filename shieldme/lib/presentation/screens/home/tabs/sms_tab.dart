import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/threat_model.dart';

class SmsTab extends StatefulWidget {
  const SmsTab({super.key});

  @override
  State<SmsTab> createState() => _SmsTabState();
}

class _SmsTabState extends State<SmsTab> with SingleTickerProviderStateMixin {
  bool _autoDetection = true;
  late TabController _tabController;

  final List<ThreatModel> _smsList = [
    ThreatModel(
      id: '1',
      type: ThreatType.scam,
      category: ThreatCategory.sms,
      sender: 'MTN Alertes',
      content: 'Votre compte MoMo sera bloqué. Cliquez pour vérifier: bit.ly/mtn-verify',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isBlocked: true,
    ),
    ThreatModel(
      id: '2',
      type: ThreatType.suspect,
      category: ThreatCategory.sms,
      sender: '+237 699 123 456',
      content: 'Félicitations! Vous avez gagné un iPhone 15. Réclamez maintenant...',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isBlocked: false,
    ),
    ThreatModel(
      id: '3',
      type: ThreatType.safe,
      category: ThreatCategory.sms,
      sender: 'Orange Money',
      content: 'Vous avez reçu 5,000 FCFA de Jean Kamga. Solde: 12,500 FCFA',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isBlocked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PROTECTION SMS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.grayLight,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Détection automatique',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Analyse chaque SMS entrant',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.grayLight,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _autoDetection,
                      onChanged: (value) {
                        setState(() {
                          _autoDetection = value;
                        });
                      },
                      activeColor: AppTheme.successGreen,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                ),
                child: const Row(
                  children: [
                    Text('📊', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '247 SMS analysés ce mois · 3 arnaques détectées',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.grayLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: AppTheme.grayLight,
            indicatorColor: AppTheme.primaryBlue,
            tabs: const [
              Tab(text: 'Tous'),
              Tab(text: 'Dangereux'),
              Tab(text: 'Sécurisés'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSmsList(_smsList),
              _buildSmsList(_smsList.where((s) => s.type != ThreatType.safe).toList()),
              _buildSmsList(_smsList.where((s) => s.type == ThreatType.safe).toList()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmsList(List<ThreatModel> smsList) {
    if (smsList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📭', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('Aucun SMS'),
            Text('Aucun SMS trouvé dans cette catégorie'),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: smsList.length,
      itemBuilder: (context, index) {
        final sms = smsList[index];
        return _buildSmsItem(sms);
      },
    );
  }

  Widget _buildSmsItem(ThreatModel sms) {
    return GestureDetector(
      onTap: () => _showSmsDetails(sms),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.borderDark
                : AppTheme.borderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: sms.verdictColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(sms.verdictIcon, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sms.sender,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sms.content,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.grayLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(sms.timestamp),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.grayLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: sms.verdictColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                sms.verdictText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: sms.verdictColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSmsDetails(ThreatModel sms) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: sms.verdictColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(sms.verdictIcon, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sms.sender,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          sms.verdictText,
                          style: TextStyle(
                            fontSize: 12,
                            color: sms.verdictColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1A2236)
                      : const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  sms.content,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _formatDate(sms.timestamp),
                style: TextStyle(fontSize: 12, color: AppTheme.grayLight),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (sms.type != ThreatType.safe)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _showToast('Expéditeur bloqué avec succès');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.dangerRed,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Bloquer l\'expéditeur'),
                      ),
                    ),
                  if (sms.type != ThreatType.safe) const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Fermer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}