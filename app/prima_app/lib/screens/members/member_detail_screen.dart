import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/region_provider.dart';
import '../../widgets/prima_app_bar.dart';
import '../../widgets/prima_button.dart';
import '../../widgets/responsive_layout.dart';
import 'member_form_screen.dart';

class MemberDetailScreen extends StatelessWidget {
  final Member member;

  const MemberDetailScreen({
    Key? key,
    required this.member,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final regionProvider = Provider.of<RegionProvider>(context);
    final User? currentUser = authProvider.currentUser;
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: PrimaAppBar(
        title: 'Member Detail',
        showBackButton: true,
        currentUser: currentUser,
        onLogout: () async {
          await authProvider.logout();
          if (context.mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(context, regionProvider, currentUser, theme),
            tablet: _buildTabletLayout(context, regionProvider, currentUser, theme),
            desktop: _buildDesktopLayout(context, regionProvider, currentUser, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    RegionProvider regionProvider,
    User? currentUser,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMemberHeader(context, theme),
        const SizedBox(height: 16),
        _buildPersonalInfoCard(context, theme),
        const SizedBox(height: 16),
        _buildAddressCard(context, regionProvider, theme),
        const SizedBox(height: 16),
        _buildKtpCard(context, theme),
        const SizedBox(height: 16),
        _buildKtaCard(context, theme),
        const SizedBox(height: 16),
        _buildActionButtons(context, currentUser),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    RegionProvider regionProvider,
    User? currentUser,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMemberHeader(context, theme),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPersonalInfoCard(context, theme),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAddressCard(context, regionProvider, theme),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildKtpCard(context, theme),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildKtaCard(context, theme),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildActionButtons(context, currentUser),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    RegionProvider regionProvider,
    User? currentUser,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMemberHeader(context, theme),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPersonalInfoCard(context, theme),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAddressCard(context, regionProvider, theme),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildActionButtons(context, currentUser),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildKtpCard(context, theme),
              const SizedBox(height: 16),
              _buildKtaCard(context, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberHeader(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'KTA: ${member.ktaNumber}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: member.status == 'active'
                              ? Colors.green.withOpacity(0.2)
                              : member.status == 'inactive'
                                  ? Colors.red.withOpacity(0.2)
                                  : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member.status,
                          style: TextStyle(
                            color: member.status == 'active'
                                ? Colors.green
                                : member.status == 'inactive'
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('NIK', member.nik),
            const Divider(),
            _buildInfoRow('Gender', member.gender),
            const Divider(),
            _buildInfoRow('Birth Place', member.birthPlace),
            const Divider(),
            _buildInfoRow('Birth Date', member.birthDate),
            const Divider(),
            _buildInfoRow('Phone', member.phone),
            const Divider(),
            _buildInfoRow('Email', member.email),
            const Divider(),
            _buildInfoRow('Registration Date', member.registrationDate),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    RegionProvider regionProvider,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Address', member.address),
            const Divider(),
            _buildInfoRow(
              'Province',
              regionProvider.getProvinceNameById(member.provinceId),
            ),
            const Divider(),
            _buildInfoRow(
              'City',
              regionProvider.getCityNameById(member.cityId),
            ),
            const Divider(),
            _buildInfoRow(
              'District',
              regionProvider.getDistrictNameById(member.districtId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKtpCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KTP Image',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (member.ktpImageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  member.ktpImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Text('Failed to load KTP image'),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('No KTP image available'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKtaCard(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KTA Document',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (member.ktaPdfUrl != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text('KTA PDF Document'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Open PDF viewer
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View KTA'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Download PDF
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download KTA'),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('No KTA document available'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, User? currentUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (currentUser?.canEditMembers == true) ...[
          PrimaButton(
            text: 'Edit Member',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberFormScreen(
                    isEditing: true,
                    member: member,
                  ),
                ),
              );
            },
            icon: Icons.edit,
            isOutlined: true,
          ),
          const SizedBox(width: 16),
        ],
        PrimaButton(
          text: 'Generate KTA',
          onPressed: () {
            // Generate KTA logic
          },
          icon: Icons.picture_as_pdf,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
