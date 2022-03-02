import 'package:flutter/material.dart';
import 'package:flutter_puzzle_hack/app/app_provider.dart';
import 'package:flutter_puzzle_hack/app/application.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>(
          create: (context) => AppProvider(),
        )
      ],
      child: const SlidePuzzleApp(),
    ),
  );
}
