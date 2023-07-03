import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Mealplan.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';


class SQLiteDatabaseAccess implements IDatabaseAccess {
  /// The string to create a table for the canteen.
  final String _canteen = '''
    CREATE TABLE Canteen (
      canteenID TEXT PRIMARY KEY,
      name TEXT
    )
  ''';

  /// The string to create a table for a line of a canteen.
  final String _line = '''
    CREATE TABLE Line(
      lineID TEXT PRIMARY KEY,
      canteenID TEXT,
      name TEXT,
      position INTEGER,
      FOREIGN KEY(canteenID) REFERENCES Canteen(canteenID)
    )
  ''';

  /// The string to create a table for a mealplan.
  final String _mealplan = '''
    CREATE TABLE MealPlan(
      mealplanID TEXT PRIMARY KEY,
      lineID TEXT,
      date TEXT PRIMARY KEY,
      isClosed BOOLEAN,
      FOREIGN KEY(lineID) REFERENCES Line(lineID)
    )
  ''';

  /// The string to create a table for a meal.
  final String _meal = '''
    CREATE TABLE Meal(
      mealID TEXT PRIMARY KEY,
      mealplanID TEXT,
      name TEXT,
      foodtype TEXT CHECK(foodtype IN (${FoodType.values.map((type) => "'$type'").join(', ')})),
      priceStudent INTEGER,
      priceEmployee INTEGER,
      pricePupil INTEGER,
      priceGuest INTEGER,
      individualRating INTEGER,
      numberOfRatings INTEGER,
      averageRating DECIMAL(1,1),
      lastServed TEXT,
      nextServed TEXT,
      relativeFrequency TEXT CHECK IN (${Frequency.values.map((frequency) => "'$frequency'").join(', ')}),
      FOREIGN KEY(mealplanID) REFERENCES MealPlan(mealplanID)
    )
  ''';

  /// The string to create a table for a side.
  final String _side = '''
    CREATE TABLE Side(
      sideID TEXT PRIMARY KEY,
      mealID TEXT,
      name TEXT,
      foodtype TEXT CHECK(foodtype IN (${FoodType.values.map((type) => "'$type'").join(', ')})),
      priceStudent INTEGER,
      priceEmployee INTEGER,
      pricePupil INTEGER,
      priceGuest INTEGER,
      FOREIGN KEY(mealID) REFERENCES Meal(mealID)
    )
  ''';

  /// The string to create a table for an additive.
  final String _image = '''
    CREATE TABLE Image(
      imageID TEXT PRIMARY KEY,
      mealID TEXT,
      url TEXT,
      FOREIGN KEY(mealID) REFERENCES Meal(mealID)
    )
  ''';

  /// The string to create a table for an additive of a meal.
  final String _mealAdditive = '''
    CREATE TABLE MealAdditive(
      mealID TEXT,
      additiveID TEXT CHECK IN (${Additive.values.map((additive) => "'$additive'").join(', ')}),
      FOREIGN KEY(mealID) REFERENCES Meal(mealID),
    )
  ''';

  /// The string to create a table for an allergen of a meal.
  final String _mealAllergen = '''
    CREATE TABLE MealAllergen(
      mealID TEXT,
      allergenID TEXT CHECK IN (${Allergen.values.map((allergen) => "'$allergen'").join(', ')}),
      FOREIGN KEY(mealID) REFERENCES Meal(mealID),
    )
  ''';

  /// The string to create a table for an additive of a side.
  final String _sideAdditive = '''
    CREATE TABLE SideAdditive(
      sideID TEXT,
      additiveID TEXT CHECK IN (${Additive.values.map((additive) => "'$additive'").join(', ')}),
      FOREIGN KEY(sideID) REFERENCES Side(sideID),
    )
  ''';

  /// The string to create a table for an allergen of a side.
  final String _sideAllergen = '''
    CREATE TABLE SideAllergen(
      sideID TEXT,
      allergenID TEXT CHECK IN (${Allergen.values.map((allergen) => "'$allergen'").join(', ')}),
      FOREIGN KEY(sideID) REFERENCES Side(sideID),
    )
  ''';

  /// The string to create a table for a favorite.
  final String _favorite = '''
    CREATE TABLE Favorite(
      favoriteID TEXT PRIMARY KEY,
      lineID TEXT,
      lastDate TEXT,
      foodtype TEXT CHECK(foodtype IN (${FoodType.values.map((type) => "'$type'").join(', ')})),
      priceStudent INTEGER,
      priceEmployee INTEGER,
      pricePupil INTEGER,
      priceGuest INTEGER,
      FOREIGN KEY(lineID) REFERENCES Line(lineID)
    )
  ''';

  SQLiteDatabaseAccess() {
    // TODO: implement constructor
  }

  @override
  Future<void> addFavorite(Meal meal) {
    // TODO: implement addFavorite
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFavorite(Meal meal) {
    // TODO: implement deleteFavorite
    throw UnimplementedError();
  }

  @override
  Future<List<Meal>> getFavorites() {
    // TODO: implement getFavorites
    throw UnimplementedError();
  }

  @override
  Future<Result<Meal>> getMealFavorite(String id) {
    // TODO: implement getMealFavorite
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Mealplan>>> getMealPlan(DateTime date, Canteen canteen) {
    // TODO: implement getMealPlan
    throw UnimplementedError();
  }

  @override
  Future<void> updateAll(List<Mealplan> mealplans) {
    // TODO: implement updateAll
    throw UnimplementedError();
  }

}