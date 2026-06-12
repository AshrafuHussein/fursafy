import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_bloc.dart';
import 'package:fursafy/features/jobs/presentation/bloc/job_feed_state.dart';
import 'package:fursafy/core/location/location_bloc.dart';
import 'package:fursafy/core/location/location_state.dart';
import 'package:fursafy/core/utils/haversine_util.dart';
import 'package:go_router/go_router.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  JobEntity? _selectedJob;
  LatLng _initialCenter = const LatLng(-6.7924, 39.2083); // Dar es Salaam fallback

  @override
  void initState() {
    super.initState();
    final locState = context.read<LocationBloc>().state;
    if (locState is LocationLoaded) {
      _initialCenter = LatLng(locState.latitude, locState.longitude);
    }
  }

  Future<void> _recenterUser() async {
    final locState = context.read<LocationBloc>().state;
    if (locState is LocationLoaded && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locState.latitude, locState.longitude),
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  Future<void> _animateToJob(JobEntity job) async {
    if (job.location != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(job.location!.latitude, job.location!.longitude),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: Stack(
        children: [
          // ─── Google Map ───
          BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locState) {
              final userLatLng = locState is LocationLoaded
                  ? LatLng(locState.latitude, locState.longitude)
                  : null;

              return BlocBuilder<JobFeedBloc, JobFeedState>(
                builder: (context, feedState) {
                  List<JobEntity> jobs = [];
                  if (feedState is JobFeedLoaded) {
                    jobs = feedState.jobs;
                  } else if (feedState is JobFeedLoading) {
                    jobs = feedState.oldJobs;
                  }

                  // Create Markers
                  final Set<Marker> markers = {};

                  // User marker
                  if (userLatLng != null) {
                    markers.add(
                      Marker(
                        markerId: const MarkerId('user_location'),
                        position: userLatLng,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure,
                        ),
                        infoWindow: const InfoWindow(title: 'My Location'),
                      ),
                    );
                  }

                  // Job markers
                  for (final job in jobs) {
                    if (job.location != null) {
                      markers.add(
                        Marker(
                          markerId: MarkerId(job.id),
                          position: LatLng(
                            job.location!.latitude,
                            job.location!.longitude,
                          ),
                          onTap: () {
                            setState(() {
                              _selectedJob = job;
                            });
                            _animateToJob(job);
                          },
                          infoWindow: InfoWindow(
                            title: job.title,
                            snippet: job.providerName,
                          ),
                        ),
                      );
                    }
                  }

                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: userLatLng ?? _initialCenter,
                      zoom: 12.0,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    markers: markers,
                    myLocationEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    onTap: (_) {
                      setState(() {
                        _selectedJob = null;
                      });
                    },
                  );
                },
              );
            },
          ),

          // ─── Top Floating Header & Back ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: FursafyTheme.ambientShadow,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: FursafyTheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Jobs Map',
                    style: FursafyTheme.headlineStyle.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      shadows: [
                        const Shadow(
                          color: Colors.black38,
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Recenter & Map Tools Button ───
          Positioned(
            right: 20,
            bottom: _selectedJob != null ? 240 : 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _recenterUser,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: FursafyTheme.floatingShadow,
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: FursafyTheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Selected Job Details Card Overlay ───
          if (_selectedJob != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 32,
              child: _buildJobDetailCard(_selectedJob!),
            ),
        ],
      ),
    );
  }

  Widget _buildJobDetailCard(JobEntity job) {
    final payLabel =
        '${job.payAmount.toStringAsFixed(0)} TZS${job.payType.name == 'hourly' ? '/hr' : ''}';
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: FursafyTheme.floatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.providerName.toUpperCase(),
                      style: FursafyTheme.labelStyle.copyWith(
                        color: FursafyTheme.secondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.title,
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: FursafyTheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: FursafyTheme.outline, size: 20),
                onPressed: () {
                  setState(() {
                    _selectedJob = null;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: FursafyTheme.outline),
              const SizedBox(width: 4),
              Text(
                job.locationName ?? 'Dar es Salaam',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget / Pay',
                    style: FursafyTheme.labelStyle.copyWith(
                      color: FursafyTheme.outline,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    payLabel,
                    style: FursafyTheme.labelStyle.copyWith(
                      color: FursafyTheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.push('/jobs/${job.id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FursafyTheme.primary,
                  foregroundColor: FursafyTheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'View Details',
                      style: FursafyTheme.labelStyle.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
