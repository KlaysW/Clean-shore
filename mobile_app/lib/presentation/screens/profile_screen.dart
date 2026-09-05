import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/auth/auth_bloc.dart';
import '../../logic/auth/auth_models.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _contactOopt() async {
    final uri = Uri.parse('mailto:oopt@clean-shore.example.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildHeaderCard(user),
              const SizedBox(height: 24),
              _buildStatsGrid(user),
              const SizedBox(height: 24),
              if (user.isOoptStaff) _buildOoptCard(context),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  icon: const Icon(Icons.logout, color: AppColors.dangerRed),
                  label: Text(
                    'Выйти',
                    style: AppTextStyles.bodyRegular.copyWith(color: AppColors.dangerRed),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.dangerRed),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.chipBackground,
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    user.nickname.isNotEmpty ? user.nickname[0].toUpperCase() : '?',
                    style: AppTextStyles.heading1,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nickname, style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(user.email, style: AppTextStyles.bodySecondary),
                if (user.isOoptStaff) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreenEnd.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Сотрудник ООПТ',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryGreenEnd,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserModel user) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        _StatCard(
          label: 'Найдено загрязнений',
          value: '${user.spotsFoundCount}',
          icon: Icons.search,
        ),
        _StatCard(
          label: 'Убрано территорий',
          value: '${user.spotsCleanedCount}',
          icon: Icons.cleaning_services,
        ),
        _StatCard(
          label: 'Очки рейтинга',
          value: '${user.ratingPoints}',
          icon: Icons.eco,
        ),
      ],
    );
  }

  Widget _buildOoptCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreenEnd.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryGreenEnd.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Профессиональный режим ООПТ', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(
            'Свяжитесь напрямую с Особо Охраняемыми Природными Территориями '
            '(ООПТ) для участия в инспекциях',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _contactOopt,
              child: const Text('Связаться с ООПТ'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryGreenEnd),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}