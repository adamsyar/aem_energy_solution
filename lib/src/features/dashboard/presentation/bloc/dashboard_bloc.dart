import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/dashboard_repository.dart';
import '../../domain/models/dashboard_data.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required this._repository}) : super(const DashboardState()) {
    on<DashboardRequested>(_onRequested);
  }

  final DashboardRepository _repository;

  Future<void> _onRequested(
    DashboardRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading, errorMessage: null));

    try {
      final data = await _repository.fetchDashboard(token: event.token);
      emit(
        state.copyWith(
          status: DashboardStatus.success,
          data: data,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
