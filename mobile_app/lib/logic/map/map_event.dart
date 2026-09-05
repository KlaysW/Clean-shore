part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapSpotsRequested extends MapEvent {
  const MapSpotsRequested();
}

class MapFilterChanged extends MapEvent {
  const MapFilterChanged(this.statusFilter);

  final String? statusFilter;

  @override
  List<Object?> get props => [statusFilter];
}

class MapUserLocationRequested extends MapEvent {
  const MapUserLocationRequested();
}