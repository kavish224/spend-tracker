import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'providers/expense_provider.dart';
import 'screens/main_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..init(),
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.systemBlue,
          scaffoldBackgroundColor: Color(0xFF0C0C0E),
          barBackgroundColor: Color(0xFF1C1C1E),
          primaryContrastingColor: CupertinoColors.white,
        ),
        home: const MainNavigation(),
      ),
    );
  }
}
