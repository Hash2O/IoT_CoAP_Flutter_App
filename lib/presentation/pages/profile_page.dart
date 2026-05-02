// import 'package:flutter/material.dart';

// class ProfilePage extends StatelessWidget {
//   const ProfilePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           "User Profile",
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Profile"),
      ),

      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {

          final user = state.user;

          if (user == null) {
            return const Center(
              child: Text("No user connected"),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  "Welcome ${user.username}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                Text("Role: ${user.role}"),

                const SizedBox(height: 10),

                Text("User ID: ${user.id}"),

                const Spacer(),

                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),

                  onPressed: () {

                    context.read<AuthBloc>().add(
                      LogoutRequested(),
                    );

                    Navigator.pushReplacementNamed(
                      context,
                      '/',
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}