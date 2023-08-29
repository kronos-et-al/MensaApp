import 'package:test/test.dart';

import './view-model/repository/CanteenTest.dart' as canteen;
import './view-model/repository/LineTest.dart' as line;
import './view-model/repository/MealPlanTest.dart' as meal_plan;
import './view-model/repository/FilterPreferenceTest.dart' as filter;

import './view-model/repository/MealTest.dart' as meal;
import './view-model/repository/SideTest.dart' as side;
import './view-model/repository/ImageDataTest.dart' as image_data;
import './view-model/repository/PriceTest.dart' as price;

import './view-model/ImageAccessTest.dart' as image;
import './view-model/MealPlanAccessTest.dart' as meal_access;
import './view-model/FavoriteMealAccessTest.dart' as favorite;
import './view-model/PreferenceAccessTest.dart' as preference;

import './model/SharedPreferencesTest.dart' as storage;
import './model/api_server/GraphQlServerAccess_test.dart' as api;
import './model/SqLiteAccessTest.dart' as database;

void main() async {
  group("canteen", () => canteen.main());
  group("line", () => line.main());
  group("meal plan", () => meal_plan.main());
  group("filter", () => filter.main());

  group("image", () => image_data.main());
  group("price", () => price.main());
  group("side", () => side.main());
  group("meal", () => meal.main());

  group("favorite access", () => favorite.main());
  group("meal plan access", () => meal_access.main());
  group("image access", () => image.main());
  group("preference access", () => preference.main());

  api.main();
  group("database", () => database.main());
  await storage.main();
}