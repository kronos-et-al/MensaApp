
abstract class IDatabaseAccess {
  Future<void> updateAll(List<MealPlan> mealplans);
  Future<Result<List<MealPlan>>> getMealPlan(DateTime date, Canteen canteen);
  Future<Result<Meal>> getMealFavorite(String id);
  Future<void> addFavorite(Meal meal);
  Future<void> deleteFavorite(Meal meal);
  Future<List<Meal>> getFavorites();
}