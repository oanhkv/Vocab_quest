import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../config/design_tokens.dart';
import '../../config/theme.dart';
import '../../providers/user_provider.dart';
import '../../utils/helpers.dart';
import '../../widgets/user_avatar.dart';

/// ✏️ Màn hình chỉnh sửa hồ sơ: đổi tên + upload avatar.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _picker = ImagePicker();

  File? _pickedImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProvider>().user;
    _nameCtrl.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Chọn ảnh avatar',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.camera,
                    color: AppColors.primary),
              ),
              title: const Text('Chụp ảnh'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.image,
                    color: AppColors.secondary),
              ),
              title: const Text('Chọn từ thư viện'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return;
    await _pickImage(source);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // 400x400 quality 75 → ~25-50KB, base64 ~35-70KB (vừa Firestore doc 1MB).
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 75,
      );
      if (picked == null) return;
      setState(() => _pickedImage = File(picked.path));
    } catch (e) {
      if (!mounted) return;
      Helpers.showError(context, 'Không mở được ảnh: $e');
    }
  }

  Future<void> _save() async {
    final userProv = context.read<UserProvider>();
    final user = userProv.user;
    if (user == null) return;

    final newName = _nameCtrl.text.trim();
    if (newName.isEmpty) {
      Helpers.showError(context, 'Tên không được để trống');
      return;
    }

    setState(() => _saving = true);
    try {
      if (newName != user.displayName) {
        await userProv.updateDisplayName(newName);
      }
      if (_pickedImage != null) {
        await userProv.updateAvatar(_pickedImage!);
      }
      if (!mounted) return;
      Helpers.showSuccess(context, 'Đã cập nhật hồ sơ ✅');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Helpers.showError(context, 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProv, _) {
          final user = userProv.user;
          if (user == null) {
            return const Center(child: Text('Vui lòng đăng nhập'));
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Center(child: _buildAvatarEditor(user.avatarUrl, user.displayName)),
                  const SizedBox(height: 24),
                  Text(
                    'Tên hiển thị',
                    style: AppText.caption.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameCtrl,
                    maxLength: 30,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên của bạn',
                      prefixIcon: const Icon(LucideIcons.user),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Email',
                    style: AppText.caption.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    enabled: false,
                    controller: TextEditingController(text: user.email),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.mail),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Lưu thay đổi',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarEditor(String currentUrl, String displayName) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: AppColors.gradientPurple),
          ),
          child: _pickedImage != null
              ? ClipOval(
                  child: Image.file(
                    _pickedImage!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                )
              : UserAvatar(
                  avatarUrl: currentUrl,
                  displayName: displayName,
                  radius: 60,
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: _saving ? null : _showImageSourceSheet,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.camera,
                  color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
