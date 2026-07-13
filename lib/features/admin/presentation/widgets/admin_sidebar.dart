import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/app/router.dart';
import 'package:fursafy/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:fursafy/features/admin/presentation/bloc/admin_event.dart';

class AdminSidebar extends StatelessWidget {
  final int activeTabIndex;
  final ValueChanged<int> onTabChanged;

  const AdminSidebar({
    super.key,
    required this.activeTabIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(
            color: FursafyTheme.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 24, 40),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: FursafyTheme.primary,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fursafy',
                      style: FursafyTheme.headlineStyle.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: FursafyTheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'GROWTH ENGINE',
                      style: FursafyTheme.labelStyle.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: FursafyTheme.secondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu items
          _sidebarItem(0, 'Dashboard', Icons.dashboard_outlined),
          _sidebarItem(1, 'Opportunities', Icons.work_outline),
          _sidebarItem(2, 'Analytics', Icons.insights),
          _sidebarItem(3, 'Users', Icons.group_outlined),
          _sidebarItem(4, 'Financials', Icons.payments_outlined),
          _sidebarItem(5, 'System Logs', Icons.terminal),
          _sidebarItem(6, 'Settings', Icons.settings_outlined),

          const Spacer(),

          // Post Opportunity Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showPostJobDialog(context),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Post Opportunity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                minimumSize: const Size(double.infinity, 48),
                elevation: 0,
              ),
            ),
          ),

          // Logout Item at bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (!context.mounted) return;
                context.go(AppRoutes.login);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: FursafyTheme.error, size: 20),
                    const SizedBox(width: 16),
                    Text(
                      'Log Out',
                      style: FursafyTheme.bodyStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: FursafyTheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, String title, IconData icon) {
    final isActive = activeTabIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => onTabChanged(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? FursafyTheme.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: FursafyTheme.bodyStyle.copyWith(
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive ? FursafyTheme.primary : FursafyTheme.outline,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostJobDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final payAmountController = TextEditingController();
    final locationController = TextEditingController(text: 'Kinondoni, Dar es Salaam');
    final skillsController = TextEditingController();
    String category = 'Tech';
    String payType = 'fixed';

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: FursafyTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Post New Opportunity',
            style: FursafyTheme.headlineStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Opportunity Title',
                        hintText: 'e.g. Graphic Designer, Assistant Mason',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe the role, responsibilities, and requirements...',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Category
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'Tech', child: Text('Technology & Tech')),
                        DropdownMenuItem(value: 'Tutoring', child: Text('Academic & Tutoring')),
                        DropdownMenuItem(value: 'Cleaning', child: Text('Home Cleaning & Services')),
                        DropdownMenuItem(value: 'Construction', child: Text('Construction & Labor')),
                        DropdownMenuItem(value: 'Other', child: Text('Other Sectors')),
                      ],
                      onChanged: (val) {
                        if (val != null) category = val;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Pay Amount & Type Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: payAmountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Pay Amount (TZS)',
                              hintText: 'e.g. 50000',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: payType,
                            decoration: const InputDecoration(labelText: 'Pay Type'),
                            items: const [
                              DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                              DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
                            ],
                            onChanged: (val) {
                              if (val != null) payType = val;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Location Name
                    TextFormField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location Name',
                        hintText: 'e.g. Kinondoni, Dar es Salaam',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Skills Required
                    TextFormField(
                      controller: skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills Required (comma separated)',
                        hintText: 'e.g. Photoshop, Illustrator',
                      ),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final skillsList = skillsController.text
                      .split(',')
                      .map((s) => s.trim())
                      .where((s) => s.isNotEmpty)
                      .toList();

                  final Map<String, dynamic> jobData = {
                    'providerId': 'admin_portal',
                    'providerName': 'Fursafy Admin',
                    'providerAvatarUrl': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCCapGDi6ZqtA7fbJVA8YOlbXsJ9RcuW9X9JzFMRqlC3XBexBohqrDnaLhdKOYsfJxgbNG6K-NCG9bO0S9xR4RW5sGbxqHETn0n_VYIhL6M7FTOJGcm0VCmemzlu0198FQtf-rCQFG3akTfsq69k1jCcx_SGP9ZgW6KAKwgEwbCtIgqT8Qn6cKW4uVfFifcKNoAvRev2oquKeAhY0kysQ8uPSwsaU7nIQ1E-8x9l_J-4-qppif8fTHdM66tAOp2HDXpcxVciyDBbRWk',
                    'providerRating': 5.0,
                    'providerJobsDone': 42,
                    'title': titleController.text.trim(),
                    'description': descController.text.trim(),
                    'category': category,
                    'payAmount': double.parse(payAmountController.text.trim()),
                    'payType': payType,
                    'location': const GeoPoint(-6.7924, 39.2083),
                    'locationName': locationController.text.trim(),
                    'skillsRequired': skillsList,
                    'status': 'open',
                    'createdAt': Timestamp.now(),
                  };

                  context.read<AdminBloc>().add(AdminJobPostRequested(jobData));
                  Navigator.pop(dialogCtx);
                }
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
