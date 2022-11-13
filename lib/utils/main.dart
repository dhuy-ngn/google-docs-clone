import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs_clone/models/response_model.dart';
import 'package:google_docs_clone/repository/auth_repository.dart';
import 'package:google_docs_clone/utils/router.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(const ProviderScope(child: FlutterApp()));
}

class FlutterApp extends ConsumerStatefulWidget {
  const FlutterApp({super.key});

  @override
  ConsumerState<FlutterApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<FlutterApp> {
  ResponseModel? responseModel;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    responseModel = await ref.read(authRepositoryProvider).getUserData();

    if (responseModel != null && responseModel!.data != null) {
      ref.read(userProvider.notifier).update((state) => responseModel!.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routeInformationParser: const RoutemasterParser(),
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        final user = ref.watch(userProvider);
        if (user != null && user.token.isNotEmpty) {
          return loggedInRoute;
        }
        return loggedOutRoute;
      }),
    );
  }
}
