import 'package:flutter/material.dart';
import 'package:study_course/model/course.dart';
import 'package:study_course/services/firebase_service.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({Key? key}) : super(key: key);

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _courseNameController.dispose();
    _instructorController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มคอร์สเรียนใหม่'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ไอคอนหนังสือตรงกลาง
                const SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.book,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // ฟอร์มกรอกข้อมูล
                TextFormField(
                  controller: _courseNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อคอร์สเรียน',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่อคอร์สเรียน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _instructorController,
                  decoration: const InputDecoration(
                    labelText: 'ผู้สอน',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกชื่อผู้สอน';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'หมวดหมู่',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณากรอกหมวดหมู่';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // ปุ่มบันทึก
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCourse,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('บันทึกคอร์สเรียน'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveCourse() async {
    // ตรวจสอบความถูกต้องของฟอร์ม
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // สร้าง object คอร์สใหม่
        final newCourse = Course(
          courseName: _courseNameController.text.trim(),
          instructor: _instructorController.text.trim(),
          category: _categoryController.text.trim(),
        );

        // บันทึกลงฐานข้อมูล
        await _firebaseService.addCourse(newCourse);

        // แสดงข้อความสำเร็จและกลับไปหน้าหลัก
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เพิ่มคอร์สเรียนสำเร็จ')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // แสดงข้อความผิดพลาด
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
          );
        }
      } finally {
        // ยกเลิกสถานะกำลังโหลด
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}