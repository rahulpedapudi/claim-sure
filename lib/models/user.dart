class User {
  final String id;
  final String phoneNumber;
  final String fullName;
  final String dateOfBirth;
  final String sex;
  final int age;
  final String location;
  final String? nomineeId;
  final String? nomineeRelationship;

  User({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.dateOfBirth,
    required this.sex,
    required this.age,
    required this.location,
    this.nomineeId,
    this.nomineeRelationship,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'sex': sex,
      'age': age,
      'location': location,
      'nomineeId': nomineeId,
      'nomineeRelationship': nomineeRelationship,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      fullName: json['fullName'],
      dateOfBirth: json['dateOfBirth'],
      sex: json['sex'],
      age: json['age'],
      location: json['location'],
      nomineeId: json['nomineeId'],
      nomineeRelationship: json['nomineeRelationship'],
    );
  }
}
