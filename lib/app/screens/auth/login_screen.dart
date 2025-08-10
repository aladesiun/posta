import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:posta/app/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final loading = controller.isLoading.value;
                return ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          await controller.login(
                            _emailController.text,
                            _passwordController.text,
                          );
                        },
                  child: Text(loading ? 'Loading...' : 'Login'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
