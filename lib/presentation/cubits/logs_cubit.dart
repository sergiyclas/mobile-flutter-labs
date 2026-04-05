import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workspace_guard/data/repositories/logs_repository.dart';

class LogsState {
  final List<LogModel> logs;
  final bool isLoading;
  final String? errorMessage;

  const LogsState({
    this.logs = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  LogsState copyWith({
    List<LogModel>? logs,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LogsState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class LogsCubit extends Cubit<LogsState> {
  final LogsRepository _logsRepository;

  LogsCubit(this._logsRepository) : super(const LogsState());

  Future<void> fetchLogs(String userId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      // Викликаємо репозиторій
      final logs = await _logsRepository.getLogs(userId);
      emit(state.copyWith(logs: logs, isLoading: false));
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error fetching logs: $e',
        ),
      );
    }
  }
}
