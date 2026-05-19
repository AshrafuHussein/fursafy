import 'package:equatable/equatable.dart';
import 'package:fursafy/features/ratings/domain/entities/rating_entity.dart';

abstract class RatingState extends Equatable {
  const RatingState();

  @override
  List<Object?> get props => [];
}

class RatingInitial extends RatingState {}

class RatingLoading extends RatingState {}

class RatingSubmitSuccess extends RatingState {
  final String ratingId;
  const RatingSubmitSuccess(this.ratingId);

  @override
  List<Object?> get props => [ratingId];
}

class RatingsLoaded extends RatingState {
  final List<RatingEntity> ratings;
  const RatingsLoaded(this.ratings);

  @override
  List<Object?> get props => [ratings];
}

class RatingCheckResult extends RatingState {
  final bool hasRated;
  const RatingCheckResult(this.hasRated);

  @override
  List<Object?> get props => [hasRated];
}

class RatingError extends RatingState {
  final String message;
  const RatingError(this.message);

  @override
  List<Object?> get props => [message];
}
