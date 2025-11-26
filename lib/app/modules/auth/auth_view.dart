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
                  // --- IKON TAMBAHAN BIAR KELIATAN BEDA ---
                  const Icon(Icons.lock_person, size: 80, color: Colors.brown),
                  const SizedBox(height: 20),

                  const Text(
                    "Masuk Aplikasi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  // Input Email
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),

                  // Input Password
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),

                  // Tombol Login
                  Obx(
                    () => SizedBox(
                      width: double.infinity, // Tombol Login Lebar Full
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                controller.signIn(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          controller.isLoading.value ? 'Loading...' : 'LOGIN',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --- BAGIAN REGISTER (SAYA BUAT MENCOLOK) ---
                  const SizedBox(height: 30),
                  const Divider(), // Garis pemisah
                  const SizedBox(height: 10),
                  const Text("Belum punya akun?"),

                  TextButton(
                    onPressed: () {
                      print(
                        "Tombol Daftar Ditekan!",
                      ); // Cek di terminal kalau diklik
                      Get.toNamed("/register");
                    },
                    child: const Text(
                      "DAFTAR DISINI SEKARANG",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown, // Warna teks coklat biar kelihatan
                        decoration: TextDecoration.underline, // Garis bawah
                      ),
                    ),
                  ),
                  // -------------------------------------------
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
