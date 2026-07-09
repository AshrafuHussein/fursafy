import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fursafy/app/theme.dart';
import 'package:fursafy/core/constants/app_constants.dart';

class UserManagementTab extends StatelessWidget {
  final String userSearchQuery;
  final String userFilterRole;
  final ValueChanged<String> onUserFilterRoleChanged;
  final Function(String uid, String currentStatus) onUserStatusToggle;
  final Function(String email) onInviteAdmin;

  const UserManagementTab({
    super.key,
    required this.userSearchQuery,
    required this.userFilterRole,
    required this.onUserFilterRoleChanged,
    required this.onUserStatusToggle,
    required this.onInviteAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Management',
                  style: FursafyTheme.headlineStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Oversee the growth of the Fursafy community. Verify and moderate identities.',
                  style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showInviteAdminDialog(context),
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: const Text('Invite Administrator'),
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // User subtabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _userTabFilterButton('All Users', 'all'),
              const SizedBox(width: 12),
              _userTabFilterButton('Youth Workers', 'youth'),
              const SizedBox(width: 12),
              _userTabFilterButton('Job Providers', 'provider'),
              const SizedBox(width: 12),
              _userTabFilterButton('Suspended', 'suspended'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(FirestorePaths.users)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error loading users: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];
            final filteredDocs = docs.where((doc) {
              final data = doc.data();
              final name = (data['displayName'] ?? '').toString().toLowerCase();
              final role = data['role'] ?? 'youth';
              final status = data['status'] ?? 'active';

              if (userSearchQuery.isNotEmpty && !name.contains(userSearchQuery.toLowerCase())) {
                return false;
              }

              if (userFilterRole == 'youth') {
                return role == 'youth';
              } else if (userFilterRole == 'provider') {
                return role == 'provider';
              } else if (userFilterRole == 'suspended') {
                return status == 'suspended';
              }

              return true;
            }).toList();

            if (filteredDocs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('No users match search or filter query.', style: FursafyTheme.bodyStyle),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                final doc = filteredDocs[index];
                final data = doc.data();
                final uid = doc.id;
                final name = data['displayName'] ?? 'No Name';
                final email = data['email'] ?? 'No Email';
                final role = data['role'] ?? 'youth';
                final status = data['status'] ?? 'active';

                final isSuspended = status == 'suspended';
                final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: FursafyTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSuspended ? FursafyTheme.error.withValues(alpha: 0.1) : FursafyTheme.primary.withValues(alpha: 0.1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: FursafyTheme.headlineStyle.copyWith(
                            color: isSuspended ? FursafyTheme.error : FursafyTheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  name,
                                  style: FursafyTheme.headlineStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: FursafyTheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: FursafyTheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    role.toUpperCase(),
                                    style: FursafyTheme.labelStyle.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: FursafyTheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              email,
                              style: FursafyTheme.bodyStyle.copyWith(
                                fontSize: 13,
                                color: FursafyTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSuspended ? FursafyTheme.error.withValues(alpha: 0.1) : FursafyTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: FursafyTheme.labelStyle.copyWith(
                            color: isSuspended ? FursafyTheme.error : FursafyTheme.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => onUserStatusToggle(uid, status),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSuspended ? FursafyTheme.primary : FursafyTheme.error,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          isSuspended ? 'Activate' : 'Suspend',
                          style: FursafyTheme.bodyStyle.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _userTabFilterButton(String label, String filterKey) {
    final isSelected = userFilterRole == filterKey;
    return ElevatedButton(
      onPressed: () => onUserFilterRoleChanged(filterKey),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? FursafyTheme.primary : FursafyTheme.surfaceContainerLow,
        foregroundColor: isSelected ? Colors.white : FursafyTheme.onSurfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      child: Text(
        label,
        style: FursafyTheme.labelStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showInviteAdminDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FursafyTheme.surface,
          title: Text('Invite Administrator', style: FursafyTheme.headlineStyle.copyWith(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(
              hintText: 'Enter email address...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  onInviteAdmin(email);
                  Navigator.pop(context);
                }
              },
              child: const Text('Send Invitation'),
            ),
          ],
        );
      },
    );
  }
}
