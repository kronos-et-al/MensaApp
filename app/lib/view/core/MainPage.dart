import 'package:app/view/core/icons/navigation/NavigationFavoritesIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationMealPlanIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationSettingsIcon.dart';
import 'package:app/view/mealplan/MealPlanView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class MainPage extends StatefulWidget {
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
              MealPlanView(),
              Container(color: Colors.green),
              Container(color: Colors.blue),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: false,
            elevation: 2,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: [
              BottomNavigationBarItem(
                icon: NavigationMealPlanIcon(),
                label: FlutterI18n.translate(context, "common.mealPlan"),
              ),
              BottomNavigationBarItem(
                icon: NavigationFavoritesIcon(),
                label: FlutterI18n.translate(context, "common.favorites"),
              ),
              BottomNavigationBarItem(
                icon: NavigationSettingsIcon(),
                label: FlutterI18n.translate(context, "common.settings"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
