import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/features/auth/presentation/bloc/register_bloc.dart';
import 'package:fursafy/core/location/location_bloc.dart';
import 'package:fursafy/core/location/location_state.dart';

/// S06 — Skills Selection Screen.
class SkillPickerScreen extends StatefulWidget {
  const SkillPickerScreen({super.key});

  @override
  State<SkillPickerScreen> createState() => _SkillPickerScreenState();
}

class _SkillPickerScreenState extends State<SkillPickerScreen> {
  final Set<String> _selectedSkills = {'Plumbing', 'Tutoring'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: FursafyTheme.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Select Skills',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: FursafyTheme.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: FursafyTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_selectedSkills.length} Selected',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: FursafyTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state.status == RegisterStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          } else if (state.status == RegisterStatus.success) {
            context.go(
              '/',
            ); // Assuming root will check auth state and redirect to Home
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 16,
                    bottom: 120,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Search
                      Container(
                        decoration: BoxDecoration(
                          color: FursafyTheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Search for skills (e.g. Carpentry)',
                            hintStyle: TextStyle(
                              color: FursafyTheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: FursafyTheme.onSurfaceVariant,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Categories
                      Text(
                        'Popular categories',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: FursafyTheme.onSurfaceVariant,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCategoryChip(
                            'Trending',
                            icon: Icons.bolt,
                            isActive: true,
                          ),
                          _buildCategoryChip('Construction'),
                          _buildCategoryChip('Domestic'),
                          _buildCategoryChip('Technical'),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          _buildSkillCard(
                            'Plumbing',
                            'Pipe installation, drainage systems.',
                            Icons.plumbing,
                            tags: ['Leak Repair', 'Fixture Install'],
                          ),
                          _buildSkillCard(
                            'Cleaning',
                            'Residential and commercial deep cleaning.',
                            Icons.cleaning_services_outlined,
                          ),
                          _buildSkillCard(
                            'Tutoring',
                            'Academic support and vocational training.',
                            Icons.school_outlined,
                            tags: ['Mathematics'],
                          ),
                          _buildSkillCard(
                            'Construction',
                            'Brickwork, roofing, and structural development.',
                            Icons.construction_outlined,
                          ),
                          _buildSkillCard(
                            'Handyman',
                            'General repairs, furniture assembly, odd jobs.',
                            Icons.handyman_outlined,
                          ),
                          _buildSkillCard(
                            'Creative',
                            'Graphic design, photography, digital marketing.',
                            Icons.palette_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Featured Large Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: FursafyTheme.primary,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: FursafyTheme.primary.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.electrical_services,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      width: 2,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Electrical Systems',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Wiring, power installation, and high-voltage maintenance.',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Progress
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: FursafyTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Almost there!',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: FursafyTheme.onSurface,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Selecting relevant skills helps us match you.',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: FursafyTheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: const LinearProgressIndicator(
                                      value: 0.75,
                                      backgroundColor:
                                          FursafyTheme.surfaceContainerHighest,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        FursafyTheme.primary,
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: FursafyTheme.secondary,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: FursafyTheme.surface.withValues(alpha: 0.9),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedSkills.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  FursafyTheme.surfaceContainerHigh,
                              foregroundColor: FursafyTheme.onSurfaceVariant,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: const Text(
                              'Reset',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: state.status == RegisterStatus.loading
                                ? null
                                : () {
                                    final locState = context.read<LocationBloc>().state;
                                    double lat = -6.7924; // Dar es Salaam fallback
                                    double lng = 39.2083;
                                    if (locState is LocationLoaded) {
                                      lat = locState.latitude;
                                      lng = locState.longitude;
                                    }
                                    context.read<RegisterBloc>().add(
                                      RegisterSkillsSubmitted(
                                        skills: _selectedSkills.toList(),
                                        latitude: lat,
                                        longitude: lng,
                                        bio:
                                            'Excited to join Fursafy community!',
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: FursafyTheme.primary,
                              foregroundColor: FursafyTheme.onPrimary,
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (state.status == RegisterStatus.loading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else ...[
                                  const Text(
                                    'Apply Skills',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(
    String label, {
    IconData? icon,
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? FursafyTheme.secondaryFixed
            : FursafyTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? FursafyTheme.onSecondaryFixed
                  : FursafyTheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isActive
                  ? FursafyTheme.onSecondaryFixed
                  : FursafyTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(
    String title,
    String subtitle,
    IconData icon, {
    List<String>? tags,
  }) {
    final isSelected = _selectedSkills.contains(title);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSkills.remove(title);
          } else {
            _selectedSkills.add(title);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? FursafyTheme.surfaceContainerLowest
              : FursafyTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? FursafyTheme.primaryFixed : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FursafyTheme.primary.withValues(alpha: 0.1)
                        : FursafyTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? FursafyTheme.primary
                        : FursafyTheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? FursafyTheme.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : FursafyTheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: FursafyTheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: FursafyTheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (tags != null && tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: FursafyTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: FursafyTheme.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
