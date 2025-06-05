import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String userId;
  final String username;
  final String email;
  final String photoUrl;
  final Timestamp createdDate;

  AppUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.createdDate,
    required this.photoUrl,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> json) {
    return AppUser(
      photoUrl: json['profileUrl'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      createdDate: json['createdDate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'email': email,
        'createdDate': createdDate,
        'profileUrl': photoUrl,
      };
}
