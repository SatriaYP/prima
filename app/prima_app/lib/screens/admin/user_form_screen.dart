import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/region_provider.dart';
import '../../widgets/prima_app_bar.dart';
import '../../widgets/prima_button.dart';
import '../../widgets/prima_text_field.dart';
import '../../widgets/responsive_layout.dart';

class UserFormScreen extends StatefulWidget {
  final bool isEditing;
  final User? user;

  const UserFormScreen({
    Key? key,
    required this.isEditing,
    this.user,
  }) : super(key: key);

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Dropdown values
  String _role = 'operator';
  String? _level = 'DPK'; // Ahora es nullable
  String? _regionCode;
  bool _isActive = true;
  int _unitKepengurusanId = 1; // Valor por defecto
  
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    
    // Load regions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegionProvider>(context, listen: false).loadRegionData();
    });
    
    // If editing, populate form with user data
    if (widget.isEditing && widget.user != null) {
      _populateFormWithUserData();
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _populateFormWithUserData() {
    final user = widget.user!;
    
    _usernameController.text = user.username;
    _emailController.text = user.email;
    
    _role = user.role;
    _level = user.level;
    _regionCode = user.regionCode;
    _unitKepengurusanId = user.unitKepengurusanId;
    _isActive = user.isActive;
  }

  Future<void> _saveUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      // En una aplicación real, esto llamaría a una API para guardar el usuario
      // También actualizaríamos el archivo user_config.json
      
      // Aquí crearíamos un objeto User con los datos del formulario
      // User newUser = User(
      //   id: widget.user?.id ?? 0, // 0 sería reemplazado por un nuevo ID en una app real
      //   username: _usernameController.text,
      //   email: _emailController.text,
      //   role: _role,
      //   unitKepengurusanId: _unitKepengurusanId,
      //   level: _level,
      //   regionCode: _regionCode,
      //   isActive: _isActive,
      // );
      
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isEditing ? 'User updated successfully' : 'User created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final regionProvider = Provider.of<RegionProvider>(context);
    final User? currentUser = authProvider.currentUser;
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      appBar: PrimaAppBar(
        title: widget.isEditing ? 'Edit User' : 'Add User',
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
          child: Form(
            key: _formKey,
            child: ResponsiveLayout(
              mobile: _buildMobileLayout(context),
              tablet: _buildTabletLayout(context),
              desktop: _buildDesktopLayout(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserInfoSection(context),
        const SizedBox(height: 24),
        _buildRoleSection(context),
        const SizedBox(height: 24),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildUserInfoSection(context),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildRoleSection(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoSection(context),
              const SizedBox(height: 24),
              _buildActionButtons(context),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildRoleSection(context),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            PrimaTextField(
              label: 'Username',
              hint: 'Enter username',
              controller: _usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter username';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PrimaTextField(
              label: 'Email',
              hint: 'Enter email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email address';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            if (!widget.isEditing) ...[
              const SizedBox(height: 16),
              PrimaTextField(
                label: 'Password',
                hint: 'Create a password',
                controller: _passwordController,
                obscureText: !_showPassword,
                suffix: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              PrimaTextField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword,
                suffix: IconButton(
                  icon: Icon(
                    _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection(BuildContext context) {
    final regionProvider = Provider.of<RegionProvider>(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role & Access',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'admin',
                  child: Text('Admin'),
                ),
                DropdownMenuItem(
                  value: 'operator',
                  child: Text('Operator'),
                ),
                DropdownMenuItem(
                  value: 'viewer',
                  child: Text('Viewer'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _role = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _level,
              decoration: InputDecoration(
                labelText: 'Level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'DPP',
                  child: Text('DPP (National)'),
                ),
                DropdownMenuItem(
                  value: 'DPW',
                  child: Text('DPW (Provincial)'),
                ),
                DropdownMenuItem(
                  value: 'DPK',
                  child: Text('DPK (City/Regency)'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _level = value!;
                  _regionCode = null; // Reset region code when level changes
                });
              },
            ),
            const SizedBox(height: 16),
            if (_level == 'DPW')
              DropdownButtonFormField<String>(
                value: _regionCode,
                decoration: InputDecoration(
                  labelText: 'Province',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: regionProvider.provinces.map((province) {
                  return DropdownMenuItem(
                    value: province.code,
                    child: Text(province.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _regionCode = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select province';
                  }
                  return null;
                },
              )
            else if (_level == 'DPK')
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _regionCode != null && _regionCode!.length >= 2 ? _regionCode!.substring(0, 2) : null,
                    decoration: InputDecoration(
                      labelText: 'Province',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: regionProvider.provinces.map((province) {
                      return DropdownMenuItem(
                        value: province.code,
                        child: Text(province.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _regionCode = null; // Reset city when province changes
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select province';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _regionCode,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: regionProvider.getCitiesByProvinceId(
                      int.tryParse(_regionCode?.substring(0, 2) ?? '0') ?? 0,
                    ).map((city) {
                      return DropdownMenuItem(
                        value: city.code,
                        child: Text(city.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _regionCode = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select city';
                      }
                      return null;
                    },
                  ),
                ],
              )
            else
              const Text('DPP level has access to all regions'),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Active Account'),
              subtitle: const Text('Toggle to enable or disable this account'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        PrimaButton(
          text: widget.isEditing ? 'Update User' : 'Create User',
          onPressed: _saveUser,
          icon: Icons.save,
        ),
      ],
    );
  }
}
