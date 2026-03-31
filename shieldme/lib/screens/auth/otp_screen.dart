import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_header.dart';
import '../../widgets/shield_button.dart';
import '../../themes/app_theme.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String? fullName;
  final String? referralCode;
  final bool isRegister;

  const OTPScreen({
    super.key,
    required this.phone,
    this.fullName,
    this.referralCode,
    required this.isRegister,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() => _errorMessage = 'Veuillez entrer le code à 6 chiffres');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.verifyOTP(
      phone: widget.phone,
      otp: _otpController.text,
      fullName: widget.fullName,
      referralCode: widget.referralCode,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (mounted) {
        // Rediriger vers l'écran principal
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } else {
      setState(() => _errorMessage = result['message'] ?? 'Code invalide');
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.sendOTP(widget.phone);

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau code envoyé!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        fontFamily: 'Outfit',
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A2236)
            : Colors.white,
        border: Border.all(color: AppTheme.grayLight.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          AuthHeader(
            icon: '📲',
            title: 'Code de vérification',
            subtitle: 'Code envoyé au ${widget.phone}',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  Pinput(
                    controller: _otpController,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: AppTheme.primaryBlue, width: 2),
                      ),
                    ),
                    onCompleted: (pin) => _verifyOTP(),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: AppTheme.dangerRed, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 32),
                  ShieldButton(
                    text: 'Vérifier',
                    onPressed: _verifyOTP,
                    isLoading: _isLoading,
                    icon: Icons.check_circle,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas reçu? ',
                        style: TextStyle(
                          color: AppTheme.grayLight,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: _resendOTP,
                        child: const Text(
                          'Renvoyer le code',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}