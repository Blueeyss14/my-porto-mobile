import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/routes/routes_name.dart';
import 'package:my_portfolio/src/routes/routes_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true,
      debugShowCheckedModeBanner: false,
      initialRoute: RoutesName.home,
      getPages: RoutesPage.pages,
    );
  }
}
