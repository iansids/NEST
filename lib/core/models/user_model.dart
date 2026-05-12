class UserModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? profilePicture;
  final String? bio;
  final DateTime? dateOfBirth;
  final int followersCount;
  final int followingCount;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.profilePicture,
    this.bio,
    this.dateOfBirth,
    this.followersCount = 0,
    this.followingCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert from Database Map (e.g., JSON/Firestore/Supabase) to Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      profilePicture: map['profile_picture'],
      bio: map['bio'],
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'])
          : null,
      followersCount: map['followers_count']?.toInt() ?? 0,
      followingCount: map['following_count']?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  // Convert Object to Database Map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'username': username,
      'profile_picture': profilePicture,
      'bio': bio,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'followers_count': followersCount,
      'following_count': followingCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}