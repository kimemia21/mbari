import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

// Enhanced M-Pesa Payment Dialog with Premium UI
class MpesaPaymentDialog extends StatefulWidget {
  final void Function(String amount, String phoneNumber)? onPaymentSuccess;
  final void Function(String errorMessage)? onPaymentFailure;

  const MpesaPaymentDialog({
    Key? key,
    this.onPaymentSuccess,
    this.onPaymentFailure,
  }) : super(key: key);

  @override
  State<MpesaPaymentDialog> createState() => _MpesaPaymentDialogState();
}

class _MpesaPaymentDialogState extends State<MpesaPaymentDialog>
    with TickerProviderStateMixin {
  // Controllers
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State management
  PaymentState _currentState = PaymentState.form;
  String? _errorMessage;
  String? _checkoutRequestId;
  Timer? _statusCheckTimer;
  int _remainingSeconds = 60;

  // Animations
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late AnimationController _scaleController;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with sample data if needed
    // _phoneNumberController.text = '0712345678';
    // _amountController.text = '500';

    // Setup animations
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _scaleController.dispose();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _remainingSeconds = 60;
    _progressController.forward();

    _statusCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  void _handleTimeout() {
    if (_currentState == PaymentState.waiting) {
      setState(() {
        _currentState = PaymentState.timeout;
        _errorMessage = "Payment request timed out. Please try again.";
      });
      _pulseController.stop();
      _progressController.stop();
    }
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _currentState = PaymentState.processing;
      _errorMessage = null;
    });

    try {
      final data = {
        "phone_number": _phoneNumberController.text.trim(),
        "amount": _amountController.text.trim(),
        "member_id": "123",
        "meeting_id": "456",
      };

      // Simulate API response
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _currentState = PaymentState.waiting;
        _checkoutRequestId = "ws_CO_${DateTime.now().millisecondsSinceEpoch}";
      });

      _pulseController.repeat();
      _startCountdown();
      _startStatusPolling();
    } catch (e) {
      setState(() {
        _currentState = PaymentState.failed;
        _errorMessage = "Connection error. Please check your internet and try again.";
      });
    }
  }

  void _startStatusPolling() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _currentState != PaymentState.waiting) {
        timer.cancel();
        return;
      }

      _checkPaymentStatus();

      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_checkoutRequestId == null) return;

    try {
      // Simulate status check - randomly succeed after some time
      if (Random().nextBool() && _remainingSeconds < 40) {
        _handlePaymentSuccess();
      }
    } catch (e) {
      debugPrint("Status check error: $e");
    }
  }

  void _handlePaymentSuccess() {
    if (_currentState != PaymentState.waiting) return;

    setState(() {
      _currentState = PaymentState.success;
    });

    _pulseController.stop();
    _progressController.stop();
    _statusCheckTimer?.cancel();
    _scaleController.forward();

    HapticFeedback.lightImpact();

    widget.onPaymentSuccess?.call(
      _amountController.text,
      _phoneNumberController.text,
    );
  }

  void _resetToForm() {
    setState(() {
      _currentState = PaymentState.form;
      _errorMessage = null;
      _checkoutRequestId = null;
      _remainingSeconds = 60;
    });

    _pulseController.stop();
    _progressController.reset();
    _scaleController.reset();
    _statusCheckTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WillPopScope(
      onWillPop: () async {
        return _currentState == PaymentState.form ||
            _currentState == PaymentState.success ||
            _currentState == PaymentState.failed ||
            _currentState == PaymentState.timeout;
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final headerColor = _getHeaderColor(colorScheme);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            headerColor.withOpacity(0.9),
            headerColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: headerColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildMpesaLogo(headerColor),
              const Spacer(),
              if (_currentState != PaymentState.processing)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _getHeaderTitle(),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _getHeaderSubtitle(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMpesaLogo(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'M-PESA',
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (_currentState) {
      case PaymentState.form:
        return _buildPaymentForm(context);
      case PaymentState.processing:
        return _buildProcessingState(context);
      case PaymentState.waiting:
        return _buildWaitingState(context);
      case PaymentState.success:
        return _buildSuccessState(context);
      case PaymentState.failed:
      case PaymentState.timeout:
        return _buildErrorState(context);
    }
  }

  Widget _buildPaymentForm(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            icon: Icons.info_outline_rounded,
            title: "How it works",
            message: "Enter your details below. You'll receive a payment prompt on your phone within seconds.",
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),

          _buildInputField(
            context,
            label: "Amount to Contribute",
            controller: _amountController,
            hint: "e.g., 500",
            icon: Icons.payments_rounded,
            keyboardType: TextInputType.number,
            validator: _validateAmount,
            prefix: "KSH ",
          ),
          const SizedBox(height: 20),

          _buildInputField(
            context,
            label: "M-Pesa Phone Number",
            controller: _phoneNumberController,
            hint: "e.g., 0712345678",
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            validator: _validatePhoneNumber,
          ),
          const SizedBox(height: 24),

          _buildInfoCard(
            context,
            icon: Icons.security_rounded,
            title: "Secure Payment",
            message: "Your transaction is protected by M-Pesa's advanced security protocols",
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 32),

          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildProcessingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Processing Payment Request...",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Please wait while we initialize your payment",
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3 + 0.3 * _pulseController.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2 * _pulseController.value),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.3 * value),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.phone_android_rounded,
                        color: colorScheme.onPrimary,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              Text(
                "Check Your Phone! 📱",
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                "Payment request sent to ${_phoneNumberController.text}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 1 - _progressAnimation.value,
                            backgroundColor: colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Time remaining: ${_remainingSeconds}s",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              _buildInfoCard(
                context,
                icon: Icons.lock_rounded,
                title: "Enter your M-Pesa PIN",
                message: "Complete the payment by entering your M-Pesa PIN on your phone",
                color: Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 32),

          Text(
            "Payment Successful! 🎉",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              "Your contribution of KSH ${_amountController.text} has been processed successfully. Thank you for your payment!",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final isTimeout = _currentState == PaymentState.timeout;

    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              isTimeout ? Icons.access_time_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 32),

          Text(
            isTimeout ? "Payment Timeout" : "Payment Failed",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _errorMessage ?? "An unexpected error occurred. Please try again.",
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _resetToForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    String? prefix,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            prefixText: prefix,
            prefixStyle: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _handlePayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.payment_rounded, size: 20, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Pay Now',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (amount < 10) {
      return 'Minimum amount is KSH 10';
    }
    
    if (amount > 300000) {
      return 'Maximum amount is KSH 300,000';
    }
    
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove any spaces or special characters
    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check if it's a valid Kenyan mobile number
    if (cleanNumber.length == 10 && cleanNumber.startsWith('07')) {
      return null; // Valid format: 07XXXXXXXX
    } else if (cleanNumber.length == 12 && cleanNumber.startsWith('2547')) {
      return null; // Valid format: 2547XXXXXXXX
    } else if (cleanNumber.length == 13 && cleanNumber.startsWith('+2547')) {
      return null; // Valid format: +2547XXXXXXXX
    }
    
    return 'Please enter a valid Kenyan mobile number (e.g., 0712345678)';
  }

  Color _getHeaderColor(ColorScheme colorScheme) {
    switch (_currentState) {
      case PaymentState.form:
      case PaymentState.processing:
      case PaymentState.waiting:
        return colorScheme.primary;
      case PaymentState.success:
        return Colors.green;
      case PaymentState.failed:
      case PaymentState.timeout:
        return Colors.red;
    }
  }

  String _getHeaderTitle() {
    switch (_currentState) {
      case PaymentState.form:
        return 'M-Pesa Payment';
      case PaymentState.processing:
        return 'Processing Payment';
      case PaymentState.waiting:
        return 'Payment Sent';
      case PaymentState.success:
        return 'Payment Complete';
      case PaymentState.failed:
        return 'Payment Failed';
      case PaymentState.timeout:
        return 'Payment Timeout';
    }
  }

  String _getHeaderSubtitle() {
    switch (_currentState) {
      case PaymentState.form:
        return 'Enter your details to contribute securely';
      case PaymentState.processing:
        return 'Initializing your payment request';
      case PaymentState.waiting:
        return 'Complete payment on your phone';
      case PaymentState.success:
        return 'Thank you for your contribution';
      case PaymentState.failed:
        return 'Something went wrong with your payment';
      case PaymentState.timeout:
        return 'Payment request has expired';
    }
  }
}

// Payment State Enum
enum PaymentState {
  form,
  processing,
  waiting,
  success,
  failed,
  timeout,
}

// Helper function to show the dialog
Future<void> showMpesaPaymentDialog(
  BuildContext context, {
  void Function(String amount, String phoneNumber)? onPaymentSuccess,
  void Function(String errorMessage)? onPaymentFailure,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: MpesaPaymentDialog(
        onPaymentSuccess: onPaymentSuccess,
        onPaymentFailure: onPaymentFailure,
      ),
    ),
  );
}