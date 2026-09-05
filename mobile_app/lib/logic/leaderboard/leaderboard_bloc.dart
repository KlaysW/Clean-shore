import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/network/network_exceptions.dart';
import '../map/map_models.dart';
import 'leaderboard_repository.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc({required LeaderboardRepository leaderboardRepository})
      : _leaderboardRepository = leaderboardRepository,
        super(const LeaderboardInitial()) {
    on<LeaderboardRequested>(_onRequested);
    on<LeaderboardRegionChanged>(_onRegionChanged);
  }

  final LeaderboardRepository _leaderboardRepository;
  String? _currentRegion;

  Future<void> _onRequested(
    LeaderboardRequested event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(const LeaderboardLoading());
    try {
      final entries = await _leaderboardRepository.getLeaderboard(
        region: _currentRegion,
      );
      emit(LeaderboardLoaded(entries: entries, activeRegion: _currentRegion));
    } on AppException catch (e) {
      emit(LeaderboardError(e.message));
    }
  }

  Future<void> _onRegionChanged(
    LeaderboardRegionChanged event,
    Emitter<LeaderboardState> emit,
  ) async {
    _currentRegion = event.region;
    add(const LeaderboardRequested());
  }
}