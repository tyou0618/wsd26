import 'package:flutter/material.dart'; // FlutterのUI部品
import 'package:shared_preferences/shared_preferences.dart'; // ローカル保存用
import 'package:firebase_core/firebase_core.dart'; // Firebase初期化
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore操作
import 'firebase_options.dart'; // Firebase設定ファイル

// アプリ起動時に最初に実行
void main() async {
  // Flutter初期化
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // アプリ起動
  runApp(const MyApp());
}

// アプリ全体
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // アプリタイトル
      title: 'First App',

      // テーマ設定
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      ),

      // 最初に表示する画面
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// メイン画面
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// 状態管理クラス
class _MyHomePageState extends State<MyHomePage> {
  // 現在のカウンタ
  int _counter = 0;

  // 過去最大値
  int _maxCounter = 0;

  // Firestoreから取得したメッセージ
  String _message = "(message)";

  // SharedPreferences
  SharedPreferences? _sp;

  // Firestoreインスタンス
  final db = FirebaseFirestore.instance;

  // 初回のみ実行
  @override
  void initState() {
    super.initState();

    // 保存データ読み込み
    _loadData();

    // Firestore監視開始
    _listenMessage();
  }

  // SharedPreferences読み込み
  Future<void> _loadData() async {
    // SharedPreferences取得
    _sp = await SharedPreferences.getInstance();

    // 保存済み最大値取得
    int savedMax = _sp?.getInt('maxCount') ?? 0;

    setState(() {
      // 最大値セット
      _maxCounter = savedMax;

      // 起動時は最大値から開始
      _counter = savedMax;
    });
  }

  // Firestoreメッセージ監視
  void _listenMessage() {
    // messagesコレクションの
    // newドキュメント監視
    final ref = db.collection("messages").doc("new");

    // リアルタイム監視
    ref.snapshots().listen((snapshot) {
      // ドキュメント存在確認
      if (snapshot.exists) {
        // データ取得
        final data = snapshot.data();

        print(data);

        // nullチェック
        if (data != null) {
          setState(() {
            // messageフィールド取得
            _message = data["message"];
          });
        }
      }
    });
  }

  // カウンタ更新
  void _setCounter(int value) {
    setState(() {
      // カウンタ更新
      _counter = value;

      // 最大値更新
      if (_counter > _maxCounter) {
        _maxCounter = _counter;
      }
    });

    // SharedPreferences保存
    _sp?.setInt('count', _counter);
    _sp?.setInt('maxCount', _maxCounter);

    // Firestore保存
    db.collection("state").doc("current").set({
      // 現在値
      "count": _counter,

      // 最大値
      "maxCount": _maxCounter,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 上部バー
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),

      body: Column(
        children: [
          // 上半分
          Expanded(
            flex: 2,

            child: Row(
              children: [
                // 左側
                Expanded(
                  flex: 2,

                  child: Column(
                    children: [
                      // 画像表示
                      Expanded(
                        child: Image.network(
                          // カウンタ値ごとに画像変更
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

                // 右側ボタン群
                Expanded(
                  child: Column(
                    children: [
                      // +1ボタン
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              // 1増加
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
                              // 1減少
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
                              // 0へ戻す
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

          // 下半分
          Expanded(
            child: Column(
              children: [
                // Firestoreメッセージ表示
                Text(_message),

                // 入力欄
                TextField(
                  // Enter押下時
                  onSubmitted: (s) {
                    // Firestore保存
                    db.collection("messages").doc("new").set({
                      // messageフィールド
                      "message": s,
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
