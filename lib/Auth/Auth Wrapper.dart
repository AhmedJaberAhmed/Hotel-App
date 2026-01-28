import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hotel_app/Auth/presentaion/Blocs/Auth%20Bloc/Auth%20Cubit.dart';
import 'package:hotel_app/Auth/presentaion/Blocs/Auth%20Bloc/Auth%20State.dart';
import 'package:hotel_app/Auth/presentaion/pages/signinPage.dart';

// ✅ import your bottom navigation shell

import '../Home/MainShell.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ✅ Authenticated -> show app shell with bottom nav
        if (state is AuthAuthenticated) {
          return const MainShell();
        }

        // Not authenticated -> sign in
        return const SignInScreen();
      },
    );
  }
}
