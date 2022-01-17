import 'package:flutter/material.dart';

import 'pages/product_add_edit.dart';
import 'pages/product_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Node JS',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        routes: {
          '/': (context) => const ProductList(),
          '/add-product': (context) => const ProductAddEdit(),
          '/edit-product': (context) => const ProductAddEdit()
        });
  }
}
