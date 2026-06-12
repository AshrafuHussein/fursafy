import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fursafy/core/services/location_service.dart';

import 'location_event.dart';
import 'location_state.dart';

/// BLoC managing device location state across the app.
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  StreamSubscription<Position>? _positionSubscription;

  LocationBloc({LocationService? locationService})
      : _locationService = locationService ?? LocationService.instance,
        super(LocationInitial()) {
    on<LocationRequested>(_onLocationRequested);
    on<LocationPermissionRequested>(_onPermissionRequested);
    on<LocationSetManually>(_onSetManually);
    on<LocationCleared>(_onCleared);
    on<LocationBackgroundStarted>(_onBackgroundStarted);
    on<LocationBackgroundStopped>(_onBackgroundStopped);
  }

  Future<void> _onLocationRequested(
    LocationRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    try {
      // Check if location services are enabled
      final serviceEnabled = await _locationService.isServiceEnabled();
      if (!serviceEnabled) {
        emit(LocationServiceDisabled());
        return;
      }

      // Check permission
      final permission = await _locationService.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPerm = await _locationService.requestPermission();
        if (newPerm == LocationPermission.denied) {
          emit(const LocationDenied());
          return;
        }
        if (newPerm == LocationPermission.deniedForever) {
          emit(const LocationDenied(isPermanent: true));
          return;
        }
      } else if (permission == LocationPermission.deniedForever) {
        emit(const LocationDenied(isPermanent: true));
        return;
      }

      // Get position + address
      final result = await _locationService.getLocationWithAddress();
      if (result == null) {
        emit(const LocationError('Could not determine your location'));
        return;
      }

      emit(LocationLoaded(
        latitude: result.latitude,
        longitude: result.longitude,
        address: result.address,
      ));
    } catch (e) {
      debugPrint('LocationBloc error: $e');
      emit(LocationError('Location error: $e'));
    }
  }

  Future<void> _onPermissionRequested(
    LocationPermissionRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());

    final permission = await _locationService.requestPermission();

    switch (permission) {
      case LocationPermission.denied:
        emit(const LocationDenied());
        break;
      case LocationPermission.deniedForever:
        emit(const LocationDenied(isPermanent: true));
        break;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        // Permission granted — now get position
        add(const LocationRequested());
        break;
      case LocationPermission.unableToDetermine:
        emit(const LocationError('Unable to determine permission status'));
        break;
    }
  }

  void _onSetManually(
    LocationSetManually event,
    Emitter<LocationState> emit,
  ) {
    emit(LocationLoaded(
      latitude: event.latitude,
      longitude: event.longitude,
      address: event.address,
    ));
  }

  void _onCleared(
    LocationCleared event,
    Emitter<LocationState> emit,
  ) {
    emit(LocationInitial());
  }

  Future<void> _onBackgroundStarted(
    LocationBackgroundStarted event,
    Emitter<LocationState> emit,
  ) async {
    // Request background permission first
    await _locationService.requestBackgroundPermission();

    await _positionSubscription?.cancel();
    _positionSubscription = _locationService
        .getPositionStream(distanceFilterMeters: 500)
        .listen((position) async {
      final address = await _locationService.getAddressFromCoords(
        position.latitude,
        position.longitude,
      );
      add(LocationSetManually(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address ?? 'Current location',
      ));
    });
  }

  Future<void> _onBackgroundStopped(
    LocationBackgroundStopped event,
    Emitter<LocationState> emit,
  ) async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
