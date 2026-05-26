import 'package:flutter/material.dart';

class TryDemoScreen extends StatefulWidget {
  const TryDemoScreen({super.key});

  @override
  State<TryDemoScreen> createState() => _TryDemoScreenState();
}

class _TryDemoScreenState extends State<TryDemoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Demo'),));
  }
}
