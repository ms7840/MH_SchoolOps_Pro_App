import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/message_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/login_notifier.dart';

/// Interactive login form with real-time validation and error banner.
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final formState = ref.read(loginNotifierProvider);
    _usernameController = TextEditingController(text: formState.username);
    _passwordController = TextEditingController(text: formState.password);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginNotifierProvider);
    final notifier = ref.read(loginNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // General error banner if present
        if (formState.generalError != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0x33EF4444) : AppColors.errorContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radius12),
              border: Border.all(color: AppColors.error.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Text(
                    formState.generalError!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? const Color(0xFFFCA5A5) : AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space20),
        ],

        // Username / Email input
        AppTextField(
          label: MessageConstants.usernameOrEmail,
          hintText: 'Enter username or registered email',
          controller: _usernameController,
          prefixIcon: Icons.person_outline_rounded,
          errorText: formState.usernameError,
          textInputAction: TextInputAction.next,
          onChanged: notifier.setUsername,
        ),
        const SizedBox(height: AppDimensions.space16),

        // Password input with visibility toggle
        AppTextField(
          label: MessageConstants.password,
          hintText: 'Enter your password',
          controller: _passwordController,
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: !formState.isPasswordVisible,
          errorText: formState.passwordError,
          textInputAction: TextInputAction.done,
          onChanged: notifier.setPassword,
          onSubmitted: (_) => notifier.submit(),
          suffixIcon: IconButton(
            icon: Icon(
              formState.isPasswordVisible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            onPressed: notifier.togglePasswordVisibility,
          ),
        ),
        const SizedBox(height: AppDimensions.space28),

        // Submit Button
        AppButton(
          label: MessageConstants.signInButton,
          isLoading: formState.isSubmitting,
          icon: Icons.login_rounded,
          onPressed: () => notifier.submit(),
        ),
      ],
    );
  }
}
