import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/gradient_header.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/settings_cubit.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  static const _profileAsset = 'assets/images/avatar5.png';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final isDarkMode = theme.brightness == Brightness.dark;
    final logoutForeground = const Color(0xFFD24A4A);
    final logoutBorder = isDarkMode
        ? logoutForeground.withValues(alpha: 0.72)
        : const Color(0xFFD97C7C);
    final logoutBackground = isDarkMode
        ? logoutForeground.withValues(alpha: 0.12)
        : const Color(0xFFFFF3F3);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  GradientHeader(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                    child: Column(
                      children: [
                        const ProfileAvatar(
                          label: 'AJ',
                          radius: 40,
                          imageAsset: _profileAsset,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppConstants.profileName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppConstants.profileRole,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    child: Transform.translate(
                      offset: const Offset(0, -18),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor,
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.antiAlias,
                          child: BlocBuilder<SettingsCubit, SettingsState>(
                            builder: (context, state) {
                              return Column(
                                children: [
                                  _SettingsTile(
                                    icon: Icons.edit_outlined,
                                    title: 'Edit Profile',
                                    trailing: const Icon(
                                      Icons.chevron_right_rounded,
                                    ),
                                    onTap: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Profile editing is UI-only for this assessment.',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  _SettingsTile(
                                    icon: Icons.notifications_none_rounded,
                                    title: 'Notifications',
                                    trailing: Switch.adaptive(
                                      value: state.notificationsEnabled,
                                      onChanged: context
                                          .read<SettingsCubit>()
                                          .toggleNotifications,
                                      activeTrackColor: const Color(0xFF433DD8),
                                      activeThumbColor: Colors.white,
                                    ),
                                  ),
                                  _SettingsTile(
                                    icon: Icons.dark_mode_outlined,
                                    title: 'Dark Mode',
                                    trailing: Switch.adaptive(
                                      value: state.isDarkMode,
                                      onChanged: context
                                          .read<SettingsCubit>()
                                          .toggleDarkMode,
                                      activeTrackColor: const Color(0xFF433DD8),
                                      activeThumbColor: Colors.white,
                                    ),
                                  ),
                                  _SettingsTile(
                                    icon: Icons.info_outline_rounded,
                                    title: 'App Version',
                                    trailing: Text(
                                      AppConstants.appVersion,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: onSurface.withValues(
                                              alpha: 0.68,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 34),
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(
                          const AuthLogoutRequested(),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        foregroundColor: logoutForeground,
                        side: BorderSide(color: logoutBorder),
                        backgroundColor: logoutBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 0,
          ),
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          trailing: trailing,
          onTap: onTap,
        ),
        if (title != 'App Version')
          Divider(
            height: 1,
            indent: 62,
            endIndent: 18,
            color: Theme.of(context).dividerColor,
          ),
      ],
    );
  }
}
