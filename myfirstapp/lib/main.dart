import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'first App',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.pink)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 1;
  SharedPreferences? _sp;

  @override
  void setState(VoidCallback fn) {
    SharedPreferences.getInstance().then((sp) {
      _sp = sp;
      });
    super.setState(fn);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                //Expanded(flex: 2, child: Text("count: $_counter")),
                Expanded(
                  flex: 2,
                  child: Image.network(
                    "https://picsum.photos/seed/$_counter/400/300",
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _counter++;
                              });
                            },
                            child: Icon(Icons.plus_one),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _counter--;
                              });
                            },
                            child: Icon(Icons.exposure_neg_1),
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _counter = 0;
                              });
                            },
                            child: Icon(Icons.exposure_zero),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Count: $_counter",
                          style: const TextStyle(color: Colors.black, fontSize: 40),
                        )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: Placeholder()),
        ],
      ),
    );
  }
}
