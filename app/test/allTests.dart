import './view-model/repository/CanteenTest.dart' as canteen;
import './view-model/repository/LineTest.dart' as line;
import './view-model/repository/MealPlanTest.dart' as mealPlan;
import './view-model/repository/FilterPreferenceTest.dart' as filter;

import './view-model/repository/MealTest.dart' as meal;
import './view-model/repository/SideTest.dart' as side;
import './view-model/repository/ImageDataTest.dart' as imageData;
import './view-model/repository/PriceTest.dart' as price;

import './view-model/ImageAccessTest.dart' as image;
import './view-model/MealPlanAccessTest.dart' as mealAccess;
import './view-model/FavoriteMealAccessTest.dart' as favorite;
import './view-model/PreferenceAccessTest.dart' as preference;

import './model/SharedPreferencesTest.dart' as storage;
import './model/api_server/GraphQlServerAccess_test.dart' as api;

void main() async {
  canteen.main();
  line.main();
  mealPlan.main();
  filter.main();

  imageData.main();
  price.main();
  side.main();
  meal.main();

  favorite.main();
  mealAccess.main();
  image.main();
  preference.main();

  await storage.main();
  api.main();
}