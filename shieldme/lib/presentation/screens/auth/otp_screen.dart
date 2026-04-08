import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/shield_button.dart';

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
  String _errorMessage = '';
  bool _isLoading = false;
  int _resendCountdown = 30;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_resendCountdown > 0) {
          setState(() {
            _resendCountdown--;
          });
        } else {
          setState(() {
            _canResend = true;
          });
          _timer?.cancel();
        }
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    final error = Validators.validateOTP(otp);
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(
      phone: widget.phone,
      otp: otp,
      fullName: widget.fullName,
      referralCode: widget.referralCode,
      isRegister: widget.isRegister,
      context: context,
    );

    setState(() => _isLoading = false);

    if (!success && mounted) {
      setState(() => _errorMessage = authProvider.error ?? 'Code invalide');
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOtp(
      widget.phone,
      isRegister: widget.isRegister,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      setState(() {
        _canResend = false;
        _resendCountdown = 30;
        _errorMessage = '';
      });
      _timer?.cancel();
      _startResendTimer();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau code envoyé!'),
          backgroundColor: AppTheme.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      setState(() {
        _errorMessage = authProvider.error ?? 'Erreur lors de l\'envoi du code';
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        fontFamily: 'Outfit',
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2236) : Colors.white,
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
                    length: AppConstants.otpLength,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        border: Border.all(color: AppTheme.primaryBlue, width: 2),
                      ),
                    ),
                    onCompleted: (pin) => _verifyOtp(),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.dangerRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: AppTheme.dangerRed,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                  ShieldButton(
                    text: 'Vérifier',
                    onPressed: _verifyOtp,
                    isLoading: _isLoading || authProvider.isLoading,
                    icon: Icons.check_circle,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _canResend ? 'Pas reçu? ' : 'Renvoyer dans $_resendCountdown s',
                        style: TextStyle(
                          color: AppTheme.grayLight,
                          fontSize: 13,
                        ),
                      ),
                      if (_canResend)
                        GestureDetector(
                          onTap: _resendOtp,
                          child: Text(
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
                  const SizedBox(height: 16),
                  Text(
                    'Vérifiez vos SMS. Le code expire dans ${AppConstants.otpExpiryMinutes} minutes.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.grayLight,
                    ),
                    textAlign: TextAlign.center,
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