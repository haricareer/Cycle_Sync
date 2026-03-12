import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _cycleLengthController = TextEditingController();
  final TextEditingController _periodDurationController =
      TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isDoctor = false;
  String? _selectedDesignation;
  final List<String> _designations = [
    'General Physician',
    'Gynaecologist',
    'Obstetrician',
    'Endocrinologist',
    'Dietician',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _header(),
              const SizedBox(height: 30),
              _nameField(),
              const SizedBox(height: 20),
              _emailField(),
              const SizedBox(height: 12),
              _doctorToggleField(),
              const SizedBox(height: 12),
              if (_isDoctor) _designationField(),
              if (_isDoctor) const SizedBox(height: 12),
              if (_isDoctor) _hospitalField(),
              if (_isDoctor) const SizedBox(height: 12),
              if (_isDoctor) _addressField(),
              if (_isDoctor) const SizedBox(height: 12),
              if (_isDoctor) _phoneField(),
              if (_isDoctor) const SizedBox(height: 20),
              if (!_isDoctor)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _ageField()),
                    const SizedBox(width: 12),
                    Expanded(child: _cycleLengthField()),
                    const SizedBox(width: 12),
                    Expanded(child: _periodDurationField()),
                  ],
                ),
              if (!_isDoctor) const SizedBox(height: 20),
              _passwordField(),
              const SizedBox(height: 20),
              _confirmPasswordField(),
              const SizedBox(height: 30),
              _registerButton(),
              const SizedBox(height: 20),
              _loginRedirect(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _header() {
    return Column(
      children: const [
        Icon(Icons.person_add_alt_1, size: 80, color: AppColors.primary),
        SizedBox(height: 12),
        Text(
          "Create Your Account",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ---------------- FIELDS ----------------
  Widget _nameField() {
    return TextFormField(
      controller: _nameController,
      decoration: _inputDecoration(
        hint: "Full Name",
        icon: Icons.person_outline,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Name is required";
        }
        return null;
      },
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

  Widget _ageField() {
    return TextFormField(
      controller: _ageController,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(hint: "Age", icon: Icons.cake_outlined),
    );
  }

  Widget _cycleLengthField() {
    return TextFormField(
      controller: _cycleLengthController,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(
        hint: "Cycle Length",
        icon: Icons.calendar_month,
      ),
    );
  }

  Widget _periodDurationField() {
    return TextFormField(
      controller: _periodDurationController,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(
        hint: "Period Days",
        icon: Icons.water_drop_outlined,
      ),
    );
  }

  Widget _doctorToggleField() {
    return SwitchListTile(
      title: const Text("Register as a Doctor"),
      subtitle: const Text("I want to monitor connected patients"),
      value: _isDoctor,
      activeThumbColor: AppColors.primary,
      onChanged: (val) {
        setState(() {
          _isDoctor = val;
        });
      },
    );
  }

  Widget _designationField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedDesignation,
      decoration: _inputDecoration(
        hint: "Select Designation",
        icon: Icons.medical_services_outlined,
      ),
      items: _designations.map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedDesignation = newValue;
        });
      },
      validator: (value) {
        if (_isDoctor && (value == null || value.isEmpty)) {
          return "Designation is required for doctors";
        }
        return null;
      },
    );
  }

  Widget _hospitalField() {
    return TextFormField(
      controller: _hospitalController,
      decoration: _inputDecoration(
        hint: "Hospital/Clinic Name",
        icon: Icons.local_hospital_outlined,
      ),
      validator: (value) {
        if (_isDoctor && (value == null || value.isEmpty)) {
          return "Hospital name is required for doctors";
        }
        return null;
      },
    );
  }

  Widget _addressField() {
    return TextFormField(
      controller: _addressController,
      decoration: _inputDecoration(
        hint: "Hospital/Clinic Address",
        icon: Icons.location_on_outlined,
      ),
      validator: (value) {
        if (_isDoctor && (value == null || value.isEmpty)) {
          return "Address is required for doctors";
        }
        return null;
      },
    );
  }

  Widget _phoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: _inputDecoration(
        hint: "Contact Number",
        icon: Icons.phone_outlined,
      ),
      validator: (value) {
        if (_isDoctor && (value == null || value.isEmpty)) {
          return "Contact number is required for doctors";
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

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      decoration: _inputDecoration(
        hint: "Confirm Password",
        icon: Icons.lock_outline,
        suffix: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Confirm your password";
        }
        if (value != _passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },
    );
  }

  // ---------------- BUTTON ----------------
  Widget _registerButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        onPressed: _isLoading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    // 1. Create user in Firebase Auth
                    final authService = AuthService();
                    final user = await authService.signUp(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );

                    if (user != null) {
                      // 2. Save user data in Firestore
                      final firestoreService = FirestoreService();
                      final userModel = UserModel(
                        uid: user.uid,
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        age: !_isDoctor
                            ? int.tryParse(_ageController.text.trim())
                            : null,
                        cycleLength: !_isDoctor
                            ? int.tryParse(_cycleLengthController.text.trim())
                            : null,
                        periodDuration: !_isDoctor
                            ? int.tryParse(
                                _periodDurationController.text.trim(),
                              )
                            : null,
                        isDoctor: _isDoctor,
                        designation: _isDoctor ? _selectedDesignation : null,
                        hospital: _isDoctor
                            ? _hospitalController.text.trim()
                            : null,
                        address: _isDoctor
                            ? _addressController.text.trim()
                            : null,
                        phone: _isDoctor ? _phoneController.text.trim() : null,
                      );
                      await firestoreService.saveUser(userModel);

                      // 3. Navigate to verify email
                      if (mounted) {
                        Navigator.pushReplacementNamed(
                          context,
                          '/verify-email',
                        );
                      }
                    }
                  } catch (e) {
                    // Show error
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
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
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Register",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  // ---------------- LOGIN REDIRECT ----------------
  Widget _loginRedirect() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: RichText(
        text: const TextSpan(
          text: "Already have an account? ",
          style: TextStyle(color: AppColors.textSecondary),
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- INPUT DECORATION ----------------
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
    );
  }
}
