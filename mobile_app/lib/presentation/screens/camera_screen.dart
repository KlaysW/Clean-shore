import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/camera/camera_bloc.dart';
import '../../logic/camera/camera_models.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.initialMode,
    this.targetSpotId,
  });

  final QuestMode initialMode;
  final String? targetSpotId;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  late QuestMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    context.read<CameraBloc>().add(CameraModeChanged(_mode));
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();

      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isCameraReady = false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final xFile = await _controller!.takePicture();

    if (!mounted) return;

    context.read<CameraBloc>().add(
          CameraPhotoCaptured(
            photoFile: File(xFile.path),
            targetSpotId: widget.targetSpotId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<CameraBloc, CameraState>(
        listener: (context, state) {
          if (state is CameraSearchResult || state is CameraCleanupResult) {
            _showResultModal(context, state);
          }
        },
        builder: (context, state) {
          return Stack(
            fit: StackFit.expand,
            children: [
              if (_isCameraReady && _controller != null)
                CameraPreview(_controller!)
              else
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              _buildScanGridOverlay(),

              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(context),
                    const Spacer(),
                    if (state is! CameraAnalyzing) _buildBottomControls(state),
                    if (state is CameraAnalyzing) _buildAnalyzingIndicator(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          if (widget.targetSpotId == null)
            _ModeToggle(
              mode: _mode,
              onChanged: (mode) {
                setState(() => _mode = mode);
                context.read<CameraBloc>().add(CameraModeChanged(mode));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildScanGridOverlay() {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ScanGridPainter(),
      ),
    );
  }

  Widget _buildBottomControls(CameraState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: state is CameraAnalyzing ? null : _capturePhoto,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Анализируем изображение...',
            style: AppTextStyles.bodyRegular.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showResultModal(BuildContext context, CameraState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AnalysisResultSheet(
        state: state,
        onRetake: () {
          Navigator.pop(context);
          context.read<CameraBloc>().add(const CameraRetakeRequested());
        },
        onDone: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});

  final QuestMode mode;
  final ValueChanged<QuestMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment('Поиск', QuestMode.search),
          _segment('Уборка', QuestMode.cleanup),
        ],
      ),
    );
  }

  Widget _segment(String label, QuestMode value) {
    final isActive = mode == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreenEnd : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ScanGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    const divisions = 3;
    for (int i = 1; i < divisions; i++) {
      final dx = size.width / divisions * i;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), paint);

      final dy = size.height / divisions * i;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnalysisResultSheet extends StatelessWidget {
  const _AnalysisResultSheet({
    required this.state,
    required this.onRetake,
    required this.onDone,
  });

  final CameraState state;
  final VoidCallback onRetake;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    int score = 0;
    List<String> materials = [];
    int ratingAwarded = 0;
    bool isDuplicate = false;

    if (state is CameraSearchResult) {
      final result = (state as CameraSearchResult).result;
      score = result.spot.pollutionScoreBefore ?? 0;
      materials = result.spot.detectedMaterials ?? [];
      ratingAwarded = result.ratingAwarded;
      isDuplicate = result.isDuplicate;
    } else if (state is CameraCleanupResult) {
      final result = (state as CameraCleanupResult).result;
      score = result.spot.pollutionScoreAfter ?? 0;
      materials = result.spot.detectedMaterials ?? [];
      ratingAwarded = result.ratingAwarded;
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDuplicate)
            Text(
              'Эта точка уже отмечена другим пользователем',
              style: AppTextStyles.bodyRegular.copyWith(color: AppColors.warningAmber),
            )
          else ...[
            Center(
              child: Text('$score / 100', style: AppTextStyles.scoreReadout),
            ),
            const SizedBox(height: 12),
            Text(
              'Обнаружено: ${materials.isEmpty ? "загрязнений не найдено" : materials.join(", ")}',
              style: AppTextStyles.bodyRegular,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '+$ratingAwarded баллов',
                style: AppTextStyles.heading3.copyWith(color: AppColors.successGreen),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetake,
                  child: const Text('Переснять'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDone,
                  child: const Text('Готово'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}