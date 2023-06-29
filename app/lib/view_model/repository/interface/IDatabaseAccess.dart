import '../data_classes/meal/Meal.dart';
import '../data_classes/mealplan/Canteen.dart';
import '../data_classes/mealplan/Mealplan.dart';

/// This is an interface to the database of the client.
abstract class IDatabaseAccess {
  /// This method updates all mealplans with the committed mealplans.
  Future<void> updateAll(List<Mealplan> mealplans);

  /// This method returns the mealplan of the committed date of the committed canteen.
  Future<Result<List<Mealplan>>> getMealPlan(DateTime date, Canteen canteen);

  /// This method returns a favorite meal.
  Future<Result<Meal>> getMealFavorite(String id);

  /// This method adds a favorite. If the favorite does already exists, it does nothing.
  Future<void> addFavorite(Meal meal);

  /// This method removes a favorite. If the favorite does not exists, it does nothing.
  Future<void> deleteFavorite(Meal meal);

  /// This method returns all Favorites.
  Future<List<Meal>> getFavorites();
}