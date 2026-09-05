part of 'camera_bloc.dart';

abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {
  const CameraInitial();
}

class CameraReady extends CameraState {
  const CameraReady({required this.mode});

  final QuestMode mode;

  @override
  List<Object?> get props => [mode];
}

class CameraAnalyzing extends CameraState {
  const CameraAnalyzing({required this.mode, required this.photoFile});

  final QuestMode mode;
  final File photoFile;

  @override
  List<Object?> get props => [mode, photoFile];
}

class CameraSearchResult extends CameraState {
  const CameraSearchResult(this.result);

  final SpotSearchResultModel result;

  @override
  List<Object?> get props => [result];
}

class CameraCleanupResult extends CameraState {
  const CameraCleanupResult(this.result);

  final SpotCleanupResultModel result;

  @override
  List<Object?> get props => [result];
}

class CameraError extends CameraState {
  const CameraError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}