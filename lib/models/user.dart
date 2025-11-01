class User {
  final String uid;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? contactNumber1;
  final String? contactNumber2;
  final String? driversLicenseFront;
  final String? driversLicenseBack;
  final String? profilePic;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.uid,
    this.firstName,
    this.lastName,
    required this.email,
    this.contactNumber1,
    this.contactNumber2,
    this.driversLicenseFront,
    this.driversLicenseBack,
    this.profilePic,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'].toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      email: json['email'].toString(),
      contactNumber1: json['contact_number1']?.toString(),
      contactNumber2: json['contact_number2']?.toString(),
      driversLicenseFront: json['drivers_license_front']?.toString(),
      driversLicenseBack: json['drivers_license_back']?.toString(),
      profilePic: json['profile_pic']?.toString(),
      role: json['role']?.toString() ?? 'User',
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'contact_number1': contactNumber1,
      'contact_number2': contactNumber2,
      'drivers_license_front': driversLicenseFront,
      'drivers_license_back': driversLicenseBack,
      'profile_pic': profilePic,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
