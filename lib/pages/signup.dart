import 'package:efrei_ged/supabase.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _form = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var fullNameController = TextEditingController();

  signup(
    BuildContext context,
  ) async {
    if (!_form.currentState!.validate()) {
      return false;
    }

    var email = emailController.text;
    var password = passwordController.text;
    var fullName = fullNameController.text;

    try {
      var res = await supabase.auth.signUp(email: email, password: password);

      if (res.user == null) {
        throw Exception("User not created");
      }

      await supabase.from("User").insert({
        "id": res.user!.id,
        "email": email,
        "fullName": fullName,
      });

      await supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      if (context.mounted) {
        if (e.hashCode == 395351213) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Email déjà utilisé"),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Identifiants incorrects"),
          ));
        }
      }

      return false;
    }

    emailController.clear();
    passwordController.clear();

    return true;
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
              "S'inscrire",
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
                        ? "Nom complet est requis"
                        : value.length <= 2
                            ? "Minimum 2 caractères"
                            : null,
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: "Nom complet",
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  TextFormField(
                    validator: (value) => value == null || value.isEmpty
                        ? "Email est requis"
                        : RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$")
                                .hasMatch(value)
                            ? null
                            : "Invalid email",
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
                if (await signup(context) && context.mounted) {
                  Navigator.of(context).pushNamed("/home");
                }
              },
              child: const Text("S'inscrire"),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed("/login");
              },
              child: const Text("Se connecter"),
            ),
          ],
        ),
      ),
    );
  }
}
