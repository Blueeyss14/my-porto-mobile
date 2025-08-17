import 'package:flutter/material.dart';
import 'package:my_portfolio/src/shared/components/appbar_custom.dart';

class BackgroundPage extends StatelessWidget {
  const BackgroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: AppbarCustom(title: 'Background Page'));
  }
}
