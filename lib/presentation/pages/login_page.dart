import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

import 'main_navigation_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final _usernameController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: BlocConsumer<AuthBloc, AuthState>(

        listener: (context, state) {

          if (state.user != null) {

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MainNavigationPage(),
              ),
            );
          }
        },

        builder: (context, state) {

          return Center(

            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  const Text(
                    "IoT Heating",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: _usernameController,
                    decoration:
                        const InputDecoration(
                      labelText: "Username",
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(
                      labelText: "Password",
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (state.error != null)
                    Text(
                      state.error!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),

                  const SizedBox(height: 12),

                  ElevatedButton(

                    onPressed: state.loading
                        ? null
                        : () {

                            context
                                .read<AuthBloc>()
                                .add(
                              LoginRequested(
                                _usernameController.text,
                                _passwordController.text,
                              ),
                            );
                          },

                    child: state.loading
                        ? const CircularProgressIndicator()
                        : const Text("Login"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}