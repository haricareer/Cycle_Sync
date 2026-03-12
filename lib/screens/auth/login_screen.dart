import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 40),
              _loginForm(),
              const SizedBox(height: 30),
              _loginButton(),
              const SizedBox(height: 20),
              _registerText(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.loginTitle,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.loginSubtitle,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ---------------- FORM ----------------
  Widget _loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [_emailField(), const SizedBox(height: 20), _passwordField()],
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(
        hint: AppStrings.emailHint,
        icon: Icons.email_outlined,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email is required";
        }
        if (!value.contains('@')) {
          return "Enter a valid email";
        }
        return null;
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: _inputDecoration(
        hint: AppStrings.passwordHint,
        icon: Icons.lock_outline,
        suffix: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password is required";
        }
        if (value.length < 6) {
          return "Password must be at least 6 characters";
        }
        return null;
      },
    );
  }

  // ---------------- BUTTON ----------------
  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    final user = await _authService.login(
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                    );

                    if (user != null && mounted) {
                      if (user.emailVerified) {
                        final userModel = await FirestoreService().getUser(
                          user.uid,
                        );
                        if (!mounted) return;
                        if (userModel != null && userModel.isDoctor) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/doctor-home',
                            (route) => false,
                          );
                        } else {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        }
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/verify-email',
                          (route) => false,
                        );
                      }
                    }
                  } on AuthException catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('An error occurred. Please try again.'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }
              },
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : const Text(
                AppStrings.loginButton,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // ---------------- REGISTER ----------------
  Widget _registerText() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/register');
        },
        child: RichText(
          text: const TextSpan(
            text: "${AppStrings.noAccount} ",
            style: TextStyle(color: AppColors.textSecondary),
            children: [
              TextSpan(
                text: AppStrings.register,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- DECORATION ----------------
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: AppColors.error),
    );
  }
}
