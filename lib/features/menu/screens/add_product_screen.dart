import 'dart:convert';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_event.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _available = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.translate('error')}$e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  Icons.photo_library,
                  AppLocalizations.of(context)!.translate('gallery'),
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildSourceOption(
                  Icons.camera_alt,
                  AppLocalizations.of(context)!.translate('camera'),
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          icon: Icon(icon, size: 32, color: const Color(0xFFFFB74D)),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.05),
            padding: const EdgeInsets.all(20),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Future<String> _processImageToBase64(File image) async {
    final bytes = await image.readAsBytes();
    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 250,
      minHeight: 250,
      quality: 40,
      format: CompressFormat.jpeg,
    );
    final base64String = base64Encode(compressedBytes);
    return 'data:image/jpeg;base64,$base64String';
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.translate('select_image'),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final base64Image = await _processImageToBase64(_selectedImage!);
      final menuItem = MenuItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _categoryController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        imageUrl: base64Image,
        available: _available,
      );

      if (mounted) {
        context.read<MenuBloc>().add(AddMenuItem(menuItem));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.translate('delicacy_added'),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.translate('error')}$e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.translate('new_delicacy'),
          style: GoogleFonts.outfit(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child:
                      _selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 32,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppLocalizations.of(
                                  context,
                                )!.translate('add_photo'),
                                style: GoogleFonts.outfit(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 32),

              _buildGlassInput(
                controller: _categoryController,
                label: AppLocalizations.of(
                  context,
                )!.translate('category_label'),
                icon: Icons.category_outlined,
                hint: AppLocalizations.of(context)!.translate('category_hint'),
                theme: theme,
              ),
              const SizedBox(height: 20),
              _buildGlassInput(
                controller: _nameController,
                label: AppLocalizations.of(
                  context,
                )!.translate('dish_name_label'),
                icon: Icons.restaurant_outlined,
                hint: AppLocalizations.of(context)!.translate('dish_name_hint'),
                theme: theme,
              ),
              const SizedBox(height: 20),
              _buildGlassInput(
                controller: _descriptionController,
                label: AppLocalizations.of(
                  context,
                )!.translate('description_label'),
                icon: Icons.description_outlined,
                hint: AppLocalizations.of(
                  context,
                )!.translate('description_hint'),
                maxLines: 3,
                theme: theme,
              ),
              const SizedBox(height: 20),
              _buildGlassInput(
                controller: _priceController,
                label: AppLocalizations.of(context)!.translate('price_label'),
                icon: Icons.payments_outlined,
                hint: '0.00',
                prefix: 'TKM ',
                isNumeric: true,
                theme: theme,
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: SwitchListTile(
                  title: Text(
                    AppLocalizations.of(context)!.translate('available_label'),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  value: _available,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (value) => setState(() => _available = value),
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveMenuItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isSaving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            AppLocalizations.of(
                              context,
                            )!.translate('save_to_menu'),
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontSize: 16,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    String? hint,
    String? prefix,
    int maxLines = 1,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: theme.colorScheme.primary, // Gold Labels
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Slightly lighter dark
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType:
                isNumeric
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : null,
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 16,
            ), // Readable Input
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.dmSans(
                color: Colors.white.withOpacity(0.3),
              ),
              prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.3)),
              prefixText: prefix,
              prefixStyle: GoogleFonts.dmSans(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return AppLocalizations.of(
                  context,
                )!.translate('required_field');
              if (isNumeric && (double.tryParse(value.trim()) ?? 0) <= 0)
                return AppLocalizations.of(context)!.translate('invalid_price');
              return null;
            },
          ),
        ),
      ],
    );
  }
}
