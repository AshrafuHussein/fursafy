import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';

/// S23 — Search & Filter Jobs (Stitch editorial design).
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;
  RangeValues _payRange = const RangeValues(0, 100000);
  List<JobEntity> _results = [];
  bool _loading = false;
  bool _hasSearched = false;

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  Future<void> _search() async {
    setState(() { _loading = true; _hasSearched = true; });
    try {
      Query<Map<String, dynamic>> q = FirebaseFirestore.instance
          .collection(FirestorePaths.jobs)
          .where('status', isEqualTo: 'open');

      if (_selectedCategory != null) {
        q = q.where('category', isEqualTo: _selectedCategory);
      }
      q = q.orderBy('createdAt', descending: true).limit(20);
      final snap = await q.get();
      var jobs = snap.docs.map((d) => JobEntity.fromMap(d.id, d.data())).toList();

      // Client-side filters
      final query = _searchCtrl.text.trim().toLowerCase();
      if (query.isNotEmpty) {
        jobs = jobs.where((j) =>
            j.title.toLowerCase().contains(query) ||
            j.description.toLowerCase().contains(query) ||
            j.skillsRequired.any((s) => s.toLowerCase().contains(query))
        ).toList();
      }
      jobs = jobs.where((j) =>
          j.payAmount >= _payRange.start && j.payAmount <= _payRange.end
      ).toList();

      setState(() { _results = jobs; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: FursafyTheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Handle
            Container(width: 48, height: 6,
              decoration: BoxDecoration(
                color: FursafyTheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(100))),
            const SizedBox(height: 24),
            Text('Filters', style: FursafyTheme.headlineStyle.copyWith(
              fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 24),

            // Category
            Align(alignment: Alignment.centerLeft,
              child: Text('CATEGORY', style: FursafyTheme.labelStyle.copyWith(
                fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 2.0, color: FursafyTheme.onSurfaceVariant))),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8,
              children: AppConstants.jobCategories.map((cat) {
                final sel = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setSheetState(() =>
                      _selectedCategory = sel ? null : cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? FursafyTheme.primary : FursafyTheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(100)),
                    child: Text(cat, style: FursafyTheme.labelStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: sel ? FursafyTheme.onPrimary : FursafyTheme.onSurfaceVariant)),
                  ),
                );
              }).toList()),
            const SizedBox(height: 24),

            // Pay Range
            Align(alignment: Alignment.centerLeft,
              child: Text('PAY RANGE (TZS)', style: FursafyTheme.labelStyle.copyWith(
                fontSize: 11, fontWeight: FontWeight.w700,
                letterSpacing: 2.0, color: FursafyTheme.onSurfaceVariant))),
            const SizedBox(height: 8),
            RangeSlider(
              values: _payRange,
              min: 0, max: 100000, divisions: 20,
              activeColor: FursafyTheme.primary,
              inactiveColor: FursafyTheme.surfaceContainerHighest,
              labels: RangeLabels(
                '${(_payRange.start / 1000).toStringAsFixed(0)}k',
                '${(_payRange.end / 1000).toStringAsFixed(0)}k'),
              onChanged: (v) => setSheetState(() => _payRange = v),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${(_payRange.start / 1000).toStringAsFixed(0)}k TZS',
                  style: FursafyTheme.labelStyle.copyWith(
                    color: FursafyTheme.primary, fontWeight: FontWeight.w700)),
              Text('${(_payRange.end / 1000).toStringAsFixed(0)}k TZS',
                  style: FursafyTheme.labelStyle.copyWith(
                    color: FursafyTheme.primary, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 32),

            // Apply
            Row(children: [
              Expanded(child: SizedBox(height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    setSheetState(() {
                      _selectedCategory = null;
                      _payRange = const RangeValues(0, 100000);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: FursafyTheme.onSurfaceVariant,
                    side: BorderSide(color: FursafyTheme.outlineVariant.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100))),
                  child: Text('Reset', style: FursafyTheme.headlineStyle.copyWith(
                    fontWeight: FontWeight.w700)),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: SizedBox(height: 52,
                child: ElevatedButton(
                  onPressed: () { Navigator.pop(ctx); _search(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FursafyTheme.primary,
                    foregroundColor: FursafyTheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Apply Filters', style: FursafyTheme.headlineStyle.copyWith(
                      fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ]),
                ),
              )),
            ]),
            const SizedBox(height: 16),
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surface.withValues(alpha: 0.8),
        elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.close, color: FursafyTheme.onSurfaceVariant, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Search Jobs', style: FursafyTheme.headlineStyle.copyWith(
          fontSize: 20, fontWeight: FontWeight.w700)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _showFilterSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedCategory != null
                      ? FursafyTheme.primary.withValues(alpha: 0.1)
                      : FursafyTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(100)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.tune, size: 18, color: _selectedCategory != null
                      ? FursafyTheme.primary : FursafyTheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text('Filter', style: FursafyTheme.labelStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _selectedCategory != null
                        ? FursafyTheme.primary : FursafyTheme.onSurfaceVariant)),
                ]),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        // Search Bar
        Padding(padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: Container(
            decoration: BoxDecoration(
              color: FursafyTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16)),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                prefixIcon: const Icon(Icons.search, color: FursafyTheme.onSurfaceVariant),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: FursafyTheme.primary),
                  onPressed: _search),
                hintText: 'Search jobs, skills...',
                hintStyle: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant.withValues(alpha: 0.6)),
              ),
              style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurface),
            ),
          ),
        ),

        // Quick Category Chips
        SizedBox(height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: AppConstants.jobCategories.map((cat) {
              final sel = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = sel ? null : cat);
                    _search();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? FursafyTheme.primary : FursafyTheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(100)),
                    child: Text(cat, style: FursafyTheme.labelStyle.copyWith(
                      fontWeight: FontWeight.w700,
                      color: sel ? FursafyTheme.onPrimary : FursafyTheme.onSurfaceVariant)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Results
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator(color: FursafyTheme.primary))
            : !_hasSearched
                ? Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search, size: 64,
                          color: FursafyTheme.outlineVariant.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('Search for opportunities', style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 18, color: FursafyTheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text('Try "Plumbing" or "Driving"', style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.outline)),
                    ]))
                : _results.isEmpty
                    ? Center(child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off, size: 56,
                              color: FursafyTheme.outlineVariant),
                          const SizedBox(height: 16),
                          Text('No results found', style: FursafyTheme.headlineStyle.copyWith(
                            fontSize: 18, color: FursafyTheme.onSurfaceVariant)),
                        ]))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: _results.length,
                        itemBuilder: (ctx, i) => _resultCard(_results[i]),
                      ),
        ),
      ]),
    );
  }

  Widget _resultCard(JobEntity job) {
    return GestureDetector(
      onTap: () => context.push('/jobs/${job.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: FursafyTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: FursafyTheme.ambientShadow),
        child: Row(children: [
          // Category icon
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: FursafyTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.work_outline, color: FursafyTheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job.title, style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 16, fontWeight: FontWeight.w700),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 14,
                    color: FursafyTheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(job.locationName ?? 'Remote',
                    style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 12, color: FursafyTheme.onSurfaceVariant)),
                const SizedBox(width: 12),
                Text('${(job.payAmount / 1000).toStringAsFixed(0)}k TZS',
                    style: FursafyTheme.labelStyle.copyWith(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: FursafyTheme.primary)),
              ]),
            ],
          )),
          const Icon(Icons.chevron_right, color: FursafyTheme.outline, size: 20),
        ]),
      ),
    );
  }
}
