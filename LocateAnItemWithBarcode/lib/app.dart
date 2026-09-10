import 'package:flutter/material.dart';

import 'screens/camera_screen.dart';
import 'screens/home_screen.dart';

class LocateItemApp extends StatelessWidget {
  const LocateItemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == CameraScreen.routeName) {
          final CameraScreenArgs args = settings.arguments as CameraScreenArgs;
          return MaterialPageRoute<void>(
            builder: (_) => CameraScreen(args: args),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
