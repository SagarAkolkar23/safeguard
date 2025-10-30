import 'package:go_router/go_router.dart';
import 'package:website/Pages/HIstoryScereen.dart';
import 'package:website/Pages/HomeScreen.dart';
import 'package:website/Pages/LoginScreen.dart';
import 'package:website/Pages/ProfileScreen.dart';
import 'package:website/Pages/SignUpScreen.dart';

class appRoutes {
  static final GoRouter MyRouter = GoRouter(
    initialLocation: "/Login",
    routes: <RouteBase>[
      GoRoute(path: '/Login', builder: (context, state) => LoginScreen()),
      GoRoute(path: '/SignUp', builder: (context, state) => SignUpScreen()),
      GoRoute(path: '/Home', builder: (context, state) => HomeScreen()),
      GoRoute(path: '/History', builder: (context, state) => HistoryPage()),
      GoRoute(path: '/Profile', builder: (context, state) => ProfileScreen()),


    ],
  );
}
