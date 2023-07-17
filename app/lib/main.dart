import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  final FlutterI18nDelegate delegate = FlutterI18nDelegate(
    translationLoader: NamespaceFileTranslationLoader(
        namespaces: ["common"],
        useCountryCode: false,
        basePath: 'assets/locales',
        fallbackDir: 'de'),
    missingTranslationHandler: (key, locale) {
      if (kDebugMode) {
        print("--- Missing Key: $key, languageCode: ${locale!.languageCode}");
      }
    },
  );
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp(
    delegate: delegate,
  ));
}

class MyApp extends StatelessWidget {
  final FlutterI18nDelegate _delegate;

  const MyApp({super.key, required FlutterI18nDelegate delegate})
      : _delegate = delegate;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mensa App',
      localizationsDelegates: [
        _delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF7AAC2B),
            onPrimary: Color(0xFFFFFFFF),
            secondary: Color(0xFF7AAC2B),
            onSecondary: Color(0xFFFFFFFF),
            error: Color(0xFFD32F2F),
            onError: Color(0xFFFFFFFF),
            background: Color(0xFFFFFFFF),
            onBackground: Color(0xFF000000),
            surface: Color(0xFFF6F6F6),
            onSurface: Color(0xFF000000)),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme(
            brightness: Brightness.dark,
            primary: Color(0xFF7AAC2B),
            onPrimary: Color(0xFFFFFFFF),
            secondary: Color(0xFF7AAC2B),
            onSecondary: Color(0xFFFFFFFF),
            error: Color(0xFFD32F2F),
            onError: Color(0xFFFFFFFF),
            background: Color(0xFF1E1E1E),
            onBackground: Color(0xFFFFFFFF),
            surface: Color(0xFF333333),
            surfaceTint: Color(0xFF202020),
            onSurface: Color(0xFFFFFFFF)),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            I18nText("common.demo"),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
