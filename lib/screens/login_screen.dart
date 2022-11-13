import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/repository/auth_repository.dart';
import 'package:google_docs_clone/utils/colors.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final snackbar = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final responseModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (responseModel.error != null) {
      snackbar.showSnackBar(SnackBar(content: Text(responseModel.error!)));
    } else {
      ref.read(userProvider.notifier).update((state) => responseModel.data);
      navigator.replace('/');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authRepositoryProvider);
    return Scaffold(
        body: Center(
            child: ElevatedButton.icon(
      onPressed: () => signInWithGoogle(ref, context),
      icon: Image.asset(
        'assets/images/google-logo.png',
        height: 20,
      ),
      label: const Text(
        "Sign in with Google",
        style: TextStyle(color: kBlackColor),
      ),
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(150, 50), backgroundColor: kWhiteColor),
    )));
  }
}
