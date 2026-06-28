import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/gradient_header.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../domain/models/employee.dart';
import '../bloc/info_cubit.dart';

class InfoTab extends StatelessWidget {
  const InfoTab({super.key});

  static const _headerHeight = 156.0;

  static const _avatarAssets = [
    'assets/images/avatar1.png',
    'assets/images/avatar2.png',
    'assets/images/avatar3.png',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final mutedText = onSurface.withValues(alpha: 0.7);
    final subduedIcon = onSurface.withValues(alpha: 0.55);

    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedHeaderDelegate(
            height: _headerHeight,
            child: GradientHeader(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: BlocBuilder<InfoCubit, String>(
                builder: (context, query) {
                  return Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor,
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: context.read<InfoCubit>().updateQuery,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: const Icon(Icons.search_rounded, size: 26),
                        suffixIcon: const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.qr_code_scanner_rounded, size: 24),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        fillColor: Colors.transparent,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: surfaceColor),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, dashboardState) {
            final employees = dashboardState.data?.users ?? const <Employee>[];

            return BlocBuilder<InfoCubit, String>(
              builder: (context, query) {
                final normalized = query.trim().toLowerCase();
                final filtered = employees
                    .where((employee) => employee.matchesQuery(normalized))
                    .toList();

                if (dashboardState.status == DashboardStatus.loading &&
                    employees.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  );
                }

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        normalized.isEmpty
                            ? 'No employee data available.'
                            : 'No results found for "$query".',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                  sliver: SliverList.separated(
                    itemBuilder: (context, index) {
                      final employee = filtered[index];
                      return Container(
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 72,
                                width: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  _avatarAssets[index % _avatarAssets.length],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) {
                                    return Center(
                                      child: Text(
                                        employee.initials,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      employee.displayName,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.4,
                                            fontSize: 17,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Department',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontSize: 14,
                                            color: mutedText,
                                          ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      'Senior Developer - iOS',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: onSurface.withValues(
                                              alpha: 0.82,
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 28,
                                color: subduedIcon,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: filtered.length,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedHeaderDelegate({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
