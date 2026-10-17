import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'providers/app_data_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (ctx) => AppDataProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Earthquake App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.teal,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        builder: EasyLoading.init(),
        home: const HomePage(),
      ),
    ),
  );
}
