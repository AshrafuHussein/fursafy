import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';
import 'package:intl/intl.dart';

/// S16 — Edit Job Bottom Sheet (Stitch design).
class EditJobScreen extends StatefulWidget {
  final String jobId;
  const EditJobScreen({super.key, required this.jobId});

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _payCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _deadline;
  // Job metadata loaded for display
  String title = '';
  String category = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs).doc(widget.jobId).get();
      final d = doc.data() ?? {};
      setState(() {
        title = d['title'] as String? ?? '';
        category = d['category'] as String? ?? '';
        _payCtrl.text = (d['payAmount'] as num?)?.toStringAsFixed(0) ?? '0';
        _descCtrl.text = d['description'] as String? ?? '';
        _deadline = (d['deadline'] as Timestamp?)?.toDate();
        _loading = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final updates = <String, dynamic>{
        'payAmount': double.tryParse(_payCtrl.text.replaceAll(',', '')) ?? 0,
        'description': _descCtrl.text.trim(),
      };
      if (_deadline != null) {
        updates['deadline'] = Timestamp.fromDate(_deadline!);
      }
      await FirebaseFirestore.instance
          .collection(FirestorePaths.jobs).doc(widget.jobId).update(updates);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Job updated'),
        backgroundColor: FursafyTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(
          primary: FursafyTheme.primary,
          onPrimary: FursafyTheme.onPrimary,
          surface: FursafyTheme.surface,
        )),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  void dispose() { _payCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FursafyTheme.surface,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: FursafyTheme.primary))
          : SafeArea(child: Column(children: [
              // Drag handle
              const SizedBox(height: 16),
              Center(child: Container(width: 48, height: 6,
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100)))),
              // Content
              Expanded(child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                children: [
                  // Title
                  Text('Edit Listing Details',
                    style: FursafyTheme.headlineStyle.copyWith(
                      fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Update the core parameters of your job posting.',
                    style: FursafyTheme.bodyStyle.copyWith(
                      color: FursafyTheme.onSurfaceVariant)),
                  const SizedBox(height: 32),

                  // Pay
                  _label('Monthly Remuneration (TZS)'),
                  const SizedBox(height: 8),
                  _input(
                    controller: _payCtrl,
                    icon: Icons.payments,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Deadline
                  _label('Application Deadline'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDeadline,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: FursafyTheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        const Icon(Icons.event, color: FursafyTheme.onSurfaceVariant, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          _deadline != null
                              ? DateFormat('MMM dd, yyyy').format(_deadline!)
                              : 'Select a deadline',
                          style: FursafyTheme.bodyStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _deadline != null
                                ? FursafyTheme.onSurface : FursafyTheme.outline),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  _label('Job Description'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _descCtrl,
                      maxLines: 5,
                      style: FursafyTheme.bodyStyle.copyWith(
                        color: FursafyTheme.onSurface, height: 1.6),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(24),
                      ),
                    ),
                  ),
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
                          borderRadius: BorderRadius.circular(100))),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                          : Text('Save Changes',
                              style: FursafyTheme.headlineStyle.copyWith(
                                fontWeight: FontWeight.w700, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(height: 48, width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel Edits',
                        style: FursafyTheme.headlineStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: FursafyTheme.onSurfaceVariant)),
                    ),
                  ),
                ],
              )),
            ])),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(text, style: FursafyTheme.headlineStyle.copyWith(
      fontWeight: FontWeight.w700, color: FursafyTheme.onSurface)),
  );

  Widget _input({required TextEditingController controller,
      required IconData icon, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: FursafyTheme.bodyStyle.copyWith(
          color: FursafyTheme.onSurface, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(icon, color: FursafyTheme.onSurfaceVariant, size: 22),
        ),
      ),
    );
  }
}
