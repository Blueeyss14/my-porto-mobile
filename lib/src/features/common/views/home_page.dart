import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/common/viewmodels/home_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeC = Get.find<HomeViewmodel>();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Home'),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: homeC.home.length,
          itemBuilder: (context, index) => ListTile(
            onTap: () => Get.toNamed(homeC.home[index].route),
            title: Text(homeC.home[index].page),
          ),
        ),
      ),
    );
  }
}
