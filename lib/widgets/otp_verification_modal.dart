import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_cms_demo_app/custom/toast_component.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/repositories/auth_repository.dart';

class OTPVerificationModal extends StatefulWidget {
  final String phoneNumber;
  final String title;
  final String subtitle;
  final void Function(String) onVerificationSuccess;
  final VoidCallback? onCancel;
  final bool isPasswordReset;

  const OTPVerificationModal({
    Key? key,
    required this.phoneNumber,
    required this.title,
    required this.subtitle,
    required this.onVerificationSuccess,
    this.onCancel,
    this.isPasswordReset = false,
  }) : super(key: key);

  @override
  _OTPVerificationModalState createState() => _OTPVerificationModalState();
}

class _OTPVerificationModalState extends State<OTPVerificationModal> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isVerifying = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  String _getOTPCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _verifyOTP() async {
    final otpCode = _getOTPCode();
    
    if (otpCode.length != 6) {
      ToastComponent.showDialog("Please enter complete 6-digit OTP");
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    var response = await AuthRepository().getVerifyOtpResponse(widget.phoneNumber, otpCode);

    setState(() {
      _isVerifying = false;
    });

    if (response.result) {
        ToastComponent.showDialog(response.message);
        Navigator.of(context).pop(); // Close modal
        widget.onVerificationSuccess(otpCode);
    } else {
        ToastComponent.showDialog(response.message);
        _clearOTP();
    }
  }

  void _resendOTP() async {
    if (_resendCountdown > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    dynamic response;
    if (widget.isPasswordReset) {
        response = await AuthRepository().getPasswordForgetResponse(widget.phoneNumber, "phone");
    } else {
        response = await AuthRepository().getOtpRegistrationResponse(widget.phoneNumber);
    }

    setState(() {
      _isResending = false;
    });

    if (response.result) {
        ToastComponent.showDialog("OTP sent successfully!");
        _startResendTimer();
        _clearOTP();
    } else {
        ToastComponent.showDialog(response.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: MyTheme.accent_color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MyTheme.dark_font_grey,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onCancel?.call();
                  },
                  icon: Icon(Icons.close, color: MyTheme.font_grey),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: MyTheme.font_grey,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // SMS delivery info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SMS may take 1-2 minutes to arrive',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Phone number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: MyTheme.soft_accent_color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.phoneNumber,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MyTheme.accent_color,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  height: 50,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MyTheme.dark_font_grey,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: MyTheme.light_grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: MyTheme.accent_color, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                      
                      // Auto-verify when all fields are filled
                      if (index == 5 && value.isNotEmpty) {
                        final otpCode = _getOTPCode();
                        if (otpCode.length == 6) {
                          // Small delay to let user see the complete code
                          Future.delayed(Duration(milliseconds: 300), () {
                            _verifyOTP();
                          });
                        }
                      }
                    },
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 24),
            
            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.accent_color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isVerifying
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Verify OTP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: TextStyle(
                    color: MyTheme.font_grey,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: _resendCountdown == 0 && !_isResending ? _resendOTP : null,
                  child: Text(
                    _resendCountdown > 0
                        ? "Resend in ${_resendCountdown}s"
                        : _isResending
                            ? "Sending..."
                            : "Resend OTP",
                    style: TextStyle(
                      color: _resendCountdown == 0 && !_isResending
                          ? MyTheme.accent_color
                          : MyTheme.font_grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: _resendCountdown == 0 && !_isResending
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
