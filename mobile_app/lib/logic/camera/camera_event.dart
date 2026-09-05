part of 'camera_bloc.dart';

abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class CameraModeChanged extends CameraEvent {
  const CameraModeChanged(this.mode);

  final QuestMode mode;

  @override
  List<Object?> get props => [mode];
}

class CameraPhotoCaptured extends CameraEvent {
  const CameraPhotoCaptured({required this.photoFile, this.targetSpotId});

  final File photoFile;
  final String? targetSpotId;

  @override
  List<Object?> get props => [photoFile, targetSpotId];
}

class CameraRetakeRequested extends CameraEvent {
  const CameraRetakeRequested();
}