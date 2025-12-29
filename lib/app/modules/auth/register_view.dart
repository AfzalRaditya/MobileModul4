// lib/app/modules/auth/register_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita pakai controller yang sama dengan Login
    final emailC = TextEditingController();
    final passC = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Baru')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 20),

            // Input Email
            TextField(
              controller: emailC,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),

            // Input Password
            TextField(
              controller: passC,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 25),

            // Tombol Daftar
            Obx(
              () => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {
                          if (emailC.text.isEmpty || passC.text.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Email dan Password wajib diisi",
                            );
                          } else {
                            controller.signUp(emailC.text, passC.text);
                          }
                        },
                        child: const Text("DAFTAR SEKARANG"),
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Tombol Balik ke Login
            TextButton(
              onPressed: () => Get.back(), // Kembali ke halaman Login
              child: const Text("Sudah punya akun? Login disini"),
            ),
          ],
        ),
      ),
    );
  }
}
