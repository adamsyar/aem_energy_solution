import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/gradient_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/models/chart_item.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/bar_chart_card.dart';
import '../widgets/donut_chart_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  void _requestDashboard(BuildContext context) {
    final token = context.read<AuthBloc>().state.token ?? '';
    context.read<DashboardBloc>().add(DashboardRequested(token: token));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null &&
          current.data != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final data = state.data;
          final mediaQuery = MediaQuery.of(context);
          final screenHeight = mediaQuery.size.height;
          final topPadding = mediaQuery.padding.top;
          final horizontalPadding = screenHeight < 750 ? 22.0 : 28.0;
          final headerHeight = (screenHeight * 0.26).clamp(210.0, 250.0);
          final cardsTopInset = (headerHeight - 44).clamp(156.0, 190.0);
          final headerBottomPadding = (headerHeight * 0.42).clamp(88.0, 108.0);

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: headerHeight,
                  child: GradientHeader(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      topPadding > 0 ? 14 : 18,
                      24,
                      headerBottomPadding,
                    ),
                    child: const Center(child: _HeaderTitle()),
                  ),
                ),
              ),
              RefreshIndicator(
                onRefresh: () async => _requestDashboard(context),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: cardsTopInset)),
                    if (state.status == DashboardStatus.loading && data == null)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      )
                    else if (state.status == DashboardStatus.failure &&
                        data == null)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          24,
                        ),
                        sliver: SliverFillRemaining(
                          hasScrollBody: false,
                          child: _DashboardErrorState(
                            message:
                                state.errorMessage ??
                                'Unable to load dashboard data.',
                            onRetry: () => _requestDashboard(context),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          24,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: [
                              BarChartCard(
                                items: data?.chartBar ?? const <ChartItem>[],
                              ),
                              const SizedBox(height: 22),
                              DonutChartCard(
                                items: data?.chartDonut ?? const <ChartItem>[],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 42,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 14),
                Text(
                  'Unable to Load Dashboard',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    child: const Text('Try Again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, ${AppConstants.profileShortName}',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.8,
      ),
    );
  }
}
