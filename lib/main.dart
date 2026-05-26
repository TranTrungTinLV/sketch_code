import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sketch/screens/introduce_screen.dart';
import 'package:sketch/screens/try_demo.dart';
import 'package:sketch/screens/editor/editor_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;
        return ScreenUtilInit(
          designSize: isMobile ? const Size(360, 690) : const Size(1920, 1080),

          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp(
            title: 'ArtifyAI - Sketch to Art',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0D1117),
            ),
            home: IntroduceScreen(),
            initialRoute: '/',
            routes: {
              '/introduce': (context) => IntroduceScreen(),
              '/try-demo': (context) => TryDemoScreen(),
              '/editor': (context) => const EditorScreen(),
            },
          ),
        );
      },
    );
  }
}
