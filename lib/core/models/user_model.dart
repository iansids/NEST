class UserModel {
  final String userId;
  final String username;
  final String? profilePicture;
  final String? bio;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.userId,
    required this.username,
    this.profilePicture,
    this.bio,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  // Convert from Database Map (e.g., JSON/Firestore/Supabase) to Object
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] ?? '',
      username: map['username'] ?? '',
      profilePicture: map['profile_picture'],
      bio: map['bio'],
      followersCount: map['followers_count']?.toInt() ?? 0,
      followingCount: map['following_count']?.toInt() ?? 0,
    );
  }

  // Convert Object to Database Map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'profile_picture': profilePicture,
      'bio': bio,
      'followers_count': followersCount,
      'following_count': followingCount,
    };
  }
}