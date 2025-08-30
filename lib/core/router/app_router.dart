import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    // Rute sementara kosong; di Step 3/4 kita isi.
    GoRoute(
      path: '/',
      builder: (context, state) => const Placeholder(),
    ),
  ],
);
