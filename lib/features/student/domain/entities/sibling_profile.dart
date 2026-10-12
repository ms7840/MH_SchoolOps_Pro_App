/// Domain entity representing a student sibling profile linked to a parent account.
class SiblingProfile {
  final String studentId;
  final String fullName;
  final String admissionNumber;
  final String classSection;
  final String? photoUrl;
  final String rollNumber;

  const SiblingProfile({
    required this.studentId,
    required this.fullName,
    required this.admissionNumber,
    required this.classSection,
    this.photoUrl,
    this.rollNumber = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SiblingProfile &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId;

  @override
  int get hashCode => studentId.hashCode;
}
