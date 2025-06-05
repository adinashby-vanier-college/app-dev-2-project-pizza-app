import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_project/repositories/firebase/firebase.dart';
import 'package:group_project/screens/login/login_screen.dart';
import 'package:group_project/screens/register/register_cubit/register_cubit.dart';
import 'package:group_project/widgets/custom_text_form_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // bool obscurePassword = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // IconData iconPassword = CupertinoIcons.eye_fill;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFE43C2D),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        "First time?",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Sign up with email",
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      CustomTextFormField(
                        label: 'Full name',
                        hintText: 'Full name',
                        controller: fullNameController,
                        validation: (val) {
                          if (val!.isEmpty) {
                            return 'Please fill in this field';
                          }
                          return null;
                        },
                      ),

                      CustomTextFormField(
                        label: 'Email',
                        hintText: 'Enter your email',
                        controller: emailController,
                        validation: (val) {
                          if (val!.isEmpty) {
                            return 'Please fill in this field';
                          } else if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(val)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      CustomTextFormField(
                        label: 'Password',
                        hintText: '********',
                        controller: passwordController,
                        obscureText: state.obscurePassword,
                        suffixIcon: IconButton(
                          onPressed: () {
                            context
                                .read<RegisterCubit>()
                                .togglePasswordVisibility();
                          },
                          icon: Icon(state.obscurePassword
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill),
                        ),
                        validation: (val) {
                          if (val!.isEmpty) {
                            return 'Please fill in this field';
                          } else if (!RegExp(
                                  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                              .hasMatch(val)) {
                            return 'Password must include uppercase, number, and symbol';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // SIGN UP BUTTON
                      CustomButton(
                        text: "SIGN UP",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            context.read<RegisterCubit>().registerUser(
                                  context: context,
                                  username: fullNameController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: const [
                          Expanded(child: Divider(color: Colors.white70)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "OR SIGN UP WITH",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white70)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: () {
                          // TODO: Google Sign-In
                          context
                              .read<RegisterCubit>().handleGoogleSignIn(context: context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 25,
                              child: Center(
                                child: Image.asset(
                                  'assets/images/google.png',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Text(
                          "Google",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already a user? ",
                            style: TextStyle(color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              "LOGIN",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
