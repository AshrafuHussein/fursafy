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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuration Hub',
                  style: FursafyTheme.headlineStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure global transactional commissions and identity verification logic.',
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
        const SizedBox(height: 32),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transactional Commissions',
                      style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Employer Fee Input
                    Text('Employer Service Fee (%)', style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _employerFeeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g. 12',
                      ),
                      onChanged: (val) {
                        final valNum = double.tryParse(val);
                        if (valNum != null) {
                          _employerFeePercentage = valNum;
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Talent Fee Input
                    Text('Talent Service Fee (%)', style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _talentFeeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g. 5',
                      ),
                      onChanged: (val) {
                        final valNum = double.tryParse(val);
                        if (valNum != null) {
                          _talentFeePercentage = valNum;
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Platform Fee calculation parameter
                    Text('Global Ledger platform fee calculation (%)', style: FursafyTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _platformFeeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g. 3',
                      ),
                      onChanged: (val) {
                        final valNum = double.tryParse(val);
                        if (valNum != null) {
                          _platformFeesPercentage = valNum;
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: FursafyTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FursafyTheme.outlineVariant.withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KYC & Security',
                      style: FursafyTheme.headlineStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    CheckboxListTile(
                      title: const Text('Require National ID for Youth'),
                      value: _reqNationalId,
                      onChanged: (val) => setState(() => _reqNationalId = val ?? true),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: FursafyTheme.primary,
                    ),
                    CheckboxListTile(
                      title: const Text('Require Business License for Providers'),
                      value: _reqBusinessLicense,
                      onChanged: (val) => setState(() => _reqBusinessLicense = val ?? true),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: FursafyTheme.primary,
                    ),
                    CheckboxListTile(
                      title: const Text('Video Interview KYC'),
                      value: _reqVideoKyc,
                      onChanged: (val) => setState(() => _reqVideoKyc = val ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: FursafyTheme.primary,
                    ),
                    const Divider(height: 32),

                    SwitchListTile(
                      title: const Text('Enforce Admin 2FA'),
                      subtitle: const Text('Mandatory authentication protection'),
                      value: _enforce2FA,
                      onChanged: (val) => setState(() => _enforce2FA = val),
                      activeThumbColor: FursafyTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
