import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../widgets/prima_button.dart';

class DashboardHeaderWidget extends StatelessWidget {
  final User? currentUser;
  final VoidCallback onDownloadData;
  final VoidCallback onAddMember;

  const DashboardHeaderWidget({
    Key? key,
    required this.currentUser,
    required this.onDownloadData,
    required this.onAddMember,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine user role
    final bool isAdmin = currentUser?.isAdmin ?? false;
    final bool isOperator = currentUser?.isOperator ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Menentukan apakah layar cukup lebar untuk menampilkan teks pada tombol
        final bool isWideScreen = constraints.maxWidth > 700;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Selamat Datang, ${currentUser?.username ?? 'Pengguna'}',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Action buttons based on role
            if (isAdmin || isOperator)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaButton(
                      text: isWideScreen ? 'Unduh Data' : '',
                      icon: Icons.download,
                      onPressed: onDownloadData,
                    ),
                    const SizedBox(width: 8),
                    PrimaButton(
                      text: isWideScreen ? 'Tambah Anggota' : '',
                      icon: Icons.person_add,
                      color: Colors.green,
                      onPressed: onAddMember,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
