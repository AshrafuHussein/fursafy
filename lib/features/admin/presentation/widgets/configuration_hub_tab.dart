import 'package:flutter/material.dart';
import 'package:fursafy/app/theme.dart';

class ConfigurationHubTab extends StatefulWidget {
  final Map<String, dynamic> initialConfig;
  final ValueChanged<Map<String, dynamic>> onSaveConfig;

  const ConfigurationHubTab({
    super.key,
    required this.initialConfig,
    required this.onSaveConfig,
  });

  @override
  State<ConfigurationHubTab> createState() => _ConfigurationHubTabState();
}

class _ConfigurationHubTabState extends State<ConfigurationHubTab> {
  late double _platformFeesPercentage;
  late double _employerFeePercentage;
  late double _talentFeePercentage;
  late bool _reqNationalId;
  late bool _reqBusinessLicense;
  late bool _reqVideoKyc;
  late bool _enforce2FA;

  late TextEditingController _employerFeeController;
  late TextEditingController _talentFeeController;
  late TextEditingController _platformFeeController;

  final List<String> _apiKeys = [
    'pk_live_********************8a2',
    'sk_test_********************4f1',
  ];

  final List<Map<String, String>> _admins = [
    {
      'name': 'Sarah Mwasiti',
      'email': 'sarah.m@fursafy.co.tz',
      'role': 'Super Admin',
      'avatar': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=150&q=80',
      'isMe': 'true',
      'status': 'active',
    },
    {
      'name': 'James Kitalu',
      'email': 'j.kitalu@fursafy.co.tz',
      'role': 'Moderator',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      'isMe': 'false',
      'status': 'active',
    },
    {
      'name': 'Lulu Mapunda',
      'email': 'lulu@fursafy.co.tz',
      'role': 'Support',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      'isMe': 'false',
      'status': 'pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _platformFeesPercentage = (widget.initialConfig['platformFee'] ?? 3.0) as double;
    _employerFeePercentage = (widget.initialConfig['employerFee'] ?? 12.0) as double;
    _talentFeePercentage = (widget.initialConfig['talentFee'] ?? 5.0) as double;
    _reqNationalId = widget.initialConfig['reqNationalId'] ?? true;
    _reqBusinessLicense = widget.initialConfig['reqBusinessLicense'] ?? true;
    _reqVideoKyc = widget.initialConfig['reqVideoKyc'] ?? false;
    _enforce2FA = widget.initialConfig['enforce2FA'] ?? true;

    _employerFeeController = TextEditingController(text: _employerFeePercentage.toStringAsFixed(0));
    _talentFeeController = TextEditingController(text: _talentFeePercentage.toStringAsFixed(0));
    _platformFeeController = TextEditingController(text: _platformFeesPercentage.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _employerFeeController.dispose();
    _talentFeeController.dispose();
    _platformFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Save changes bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration Hub',
                  style: FursafyTheme.headlineStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Manage your platform\'s core logic, administrative access, and security protocols from a single editorial dashboard.',
                  style: FursafyTheme.bodyStyle.copyWith(color: FursafyTheme.onSurfaceVariant),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                widget.onSaveConfig({
                  'platformFee': _platformFeesPercentage,
                  'employerFee': _employerFeePercentage,
                  'talentFee': _talentFeePercentage,
                  'reqNationalId': _reqNationalId,
                  'reqBusinessLicense': _reqBusinessLicense,
                  'reqVideoKyc': _reqVideoKyc,
                  'enforce2FA': _enforce2FA,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: FursafyTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                elevation: 0,
              ),
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Section 1: Platform Settings
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left block (Transactional settings)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.tune, color: FursafyTheme.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Platform Settings',
                          style: TextStyle(fontFamily: FursafyTheme.headlineFont, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Transactional Service Fees',
                      style: FursafyTheme.labelStyle.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: FursafyTheme.outline, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Set the percentage Fursafy retains from each successful job match.',
                      style: FursafyTheme.bodyStyle.copyWith(fontSize: 13, color: FursafyTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EMPLOYER FEE (%)', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _employerFeeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: '%',
                                ),
                                onChanged: (val) {
                                  final numVal = double.tryParse(val);
                                  if (numVal != null) _employerFeePercentage = numVal;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TALENT SERVICE FEE (%)', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _talentFeeController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: '%',
                                ),
                                onChanged: (val) {
                                  final numVal = double.tryParse(val);
                                  if (numVal != null) _talentFeePercentage = numVal;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GLOBAL PLATFORM FEE (%)', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _platformFeeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            suffixText: '%',
                          ),
                          onChanged: (val) {
                            final numVal = double.tryParse(val);
                            if (numVal != null) _platformFeesPercentage = numVal;
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),

            // Right block (KYC settings)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: FursafyTheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identity Verification Requirements',
                      style: FursafyTheme.headlineStyle.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _kycCheckboxTile('Require National ID for Talent', _reqNationalId, (val) {
                      setState(() => _reqNationalId = val ?? true);
                    }),
                    const SizedBox(height: 16),
                    _kycCheckboxTile('Employer Business License', _reqBusinessLicense, (val) {
                      setState(() => _reqBusinessLicense = val ?? true);
                    }),
                    const SizedBox(height: 16),
                    _kycCheckboxTile('Video Interview KYC', _reqVideoKyc, (val) {
                      setState(() => _reqVideoKyc = val ?? false);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Section 2: Security & API
        Row(
          children: const [
            Icon(Icons.shield_outlined, color: FursafyTheme.secondary, size: 20),
            SizedBox(width: 8),
            Text(
              'Security & Authentication',
              style: TextStyle(fontFamily: FursafyTheme.headlineFont, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: 2FA Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: FursafyTheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phonelink_lock, color: FursafyTheme.secondary),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Two-Factor Authentication',
                            style: FursafyTheme.headlineStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enforce 2FA for all administrator accounts to prevent unauthorized access.',
                            style: FursafyTheme.bodyStyle.copyWith(fontSize: 13, color: FursafyTheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Switch(
                                value: _enforce2FA,
                                onChanged: (val) => setState(() => _enforce2FA = val),
                                activeColor: FursafyTheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _enforce2FA ? 'Currently Enforced' : 'Disabled',
                                style: FursafyTheme.labelStyle.copyWith(
                                  color: _enforce2FA ? FursafyTheme.primary : FursafyTheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),

            // Right: API Keys Card
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active API Keys',
                          style: FursafyTheme.headlineStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Generate New'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: _apiKeys.map((key) => _buildApiKeyRow(key)).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Section 3: Admin Management
        Row(
          children: const [
            Icon(Icons.admin_panel_settings_outlined, color: FursafyTheme.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Admin Management',
              style: TextStyle(fontFamily: FursafyTheme.headlineFont, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Add Admin Form (1/3 width)
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add New Admin',
                      style: FursafyTheme.headlineStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Text('FULL NAME', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                    const SizedBox(height: 8),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'John Doe',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('WORK EMAIL', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                    const SizedBox(height: 8),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'john@fursafy.com',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('ROLE', style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: 'Moderator',
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Moderator', child: Text('Moderator')),
                        DropdownMenuItem(value: 'Financial Analyst', child: Text('Financial Analyst')),
                        DropdownMenuItem(value: 'Support Manager', child: Text('Support Manager')),
                      ],
                      onChanged: (val) {},
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: FursafyTheme.onSurface,
                        foregroundColor: FursafyTheme.surface,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Send Invite', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),

            // Right Admin List (2/3 width)
            Expanded(
              flex: 2,
              child: Column(
                children: _admins.map((admin) => _buildAdminCard(admin)).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _kycCheckboxTile(String label, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              checkColor: FursafyTheme.primary,
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: FursafyTheme.labelStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyRow(String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: FursafyTheme.outline,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.content_copy, size: 16, color: FursafyTheme.outline),
                onPressed: () {},
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete, size: 16, color: FursafyTheme.error),
                onPressed: () {},
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAdminCard(Map<String, String> admin) {
    final isMe = admin['isMe'] == 'true';
    final isPending = admin['status'] == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FursafyTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
      ),
      child: Opacity(
        opacity: isPending ? 0.6 : 1.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(admin['avatar']!),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin['name']!,
                      style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      '${admin['email']!} • ${admin['role']!}',
                      style: FursafyTheme.bodyStyle.copyWith(fontSize: 12, color: FursafyTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                if (isMe)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FursafyTheme.primaryFixed,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'ME',
                      style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.onPrimaryFixed),
                    ),
                  ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FursafyTheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      'PENDING INVITE',
                      style: FursafyTheme.labelStyle.copyWith(fontSize: 10, fontWeight: FontWeight.bold, color: FursafyTheme.outline),
                    ),
                  ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: FursafyTheme.outline),
                  onPressed: () {},
                ),
                if (!isMe)
                  IconButton(
                    icon: Icon(isPending ? Icons.refresh : Icons.delete, size: 18, color: isPending ? FursafyTheme.primary : FursafyTheme.error),
                    onPressed: () {},
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
