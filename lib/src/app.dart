import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/storage/app_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/dashboard/data/dashboard_repository.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/pages/main_shell_page.dart';
import 'features/info/presentation/bloc/info_cubit.dart';
import 'features/navigation/presentation/bloc/navigation_cubit.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';

class AemEnergyApp extends StatelessWidget {
  const AemEnergyApp({
    super.key,
    required this.storage,
    required this.authRepository,
    required this.dashboardRepository,
  });

  final AppStorage storage;
  final AuthRepository authRepository;
  final DashboardRepository dashboardRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: storage),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: dashboardRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AuthBloc(authRepository: authRepository)
                  ..add(const AuthStarted()),
          ),
          BlocProvider(
            create: (_) => SettingsCubit(storage: storage)..loadPreferences(),
          ),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              title: 'AEM Energy Solution',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: settingsState.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: const _AppView(),
            );
          },
        ),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const _SplashPage();
          case AuthStatus.unauthenticated:
            return const LoginPage();
          case AuthStatus.authenticated:
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) =>
                      DashboardBloc(
                        repository: context.read<DashboardRepository>(),
                      )..add(
                        DashboardRequested(
                          token: context.read<AuthBloc>().state.token ?? '',
                        ),
                      ),
                ),
                BlocProvider(create: (_) => NavigationCubit()),
                BlocProvider(create: (_) => InfoCubit()),
              ],
              child: const MainShellPage(),
            );
        }
      },
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary,
              colors.primary.withValues(alpha: 0.85),
              colors.surface,
            ],
          ),
        ),
        child: const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
