import 'package:app/view/core/icons/navigation/NavigationFavoritesIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationMealPlanIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationSettingsIcon.dart';
import 'package:app/view/favorites/Favorites.dart';
import 'package:app/view/mealplan/MealPlanView.dart';
import 'package:app/view/settings/Settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// This widget is used to display the main page of the app.
class MainPage extends StatefulWidget {
  /// Creates a new MainPage widget.
  /// @param key The key to identify this widget.
  /// @returns A new MainPage widget.
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              const MealPlanView(),
              const Favorites(),
              Settings(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: false,
            elevation: 2,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: const NavigationMealPlanIcon(),
                label: FlutterI18n.translate(context, "common.mealPlan"),
              ),
              BottomNavigationBarItem(
                icon: const NavigationFavoritesIcon(),
                label: FlutterI18n.translate(context, "common.favorites"),
              ),
              BottomNavigationBarItem(
                icon: const NavigationSettingsIcon(),
                label: FlutterI18n.translate(context, "common.settings"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
