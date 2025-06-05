import 'package:flutter/material.dart';
import 'package:group_project/screens/Home_screen/home_screen.dart';
import 'package:group_project/screens/cart_screen/cart_screen.dart';
import 'package:group_project/screens/profile_screen/profile_screen.dart';
import 'package:group_project/utils/colors.dart';

class CommonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CommonBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColor.primaryColor,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        _buildNavItem(0, Icons.home, "Home"),
        _buildNavItem(1, Icons.shopping_cart, "Cart"),
        _buildNavItem(2, Icons.person, "Profile"),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = index == currentIndex;

    return BottomNavigationBarItem(
      icon: isSelected
          ? CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(icon, color: AppColor.primaryColor),
      )
          : Icon(icon, color: Colors.white),
      label: label,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false,
      child: Scaffold(
        body: screens[selectedIndex],
        bottomNavigationBar: CommonBottomNavBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
        ),
      ),
    );
  }
}
