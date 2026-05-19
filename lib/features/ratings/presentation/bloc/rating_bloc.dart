import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fursafy/features/ratings/domain/repositories/rating_repository.dart';
import 'rating_event.dart';
import 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final RatingRepository _repo;

  RatingBloc({required RatingRepository ratingRepository})
      : _repo = ratingRepository,
        super(RatingInitial()) {
    on<RatingSubmitted>(_onSubmit);
    on<RatingsLoadRequested>(_onLoad);
    on<RatingCheckRequested>(_onCheck);
  }

  Future<void> _onSubmit(
    RatingSubmitted event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    final result = await _repo.submitRating(
      raterId: event.raterId,
      raterName: event.raterName,
      raterAvatarUrl: event.raterAvatarUrl,
      rateeId: event.rateeId,
      jobId: event.jobId,
      score: event.score,
      comment: event.comment,
    );
    if (result.failure != null) {
      emit(RatingError(result.failure!.message));
    } else {
      emit(RatingSubmitSuccess(result.ratingId!));
    }
  }

  Future<void> _onLoad(
    RatingsLoadRequested event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    final result = await _repo.getUserRatings(event.userId);
    if (result.failure != null) {
      emit(RatingError(result.failure!.message));
    } else {
      emit(RatingsLoaded(result.ratings));
    }
  }

  Future<void> _onCheck(
    RatingCheckRequested event,
    Emitter<RatingState> emit,
  ) async {
    emit(RatingLoading());
    final hasRated = await _repo.hasRated(
      raterId: event.raterId,
      jobId: event.jobId,
    );
    emit(RatingCheckResult(hasRated));
  }
}
