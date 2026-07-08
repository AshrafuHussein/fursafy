import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/app/theme.dart';

/// S02 — Onboarding screen with 3 slides. Shown once on first launch.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.location_on_rounded,
      emoji: '📍',
      title: 'Find Jobs Near You',
      titleSw: 'Pata Kazi Karibu Nawe',
      description:
          'Discover short-term job opportunities in your area. From tech repairs to cleaning, tutoring to construction — opportunities are just a tap away.',
      descriptionSw:
          'Gundua fursa za kazi za muda mfupi karibu nawe. Kutoka marekebisho ya teknolojia hadi usafi — fursa ziko mbele yako.',
      gradient: [Color(0xFF00694C), Color(0xFF008560)],
    ),
    _SlideData(
      icon: Icons.auto_awesome_rounded,
      emoji: '⚡',
      title: 'Smart Skill Matching',
      titleSw: 'Ulinganifu wa Ujuzi',
      description:
          'Our matching engine connects you with jobs that fit your skills and location. Get notified instantly when a perfect opportunity appears.',
      descriptionSw:
          'Injini yetu ya ulinganishaji inakuunganisha na kazi zinazolingana na ujuzi wako. Pata arifa mara moja fursa inapoonekana.',
      gradient: [Color(0xFF855400), Color(0xFFFCAA33)],
    ),
    _SlideData(
      icon: Icons.star_rounded,
      emoji: '⭐',
      title: 'Build Your Reputation',
      titleSw: 'Jenga Sifa Yako',
      description:
          'Earn ratings and reviews after every completed job. The more you work, the more visible and trusted you become to providers.',
      descriptionSw:
          'Pata maoni na alama baada ya kila kazi. Kadri unavyofanya kazi, ndivyo unavyoonekana zaidi na kuaminiwa.',
      gradient: [Color(0xFF993F3A), Color(0xFFB85751)],
    ),
  ];

  void _onNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    final box = await Hive.openBox('app_prefs');
    await box.put('hasSeenOnboarding', true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 24),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: FursafyTheme.bodyStyle.copyWith(
                      color: FursafyTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _buildSlide(slide);
                },
              ),
            ),

            // Dot Indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? FursafyTheme.primary
                          : FursafyTheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FursafyTheme.primary,
                    foregroundColor: FursafyTheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    _currentPage == _slides.length - 1
                        ? 'Get Started'
                        : 'Next',
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_SlideData slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: slide.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: slide.gradient.first.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: Text(
                slide.emoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: FursafyTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Swahili subtitle
          Text(
            slide.titleSw,
            textAlign: TextAlign.center,
            style: FursafyTheme.bodyStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: FursafyTheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: FursafyTheme.bodyStyle.copyWith(
              fontSize: 15,
              color: FursafyTheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideData {
  final IconData icon;
  final String emoji;
  final String title;
  final String titleSw;
  final String description;
  final String descriptionSw;
  final List<Color> gradient;

  const _SlideData({
    required this.icon,
    required this.emoji,
    required this.title,
    required this.titleSw,
    required this.description,
    required this.descriptionSw,
    required this.gradient,
  });
}
