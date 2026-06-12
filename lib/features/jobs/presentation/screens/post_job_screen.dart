import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:fursafy/features/jobs/domain/entities/job_entity.dart';
import 'package:fursafy/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

/// S15 — Post a Job screen (Provider) - Stitch Exact Match.
class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _payCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _customSkillCtrl = TextEditingController();

  String _selectedPayType = 'fixed';
  final List<String> _selectedSkills = [];
  bool _submitting = false;
  GeoPoint? _selectedGeoPoint;

  Future<void> _useCurrentLocation() async {
    final serviceEnabled = await LocationService.instance.isServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services (GPS) are disabled. Opening settings...'),
          backgroundColor: Colors.orange,
        ),
      );
      await LocationService.instance.openLocationSettings();
      return;
    }

    var permission = await LocationService.instance.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await LocationService.instance.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission permanently denied. Opening settings...'),
          backgroundColor: Colors.redAccent,
        ),
      );
      await LocationService.instance.openAppSettings();
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text('Determining location...'),
          ],
        ),
        duration: Duration(seconds: 4),
      ),
    );

    final result = await LocationService.instance.getLocationWithAddress();
    if (result != null) {
      setState(() {
        _selectedGeoPoint = GeoPoint(result.latitude, result.longitude);
        _locationCtrl.text = result.address;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location updated: ${result.address}'),
          backgroundColor: FursafyTheme.primary,
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get location. Make sure GPS is enabled and has a signal.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  final List<String> _suggestedSkills = [
    'Graphic Design',
    'React.js',
    'Marketing',
    'Project Management',
    'Social Media',
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final docRef =
        FirebaseFirestore.instance.collection(FirestorePaths.jobs).doc();

    final job = JobEntity(
      id: docRef.id,
      providerId: uid,
      providerName:
          FirebaseAuth.instance.currentUser?.displayName ?? 'Provider',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      skillsRequired: _selectedSkills,
      location: _selectedGeoPoint ?? const GeoPoint(-6.7924, 39.2083),
      locationName: _locationCtrl.text.trim().isEmpty
          ? 'Dar es Salaam, Tanzania'
          : _locationCtrl.text.trim(),
      payAmount: double.tryParse(_payCtrl.text.trim()) ?? 0,
      payType: PayType.fromString(_selectedPayType),
      category: 'Other',
      status: JobStatus.open,
      createdAt: DateTime.now(),
    );

    try {
      await docRef.set(job.toMap());
      setState(() => _submitting = false);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      setState(() => _submitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post job: $e')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: FursafyTheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      FursafyTheme.primary,
                      FursafyTheme.primaryContainer
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Job Posted!',
                style: FursafyTheme.headlineStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: FursafyTheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your job is now live. Matching youth will be notified.',
                textAlign: TextAlign.center,
                style: FursafyTheme.bodyStyle.copyWith(
                  color: FursafyTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FursafyTheme.primary,
                    foregroundColor: FursafyTheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: FursafyTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      appBar: AppBar(
        backgroundColor: FursafyTheme.surfaceContainerLow.withValues(alpha: 0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: FursafyTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Fursafy',
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: FursafyTheme.primary,
          ),
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: FursafyTheme.surfaceContainerHighest,
              child: Icon(Icons.business, size: 16, color: FursafyTheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Editorial Header
                Text(
                  'OPPORTUNITY CREATOR',
                  style: FursafyTheme.labelStyle.copyWith(
                    color: FursafyTheme.secondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: 'Post a new\n',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: FursafyTheme.onSurface,
                    ),
                    children: [
                      TextSpan(
                        text: 'job opening.',
                        style: FursafyTheme.headlineStyle.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          color: FursafyTheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Fill in the details below to find the best curated talent for your project or company.',
                  style: FursafyTheme.bodyStyle.copyWith(
                    color: FursafyTheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),

                // Core Details Section
                _buildSectionContainer(
                  title: 'Core Details',
                  dotColor: FursafyTheme.primary,
                  child: Column(
                    children: [
                      _buildLabel('Job Title'),
                      _buildUnderlineInput(
                        controller: _titleCtrl,
                        hint: 'e.g. Senior Creative Designer',
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Job Description'),
                      _buildUnderlineInput(
                        controller: _descCtrl,
                        hint: 'Describe the role, responsibilities...',
                        maxLines: 4,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Skills Required Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: FursafyTheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Skills Required', FursafyTheme.secondary),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _suggestedSkills.map((s) {
                                final isSelected = _selectedSkills.contains(s);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelected
                                          ? _selectedSkills.remove(s)
                                          : _selectedSkills.add(s);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? FursafyTheme.primaryFixed
                                          : FursafyTheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(100),
                                      border: isSelected
                                          ? null
                                          : Border.all(
                                              color: FursafyTheme.outlineVariant
                                                  .withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      s,
                                      style: FursafyTheme.labelStyle.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? FursafyTheme.onPrimaryFixed
                                            : FursafyTheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: FursafyTheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _customSkillCtrl,
                                      decoration: InputDecoration(
                                        hintText: 'Add custom skill...',
                                        hintStyle: FursafyTheme.bodyStyle.copyWith(
                                          color: FursafyTheme.outline,
                                          fontSize: 14,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 24),
                                      ),
                                      onSubmitted: (val) {
                                        if (val.trim().isNotEmpty &&
                                            !_selectedSkills.contains(val.trim())) {
                                          setState(() {
                                            _suggestedSkills.add(val.trim());
                                            _selectedSkills.add(val.trim());
                                            _customSkillCtrl.clear();
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      final val = _customSkillCtrl.text.trim();
                                      if (val.isNotEmpty &&
                                          !_selectedSkills.contains(val)) {
                                        setState(() {
                                          _suggestedSkills.add(val);
                                          _selectedSkills.add(val);
                                          _customSkillCtrl.clear();
                                        });
                                      }
                                    },
                                    icon: const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: FursafyTheme.primary,
                                      child: Icon(Icons.add,
                                          size: 16, color: FursafyTheme.onPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: FursafyTheme.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: FursafyTheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb,
                                color: FursafyTheme.primary, size: 28),
                            const SizedBox(height: 16),
                            Text(
                              'Curator Tip',
                              style: FursafyTheme.headlineStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: FursafyTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Adding at least 5 skills increases candidate matching accuracy by 40%.',
                              style: FursafyTheme.bodyStyle.copyWith(
                                fontSize: 12,
                                color: FursafyTheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Logistics
                _buildSectionContainer(
                  title: 'Logistics',
                  dotColor: FursafyTheme.tertiary,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Location'),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildUnderlineInput(
                                        controller: _locationCtrl,
                                        hint: 'Dar es Salaam',
                                        icon: Icons.location_on,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _useCurrentLocation,
                                      icon: const Icon(Icons.my_location),
                                      style: IconButton.styleFrom(
                                        backgroundColor: FursafyTheme.primary,
                                        foregroundColor: FursafyTheme.onPrimary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.all(16),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Deadline'),
                                _buildUnderlineInput(
                                  controller: TextEditingController(),
                                  hint: 'Select date',
                                  icon: Icons.calendar_today,
                                  readOnly: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Budget / Pay (TZS)'),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildUnderlineInput(
                              controller: _payCtrl,
                              hint: '500,000',
                              prefixText: 'TZS  ',
                              keyboardType: TextInputType.number,
                              validator: (v) => v!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: FursafyTheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              children: [
                                _buildToggleBtn('Fixed', _selectedPayType == 'fixed'),
                                _buildToggleBtn('Hourly', _selectedPayType == 'hourly'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Banner
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: FursafyTheme.surfaceContainerHighest,
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          FursafyTheme.primary.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Make your listing stand out.',
                          style: FursafyTheme.headlineStyle.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quality descriptions attract quality people.',
                          style: FursafyTheme.bodyStyle.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FursafyTheme.primary,
                          foregroundColor: FursafyTheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 4,
                          shadowColor: FursafyTheme.primary.withValues(alpha: 0.2),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ))
                            : Text(
                                'Post Job',
                                style: FursafyTheme.bodyStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 1,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: FursafyTheme.onSurfaceVariant,
                        ),
                        child: Text(
                          'Save as Draft',
                          style: FursafyTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Color dotColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title, dotColor),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: FursafyTheme.headlineStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: FursafyTheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: FursafyTheme.labelStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: FursafyTheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildUnderlineInput({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    String? prefixText,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        prefixStyle: FursafyTheme.bodyStyle.copyWith(
          fontWeight: FontWeight.bold,
          color: FursafyTheme.onSurfaceVariant,
        ),
        prefixIcon: icon != null
            ? Icon(icon, color: FursafyTheme.onSurfaceVariant, size: 20)
            : null,
        filled: true,
        fillColor: FursafyTheme.surfaceContainerHighest,
        hintStyle: FursafyTheme.bodyStyle.copyWith(
          color: FursafyTheme.outline,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: FursafyTheme.primary, width: 2),
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPayType = label.toLowerCase());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? FursafyTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: FursafyTheme.labelStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected
                ? FursafyTheme.onPrimary
                : FursafyTheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
