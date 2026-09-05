part of 'leaderboard_bloc.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {
  const LeaderboardInitial();
}

class LeaderboardLoading extends LeaderboardState {
  const LeaderboardLoading();
}

class LeaderboardLoaded extends LeaderboardState {
  const LeaderboardLoaded({required this.entries, this.activeRegion});

  final List<LeaderboardEntryModel> entries;
  final String? activeRegion;

  List<LeaderboardEntryModel> get topThree => entries.take(3).toList();
  List<LeaderboardEntryModel> get restOfList => entries.skip(3).toList();

  @override
  List<Object?> get props => [entries, activeRegion];
}

class LeaderboardError extends LeaderboardState {
  const LeaderboardError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}