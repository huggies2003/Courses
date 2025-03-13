import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:study_course/model/course.dart';

class FirebaseService {
  // ตั้งค่า collection ตามที่กำหนด
  final CollectionReference coursesCollection = 
      FirebaseFirestore.instance.collection('Courses');

  // เพิ่มคอร์สใหม่
  Future<void> addCourse(Course course) async {
    await coursesCollection.add(course.toMap());
  }

  // ดึงข้อมูลคอร์สทั้งหมด
  Stream<List<Course>> getCourses() {
    return coursesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Course.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
    });
  }

  // แก้ไขข้อมูลคอร์ส (เฉพาะ instructor และ category)
  Future<void> updateCourse(Course course) async {
    if (course.id != null) {
      await coursesCollection.doc(course.id).update({
        'instructor': course.instructor,
        'category': course.category,
      });
    }
  }

  // ลบคอร์ส
  Future<void> deleteCourse(String courseId) async {
    await coursesCollection.doc(courseId).delete();
  }
}