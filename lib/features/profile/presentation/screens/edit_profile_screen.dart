import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';

/// S13 — Edit Profile Bottom Sheet (Stitch design).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users).doc(uid).get();
      final profileDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.youthProfiles).doc(uid).get();
      final u = userDoc.data() ?? {};
      final p = profileDoc.data() ?? {};
      setState(() {
        _nameCtrl.text = u['displayName'] as String? ?? '';
        _avatarUrl = u['avatarUrl'] as String?;
        _bioCtrl.text = p['bio'] as String? ?? '';
        _locationCtrl.text = u['locationName'] as String? ?? '';
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users).doc(uid).update({
        'displayName': _nameCtrl.text.trim(),
        'locationName': _locationCtrl.text.trim(),
      });
      await FirebaseFirestore.instance
          .collection(FirestorePaths.youthProfiles).doc(uid).set({
        'bio': _bioCtrl.text.trim(),
      }, SetOptions(merge: true));
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(_nameCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Profile updated'),
        backgroundColor: FursafyTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _bioCtrl.dispose(); _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surfaceContainerLowest,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: FursafyTheme.primary))
          : SafeArea(
              child: Column(
                children: [
                  // Drag Handle
                  const SizedBox(height: 16),
                  Center(child: Container(
                    width: 48, height: 6,
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  )),
                  // Content
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                        children: [
                          // Title
                          Center(child: Text('Edit Profile',
                            style: FursafyTheme.headlineStyle.copyWith(
                              fontSize: 24, fontWeight: FontWeight.w800,
                            ))),
                          const SizedBox(height: 4),
                          Center(child: Text('Refine your professional identity',
                            style: FursafyTheme.bodyStyle.copyWith(
                              fontSize: 14, color: FursafyTheme.onSurfaceVariant,
                            ))),
                          const SizedBox(height: 40),
                          // Avatar
                          Center(child: GestureDetector(
                            onTap: () { /* TODO: image picker */ },
                            child: Column(children: [
                              Container(
                                width: 128, height: 128,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FursafyTheme.primaryFixed.withValues(alpha: 0.3),
                                    width: 4,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: FursafyTheme.surfaceContainerHighest,
                                  backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                                  child: _avatarUrl == null
                                      ? const Icon(Icons.person, size: 56, color: FursafyTheme.outline)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text('Change Photo', style: FursafyTheme.bodyStyle.copyWith(
                                color: FursafyTheme.primary, fontWeight: FontWeight.w700, fontSize: 14,
                              )),
                            ]),
                          )),
                          const SizedBox(height: 40),
                          // Fields
                          _field('Full Name', _nameCtrl,
                              validator: (v) => v!.isEmpty ? 'Required' : null),
                          const SizedBox(height: 24),
                          _field('Professional Bio', _bioCtrl,
                              maxLines: 3, maxLength: AppConstants.maxBioLength),
                          const SizedBox(height: 24),
                          _field('Location', _locationCtrl,
                              prefixIcon: Icons.location_on),
                          const SizedBox(height: 32),
                          // Save
                          SizedBox(height: 56, width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FursafyTheme.primary,
                                foregroundColor: FursafyTheme.onPrimary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                              ),
                              child: _saving
                                  ? const SizedBox(width: 20, height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Save Changes', style: FursafyTheme.bodyStyle.copyWith(
                                      fontWeight: FontWeight.w700, fontSize: 18)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Discard
                          SizedBox(height: 48, width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Discard', style: FursafyTheme.bodyStyle.copyWith(
                                fontWeight: FontWeight.w700, color: FursafyTheme.onSurfaceVariant)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {int maxLines = 1, int? maxLength, IconData? prefixIcon,
      String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label.toUpperCase(), style: FursafyTheme.labelStyle.copyWith(
            fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 2.0, color: FursafyTheme.onSurfaceVariant,
          )),
        ),
        Container(
          decoration: BoxDecoration(
            color: FursafyTheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: ctrl, maxLines: maxLines, maxLength: maxLength,
            validator: validator,
            style: FursafyTheme.bodyStyle.copyWith(
              color: FursafyTheme.onSurface, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: FursafyTheme.primary, size: 22) : null,
              counterStyle: FursafyTheme.labelStyle.copyWith(
                color: FursafyTheme.outline, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }
}
