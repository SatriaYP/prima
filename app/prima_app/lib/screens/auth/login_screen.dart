import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/app_assets.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/prima_button.dart';
import '../../widgets/prima_text_field.dart';
import '../../widgets/prima_logo.dart';
import '../../widgets/responsive_layout.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showPassword = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        print('Login attempt with username: ${_usernameController.text.trim()}');
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        final success = await authProvider.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );
        
        print('Login result: $success');
        print('Auth error: ${authProvider.error}');
        print('Is authenticated: ${authProvider.isAuthenticated}');
        
        if (success && mounted) {
          // Navigate to home screen
          print('Navigating to home screen');
          Navigator.pushReplacementNamed(context, '/home');
        } else if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.error ?? 'Login failed')),
          );
        }
      } catch (e) {
        print('Exception in login button: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to check image paths
    print('Logo path: ${AppAssets.logoHome}');
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ResponsiveLayout(
              mobile: _buildLoginForm(context, authProvider, theme),
              tablet: SizedBox(
                width: 450,
                child: _buildLoginForm(context, authProvider, theme),
              ),
              desktop: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: theme.primaryColor,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Use a SizedBox with fixed dimensions to ensure the logo displays correctly
                            SizedBox(
                              height: 150,
                              width: 300,
                              child: Center(
                                child: Image.asset(
                                  AppAssets.logoHome,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'PRIMA ID',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Membership Management System',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: SizedBox(
                        width: 450,
                        child: _buildLoginForm(context, authProvider, theme),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(
      BuildContext context, AuthProvider authProvider, ThemeData theme) {
    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.enter) {
          _login();
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ResponsiveLayout.isMobile(context) || ResponsiveLayout.isTablet(context)) ...[
            // Use a SizedBox with fixed dimensions to ensure the logo displays correctly
            SizedBox(
              height: 120,
              width: 240,
              child: Center(
                child: Image.asset(
                  AppAssets.logoHome,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'PRIMA ID',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Membership Management System',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
          Text(
            'Login',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          PrimaTextField(
            label: 'Username',
            hint: 'Enter your username',
            controller: _usernameController,
            keyboardType: TextInputType.text,
            // Move to password field when Enter is pressed
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          PrimaTextField(
            label: 'Password',
            hint: 'Enter your password',
            controller: _passwordController,
            obscureText: !_showPassword,
            // Add onFieldSubmitted to handle Enter key press
            onFieldSubmitted: (_) => _login(),
            // Add textInputAction to show the Enter key as a submit action
            textInputAction: TextInputAction.done,
            suffix: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Navigate to forgot password screen
              },
              child: const Text('Forgot Password?'),
            ),
          ),
          const SizedBox(height: 24),
          if (authProvider.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.error),
              ),
              child: Text(
                authProvider.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
            const SizedBox(height: 16),
          ],
          PrimaButton(
            text: 'Login',
            onPressed: _login,
            isLoading: authProvider.isLoading,
            icon: Icons.login,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Don\'t have an account?'),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
