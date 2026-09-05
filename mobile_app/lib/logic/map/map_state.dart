part of 'map_bloc.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  const MapLoaded({
    required this.spots,
    this.activeFilter,
    this.userLat,
    this.userLon,
  });

  final List<SpotModel> spots;
  final String? activeFilter;
  final double? userLat;
  final double? userLon;

  MapLoaded copyWith({
    List<SpotModel>? spots,
    String? activeFilter,
    double? userLat,
    double? userLon,
  }) {
    return MapLoaded(
      spots: spots ?? this.spots,
      activeFilter: activeFilter ?? this.activeFilter,
      userLat: userLat ?? this.userLat,
      userLon: userLon ?? this.userLon,
    );
  }

  @override
  List<Object?> get props => [spots, activeFilter, userLat, userLon];
}

class MapError extends MapState {
  const MapError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}