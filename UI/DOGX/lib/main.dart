import 'package:programmer/json_file_handler.dart';
import 'package:programmer/reg_provider.dart';
import 'package:programmer/register.dart';
import 'package:programmer/register_list.dart';
import 'package:programmer/ui_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {

  RegisterList.chipList = await JsonFileHandler.readChipsFromJsonFile();

  RegisterList.getSendData(RegisterList.chipList.first);

  runApp(ChangeNotifierProvider(
      create: (context) => RegProvider(),
      lazy: false,
      builder: ((context, child) => const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      // Use the default dark theme
      themeMode: ThemeMode.dark,
      // Use dark mode
      home: const UIpage(),
    );
  }
}
