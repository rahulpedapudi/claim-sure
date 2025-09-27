import 'package:claim_sure/screens/add_asset.dart';
import 'package:claim_sure/screens/select_nominee.dart';
import 'package:claim_sure/services/api_service.dart';
import 'package:claim_sure/theme.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data - in real app this would come from a database/API
  bool hasNominee = false; // This would be checked from user data
  Map<String, String>? nomineeDetails;
  List<Map<String, dynamic>> assets = []; // User's assets
  bool _isLoadingAssets = true;
  String? _assetError;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    setState(() {
      _isLoadingAssets = true;
      _assetError = null;
    });

    try {
      final result = await ApiService.getMyAssets();

      if (!mounted) return;

      if (result['success'] == true) {
        final dynamic data = result['data'];
        List<dynamic> rawAssets = [];

        if (data is List) {
          // Direct array response from /my-assets
          rawAssets = data;
        } else if (data is Map<String, dynamic>) {
          // Wrapped response with metadata
          rawAssets = (data['assets'] as List?) ?? [];

          if (data['has_nominee'] is bool) {
            hasNominee = data['has_nominee'] as bool;
          }

          if (data['nominee'] is Map<String, dynamic>) {
            final nominee = data['nominee'] as Map<String, dynamic>;
            nomineeDetails = nominee.map(
              (key, value) => MapEntry(key, value?.toString() ?? ''),
            );
          }
        }

        assets = rawAssets.where((asset) => asset is Map).map((asset) {
          final map = Map<String, dynamic>.from(asset as Map);

          final dynamic valueRaw = map['value'] ?? map['amount'];
          double? value;
          if (valueRaw is num) {
            value = valueRaw.toDouble();
          } else if (valueRaw != null) {
            value = double.tryParse(valueRaw.toString());
          }

          return {
            'title': map['title'] ?? map['name'] ?? 'Asset',
            'type': map['type'] ?? map['asset_type'] ?? 'Category',
            'institution': map['institution'] ?? map['bank'] ?? 'Institution',
            'value': value,
            'accountNumber': map['accountNumber'] ?? map['account_number'] ?? '',
            'description': map['description'] ?? '',
            'nomineeName': map['nominee_name'] ?? map['nominee'] ?? '',
            'createdAt': map['created_at'] ?? map['createdAt'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      if (!mounted) return;

      _assetError = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load assets: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAssets = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClaimSure Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: _isLoadingAssets
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh assets',
            onPressed: _isLoadingAssets ? null : _loadAssets,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          hasNominee ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Secure family vault',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasNominee
                                  ? 'Nominee verified (${nomineeDetails?['username'] ?? 'unknown'}). You can add and manage assets freely.'
                                  : 'Add a nominee to unlock full asset management.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SelectNomineeScreen(),
                              ),
                            ).then((result) {
                              if (result is Map<String, String> && result['username'] != null) {
                                setState(() {
                                  hasNominee = true;
                                  nomineeDetails = result;
                                });
                              }
                            });
                          },
                          child: Text(hasNominee ? 'Manage nominee' : 'Secure a nominee'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddAssetScreen(),
                              ),
                            ).then((result) {
                              if (result != null) {
                                setState(() {
                                  assets.add(result);
                                });
                              }
                            });
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add asset'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!hasNominee)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ClaimSureTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: ClaimSureTheme.warningColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add a nominee to unlock your vault',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Nominees help claim funds seamlessly. Register at least one nominee to start documenting assets.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (!hasNominee) const SizedBox(height: 24),
            Text(
              'My assets',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (_isLoadingAssets)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_assetError != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[400], size: 36),
                    const SizedBox(height: 12),
                    Text(
                      'Unable to load assets',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _assetError!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red[400]),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _loadAssets,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (assets.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 42,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      hasNominee ? 'Document your first asset' : 'Nominee required before adding assets',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasNominee
                          ? 'Capture deposits, investments, insurance policies, and more in minutes.'
                          : 'Protect your legacy by nominating a trusted family member first.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddAssetScreen(),
                          ),
                        ).then((result) {
                          if (result != null) {
                            setState(() {
                              assets.add(result);
                            });
                          }
                        });
                      },
                      child: const Text('Add first asset'),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  final String title = asset['title']?.toString() ?? 'Asset';
                  final String type = asset['type']?.toString() ?? 'Category';
                  final String institution = asset['institution']?.toString() ?? 'Institution';
                  final double? value = asset['value'] is num
                      ? (asset['value'] as num).toDouble()
                      : double.tryParse(asset['value']?.toString() ?? '');
                  final String accountNumber =
                      asset['accountNumber']?.toString() ?? '—';
                  final String nomineeName =
                      (asset['nomineeName']?.toString() ?? '').trim();
                  final String description =
                      asset['description']?.toString() ?? '';
                  final String createdAtRaw =
                      asset['createdAt']?.toString() ?? '';

                  String createdAtDisplay = '—';
                  if (createdAtRaw.isNotEmpty) {
                    try {
                      final date = DateTime.parse(createdAtRaw).toLocal();
                      createdAtDisplay =
                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    } catch (_) {
                      createdAtDisplay = createdAtRaw;
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ClaimSureTheme.secondaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: ClaimSureTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: theme.textTheme.titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    value != null ? '₹${value.toStringAsFixed(2)}' : '₹—',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                type,
                                style: theme.textTheme.bodyMedium,
                              ),
                              if (description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  description,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_rounded, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      institution,
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.confirmation_num_outlined, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Account #: $accountNumber',
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              if (nomineeName.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline_rounded, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Nominee: $nomineeName',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_rounded, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Created: $createdAtDisplay',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
