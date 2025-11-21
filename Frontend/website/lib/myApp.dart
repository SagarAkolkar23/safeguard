import 'package:flutter/material.dart';
import 'package:website/core/appRoutes.dart';

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRoutes.MyRouter,
      debugShowCheckedModeBanner: false,
      
    );
  }
}
