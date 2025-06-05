import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:group_project/main.dart';
import 'package:group_project/repositories/firebase/firebase.dart';
import 'package:group_project/repositories/models/user.dart';
import 'package:group_project/screens/bottom_bar/bottom_bar.dart';
import 'package:group_project/screens/login/login_screen.dart';
import 'package:group_project/utils/loader.dart';
import 'package:group_project/widgets/snackbar.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(RegisterState.initial());

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> registerUser(
      {required String username,
      required String email,
      required String password,
      required BuildContext context}) async {
    emit(state.copyWith(isLoading: true, error: null, isSuccess: false));

    try {
      CommonUtils.showProgressLoading(context);
      // Create user with email and password
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      // Save additional data to Firestore
      await firestore.collection('Users').doc(userId).set({
        'username': username,
        'email': email.toLowerCase(),
        'userId': userId,
        'createdDate': Timestamp.fromDate(DateTime.now()),
        "profileUrl": "",
      });
      await fetchUserByEmail(email);
      showCustomSnackbar(
        context: context,
        title: "SUCCESS",
        message: "Registration successful",
        color: Colors.green,
      );
      // emit(state.copyWith(isLoading: false, isSuccess: true));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      CommonUtils.hideProgressLoading();
      showCustomSnackbar(
        context: context,
        title: "ERROR",
        message: "Something went wrong",
        color: Colors.red,
      );
      debugPrint("$e");
      emit(state.copyWith(isLoading: false, error: e.toString()));
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

  Future<void> handleGoogleSignIn({required BuildContext context}) async {
    try {
      CommonUtils.showProgressLoading(context);
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        // Save user to Firestore if new
        final userDoc =
            FirebaseFirestore.instance.collection('Users').doc(user.uid);

        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'username': user.displayName ?? '',
            'email': user.email ?? '',
            'createdDate': Timestamp.fromDate(DateTime.now()),
            "userId": user.uid,
            "profileUrl": user.photoURL!.isEmpty ? "" : user.photoURL,
          });
        }
        await fetchUserByEmail(user.email!.toLowerCase());
        CommonUtils.hideProgressLoading();
        // Navigate to MainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      CommonUtils.hideProgressLoading();
      showCustomSnackbar(
        context: context,
        title: "ERROR",
        message: "Google login failed",
        color: Colors.red,
      );
    } catch (e) {
      showCustomSnackbar(
        context: context,
        title: "ERROR",
        message: "An unknown error occurred.",
        color: Colors.red,
      );
      CommonUtils.hideProgressLoading();
    }
  }
}
