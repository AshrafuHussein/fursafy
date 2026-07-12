import 'package:flutter/material.dart';
import 'package:fursafy/app/theme.dart';

class AnalyticsReportsTab extends StatelessWidget {
  final int totalJobs;
  final int completedJobs;
  final int totalApplications;
  final int totalProviders;
  final List<Map<String, dynamic>> regionalData;
  final List<Map<String, dynamic>> categoryShareData;
  final List<Map<String, dynamic>> growthMetrics;

  const AnalyticsReportsTab({
    super.key,
    required this.totalJobs,
    required this.completedJobs,
    required this.totalApplications,
    required this.totalProviders,
    required this.regionalData,
    required this.categoryShareData,
    required this.growthMetrics,
  });

  @override
  Widget build(BuildContext context) {
    // Determine skill category shares dynamically
    final double plumbingFill = _getCategoryPercentage('cleaning'); // plumbing is mapped or cleaning
    final double cleaningFill = _getCategoryPercentage('cleaning');
    final double techFill = _getCategoryPercentage('tech');
    final double constructionFill = _getCategoryPercentage('construction');
    final double tutoringFill = _getCategoryPercentage('tutoring');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: FursafyTheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    children: const [
                      TextSpan(text: 'National Economic '),
                      TextSpan(
                        text: 'Vitality',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: FursafyTheme.primary,
                        ),
                      ),
                      TextSpan(text: ' Index'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Deep dive into the Tanzanian gig economy performance across regional hubs and skill sectors.',
                  style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: const Text('PDF Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FursafyTheme.surfaceContainerLowest,
                    foregroundColor: FursafyTheme.onSurface,
                    side: BorderSide(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    elevation: 0,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FursafyTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Chart and Stats look
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Line Chart (2/3 width)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Growth Over Time',
                              style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Key matching metrics comparisons',
                              style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.outline),
                            ),
                          ],
                        ),
                        // Legend
                        Row(
                          children: [
                            _chartLegendDot(FursafyTheme.primary, 'SIGNUPS'),
                            const SizedBox(width: 16),
                            _chartLegendDot(FursafyTheme.secondary, 'JOBS'),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Custom Line Spline Painter
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: SplineChartPainter(growthMetrics: growthMetrics),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('JAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                        Text('FEB', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                        Text('MAR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.primary)),
                        Text('APR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                        Text('MAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                        Text('JUN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                        Text('JUL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),

            // Right Stats Cards (1/3 width)
            Expanded(
              child: Column(
                children: [
                  _bentoTotalValueCard('Total Match Velocity', '${totalApplications}', 'applications submitted to date', Icons.trending_up, FursafyTheme.primaryContainer, FursafyTheme.onPrimaryContainer),
                  const SizedBox(height: 24),
                  _bentoTotalValueCard('Active Providers', '${totalProviders}', 'verified partners listing opportunities', Icons.groups, FursafyTheme.secondaryFixed, FursafyTheme.onSecondaryFixed),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Map and Skills
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Map (2/3 width)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Regional Distribution',
                      style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Active job hubs across Tanzania',
                      style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.outline),
                    ),
                    const SizedBox(height: 20),
                    // Map widget container with background photo and overlays
                    Container(
                      height: 380,
                      decoration: BoxDecoration(
                        color: FursafyTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Opacity(
                              opacity: 0.35,
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuAbg7EeW7wD13FsR_nWoTksrp5Hq2AQK4-UgKbu39tutjZptsTYJW-P8ln6bFZnvWUnP3ivj9nS8ZDF-ub9PYfmt3YcKKnlfIqNLhK66puzkvbAWoNr0vBUSljK68FNN9pOimPSMnr0f_fu-7KvCK2X6td_5TzLilLmMruu-qPIRl_b6U-QUmN815JZUqCwp39GZD-zeXkUbIF84Ny3Q1c-JIrPbNohNArBuay9vxrlbOPSOIMs6QqzPOl_71FvxM5O_e-9Zd4aQEFv',
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Hotspots driven by dynamic data
                          ..._buildMapHotspots(),

                          // Legends Overlay Box
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Top Hubs'.toUpperCase(),
                                    style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline, letterSpacing: 1.2),
                                  ),
                                  const SizedBox(height: 12),
                                  ..._buildLegendsList(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),

            // Right: Skills list (1/3 width)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Top Skill Categories',
                      style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    _skillRow('Plumbing & Maintenance', plumbingFill, '${(plumbingFill * totalJobs).round()} Jobs', FursafyTheme.primary),
                    const SizedBox(height: 20),
                    _skillRow('Professional Cleaning', cleaningFill, '${(cleaningFill * totalJobs).round()} Jobs', FursafyTheme.primary),
                    const SizedBox(height: 20),
                    _skillRow('Electrical Services', techFill, '${(techFill * totalJobs).round()} Jobs', FursafyTheme.secondary),
                    const SizedBox(height: 20),
                    _skillRow('IT Support & Tech', constructionFill, '${(constructionFill * totalJobs).round()} Jobs', FursafyTheme.primary),
                    const SizedBox(height: 20),
                    _skillRow('Delivery & Logistics', tutoringFill, '${(tutoringFill * totalJobs).round()} Jobs', FursafyTheme.primary),

                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: FursafyTheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: const Border(left: BorderSide(color: FursafyTheme.secondary, width: 4)),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.onSurfaceVariant, fontStyle: FontStyle.italic),
                          children: const [
                            TextSpan(text: '"The demand for '),
                            TextSpan(text: 'Electrical Services', style: TextStyle(fontWeight: FontWeight.bold, color: FursafyTheme.secondary)),
                            TextSpan(text: ' has increased by 12% in the last quarter, signaling a need for more certified vocational training."'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Analytical Reports list
        Container(
          decoration: BoxDecoration(
            color: FursafyTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Generated Analytical Reports',
                      style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All History'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: FursafyTheme.outlineVariant),
              _reportItem('Q1-Skill-Demand-Report.pdf', 'Mar 12, 2024 • 4.2 MB', isPdf: true),
              const Divider(height: 1, color: FursafyTheme.outlineVariant),
              _reportItem('Regional-Growth-Data-Export.csv', 'Mar 10, 2024 • 1.8 MB', isPdf: false),
            ],
          ),
        ),
      ],
    );
  }

  double _getCategoryPercentage(String category) {
    if (categoryShareData.isEmpty) return 0.25;
    final total = categoryShareData.fold<int>(0, (sum, item) => sum + ((item['count'] ?? 0) as num).toInt());
    if (total == 0) return 0.25;
    final item = categoryShareData.firstWhere(
      (e) => e['category']?.toString().toLowerCase() == category.toLowerCase(),
      orElse: () => {'count': 0},
    );
    return ((item['count'] ?? 0) as num) / total;
  }

  List<Widget> _buildMapHotspots() {
    if (regionalData.isEmpty) {
      return const [
        Positioned(top: 220, right: 80, child: MapHotspot(label: 'Dar es Salaam: 2.4k Jobs')),
        Positioned(top: 120, left: 140, child: MapHotspot(label: 'Mwanza: 800 Jobs', isAmber: true)),
        Positioned(top: 170, left: 200, child: MapHotspot(label: 'Dodoma: 1.2k Jobs')),
      ];
    }
    final List<Widget> list = [];
    double top = 100;
    double left = 100;
    for (var r in regionalData) {
      final region = r['region']?.toString() ?? 'Unknown';
      final count = r['count'] ?? 0;
      
      list.add(
        Positioned(
          top: top,
          left: left,
          child: MapHotspot(label: '$region: $count Jobs'),
        ),
      );
      top += 50;
      left += 60;
    }
    return list;
  }

  List<Widget> _buildLegendsList() {
    if (regionalData.isEmpty) {
      return [
        _legendItem('Dar es Salaam', '42%'),
        const SizedBox(height: 8),
        _legendItem('Arusha', '18%'),
        const SizedBox(height: 8),
        _legendItem('Mbeya', '12%'),
      ];
    }
    final total = regionalData.fold<int>(0, (sum, r) => sum + ((r['count'] ?? 0) as num).toInt());
    if (total == 0) return [const Text('No data')];

    final List<Widget> list = [];
    for (var r in regionalData.take(3)) {
      final region = r['region']?.toString() ?? 'Other';
      final count = ((r['count'] ?? 0) as num).toDouble();
      final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
      list.add(_legendItem(region, '$pct%'));
      list.add(const SizedBox(height: 8));
    }
    return list;
  }

  Widget _chartLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(
          label,
          style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline),
        ),
      ],
    );
  }

  Widget _bentoTotalValueCard(String title, String count, String trend, IconData icon, Color bg, Color fg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: fg.withValues(alpha: 0.8), letterSpacing: 1.2),
              ),
              Icon(icon, color: fg.withValues(alpha: 0.8), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: FursafyTheme.headlineStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w900, color: fg),
          ),
          const SizedBox(height: 12),
          Text(
            trend,
            style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: fg.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, String value) {
    return SizedBox(
      width: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 12, color: FursafyTheme.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _skillRow(String label, double fill, String stats, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(stats, style: TextStyle(fontSize: 12, color: FursafyTheme.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: fill,
            backgroundColor: FursafyTheme.surfaceContainerHighest,
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _reportItem(String filename, String meta, {required bool isPdf}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPdf ? FursafyTheme.errorContainer : FursafyTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isPdf ? Icons.picture_as_pdf : Icons.description,
                  color: isPdf ? FursafyTheme.error : FursafyTheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(filename, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(meta, style: const TextStyle(fontSize: 10, color: FursafyTheme.outline, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {},
            color: FursafyTheme.outline,
          ),
        ],
      ),
    );
  }
}

class SplineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> growthMetrics;

  SplineChartPainter({required this.growthMetrics});

  @override
  void paint(Canvas canvas, Size size) {
    // Background lines
    final linePaint = Paint()
      ..color = FursafyTheme.outlineVariant.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    if (growthMetrics.isEmpty) {
      // Stock painter coordinates
      final path1 = Path();
      path1.moveTo(0, size.height * 0.7);
      path1.cubicTo(size.width * 0.15, size.height * 0.65, size.width * 0.3, size.height * 0.2, size.width * 0.45, size.height * 0.3);
      path1.cubicTo(size.width * 0.6, size.height * 0.4, size.width * 0.75, size.height * 0.05, size.width, size.height * 0.1);

      final linePaint1 = Paint()
        ..color = FursafyTheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;

      final path2 = Path();
      path2.moveTo(0, size.height * 0.8);
      path2.cubicTo(size.width * 0.2, size.height * 0.85, size.width * 0.4, size.height * 0.5, size.width * 0.6, size.height * 0.45);
      path2.cubicTo(size.width * 0.8, size.height * 0.4, size.width * 0.9, size.height * 0.25, size.width, size.height * 0.2);

      final linePaint2 = Paint()
        ..color = FursafyTheme.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawPath(path1, linePaint1);
      canvas.drawPath(path2, linePaint2);
      return;
    }

    // Dynamic coordinates based on growth metrics
    final path1 = Path();
    final path2 = Path();

    final count = growthMetrics.length;
    double maxSignups = 10;
    double maxJobs = 10;

    for (var m in growthMetrics) {
      final s = ((m['signups'] ?? 0) as num).toDouble();
      final j = ((m['jobs'] ?? 0) as num).toDouble();
      if (s > maxSignups) maxSignups = s;
      if (j > maxJobs) maxJobs = j;
    }

    final double step = size.width / (count - 1);
    for (int i = 0; i < count; i++) {
      final x = i * step;
      final ySignups = size.height * (1.0 - (((growthMetrics[i]['signups'] ?? 0) as num).toDouble() / maxSignups).clamp(0.05, 0.95));
      final yJobs = size.height * (1.0 - (((growthMetrics[i]['jobs'] ?? 0) as num).toDouble() / maxJobs).clamp(0.05, 0.95));

      if (i == 0) {
        path1.moveTo(x, ySignups);
        path2.moveTo(x, yJobs);
      } else {
        path1.lineTo(x, ySignups);
        path2.lineTo(x, yJobs);
      }
    }

    final linePaint1 = Paint()
      ..color = FursafyTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final linePaint2 = Paint()
      ..color = FursafyTheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawPath(path1, linePaint1);
    canvas.drawPath(path2, linePaint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MapHotspot extends StatefulWidget {
  final String label;
  final bool isAmber;

  const MapHotspot({super.key, required this.label, this.isAmber = false});

  @override
  State<MapHotspot> createState() => _MapHotspotState();
}

class _MapHotspotState extends State<MapHotspot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color = widget.isAmber ? FursafyTheme.secondary : FursafyTheme.primary;

    return Tooltip(
      message: widget.label,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: 16 * _controller.value * 2.5,
                height: 16 * _controller.value * 2.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.3 * (1 - _controller.value)),
                ),
              );
            },
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}
