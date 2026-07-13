import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fursafy/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fursafy/features/auth/domain/repositories/auth_repository.dart';
import 'package:fursafy/core/services/notification_service.dart';
import 'package:fursafy/features/auth/domain/entities/user_entity.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/core/error/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockNotificationService mockNotificationService;
  late StreamController<UserEntity?> authStateController;

  final sampleUser = UserEntity(
    uid: 'test_uid_123',
    email: 'test@example.com',
    displayName: 'Test User',
    role: UserRole.youth,
    status: AccountStatus.active,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockNotificationService = MockNotificationService();
    
    // Inject mock NotificationService
    NotificationService.instance = mockNotificationService;

    authStateController = StreamController<UserEntity?>.broadcast();
    
    // Default stubbing
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => authStateController.stream);
    
    when(() => mockNotificationService.refreshTokenForUser(any()))
        .thenAnswer((_) => Future.value());
  });

  tearDown(() {
    authStateController.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(
        AuthBloc(authRepository: mockAuthRepository).state,
        isA<AuthInitial>(),
      );
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when getCurrentUser returns a user on AuthCheckRequested',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) => Future.value(sampleUser));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        AuthAuthenticated(sampleUser),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.getCurrentUser()).called(1);
        verify(() => mockNotificationService.refreshTokenForUser('test_uid_123')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when getCurrentUser returns null on AuthCheckRequested',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) => Future.value(null));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when signInWithEmail is successful',
      build: () {
        when(() => mockAuthRepository.signInWithEmail(
              email: 'test@example.com',
              password: 'password123',
            )).thenAnswer((_) => Future.value((user: sampleUser, failure: null)));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        AuthAuthenticated(sampleUser),
      ],
      verify: (_) {
        verify(() => mockNotificationService.refreshTokenForUser('test_uid_123')).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when signInWithEmail fails',
      build: () {
        const failure = AuthFailure(message: 'Incorrect password.');
        when(() => mockAuthRepository.signInWithEmail(
              email: 'test@example.com',
              password: 'password123',
            )).thenAnswer((_) => Future.value((user: sampleUser, failure: failure)));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthSignInRequested(
        email: 'test@example.com',
        password: 'password123',
      )),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('Incorrect password.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when AuthSignOutRequested is added',
      build: () {
        when(() => mockAuthRepository.signOut()).thenAnswer((_) => Future.value());
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(AuthSignOutRequested()),
      expect: () => [
        isA<AuthUnauthenticated>(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.signOut()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when AuthStateChanged emits a user',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(AuthStateChanged(sampleUser)),
      expect: () => [
        AuthAuthenticated(sampleUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthUnauthenticated] when AuthStateChanged emits null',
      build: () => AuthBloc(authRepository: mockAuthRepository),
      act: (bloc) => bloc.add(const AuthStateChanged(null)),
      expect: () => [
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSent] when sendPasswordResetEmail is successful',
      build: () {
        when(() => mockAuthRepository.sendPasswordResetEmail(email: 'test@example.com'))
            .thenAnswer((_) => Future.value(null));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: 'test@example.com')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthPasswordResetSent>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when sendPasswordResetEmail fails',
      build: () {
        const failure = AuthFailure(message: 'No user found with this email.');
        when(() => mockAuthRepository.sendPasswordResetEmail(email: 'test@example.com'))
            .thenAnswer((_) => Future.value(failure));
        return AuthBloc(authRepository: mockAuthRepository);
      },
      act: (bloc) => bloc.add(const AuthPasswordResetRequested(email: 'test@example.com')),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('No user found with this email.'),
      ],
    );
  });
}
