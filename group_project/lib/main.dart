import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_project/repositories/models/user.dart';
import 'package:group_project/screens/Home_screen/home_screen_cubit.dart';
import 'package:group_project/screens/login/login_cubit/login_cubit.dart';
import 'package:group_project/screens/register/register_cubit/register_cubit.dart';
import 'package:group_project/screens/splash/splash_screen.dart';
import 'package:group_project/utils/colors.dart';

AppUser? listUser;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RegisterCubit>(
          create: (_) => RegisterCubit(),
        ),
        BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(),
        ),
        BlocProvider<HomeScreenCubit>(
          create: (_) => HomeScreenCubit(listUser!.userId),
        ),
        // Add more BlocProviders here as needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'group_project',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primaryColor),
            useMaterial3: true,
            primaryColor: AppColor.primaryColor),
        home: SplashScreen(),
      ),
    );
  }
}
