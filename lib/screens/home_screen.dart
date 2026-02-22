import 'package:flutter/material.dart';
import 'main_navigation.dart';

@Deprecated('Use MainNavigation as app home.')
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigation();
  }
}
