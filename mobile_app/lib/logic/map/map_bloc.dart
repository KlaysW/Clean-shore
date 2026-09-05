import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/network/network_exceptions.dart';
import 'map_models.dart';
import 'map_repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required MapRepository mapRepository})
      : _mapRepository = mapRepository,
        super(const MapInitial()) {
    on<MapSpotsRequested>(_onSpotsRequested);
    on<MapFilterChanged>(_onFilterChanged);
    on<MapUserLocationRequested>(_onUserLocationRequested);
  }

  final MapRepository _mapRepository;
  String? _currentFilter;

  Future<void> _onSpotsRequested(
    MapSpotsRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());
    try {
      final spots = await _mapRepository.getSpots(statusFilter: _currentFilter);
      emit(MapLoaded(spots: spots, activeFilter: _currentFilter));
    } on AppException catch (e) {
      emit(MapError(e.message));
    }
  }

  Future<void> _onFilterChanged(
    MapFilterChanged event,
    Emitter<MapState> emit,
  ) async {
    _currentFilter = event.statusFilter;
    add(const MapSpotsRequested());
  }

  Future<void> _onUserLocationRequested(
    MapUserLocationRequested event,
    Emitter<MapState> emit,
  ) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(const MapError('Службы геолокации отключены'));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(const MapError('Доступ к геолокации запрещён'));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(const MapError('Разрешение на геолокацию запрещено навсегда. Включите его в настройках'));
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final currentState = state;
      if (currentState is MapLoaded) {
        emit(currentState.copyWith(
          userLat: position.latitude,
          userLon: position.longitude,
        ));
      }
    } catch (e) {
      emit(MapError('Не удалось определить местоположение: $e'));
    }
  }
}