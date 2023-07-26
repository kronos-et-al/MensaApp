import 'package:app/model/api_server/GraphQlServerAccess.dart';
import 'package:app/model/api_server/config.dart';
import 'package:app/model/database/SQLiteDatabaseAccess.dart';
import 'package:app/model/local_storage/SharedPreferenceAccess.dart';
import 'package:app/view/core/MainPage.dart';
import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/icons/navigation/NavigationFilterOutlinedIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationListOutlinedIcon.dart';
import 'package:app/view/core/meal_view_format/MealGrid.dart';
import 'package:app/view/core/selection_components/MensaDropdown.dart';
import 'package:app/view/core/selection_components/MensaDropdownEntry.dart';
import 'package:app/view/mealplan/MealPlanClosed.dart';
import 'package:app/view/mealplan/MealPlanDateSelect.dart';
import 'package:app/view/mealplan/MealPlanError.dart';
import 'package:app/view/mealplan/MealPlanFilter.dart';
import 'package:app/view/mealplan/MealPlanNoData.dart';
import 'package:app/view/mealplan/MealPlanToolbar.dart';
import 'package:app/view/mealplan/MealPlanView.dart';
import 'package:app/view_model/logic/favorite/FavoriteMealAccess.dart';
import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/logic/image/ImageAccess.dart';
import 'package:app/view_model/logic/meal/CombinedMealPlanAccess.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/logic/preference/PreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/data_classes/settings/MensaColorScheme.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:app/view_model/repository/interface/ILocalStorage.dart';
import 'package:app/view_model/repository/interface/IServerAccess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final FlutterI18nDelegate delegate = FlutterI18nDelegate(
    translationLoader: NamespaceFileTranslationLoader(namespaces: [
      "common",
      "ratings",
      "snackbar",
      "settings",
      "priceCategory",
      "mensaColorScheme",
      "filter",
      "image",
      "reportReason",
      "additive",
      "allergen"
    ], useCountryCode: false, basePath: 'assets/locales', fallbackDir: 'de'),
    missingTranslationHandler: (key, locale) {
      if (kDebugMode) {
        print("--- Missing Key: $key, languageCode: ${locale!.languageCode}");
      }
    },
  );
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MensaApp(
    delegate: delegate,
  ));
}

class MensaApp extends StatelessWidget {
  final FlutterI18nDelegate _delegate;

  const MensaApp({super.key, required FlutterI18nDelegate delegate})
      : _delegate = delegate;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, sharedPreferences) {
          if (!sharedPreferences.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (sharedPreferences.hasError) {
            return Center(child: Text(sharedPreferences.error.toString()));
          }
          ILocalStorage sharedPreferencesAccess =
              SharedPreferenceAccess(sharedPreferences.requireData);
          IDatabaseAccess db = SQLiteDatabaseAccess();
          IServerAccess api = GraphQlServerAccess(testServer, testApiKey,
              sharedPreferencesAccess.getClientIdentifier() ?? "");
          return MultiProvider(
              providers: [
                ChangeNotifierProvider<IMealAccess>(
                    create: (context) => CombinedMealPlanAccess(
                          sharedPreferencesAccess,
                          api,
                          db,
                        )),
                ChangeNotifierProvider<IFavoriteMealAccess>(
                    create: (context) => FavoriteMealAccess(db)),
                ChangeNotifierProvider<IPreferenceAccess>(
                    create: (context) =>
                        PreferenceAccess(sharedPreferencesAccess)),
                ChangeNotifierProvider<IImageAccess>(
                    create: (context) => ImageAccess(api)),
              ],
              child: Consumer<IPreferenceAccess>(
                builder: (context, preferenceAccess, child) => MaterialApp(
                  title: 'Mensa App',
                  themeMode: (() {
                    switch (preferenceAccess.getColorScheme()) {
                      case MensaColorScheme.light:
                        return ThemeMode.light;
                      case MensaColorScheme.dark:
                        return ThemeMode.dark;
                      case MensaColorScheme.system:
                        return ThemeMode.system;
                    }
                  }()),
                  localizationsDelegates: [
                    _delegate,
                    ...GlobalMaterialLocalizations.delegates,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('de'),
                  ],
                  theme: ThemeData(
                    useMaterial3: true,
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
                    useMaterial3: true,
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
                  home: MainPage()
                ),
              ));
        });
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
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Container(
        color: Theme.of(context).colorScheme.background,
        child: SafeArea(
            child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: MealPlanView(),
        )));
  }
}
