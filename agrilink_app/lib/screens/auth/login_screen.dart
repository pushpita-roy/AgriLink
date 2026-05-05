import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.buyer;
  bool _isLoginTab = true;

  final List<String> _bangladeshDivisions = [
    'Barishal', 'Chattogram', 'Dhaka', 'Khulna',
    'Mymensingh', 'Rajshahi', 'Rangpur', 'Sylhet'
  ];

  // This is your shared strict validator (8+ chars, Case sensitive, Special char)
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    final regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[!@#\$&*~]).{8,}$');
    if (!regex.hasMatch(value)) {
      return 'Must be 8+ chars with a-z, A-Z, & a special char (!@#\$&*)';
    }
    return null;
  }

  String? _selectedDivision;

  // Sign Up fields
  final _nameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  UserRole _signupRole = UserRole.buyer;
  bool _obscureSignupPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
      _selectedRole,
    );
    if (success && mounted) {
      _navigateToHome(authProvider.currentUser!.role);
    }
  }

  void _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDivision == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a division')),
      );
      return;
    }
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      name: _nameController.text.trim(),
      email: _signupEmailController.text.trim(),
      password: _signupPasswordController.text,
      role: _signupRole,
      division: _selectedDivision!,
    );
    if (success && mounted) {
      _navigateToHome(authProvider.currentUser!.role);
    }
  }

  void _navigateToHome(UserRole role) {
    switch (role) {
      case UserRole.farmer:
        Navigator.pushReplacementNamed(context, '/farmer-home');
        break;
      case UserRole.buyer:
        Navigator.pushReplacementNamed(context, '/buyer-home');
        break;
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, '/admin-home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.eco, size: 50, color: AppColors.primary);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'AgriLink',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTabBar(),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: _isLoginTab ? _buildLoginForm() : _buildSignUpForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimens.borderRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // FIX: Clear validation and provider errors before switching
                _formKey.currentState?.reset();
                context.read<AuthProvider>().clearError();
                setState(() => _isLoginTab = true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _isLoginTab ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.borderRadius),
                ),
                child: Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _isLoginTab ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // FIX: Clear validation and provider errors before switching
                _formKey.currentState?.reset();
                context.read<AuthProvider>().clearError();
                setState(() => _isLoginTab = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !_isLoginTab ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.borderRadius),
                ),
                child: Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: !_isLoginTab ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm({Key? key}) {
    return Consumer<AuthProvider>(
      key: key,
      builder: (context, auth, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Your Email',
                hintText: 'Enter your registered email',
                prefixIcon: Icon(Icons.email_outlined),
                helperText: ' ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your password';
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                helperText: ' ',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),

            // --- FORGOT PASSWORD BUTTON ---
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Add your forgot password navigation logic here
                },
                child: const Text('Forgot password?'),
              ),
            ),
            // ------------------------------

            if (auth.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  auth.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),
            _buildRolePicker(_selectedRole, (role) { setState(() => _selectedRole = role); }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _handleLogin,
              child: auth.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSignUpForm({Key? key}) {
    return Consumer<AuthProvider>(
      key: key,
      builder: (context, auth, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              validator: (value) => (value == null || value.isEmpty) ? 'Enter name' : null,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                prefixIcon: Icon(Icons.person_outlined),
                // FIX: Reserves space so the field doesn't jump
                helperText: ' ',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signupEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Your Email',
                prefixIcon: Icon(Icons.email_outlined),
                // FIX: Reserves space
                helperText: ' ',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter your email';
                final email = value.trim().toLowerCase();
                if (!(email.endsWith('@gmail.com') || email.endsWith('@yahoo.com') || email.endsWith('@hotmail.com'))) {
                  return 'Only @gmail.com, @yahoo.com, or @hotmail.com allowed';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDivision,
              decoration: const InputDecoration(
                labelText: 'Select Division',
                prefixIcon: Icon(Icons.location_on_outlined),
                // FIX: Dropdowns need space too!
                helperText: ' ',
              ),
              items: _bangladeshDivisions.map((String division) {
                return DropdownMenuItem<String>(value: division, child: Text(division));
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedDivision = newValue),
              validator: (value) => (value == null || value.isEmpty) ? 'Please select your division' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _signupPasswordController,
              obscureText: _obscureSignupPassword,
              decoration: InputDecoration(
                labelText: 'Create Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                // FIX: Reserves space
                helperText: ' ',
                suffixIcon: IconButton(
                  icon: Icon(_obscureSignupPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
                ),
              ),
              validator: _validatePassword,
            ),

            // Auth Provider Global Error
            if (auth.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                auth.errorMessage!,
                style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 16),
            _buildRolePicker(_signupRole, (role) { setState(() => _signupRole = role); }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: auth.isLoading ? null : _handleSignUp,
              child: auth.isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRolePicker(UserRole selectedRole, ValueChanged<UserRole> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select User',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _roleOption('Farmer', Icons.agriculture, UserRole.farmer, selectedRole, onChanged)),
            const SizedBox(width: 8),
            Expanded(child: _roleOption('Buyer', Icons.shopping_bag_outlined, UserRole.buyer, selectedRole, onChanged)),
            const SizedBox(width: 8),
            Expanded(child: _roleOption('Admin', Icons.admin_panel_settings, UserRole.admin, selectedRole, onChanged)),
          ],
        ),
      ],
    );
  }

  Widget _roleOption(String label, IconData icon, UserRole role, UserRole selectedRole, ValueChanged<UserRole> onChanged) {
    final isSelected = role == selectedRole;
    return GestureDetector(
      onTap: () => onChanged(role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}