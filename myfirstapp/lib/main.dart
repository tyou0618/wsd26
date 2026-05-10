import 'package:flutter/material.dart'; // FlutterのUI部品を使う
import 'package:shared_preferences/shared_preferences.dart'; // データ保存用
import 'dart:async'; // 非同期処理(async / await)用
import 'package:firebase_core/firebase_core.dart'; // Firebase初期化用
import 'firebase_options.dart'; // Firebase設定ファイル

// アプリ起動時に最初に呼ばれる関数
void main() async {

  // Flutterの初期化
  WidgetsFlutterBinding.ensureInitialized();

  // Firebaseを初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // アプリ起動
  runApp(const MyApp());
}


// アプリ全体の設定
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      // アプリ名
      title: 'First App',

      // テーマカラー設定
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
        ),
      ),

      // 最初に表示する画面
      home: const MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}


// メイン画面
class MyHomePage extends StatefulWidget {

  // titleを受け取る
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


// 状態を管理するクラス
class _MyHomePageState extends State<MyHomePage> {

  int _counter = 0; // 現在のカウンタ
  int _maxCounter = 0; // 過去最大値

  SharedPreferences? _sp; // 保存機能


  // 画面生成時に1回だけ実行
  @override
  void initState() {
    super.initState();

    // 保存データを読み込む
    _loadData();
  }


  // 保存データ読み込み
  Future<void> _loadData() async {

    // SharedPreferences取得
    _sp = await SharedPreferences.getInstance();

    // 保存済み最大値を取得
    // もし存在しなければ0
    int savedMax = _sp?.getInt('maxCount') ?? 0;

    setState(() {

      // 最大値セット
      _maxCounter = savedMax;

      // 起動時は最大値から開始
      _counter = savedMax;
    });
  }


  // カウンタ更新関数
  void _setCounter(int value) {

    setState(() {

      // カウンタ更新
      _counter = value;

      // 最大値より大きければ更新
      if (_counter > _maxCounter) {
        _maxCounter = _counter;
      }
    });

    // データ保存
    _sp?.setInt('count', _counter); // 現在値保存
    _sp?.setInt('maxCount', _maxCounter); // 最大値保存
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // 上部バー
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      body: Column(
        children: [

          // 上半分
          Expanded(
            flex: 2,

            child: Row(
              children: [

                // 左側(画像とテキスト)
                Expanded(
                  flex: 2,

                  child: Column(
                    children: [

                      // 画像表示
                      Expanded(
                        child: Image.network(

                          // カウンタ値ごとに違う画像
                          "https://picsum.photos/seed/$_counter/400/300",
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 現在値表示
                      Text(
                        "Count: $_counter",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // 最大値表示
                      Text(
                        "Max Count: $_maxCounter",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),


                // 右側(ボタン)
                Expanded(
                  child: Column(
                    children: [

                      // +1ボタン
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {

                              // カウンタを1増やす
                              _setCounter(_counter + 1);
                            },
                            child: const Icon(Icons.plus_one),
                          ),
                        ),
                      ),


                      // -1ボタン
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {

                              // カウンタを1減らす
                              _setCounter(_counter - 1);
                            },
                            child: const Icon(Icons.exposure_neg_1),
                          ),
                        ),
                      ),


                      // リセットボタン
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {

                              // 0に戻す
                              _setCounter(0);
                            },
                            child: const Icon(Icons.refresh),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),


          // 下半分(仮の空領域)
          const Expanded(
            child: Placeholder(),
          ),
        ],
      ),
    );
  }
}