import 'package:equatable/equatable.dart';

abstract class JobFeedEvent extends Equatable {
  const JobFeedEvent();

  @override
  List<Object?> get props => [];
}

class JobFeedLoadRequested extends JobFeedEvent {
  final String? category;
  final bool refresh;

  const JobFeedLoadRequested({this.category, this.refresh = false});

  @override
  List<Object?> get props => [category, refresh];
}

class JobFeedSearchRequested extends JobFeedEvent {
  final String query;

  const JobFeedSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class JobFeedFilterLocationApplied extends JobFeedEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const JobFeedFilterLocationApplied({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm];
}
