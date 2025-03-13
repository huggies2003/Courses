class Course {
  String? id;
  String courseName;
  String instructor;
  String category;

  Course({
    this.id,
    required this.courseName,
    required this.instructor,
    required this.category,
  });

  // แปลงข้อมูลจาก Firestore มาเป็น Object
  factory Course.fromMap(Map<String, dynamic> data, String documentId) {
    return Course(
      id: documentId,
      courseName: data['courseName'] ?? '',
      instructor: data['instructor'] ?? '',
      category: data['category'] ?? '',
    );
  }

  // แปลงข้อมูลจาก Object ไปเป็นรูปแบบที่ Firestore ต้องการ
  Map<String, dynamic> toMap() {
    return {
      'courseName': courseName,
      'instructor': instructor,
      'category': category,
    };
  }

  // สร้าง Course ใหม่จาก course ที่มีอยู่แล้ว (ใช้สำหรับการแก้ไข)
  Course copyWith({
    String? courseName,
    String? instructor,
    String? category,
  }) {
    return Course(
      id: this.id,
      courseName: courseName ?? this.courseName,
      instructor: instructor ?? this.instructor,
      category: category ?? this.category,
    );
  }
}