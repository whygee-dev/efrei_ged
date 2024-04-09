import 'dart:async';

import 'package:efrei_ged/supabase.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  login(
    BuildContext context,
  ) async {
    if (!_form.currentState!.validate()) {
      return false;
    }

    var email = emailController.text;
    var password = passwordController.text;

    try {
      var res = await supabase.auth
          .signInWithPassword(email: email, password: password);

      if (res.user == null) {
        throw Exception("User not found");
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Identifiants incorrects"),
        ));
      }

      return false;
    }

    emailController.clear();
    passwordController.clear();

    return true;
  }

  StreamSubscription<AuthState>? subscription;

  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    subscription?.cancel();
    super.dispose();
  }

  void _setupAuthListener() {
    subscription = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushNamed("/home");
      }

      if (event == AuthChangeEvent.initialSession) {
        if (supabase.auth.currentUser != null) {
          Navigator.of(context).pushNamed("/home");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Efrei GED",
              style: Theme.of(context).textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 100.0),
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    validator: (value) => value == null || value.isEmpty
                        ? "Email est requis"
                        : RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$")
                                .hasMatch(value)
                            ? null
                            : "Email invalide",
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe",
                    ),
                    controller: passwordController,
                    validator: (value) => value == null || value.isEmpty
                        ? "Mot de passe est requis"
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50.0),
            ElevatedButton(
              onPressed: () async {
                if (await login(context) && context.mounted) {
                  Navigator.of(context).pushNamed("/home");
                }
              },
              child: const Text("Se connecter"),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/signup");
              },
              child: const Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
