import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/network_exceptions.dart';
import 'camera_models.dart';
import 'camera_repository.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc({required CameraRepository cameraRepository})
      : _cameraRepository = cameraRepository,
        super(const CameraInitial()) {
    on<CameraModeChanged>(_onModeChanged);
    on<CameraPhotoCaptured>(_onPhotoCaptured);
    on<CameraRetakeRequested>(_onRetakeRequested);
  }

  final CameraRepository _cameraRepository;
  QuestMode _mode = QuestMode.search;

  Future<void> _onModeChanged(
    CameraModeChanged event,
    Emitter<CameraState> emit,
  ) async {
    _mode = event.mode;
    emit(CameraReady(mode: _mode));
  }

  Future<void> _onPhotoCaptured(
    CameraPhotoCaptured event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraAnalyzing(mode: _mode, photoFile: event.photoFile));

    try {
      final photoUrl = await _cameraRepository.uploadPhoto(event.photoFile);

      if (_mode == QuestMode.search) {
        final position = await Geolocator.getCurrentPosition();
        final result = await _cameraRepository.submitSearch(
          lat: position.latitude,
          lon: position.longitude,
          photoUrl: photoUrl,
        );
        emit(CameraSearchResult(result));
      } else {
        if (event.targetSpotId == null) {
          emit(const CameraError('Не выбрана точка загрязнения для уборки'));
          return;
        }
        final result = await _cameraRepository.submitCleanup(
          spotId: event.targetSpotId!,
          photoAfterUrl: photoUrl,
        );
        emit(CameraCleanupResult(result));
      }
    } on AppException catch (e) {
      emit(CameraError(e.message));
    } catch (e) {
      emit(CameraError('Не удалось обработать фото: $e'));
    }
  }

  Future<void> _onRetakeRequested(
    CameraRetakeRequested event,
    Emitter<CameraState> emit,
  ) async {
    emit(CameraReady(mode: _mode));
  }
}