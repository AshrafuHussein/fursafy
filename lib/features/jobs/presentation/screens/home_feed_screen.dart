import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_bloc.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_event.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_state.dart';
import 'package:fursafy/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fursafy/core/location/location_bloc.dart';
import 'package:fursafy/core/location/location_event.dart';
import 'package:fursafy/core/location/location_state.dart';
import 'package:fursafy/core/utils/haversine_util.dart';

/// S07 — Worker Home Feed (Stitch Exact Match).
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final List<String> _categories = [
    'All',
    'Nearby 📍',
    'Construction',
    'Cleaning',
    'Delivery',
    'Events',
    'Tech',
    'Admin',
  ];
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    if (context.read<JobFeedBloc>().state is JobFeedInitial) {
      context.read<JobFeedBloc>().add(const JobFeedLoadRequested());
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final userName = user != null
        ? (user.displayName.split(' ').first)
        : 'there';
    final avatarUrl = user?.avatarUrl;

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: CustomScrollView(
        slivers: [
          // Sticky App Bar
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 0,
            backgroundColor: FursafyTheme.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: FursafyTheme.outlineVariant.withValues(alpha: 0.2),
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fursafy',
                  style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: FursafyTheme.primary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.map_outlined,
                          color: FursafyTheme.onSurface),
                      onPressed: () => context.push(AppRoutes.map),
                    ),
                    IconButton(
                      icon: BlocBuilder<NotificationBloc, NotificationState>(
                        buildWhen: (prev, curr) =>
                            prev.unreadCount != curr.unreadCount,
                        builder: (context, notifState) {
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.notifications_none_rounded,
                                  color: FursafyTheme.onSurface),
                              if (notifState.unreadCount > 0)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    decoration: const BoxDecoration(
                                      color: FursafyTheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      notifState.unreadCount > 9
                                          ? '9+'
                                          : '${notifState.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      onPressed: () => context.push(AppRoutes.notifications),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.profile),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: FursafyTheme.primaryFixed,
                        backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                            ? CachedNetworkImageProvider(avatarUrl)
                            : null,
                        child: avatarUrl == null || avatarUrl.isEmpty
                            ? const Icon(Icons.person,
                                size: 20, color: FursafyTheme.onPrimaryFixed)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ],
            ),
          ),

          // Welcome Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Hi, $userName 👋',
                        style: FursafyTheme.bodyStyle.copyWith(
                          color: FursafyTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      BlocBuilder<LocationBloc, LocationState>(
                        builder: (context, state) {
                          if (state is LocationLoaded) {
                            return Row(
                              children: [
                                const Icon(Icons.location_on_rounded,
                                    size: 14, color: FursafyTheme.primary),
                                const SizedBox(width: 4),
                                Text(
                                  state.address.split(',').first,
                                  style: FursafyTheme.labelStyle.copyWith(
                                    color: FursafyTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      text: 'Find your next\n',
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        color: FursafyTheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: 'opportunity.',
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: FursafyTheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Focus(
                    onFocusChange: (v) => setState(() => _searchFocused = v),
                    child: Container(
                      decoration: BoxDecoration(
                        color: FursafyTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(100),
                        border: _searchFocused
                            ? Border.all(color: FursafyTheme.primary, width: 2)
                            : null,
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            context
                                .read<JobFeedBloc>()
                                .add(JobFeedSearchRequested(val.trim()));
                          } else {
                            context.read<JobFeedBloc>().add(
                                  JobFeedLoadRequested(
                                      category: _selectedCategory,
                                      refresh: true),
                                );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Search jobs, skills, or location...',
                          hintStyle: FursafyTheme.bodyStyle.copyWith(
                            color: FursafyTheme.outline,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: FursafyTheme.onSurfaceVariant),
                          suffixIcon: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: FursafyTheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.tune_rounded,
                                  size: 16, color: Colors.white),
                            ),
                            onPressed: () => context.push(AppRoutes.search),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Featured Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1521737711867-e3b97375f902?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        FursafyTheme.primary.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: FursafyTheme.secondary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '🔥 FEATURED',
                          style: FursafyTheme.labelStyle.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '500+ New Jobs\nThis Week',
                        style: FursafyTheme.headlineStyle.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Category chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        if (cat == 'Nearby 📍') {
                          final locState = context.read<LocationBloc>().state;
                          if (locState is LocationLoaded) {
                            context.read<JobFeedBloc>().add(
                                  JobFeedFilterLocationApplied(
                                    latitude: locState.latitude,
                                    longitude: locState.longitude,
                                    radiusKm: 25.0,
                                  ),
                                );
                          } else {
                            context.read<LocationBloc>().add(const LocationRequested());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fetching location... please wait.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            setState(() => _selectedCategory = 'All');
                            context.read<JobFeedBloc>().add(
                                  const JobFeedLoadRequested(
                                      category: 'All', refresh: true),
                                );
                          }
                        } else {
                          context.read<JobFeedBloc>().add(
                                JobFeedLoadRequested(
                                    category: cat, refresh: true),
                              );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? FursafyTheme.primary
                              : FursafyTheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          cat,
                          style: FursafyTheme.labelStyle.copyWith(
                            color: isSelected
                                ? Colors.white
                                : FursafyTheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Opportunities',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.search),
                    child: Text(
                      'See all',
                      style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Job Feed
          BlocBuilder<JobFeedBloc, JobFeedState>(
            builder: (context, state) {
              if (state is JobFeedLoading && state.isFirstFetch) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: FursafyTheme.primary),
                  ),
                );
              }

              List<JobEntity> jobs = [];
              if (state is JobFeedLoading) {
                jobs = state.oldJobs;
              } else if (state is JobFeedLoaded) {
                jobs = state.jobs;
              } else if (state is JobFeedError) {
                jobs = state.oldJobs;
              }

              if (state is JobFeedError && jobs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_outlined,
                            size: 56, color: FursafyTheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load jobs',
                          style: FursafyTheme.headlineStyle.copyWith(
                            color: FursafyTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check your connection and try again',
                          style: FursafyTheme.bodyStyle.copyWith(
                            color: FursafyTheme.outline,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context
                              .read<JobFeedBloc>()
                              .add(const JobFeedLoadRequested(refresh: true)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (jobs.isEmpty) {
                return SliverFillRemaining(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: FursafyTheme.primaryFixed.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.work_off_outlined,
                              size: 48, color: FursafyTheme.primary),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No jobs found',
                          style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different category or check back later — new opportunities are added daily.',
                          textAlign: TextAlign.center,
                          style: FursafyTheme.bodyStyle.copyWith(
                            color: FursafyTheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _selectedCategory = 'All');
                            context
                                .read<JobFeedBloc>()
                                .add(const JobFeedLoadRequested(refresh: true));
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Show All Jobs'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: FursafyTheme.primary),
                            foregroundColor: FursafyTheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= jobs.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: FursafyTheme.primary),
                          ),
                        );
                      }
                      return _buildJobCard(jobs[index]);
                    },
                    childCount: state is JobFeedLoading
                        ? jobs.length + 1
                        : jobs.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildJobCard(JobEntity job) {
    final payLabel =
        '${job.payAmount.toStringAsFixed(0)} TZS${job.payType.name == 'hourly' ? '/hr' : ''}';
    final skills = job.skillsRequired.take(3).toList();

    final locState = context.read<LocationBloc>().state;
    String? distanceStr;
    if (locState is LocationLoaded && job.location != null) {
      final distance = HaversineUtil.distanceKm(
        lat1: locState.latitude,
        lon1: locState.longitude,
        lat2: job.location!.latitude,
        lon2: job.location!.longitude,
      );
      distanceStr = '${distance.toStringAsFixed(1)} km away';
    }

    return GestureDetector(
      onTap: () => context.push('/jobs/${job.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: FursafyTheme.surfaceContainerHighest,
                  backgroundImage: job.providerAvatarUrl != null
                      ? NetworkImage(job.providerAvatarUrl!)
                      : null,
                  child: job.providerAvatarUrl == null
                      ? const Icon(Icons.business,
                          size: 20, color: FursafyTheme.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.providerName,
                        style: FursafyTheme.labelStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: FursafyTheme.onSurface,
                        ),
                      ),
                      Text(
                        timeago.format(job.createdAt),
                        style: FursafyTheme.labelStyle.copyWith(
                          color: FursafyTheme.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Pay Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: FursafyTheme.primaryFixed,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    payLabel,
                    style: FursafyTheme.labelStyle.copyWith(
                      color: FursafyTheme.onPrimaryFixed,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Job Title
            Text(
              job.title,
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: FursafyTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: FursafyTheme.outline),
                const SizedBox(width: 4),
                Text(
                  job.locationName ?? 'Tanzania',
                  style: FursafyTheme.bodyStyle.copyWith(
                    color: FursafyTheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                if (distanceStr != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: FursafyTheme.outlineVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    distanceStr,
                    style: FursafyTheme.bodyStyle.copyWith(
                      color: FursafyTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Skills + Apply Row
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    children: skills
                        .map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: FursafyTheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                s,
                                style: FursafyTheme.labelStyle.copyWith(
                                  fontSize: 11,
                                  color: FursafyTheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => context.push('/jobs/${job.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: FursafyTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_max_rounded, 'HOME', true),
              _navItem(Icons.search_rounded, 'SEARCH', false,
                  onTap: () => context.push(AppRoutes.search)),
              _navItem(Icons.description_outlined, 'APPLIED', false,
                  onTap: () => context.push(AppRoutes.myApplications)),
              _navItemWithBadge(
                Icons.notifications_none_rounded,
                'ALERTS',
                false,
                onTap: () => context.push(AppRoutes.notifications),
              ),
              _navItem(Icons.person_outline_rounded, 'PROFILE', false,
                  onTap: () => context.push(AppRoutes.profile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? FursafyTheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: FursafyTheme.labelStyle.copyWith(
                color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Nav item with a reactive unread notification badge.
  Widget _navItemWithBadge(IconData icon, String label, bool isActive,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: BlocBuilder<NotificationBloc, NotificationState>(
        buildWhen: (prev, curr) => prev.unreadCount != curr.unreadCount,
        builder: (context, notifState) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? FursafyTheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      color: isActive
                          ? FursafyTheme.primary
                          : FursafyTheme.outline,
                      size: 24,
                    ),
                    if (notifState.unreadCount > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          decoration: const BoxDecoration(
                            color: FursafyTheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            notifState.unreadCount > 9
                                ? '9+'
                                : '${notifState.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: FursafyTheme.labelStyle.copyWith(
                    color:
                        isActive ? FursafyTheme.primary : FursafyTheme.outline,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
