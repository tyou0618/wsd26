import 'package:flutter/material.dart'; // Flutterの画面(UI)を作るためのライブラリ
import 'package:shared_preferences/shared_preferences.dart'; // スマホ内に簡単なデータを保存するためのライブラリ
import 'package:firebase_core/firebase_core.dart'; // Firebaseを使うための基本ライブラリ
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore(Database)を操作するためのライブラリ
import 'firebase_options.dart'; // Firebaseの接続設定ファイル
import 'dart:convert'; // JSON形式のデータを変換するためのライブラリ
import 'package:http/http.dart' as http; // API通信をするためのライブラリ

// =========================
// アプリ起動時に最初に実行
// =========================
void main() async {
  // Flutter内部の初期化
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase初期化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // アプリ開始
  runApp(const MyApp());
}

// =========================
// アプリ全体
// =========================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // アプリタイトル
      title: 'First App',

      // アプリのデザインテーマ
      theme: ThemeData(
        // ピンク色ベース
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
      ),

      // 最初に表示する画面
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

// =========================
// メイン画面
// =========================
class MyHomePage extends StatefulWidget {
  // コンストラクタ
  const MyHomePage({super.key, required this.title});

  // タイトル
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// =========================
// 状態管理クラス
// =========================
class _MyHomePageState extends State<MyHomePage> {
  // 現在のカウンタ値
  int _counter = 0;

  // 過去最大値
  int _maxCounter = 0;

  // Firestoreから取得したメッセージ
  String _message = "(message)";

  // 気温表示用
  String _weather = "";

  // 天気アイコンURL
  String _icon = "";

  // ローカル保存用
  SharedPreferences? _sp;

  // Firestoreインスタンス作成
  final db = FirebaseFirestore.instance;

  // =========================
  // 初回のみ実行
  // =========================
  @override
  void initState() {
    super.initState();

    // ローカル保存データ読み込み
    _loadData();

    // Firestore監視開始
    _listenMessage();

    // 天気取得
    _getWeather();
  }

  // =========================
  // SharedPreferences読み込み
  // =========================
  Future<void> _loadData() async {
    // SharedPreferences取得
    _sp = await SharedPreferences.getInstance();

    // 保存済み最大値取得
    // 無ければ0
    int savedMax = _sp?.getInt('maxCount') ?? 0;

    // 画面更新
    setState(() {
      // 最大値セット
      _maxCounter = savedMax;

      // 起動時は最大値から開始
      _counter = savedMax;
    });
  }

  // =========================
  // Firestoreメッセージ監視
  // =========================
  void _listenMessage() {
    // messagesコレクションの
    // newドキュメントを取得
    final ref = db.collection("messages").doc("new");

    // リアルタイム監視
    ref.snapshots().listen((snapshot) {
      // ドキュメント存在確認
      if (snapshot.exists) {
        // データ取得
        final data = snapshot.data();

        // デバッグ表示
        print(data);

        // nullでなければ
        if (data != null) {
          // 画面更新
          setState(() {
            // messageフィールド取得
            _message = data["message"];
          });
        }
      }
    });
  }

  // =========================
  // 天気取得
  // =========================
  Future<void> _getWeather() async {
    final url = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?id=1853908&appid=d17a39332aa5157e0688db8188c87507&units=metric",
    );

    try {
      final resp = await http.get(url);

      print(resp.statusCode);
      print(resp.body);

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);

        final temp = data["main"]["temp"];

        final weather = data["weather"];

        final icon = weather[0]["icon"];

        setState(() {
          // 気温
          _weather = "$temp °C";

          // アイコン
          _icon = "https://openweathermap.org/img/wn/$icon@2x.png";
        });

        print(_weather);
        print(_icon);
      } else {
        setState(() {
          _weather = "API Error";
        });
      }
    } catch (e) {
      print(e);

      setState(() {
        _weather = "通信失敗";
      });
    }
  }

  // =========================
  // カウンタ更新
  // =========================
  void _setCounter(int value) {
    // 画面更新
    setState(() {
      // カウンタ変更
      _counter = value;

      // 最大値更新
      if (_counter > _maxCounter) {
        _maxCounter = _counter;
      }
    });

    // =========================
    // ローカル保存
    // =========================

    // 現在値保存
    _sp?.setInt('count', _counter);

    // 最大値保存
    _sp?.setInt('maxCount', _maxCounter);

    // =========================
    // Firestore保存
    // =========================
    db.collection("state").doc("current").set({
      // 現在値
      "count": _counter,

      // 最大値
      "maxCount": _maxCounter,
    });
  }

  // =========================
  // 画面UI作成
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 上部バー
      appBar: AppBar(
        // 色設定
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        // タイトル表示
        title: Text(widget.title),
      ),

      // =========================
      // メイン画面
      // =========================
      body: Column(
        children: [
          Expanded(
            flex: 2,

            child: Row(
              children: [
                // =========================
                // 左側
                // =========================
                Expanded(
                  flex: 2,

                  child: Column(
                    children: [
                      // ランダム画像表示
                      Expanded(
                        child: Image.network(
                          // カウンタ値で画像変更
                          "https://picsum.photos/seed/$_counter/400/300",
                        ),
                      ),

                      const SizedBox(height: 10),

                      // カウンタ表示
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

                // =========================
                // 右側ボタン群
                // =========================
                Expanded(
                  child: Column(
                    children: [
                      // +1ボタン
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () {
                              // カウンタ+1
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
                              // カウンタ-1
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

                      // API通信テストボタン
                      Expanded(
                        child: FittedBox(
                          child: ElevatedButton(
                            onPressed: () async {
                              // URL作成
                              final url = Uri.parse(
                                "https://jsonplaceholder.typicode.com/posts",
                              );

                              // 送信データ
                              final data = {
                                "title": "test You",
                                "body": "test message",
                                "userId": 1,
                              };

                              // POST通信
                              final resp = await http.post(
                                url,

                                headers: {"Content-Type": "application/json"},

                                body: jsonEncode(data),
                              );

                              // 結果表示
                              print(resp.statusCode);
                              print(resp.body);
                            },

                            child: const Icon(Icons.api),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // =========================
          // 下半分
          // =========================
          // ===== 下半分 =====
          Expanded(
            flex: 1,

            child: Row(
              children: [
                // ===== 左側：Firestore入力 =====
                Expanded(
                  flex: 1,

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        // Firestoreメッセージ表示
                        Text(_message, style: const TextStyle(fontSize: 24)),

                        const SizedBox(height: 20),

                        // 入力欄
                        TextField(
                          onSubmitted: (s) {
                            db.collection("messages").doc("new").set({
                              "message": s,
                            });
                          },

                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),

                            hintText: "メッセージ入力",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ===== 右側：天気 =====
                Expanded(
                  flex: 1,

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text(
                        "Weather",

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // アイコン
                      if (_icon.isNotEmpty) Image.network(_icon, width: 80),

                      // 気温
                      Text(_weather, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
