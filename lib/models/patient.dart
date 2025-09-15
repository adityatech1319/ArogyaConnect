class Patient {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final String village;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.village,
  });

  // Convert Patient → Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'village': village,
    };
  }

  // Convert Map → Patient
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      village: map['village'],
    );
  }
}
