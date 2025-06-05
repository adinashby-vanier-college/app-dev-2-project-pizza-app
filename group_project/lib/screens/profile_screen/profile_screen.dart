import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_project/main.dart';
import 'package:group_project/repositories/models/user.dart';
import 'package:group_project/screens/favorite_pizza/favorite_pizza.dart';
import 'package:group_project/screens/login/login_screen.dart';
import 'package:group_project/screens/order_history/order_history.dart';
import 'package:group_project/screens/profile_screen/logout.dart';
import 'package:group_project/utils/colors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.backgroundColor, // Light top background
        body: Column(
          children: [
            const SizedBox(height: 20),
            // Title
            const Text(
              "Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // White container with rounded top
            Expanded(
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    listUser!.photoUrl.isEmpty
                        ? CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColor.primaryColor,
                            child: Text(
                              listUser!.username.isEmpty
                                  ? "P"
                                  : listUser!.username[0],
                              style:
                                  TextStyle(fontSize: 40, color: Colors.white),
                            ))
                        : CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColor.primaryColor,
                            backgroundImage: NetworkImage(listUser!.photoUrl),
                          ),
                    SizedBox(height: 10),
                    // User info
                    Text(
                      listUser!.username.isEmpty ? "demo" : listUser!.username,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listUser!.email.isEmpty
                          ? "demo@gmail.com"
                          : listUser!.email,
                      style: TextStyle(fontSize: 14),
                    ),

                    const SizedBox(height: 30),

                    // Buttons
                    _buildOptionButton(
                      icon: Iconsax.clock,
                      label: "Order History",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OrderHistoryScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    _buildOptionButton(
                      icon: Iconsax.heart,
                      label: "Favorite Pizza",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FavoritePizza(),
                          ),
                        );
                      },
                    ),
                    const Spacer(),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Logout logic
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Logout()),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                        label: const Text(
                          "Log Out",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      print("User logged out successfully.");
    } catch (e) {
      print("Logout failed: $e");
    }
  }

  void logoutAndNavigateToLogin(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                Text(label, style: const TextStyle(color: Colors.white)),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
