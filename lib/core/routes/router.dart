import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_routes.dart';
import '../../features/call/call.dart';
import '../../injection_container.dart';


final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.home,
      builder: (BuildContext context, GoRouterState state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<CallFetcherBloc>()),
            BlocProvider(create: (_) => sl<CallUiCubit>()),
          ],
          child: const CallPage(),
        );
      },
    ),

  ],
);
