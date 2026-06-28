import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'user@aemenersol.com');
  final _passwordController = TextEditingController(text: 'Test@123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthBloc>().add(
      AuthLoginSubmitted(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final headingColor = colors.onSurface;
    final secondaryTextColor = colors.onSurface.withValues(alpha: 0.76);
    final tertiaryTextColor = colors.onSurface.withValues(alpha: 0.68);
    final buttonShadow = colors.primary.withValues(
      alpha: isDarkMode ? 0.34 : 0.24,
    );

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: 420,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 78),
                          const _LogoBadge(),
                          const SizedBox(height: 60),
                          Text(
                            'Welcome Back',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              color: headingColor,
                            ),
                          ),
                          const SizedBox(height: 40),
                          _AuthInput(
                            controller: _emailController,
                            hintText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.mail_outline_rounded,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              final emailRegex = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );
                              if (text.isEmpty) {
                                return 'Email is required.';
                              }
                              if (!emailRegex.hasMatch(text)) {
                                return 'Enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          _AuthInput(
                            controller: _passwordController,
                            hintText: 'Password',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: tertiaryTextColor,
                              ),
                            ),
                            validator: (value) {
                              if ((value ?? '').isEmpty) {
                                return 'Password is required.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 42),
                          BlocBuilder<AuthBloc, AuthState>(
                            buildWhen: (previous, current) =>
                                previous.isSubmitting != current.isSubmitting,
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFF4B4CF1),
                                        Color(0xFF2E34D4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: buttonShadow,
                                        blurRadius: 18,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: state.isSubmitting
                                        ? null
                                        : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          Colors.transparent,
                                      disabledForegroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      minimumSize: const Size.fromHeight(60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: state.isSubmitting
                                        ? const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.3,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 18),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: secondaryTextColor,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(top: 42, bottom: 22),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: const [
                                  TextSpan(text: 'Don’t have an account? '),
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: TextStyle(
                                      color: Color(0xFF3941D4),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A4BF2), Color(0xFF2F35D6)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x223942D8),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'DevCorp',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}

class _AuthInput extends StatelessWidget {
  const _AuthInput({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.textInputAction,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 19,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.55),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.55),
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE15C54)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE15C54), width: 1.4),
        ),
      ),
    );
  }
}
