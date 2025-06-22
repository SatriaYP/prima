import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../models/member_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/region_provider.dart';
import '../../widgets/prima_app_bar.dart';
import '../../widgets/prima_button.dart';
import '../../widgets/prima_text_field.dart';
import '../../widgets/responsive_layout.dart';

class MemberFormScreen extends StatefulWidget {
  final bool isEditing;
  final Member? member;

  const MemberFormScreen({
    Key? key,
    required this.isEditing,
    this.member,
  }) : super(key: key);

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _birthPlaceController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Dropdown values
  String _gender = 'male';
  String _status = 'active';
  int? _provinceId;
  int? _cityId;
  int? _districtId;
  
  // KTP image
  File? _ktpImage;
  bool _isProcessingOcr = false;
  
  // Date picker
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    
    // Load regions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegionProvider>(context, listen: false).loadRegionData();
    });
    
    // If editing, populate form with member data
    if (widget.isEditing && widget.member != null) {
      _populateFormWithMemberData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _birthPlaceController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populateFormWithMemberData() {
    final member = widget.member!;
    
    _nameController.text = member.name;
    _nikController.text = member.nik;
    _birthPlaceController.text = member.birthPlace;
    _birthDateController.text = member.birthDate;
    _addressController.text = member.address;
    _phoneController.text = member.phone;
    _emailController.text = member.email;
    
    _gender = member.gender;
    _status = member.status;
    _provinceId = member.provinceId;
    _cityId = member.cityId;
    _districtId = member.districtId;
    
    // Parse birth date
    try {
      _selectedDate = DateTime.parse(member.birthDate);
    } catch (e) {
      // Ignore parsing errors
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final croppedImage = await _cropImage(File(image.path));
      if (croppedImage != null) {
        setState(() {
          _ktpImage = croppedImage;
        });
        
        // Process OCR
        await _processOcr();
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio3x2,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop KTP Image',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio3x2,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop KTP Image',
        ),
      ],
    );
    
    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    
    return null;
  }

  Future<void> _processOcr() async {
    if (_ktpImage == null) return;
    
    setState(() {
      _isProcessingOcr = true;
    });
    
    try {
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      final ocrData = await memberProvider.processKtpOcr(_ktpImage!);
      
      if (ocrData != null) {
        // Populate form with OCR data
        setState(() {
          _nameController.text = ocrData['name'] ?? '';
          _nikController.text = ocrData['nik'] ?? '';
          _birthPlaceController.text = ocrData['birth_place'] ?? '';
          
          // Parse birth date
          if (ocrData['birth_date'] != null) {
            _birthDateController.text = ocrData['birth_date'];
            try {
              _selectedDate = DateTime.parse(ocrData['birth_date']);
            } catch (e) {
              // Ignore parsing errors
            }
          }
          
          _addressController.text = ocrData['address'] ?? '';
          
          // Set gender
          if (ocrData['gender'] != null) {
            final genderLower = ocrData['gender'].toString().toLowerCase();
            if (genderLower.contains('laki') || genderLower.contains('male')) {
              _gender = 'male';
            } else if (genderLower.contains('perempuan') || genderLower.contains('female')) {
              _gender = 'female';
            }
          }
          
          // TODO: Match province, city, district from OCR data
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KTP data extracted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process OCR: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessingOcr = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveMember() async {
    if (_formKey.currentState?.validate() ?? false) {
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;
      
      // Prepare member data
      final memberData = {
        'name': _nameController.text.trim(),
        'nik': _nikController.text.trim(),
        'gender': _gender,
        'birth_place': _birthPlaceController.text.trim(),
        'birth_date': _birthDateController.text.trim(),
        'address': _addressController.text.trim(),
        'province_id': _provinceId,
        'city_id': _cityId,
        'district_id': _districtId,
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'status': _status,
        'created_by': currentUser?.id ?? 1,
      };
      
      try {
        if (widget.isEditing && widget.member != null) {
          // Update existing member
          await memberProvider.updateMember(widget.member!.id, memberData);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Member updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          // Create new member
          await memberProvider.createMember(memberData);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Member created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final regionProvider = Provider.of<RegionProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final User? currentUser = authProvider.currentUser;
    final bool isDesktop = ResponsiveLayout.isDesktop(context);
    
    return Scaffold(
      appBar: PrimaAppBar(
        title: widget.isEditing ? 'Edit Member' : 'Add Member',
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
              mobile: _buildMobileLayout(context, regionProvider, memberProvider),
              tablet: _buildTabletLayout(context, regionProvider, memberProvider),
              desktop: _buildDesktopLayout(context, regionProvider, memberProvider),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    RegionProvider regionProvider,
    MemberProvider memberProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKtpImageSection(context, memberProvider),
        const SizedBox(height: 24),
        _buildPersonalInfoSection(context),
        const SizedBox(height: 24),
        _buildAddressSection(context, regionProvider),
        const SizedBox(height: 24),
        _buildContactSection(context),
        const SizedBox(height: 24),
        _buildStatusSection(context),
        const SizedBox(height: 24),
        _buildActionButtons(context, memberProvider),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    RegionProvider regionProvider,
    MemberProvider memberProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKtpImageSection(context, memberProvider),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildPersonalInfoSection(context),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildContactSection(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildAddressSection(context, regionProvider),
        const SizedBox(height: 24),
        _buildStatusSection(context),
        const SizedBox(height: 24),
        _buildActionButtons(context, memberProvider),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    RegionProvider regionProvider,
    MemberProvider memberProvider,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalInfoSection(context),
              const SizedBox(height: 24),
              _buildAddressSection(context, regionProvider),
              const SizedBox(height: 24),
              _buildContactSection(context),
              const SizedBox(height: 24),
              _buildStatusSection(context),
              const SizedBox(height: 24),
              _buildActionButtons(context, memberProvider),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildKtpImageSection(context, memberProvider),
        ),
      ],
    );
  }

  Widget _buildKtpImageSection(
    BuildContext context,
    MemberProvider memberProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KTP Image',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (_ktpImage != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _ktpImage!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _ktpImage = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              )
            else if (widget.isEditing && widget.member?.ktpImageUrl != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.member!.ktpImageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
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
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              )
            else
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 16),
                      const Text('Upload KTP Image'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            PrimaButton(
              text: 'Upload KTP Image',
              onPressed: _pickImage,
              icon: Icons.upload,
              isLoading: _isProcessingOcr,
            ),
            if (_ktpImage != null) ...[
              const SizedBox(height: 8),
              PrimaButton(
                text: 'Process OCR',
                onPressed: _processOcr,
                icon: Icons.document_scanner,
                isLoading: _isProcessingOcr,
                isOutlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            PrimaTextField(
              label: 'Full Name',
              hint: 'Enter full name',
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            PrimaTextField(
              label: 'NIK',
              hint: 'Enter 16-digit NIK',
              controller: _nikController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter NIK';
                }
                if (value.length != 16) {
                  return 'NIK must be 16 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: PrimaTextField(
                    label: 'Birth Place',
                    hint: 'Enter birth place',
                    controller: _birthPlaceController,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter birth place';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PrimaTextField(
                    label: 'Birth Date',
                    hint: 'YYYY-MM-DD',
                    controller: _birthDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter birth date';
                      }
                      return null;
                    },
                    suffix: const Icon(Icons.calendar_today),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Gender',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Male'),
                    value: 'male',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Female'),
                    value: 'female',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection(
    BuildContext context,
    RegionProvider regionProvider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            PrimaTextField(
              label: 'Address',
              hint: 'Enter full address',
              controller: _addressController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _provinceId,
              decoration: InputDecoration(
                labelText: 'Province',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: regionProvider.provinces.map((province) {
                return DropdownMenuItem(
                  value: province.id,
                  child: Text(province.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _provinceId = value;
                  _cityId = null;
                  _districtId = null;
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
            DropdownButtonFormField<int>(
              value: _cityId,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _provinceId != null
                  ? regionProvider.getCitiesByProvinceId(_provinceId!).map((city) {
                      return DropdownMenuItem(
                        value: city.id,
                        child: Text(city.name),
                      );
                    }).toList()
                  : [],
              onChanged: _provinceId != null
                  ? (value) {
                      setState(() {
                        _cityId = value;
                        _districtId = null;
                      });
                    }
                  : null,
              validator: (value) {
                if (value == null) {
                  return 'Please select city';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _districtId,
              decoration: InputDecoration(
                labelText: 'District',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _cityId != null
                  ? regionProvider.getDistrictsByCityId(_cityId!).map((district) {
                      return DropdownMenuItem(
                        value: district.id,
                        child: Text(district.name),
                      );
                    }).toList()
                  : [],
              onChanged: _cityId != null
                  ? (value) {
                      setState(() {
                        _districtId = value;
                      });
                    }
                  : null,
              validator: (value) {
                if (value == null) {
                  return 'Please select district';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            PrimaTextField(
              label: 'Phone Number',
              hint: 'Enter phone number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membership Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Active'),
                ),
                DropdownMenuItem(
                  value: 'inactive',
                  child: Text('Inactive'),
                ),
                DropdownMenuItem(
                  value: 'pending',
                  child: Text('Pending'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    MemberProvider memberProvider,
  ) {
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
          text: widget.isEditing ? 'Update Member' : 'Save Member',
          onPressed: _saveMember,
          isLoading: memberProvider.isLoading,
          icon: Icons.save,
        ),
      ],
    );
  }
}
