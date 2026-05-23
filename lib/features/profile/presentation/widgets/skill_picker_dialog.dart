import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fursafy/app/theme.dart';

class SkillCategory {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<String> subSkills;
  final bool isFeatured;
  final List<String> tags;

  const SkillCategory({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.subSkills,
    required this.tags,
    this.isFeatured = false,
  });
}

class SkillPickerDialog extends StatefulWidget {
  final List<String> initialSelectedSkills;

  const SkillPickerDialog({
    super.key,
    required this.initialSelectedSkills,
  });

  @override
  State<SkillPickerDialog> createState() => _SkillPickerDialogState();
}

class _SkillPickerDialogState extends State<SkillPickerDialog> {
  late List<String> _selectedSkills;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedTag;
  final Set<String> _expandedFeaturedCategories = {};

  final List<SkillCategory> _categories = const [
    SkillCategory(
      id: 'plumbing',
      title: 'Plumbing',
      description: 'Pipe installation, drainage systems, and maintenance.',
      icon: Icons.plumbing,
      subSkills: ['Leak Repair', 'Fixture Install', 'Drain Cleaning'],
      tags: ['Domestic', 'Trending'],
    ),
    SkillCategory(
      id: 'cleaning',
      title: 'Cleaning',
      description: 'Residential and commercial deep cleaning services.',
      icon: Icons.cleaning_services,
      subSkills: ['Deep Clean', 'Carpet Clean', 'Window Clean'],
      tags: ['Domestic'],
    ),
    SkillCategory(
      id: 'tutoring',
      title: 'Tutoring',
      description: 'Academic support and vocational skill training.',
      icon: Icons.school,
      subSkills: ['Mathematics', 'English', 'Science'],
      tags: ['Technical'],
    ),
    SkillCategory(
      id: 'construction',
      title: 'Construction',
      description: 'Brickwork, roofing, and structural development.',
      icon: Icons.construction,
      subSkills: ['Bricklaying', 'Roofing', 'Carpentry'],
      tags: ['Construction'],
    ),
    SkillCategory(
      id: 'electrical',
      title: 'Electrical Systems',
      description: 'Wiring, power installation, and high-voltage maintenance for professional certified technicians.',
      icon: Icons.electrical_services,
      subSkills: ['Wiring', 'High Voltage', 'Fixture Install', 'Generator Setup', 'Appliance Install', 'Solar Install'],
      tags: ['Technical', 'Trending'],
      isFeatured: true,
    ),
    SkillCategory(
      id: 'handyman',
      title: 'Handyman',
      description: 'General repairs, furniture assembly, and odd jobs.',
      icon: Icons.handyman,
      subSkills: ['Furniture Assembly', 'Odd Jobs', 'Appliance Repair'],
      tags: ['Domestic'],
    ),
    SkillCategory(
      id: 'creative',
      title: 'Creative',
      description: 'Graphic design, photography, and digital marketing.',
      icon: Icons.palette,
      subSkills: ['Graphic Design', 'Photography', 'Videography'],
      tags: ['Technical', 'Trending'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSkills = List.from(widget.initialSelectedSkills);
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  void _toggleCategory(SkillCategory category) {
    setState(() {
      final isCategorySelected = _selectedSkills.contains(category.title);
      if (isCategorySelected) {
        _selectedSkills.remove(category.title);
        // Option: also remove sub-skills of this category if desired
        for (final sub in category.subSkills) {
          _selectedSkills.remove(sub);
        }
      } else {
        _selectedSkills.add(category.title);
      }
    });
  }

  bool _isCategoryActive(SkillCategory category) {
    if (_selectedSkills.contains(category.title)) return true;
    for (final sub in category.subSkills) {
      if (_selectedSkills.contains(sub)) return true;
    }
    return false;
  }

  void _resetSkills() {
    setState(() {
      _selectedSkills.clear();
    });
  }

  List<SkillCategory> get _filteredCategories {
    List<SkillCategory> list = _categories;

    // Filter by tag
    if (_selectedTag != null) {
      if (_selectedTag == 'Trending') {
        list = list.where((c) => c.tags.contains('Trending')).toList();
      } else {
        list = list.where((c) => c.tags.contains(_selectedTag!)).toList();
      }
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      list = list.where((c) {
        final matchesCategory = c.title.toLowerCase().contains(_searchQuery) ||
            c.description.toLowerCase().contains(_searchQuery);
        final matchesSubskills = c.subSkills.any((s) => s.toLowerCase().contains(_searchQuery));
        return matchesCategory || matchesSubskills;
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = mediaQuery.viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    // Calculate dynamic progress based on number of selected skills
    // We target at least 3-5 skills for a complete profile
    final double progress = (_selectedSkills.length / 5.0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // Sticky Header
                _buildHeader(),
                
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 16,
                      bottom: isKeyboardOpen ? viewInsets.bottom + 24 : 120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Input
                        _buildSearchSection(),
                        const SizedBox(height: 24),

                        // Popular Categories
                        _buildPopularCategories(),
                        const SizedBox(height: 32),

                        // Skill Grid
                        _buildSkillGrid(),
                        const SizedBox(height: 32),

                        // Profile Completion Hint
                        _buildProfileCompletionHint(progress),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Bottom action bar (fixed glassmorphism)
            if (!isKeyboardOpen) _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: FursafyTheme.surface.withValues(alpha: 0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: FursafyTheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: FursafyTheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Select Skills',
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: FursafyTheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: FursafyTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '${_selectedSkills.length} Selected',
              style: FursafyTheme.labelStyle.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: FursafyTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _searchCtrl,
        style: FursafyTheme.bodyStyle.copyWith(
          color: FursafyTheme.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search for skills (e.g. Carpentry)',
          hintStyle: FursafyTheme.bodyStyle.copyWith(
            color: FursafyTheme.onSurfaceVariant.withValues(alpha: 0.6),
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: FursafyTheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPopularCategories() {
    final tags = ['Trending', 'Construction', 'Domestic', 'Technical'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular categories',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: FursafyTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: tags.map((tag) {
              final isSelected = _selectedTag == tag;
              
              if (tag == 'Trending') {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTag = isSelected ? null : tag;
                      });
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? FursafyTheme.secondaryFixed
                            : FursafyTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt,
                            size: 18,
                            color: isSelected 
                                ? FursafyTheme.onSecondaryFixed
                                : FursafyTheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Trending',
                            style: FursafyTheme.labelStyle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected 
                                  ? FursafyTheme.onSecondaryFixed
                                  : FursafyTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTag = isSelected ? null : tag;
                    });
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? FursafyTheme.primary
                          : FursafyTheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      tag,
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? FursafyTheme.onPrimary
                            : FursafyTheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillGrid() {
    final categories = _filteredCategories;

    if (categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: FursafyTheme.outline.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No skills matching search found',
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Standard Grid with Bento design patterns.
    // If a featured category is present, it will be rendered as a full-width item,
    // while regular categories are displayed side-by-side or stacked.
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        if (category.isFeatured) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildFeaturedCard(category),
          );
        }

        // For regular categories, we can lay them out beautifully.
        // In a true asymmetric list, we just render them one after another or grouped in pairs.
        // Let's render pairs side-by-side if they are not featured, or render them as beautiful full-width elements that stack neatly.
        // Stacking neatly with staggered items/chips is extremely clean on mobile screens!
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildCategoryCard(category),
        );
      },
    );
  }

  Widget _buildCategoryCard(SkillCategory category) {
    final isSelected = _selectedSkills.contains(category.title);
    final isActive = _isCategoryActive(category);

    return InkWell(
      onTap: () => _toggleCategory(category),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive 
              ? FursafyTheme.surfaceContainerLowest
              : FursafyTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive 
                ? FursafyTheme.primary.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: isActive ? FursafyTheme.ambientShadow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isActive 
                        ? FursafyTheme.primary.withValues(alpha: 0.1)
                        : FursafyTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category.icon,
                    size: 28,
                    color: isActive ? FursafyTheme.primary : FursafyTheme.onSurfaceVariant,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? FursafyTheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? FursafyTheme.primary : FursafyTheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              category.title,
              style: FursafyTheme.headlineStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: FursafyTheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.description,
              style: FursafyTheme.bodyStyle.copyWith(
                fontSize: 14,
                color: FursafyTheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (category.subSkills.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: category.subSkills.map((sub) {
                  final isSubSelected = _selectedSkills.contains(sub);
                  return InkWell(
                    onTap: () {
                      _toggleSkill(sub);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSubSelected 
                            ? FursafyTheme.primary.withValues(alpha: 0.1)
                            : FursafyTheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                        border: isSubSelected
                            ? Border.all(color: FursafyTheme.primary.withValues(alpha: 0.2))
                            : null,
                      ),
                      child: Text(
                        sub,
                        style: FursafyTheme.labelStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSubSelected ? FursafyTheme.primary : FursafyTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(SkillCategory category) {
    final isExpanded = _expandedFeaturedCategories.contains(category.id);
    final isActive = _isCategoryActive(category);

    return Container(
      decoration: BoxDecoration(
        color: FursafyTheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: FursafyTheme.floatingShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background blur circle
          Positioned(
            right: -32,
            top: -32,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FursafyTheme.primaryContainer.withValues(alpha: 0.2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.electrical_services,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${category.subSkills.length} Skills Available',
                          style: FursafyTheme.labelStyle.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.6),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedFeaturedCategories.remove(category.id);
                              } else {
                                _expandedFeaturedCategories.add(category.id);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isExpanded ? Colors.white : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isExpanded ? Icons.remove : Icons.add,
                              color: isExpanded ? FursafyTheme.primary : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      category.title,
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  category.description,
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),

                // Expanded subskills list
                if (isExpanded) ...[
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: category.subSkills.map((sub) {
                      final isSubSelected = _selectedSkills.contains(sub);
                      return InkWell(
                        onTap: () {
                          _toggleSkill(sub);
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSubSelected 
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                            border: isSubSelected
                                ? null
                                : Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            sub,
                            style: FursafyTheme.labelStyle.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSubSelected ? FursafyTheme.primary : Colors.white,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionHint(double progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Almost there!',
                  style: FursafyTheme.headlineStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: FursafyTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecting relevant skills helps us match you with the best opportunities in Dar es Salaam.',
                  style: FursafyTheme.bodyStyle.copyWith(
                    fontSize: 14,
                    color: FursafyTheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FursafyTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      height: 8,
                      width: (MediaQuery.of(context).size.width - 120) * progress,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [FursafyTheme.primary, FursafyTheme.primaryContainer],
                        ),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: FursafyTheme.secondary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            color: FursafyTheme.surface.withValues(alpha: 0.85),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: _resetSkills,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: FursafyTheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Reset',
                        style: FursafyTheme.headlineStyle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: FursafyTheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context, _selectedSkills);
                    },
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: FursafyTheme.primary,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: FursafyTheme.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Apply Skills',
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: FursafyTheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: FursafyTheme.onPrimary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
