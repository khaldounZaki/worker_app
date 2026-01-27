import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/auth/login_page.dart';
import 'views/home/home_page.dart';
import 'utils/constants.dart';

class WorkerApp extends StatelessWidget {
  const WorkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worker App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          if (user == null) return const LoginPage();
          // If user is logged in, show HomePage; HomePage will check activation status
          return const HomePage();
        },
      ),
      debugShowCheckedModeBanner: false,
      routes: {Routes.login: (_) => const LoginPage()},
    );
  }
}
