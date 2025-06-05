import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_project/main.dart';
import 'package:group_project/repositories/firebase/firebase.dart';
import 'package:group_project/screens/bottom_bar/bottom_bar.dart';
import 'package:group_project/utils/loader.dart';
import 'package:group_project/widgets/snackbar.dart';
import 'package:meta/meta.dart';

import '../../../repositories/models/user.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState.initial());
  final FirebaseAuth auth = FirebaseAuth.instance;

  void login(
      {required String email,
      required String password,
      required BuildContext context}) async {
    try {
      CommonUtils.showProgressLoading(context);
      final querySnapshot =
          await users.where('email', isEqualTo: email.toLowerCase()).get();

      if (querySnapshot.docs.isEmpty) {
        CommonUtils.hideProgressLoading();
        showCustomSnackbar(
          context: context,
          title: "ERROR",
          message: "User not registered.",
          color: Colors.red,
        );
        return;
      }

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email.toLowerCase(),
        password: password,
      );

      if (userCredential.user != null) {
        await fetchUserByEmail(email.toLowerCase());
        showCustomSnackbar(
          context: context,
          title: "SUCCESS",
          message: "login successful",
          color: Colors.green,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        CommonUtils.hideProgressLoading();
        showCustomSnackbar(
          context: context,
          title: "ERROR",
          message: "Incorrect password.",
          color: Colors.red,
        );
      }
    } catch (e) {
      CommonUtils.hideProgressLoading();
      debugPrint("$e");
    }
  }

  fetchUserByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (snapshot.docs.isNotEmpty) {
        listUser = AppUser.fromFirestore(
            snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        print("❌ No user found with email: $email");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching user by email: $e");
      return null;
    }
  }

  void togglePasswordVisibility() {
    state.obscurePassword = !state.obscurePassword;

    emit(state.copyWith(obscurePassword: state.obscurePassword));
  }
}
