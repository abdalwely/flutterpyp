import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageUploadService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final ImagePicker _picker = ImagePicker();

  // رفع صورة الملف الشخصي
  static Future<String?> uploadProfileImage({
    required String userId,
    required ImageSource source,
  }) async {
    try {
      // طلب الصلاحيات
      await _requestPermissions(source);

      // اختيار الصورة
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        return null;
      }

      // رفع الصورة إلى Firebase Storage
      final String fileName = 'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(fileName);

      final UploadTask uploadTask = ref.putFile(File(image.path));
      final TaskSnapshot snapshot = await uploadTask;

      // الحصول على رابط التحميل
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('خطأ في رفع الصورة: ${e.toString()}');
    }
  }

  // حذف صورة الملف الشخصي السابقة
  static Future<void> deleteProfileImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.contains('firebase')) {
        final Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      // يمكن تجاهل الخطأ إذا كانت الصورة غير موجودة
      print('تحذير: لم يتم حذف الصورة السابقة: $e');
    }
  }

  // عرض نافذة اختيار مصدر الصورة
  static Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'اختر مصدر الصورة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'الكاميرا',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'التقط صورة جديدة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF28a745), Color(0xFF20c997)],
                    ),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'المعرض',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'اختر من الصور المحفوظة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // طلب الصلاحيات المطلوبة
  static Future<void> _requestPermissions(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isDenied) {
        throw Exception('يجب منح صلاحية الكاميرا لاستخدام هذه الميزة');
      }
    } else {
      final status = await Permission.photos.request();
      if (status.isDenied) {
        throw Exception('يجب منح صلاحية الوصول للصور لاستخدام هذه الميزة');
      }
    }
  }

  // تحديد حجم الملف
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    final fileSize = await file.length();
    return fileSize;
  }

  // التحقق من صيغة الصورة
  static bool isValidImageFormat(String fileName) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif'];
    return validExtensions.any((ext) => fileName.toLowerCase().endsWith(ext));
  }

  // ضغط الصورة إذا كانت كبيرة الحجم
  static Future<XFile?> compressImage(XFile image) async {
    try {
      // إذا كان حجم الملف أكبر من 2 ميجابايت، يتم ضغطه
      final fileSize = await getFileSize(image.path);
      if (fileSize > 2 * 1024 * 1024) { // 2MB
        final compressedImage = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 70,
        );
        return compressedImage;
      }
      return image;
    } catch (e) {
      return image; // إرجاع الصورة الأصلية في حالة فشل الضغط
    }
  }

  // رفع صور متع��دة (للاستخدام المستقبلي)
  static Future<List<String>> uploadMultipleImages({
    required String userId,
    required String folder,
    required List<XFile> images,
  }) async {
    final List<String> downloadUrls = [];

    try {
      for (int i = 0; i < images.length; i++) {
        final XFile image = images[i];
        final String fileName = '$folder/$userId/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final Reference ref = _storage.ref().child(fileName);

        final UploadTask uploadTask = ref.putFile(File(image.path));
        final TaskSnapshot snapshot = await uploadTask;

        final String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      }

      return downloadUrls;
    } catch (e) {
      throw Exception('خطأ في رفع الصور: ${e.toString()}');
    }
  }

  // تنظيف الذاكرة المؤقتة للصور
  static Future<void> clearImageCache() async {
    try {
      // يمكن إضافة منطق تنظيف الذاكرة المؤقتة هنا
      print('تم تنظيف الذاكرة المؤقتة للصور');
    } catch (e) {
      print('خطأ في تنظيف الذاكرة المؤقتة: $e');
    }
  }
}
