class AppUser {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String photoUrl;
  final String role; // assembler, welder, etc.
  final bool isActive;

  AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.role,
    required this.isActive,
  });

  factory AppUser.fromMap(Map<String, dynamic> m, String id) {
    return AppUser(
      uid: id,
      email: m['email'] ?? '',
      name: m['name'] ?? '',
      phone: m['phone'] ?? '',
      photoUrl: m['photoUrl'] ?? '',
      role: m['role'] ?? '',
      isActive: m['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role,
      'isActive': isActive,
    };
  }
}
