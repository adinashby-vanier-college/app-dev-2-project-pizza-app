import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_project/main.dart';
import 'package:group_project/repositories/models/user.dart';
import 'package:group_project/screens/bottom_bar/bottom_bar.dart';
import 'package:group_project/screens/login/login_screen.dart';
import 'package:group_project/utils/image_path.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await fetchUserByEmail(user.uid);
        // User is logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        // User is NOT logged in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }
  fetchUserByEmail(String id) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('userId', isEqualTo: id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        listUser = AppUser.fromFirestore(
            snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        print("❌ No user found with email: $id");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching user by email: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          ImagePath.appLogo,
          width: double.infinity, // Optional: adjust size
        ),
      ),
    );
  }
}
