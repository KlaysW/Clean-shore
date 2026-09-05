part of 'leaderboard_bloc.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LeaderboardRequested extends LeaderboardEvent {
  const LeaderboardRequested();
}

class LeaderboardRegionChanged extends LeaderboardEvent {
  const LeaderboardRegionChanged(this.region);

  final String? region;

  @override
  List<Object?> get props => [region];
}