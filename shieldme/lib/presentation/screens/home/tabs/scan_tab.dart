import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/threat_model.dart';

class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final TextEditingController _urlController = TextEditingController();
  bool _isScanning = false;
  ThreatModel? _lastScanResult;
  final List<Map<String, dynamic>> _scanHistory = [];

  final List<String> _maliciousDomains = [
    'mtn-momo-verify.tk',
    'orangemoney-update.cf',
    'camtel-secure.ga',
    'momo-prize.xyz',
  ];

  Future<void> _scanUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showToast('Veuillez entrer un lien à scanner');
      return;
    }

    setState(() {
      _isScanning = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    final isMalicious = _checkIfMalicious(url);
    final threatType = isMalicious ? ThreatType.scam : ThreatType.safe;
    final verdictColor = isMalicious ? AppTheme.dangerRed : AppTheme.successGreen;
    final verdictIcon = isMalicious ? '🚨' : '✅';
    final verdictText = isMalicious ? 'DANGEREUX' : 'SÉCURISÉ';

    final result = ThreatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: threatType,
      category: ThreatCategory.link,
      sender: _extractDomain(url),
      content: isMalicious 
          ? 'Ce lien est une tentative de phishing. Il impersonne MTN MoMo pour voler vos identifiants.'
          : 'Ce lien semble sécurisé. Aucune menace détectée.',
      url: url,
      timestamp: DateTime.now(),
      isBlocked: false,
    );

    setState(() {
      _lastScanResult = result;
      _isScanning = false;
      _scanHistory.insert(0, {
        'url': url,
        'isMalicious': isMalicious,
        'date': DateTime.now(),
      });
    });

    _showToast(isMalicious ? '⚠️ Lien dangereux détecté !' : '✅ Lien sécurisé');
  }

  bool _checkIfMalicious(String url) {
    final lowerUrl = url.toLowerCase();
    for (final domain in _maliciousDomains) {
      if (lowerUrl.contains(domain)) {
        return true;
      }
    }
    return false;
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.tryParse(url);
      if (uri != null && uri.host.isNotEmpty) {
        return uri.host;
      }
      return url.split('/').first;
    } catch (e) {
      return url;
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('dangereux') ? AppTheme.dangerRed : AppTheme.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} j';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SCANNER DE LIENS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.grayLight,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'Collez un lien ici pour vérifier...',
                    prefixIcon: const Icon(Icons.link),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A2236) : const Color(0xFFF8FAFF),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _scanUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isScanning
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('🔍 Scanner maintenant'),
                  ),
                ),
              ],
            ),
          ),
          if (_lastScanResult != null) ...[
            const SizedBox(height: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _lastScanResult!.verdictColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _lastScanResult!.verdictColor),
              ),
              child: Column(
                children: [
                  Text(
                    _lastScanResult!.verdictIcon,
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastScanResult!.verdictText,
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: _lastScanResult!.verdictColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _lastScanResult!.sender,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.grayLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _lastScanResult!.content,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'HISTORIQUE DES SCANS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.grayLight,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          if (_scanHistory.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text('🔍', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 16),
                    Text('Aucun scan'),
                    Text('Scannez votre premier lien pour voir l\'historique'),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _scanHistory.length > 10 ? 10 : _scanHistory.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _scanHistory[index];
                final isMalicious = item['isMalicious'];
                return ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (isMalicious ? AppTheme.dangerRed : AppTheme.successGreen)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(isMalicious ? '🚨' : '✅', style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  title: Text(
                    _extractDomain(item['url']),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    item['url'].length > 40 ? '${item['url'].substring(0, 40)}...' : item['url'],
                    style: const TextStyle(fontSize: 11, color: AppTheme.grayLight),
                  ),
                  trailing: Text(
                    _formatDate(item['date']),
                    style:const TextStyle(fontSize: 11, color: AppTheme.grayLight),
                  ),
                  onTap: () {
                    _urlController.text = item['url'];
                    _scanUrl();
                  },
                );
              },
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}