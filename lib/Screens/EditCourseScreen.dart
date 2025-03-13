import 'package:flutter/material.dart';
import 'package:study_course/model/course.dart';
import 'package:study_course/services/firebase_service.dart';

class EditCourseScreen extends StatefulWidget {
  final Course course;

  const EditCourseScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _courseNameController;
  late final TextEditingController _instructorController;
  late final TextEditingController _categoryController;
  
  final FirebaseService _firebaseService = FirebaseService();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นให้กับ text controller
    _courseNameController = TextEditingController(text: widget.course.courseName);
    _instructorController = TextEditingController(text: widget.course.instructor);
    _categoryController = TextEditingController(text: widget.course.category);
  }

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
        title: const Text('แก้ไขคอร์สเรียน'),
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
                // แสดงไอคอนและชื่อคอร์ส
                const SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.edit_note,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                Center(
                  child: Text(
                    widget.course.courseName,
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                
                // ชื่อคอร์สแสดงเป็น disabled เพราะแก้ไขไม่ได้
                TextFormField(
                  controller: _courseNameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อคอร์สเรียน',
                    prefixIcon: Icon(Icons.book_outlined),
                  ),
                  enabled: false,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                
                // ผู้สอนสามารถแก้ไขได้
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
                
                // หมวดหมู่สามารถแก้ไขได้
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
                
                // ปุ่มบันทึกการแก้ไข
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateCourse,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('บันทึกการแก้ไข'),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // ปุ่มลบคอร์สเรียน
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _confirmDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'ลบคอร์สเรียนนี้',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateCourse() async {
    // ตรวจสอบความถูกต้องของฟอร์ม
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // สร้าง object คอร์สที่อัปเดต
        final updatedCourse = widget.course.copyWith(
          instructor: _instructorController.text.trim(),
          category: _categoryController.text.trim(),
        );

        // บันทึกลงฐานข้อมูล
        await _firebaseService.updateCourse(updatedCourse);

        // แสดงข้อความสำเร็จและกลับไปหน้าหลัก
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('แก้ไขคอร์สเรียนสำเร็จ')),
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

  // แสดงกล่องยืนยันการลบคอร์ส
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบคอร์ส "${widget.course.courseName}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCourse();
            },
            child: const Text(
              'ลบ',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ลบคอร์สเรียน
  void _deleteCourse() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // ลบคอร์สจากฐานข้อมูล
      if (widget.course.id != null) {
        await _firebaseService.deleteCourse(widget.course.id!);
      }

      // แสดงข้อความสำเร็จและกลับไปหน้าหลัก
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบคอร์สเรียนสำเร็จ')),
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