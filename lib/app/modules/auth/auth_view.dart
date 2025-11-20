// lib/app/modules/auth/auth_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: Get.find<AuthController>(), 
      builder: (controller) {
        final emailController = TextEditingController(); 
        final passwordController = TextEditingController(); 

        return Scaffold(
          appBar: AppBar(title: const Text("Login Supabase")),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Masuk untuk Sinkronisasi Cloud", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),

                  Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : () {
                      controller.signIn(emailController.text.trim(), passwordController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50), 
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      controller.isLoading.value ? 'Authenticating...' : 'Login',
                      style: const TextStyle(fontSize: 18),
                    ),
                  )),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}