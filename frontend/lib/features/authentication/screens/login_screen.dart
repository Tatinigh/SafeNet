import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        final error = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Login failed'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  void _handleGoogleLogin() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
    if (mounted) {
      context.go('/home');
    }
  }

  void _handleGuestLogin() {
    ref.read(authProvider.notifier).signInAsGuest();
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                : [const Color(0xFFEFF6FF), const Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    // Logo Icon Painter
                    const Center(child: ShieldBrainLogo(size: 110)),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      'SafeNet AI',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'AI-Powered Digital Safety Assistant',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password text
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Show forgot password alert dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: AppTheme.cardBorderRadius),
                              title: const Text('Reset Password'),
                              content: const Text(
                                'A password reset link will be sent to your email address shortly if it is registered.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.inter(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email Login Button
                    ElevatedButton(
                      onPressed: authState.isLoading ? null : _handleEmailLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                        elevation: 6,
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: 16),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textLightColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Google Login Button
                    OutlinedButton.icon(
                      onPressed: authState.isLoading ? null : _handleGoogleLogin,
                      icon: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/24px-Google_%22G%22_logo.svg.png',
                        height: 20,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 28),
                      ),
                      label: const Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Guest Login Button
                    TextButton(
                      onPressed: authState.isLoading ? null : _handleGuestLogin,
                      child: Text(
                        'Continue as Guest',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painted glowing brain circuit shield logo.
/// Matches Image 5 logo design.
class ShieldBrainLogo extends StatelessWidget {
  final double size;

  const ShieldBrainLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.04),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size(size * 0.7, size * 0.7),
        painter: _ShieldBrainPainter(),
      ),
    );
  }
}

class _ShieldBrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;

    // Draw external Shield
    final shieldPath = Path();
    shieldPath.moveTo(width * 0.5, 0);
    shieldPath.quadraticBezierTo(width * 0.85, height * 0.05, width * 0.9, height * 0.15);
    shieldPath.quadraticBezierTo(width * 0.95, height * 0.5, width * 0.5, height * 0.95);
    shieldPath.quadraticBezierTo(width * 0.05, height * 0.5, width * 0.1, height * 0.15);
    shieldPath.quadraticBezierTo(width * 0.15, height * 0.05, width * 0.5, 0);
    shieldPath.close();

    // Dark Blue Shield Outline
    paint.color = AppTheme.primaryColor;
    canvas.drawPath(shieldPath, paint);

    // Glowing Inner Brain Lines
    final innerPaint = Paint()
      ..color = AppTheme.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Left hemisphere outline
    final brainPath = Path();
    brainPath.moveTo(width * 0.5, height * 0.25);
    brainPath.cubicTo(width * 0.3, height * 0.2, width * 0.25, height * 0.45, width * 0.35, height * 0.55);
    brainPath.cubicTo(width * 0.25, height * 0.65, width * 0.35, height * 0.75, width * 0.5, height * 0.7);

    // Right hemisphere outline
    brainPath.moveTo(width * 0.5, height * 0.25);
    brainPath.cubicTo(width * 0.7, height * 0.2, width * 0.75, height * 0.45, width * 0.65, height * 0.55);
    brainPath.cubicTo(width * 0.75, height * 0.65, width * 0.65, height * 0.75, width * 0.5, height * 0.7);

    canvas.drawPath(brainPath, innerPaint);

    // Dynamic node dots
    final dotPaint = Paint()..color = AppTheme.secondaryColor..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(width * 0.32, height * 0.38), 3.0, dotPaint);
    canvas.drawCircle(Offset(width * 0.68, height * 0.38), 3.0, dotPaint);
    canvas.drawCircle(Offset(width * 0.42, height * 0.62), 2.5, dotPaint);
    canvas.drawCircle(Offset(width * 0.58, height * 0.62), 2.5, dotPaint);
    
    // Center Core Connection
    canvas.drawCircle(Offset(width * 0.5, height * 0.45), 4.5, Paint()..color = AppTheme.primaryColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
