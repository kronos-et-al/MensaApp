import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Mealplan.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteDatabaseAccess implements IDatabaseAccess {
  /// The string to create a table for the canteen.
  static const String _canteen = '''
    CREATE TABLE Canteen (
      canteenID TEXT PRIMARY KEY,
      name TEXT NOT NULL
    )
  ''';

  /// The string to create a table for a line of a canteen.
  static const String _line = '''
    CREATE TABLE Line(
      lineID TEXT PRIMARY KEY,
      canteenID TEXT NOT NULL,
      name TEXT NOT NULL,
      position INTEGER NOT NULL,
      FOREIGN KEY(canteenID) REFERENCES Canteen(canteenID)
    )
  ''';

  /// The string to create a table for a mealplan.
  static const String _mealplan = '''
    CREATE TABLE MealPlan(
      mealplanID TEXT,
      lineID TEXT NOT NULL,
      date TEXT,
      isClosed BOOLEAN NOT NULL,
      FOREIGN KEY(lineID) REFERENCES Line(lineID),
      PRIMARY KEY(mealplanID, date)
    )
  ''';

  /// The string to create a table for a meal.
  static final String _meal = '''
    CREATE TABLE Meal(
      mealID TEXT PRIMARY KEY,
      mealplanID TEXT NOT NULL,
      name TEXT NOT NULL,
      foodtype TEXT NOT NULL CHECK(foodtype IN (${FoodType.values.map((type) => "'$type'").join(', ')})),
      priceStudent INTEGER NOT NULL CHECK(priceStudent >= 0),
      priceEmployee INTEGER NOT NULL CHECK(priceEmployee >= 0),
      pricePupil INTEGER NOT NULL CHECK(pricePupil >= 0),
      priceGuest INTEGER NOT NULL CHECK(priceGuest >= 0),
      individualRating INTEGER,
      numberOfRatings INTEGER NOT NULL,
      averageRating DECIMAL(1,1),
      lastServed TEXT NOT NULL,
      nextServed TEXT,
      relativeFrequency TEXT CHECK IN (${Frequency.values.map((frequency) => "'$frequency'").join(', ')}),
      FOREIGN KEY(mealplanID) REFERENCES MealPlan(mealplanID)
    )
  ''';

  /// The string to create a table for a side.
  static final String _side = '''
    CREATE TABLE Side(
      sideID TEXT PRIMARY KEY,
      mealID TEXT NOT NULL,
      name TEXT NOT NULL,
      foodtype TEXT NOT NULL CHECK(foodtype IN (${FoodType.values.map((type) => "'$type'").join(', ')})),
      priceStudent INTEGER NOT NULL CHECK(priceStudent >= 0),
      priceEmployee INTEGER NOT NULL CHECK(priceEmployee >= 0),
      pricePupil INTEGER NOT NULL CHECK(pricePupil >= 0),
      priceGuest INTEGER NOT NULL CHECK(priceGuest >= 0),
      FOREIGN KEY(mealID) REFERENCES Meal(mealID)
    )
  ''';

  /// The string to create a table for an additive.
  static const String _image = '''
    CREATE TABLE Image(
      imageID TEXT PRIMARY KEY,
      mealID TEXT NOT NULL,
      url TEXT NOT NULL,
      FOREIGN KEY(mealID) REFERENCES Meal(mealID)
    )
  ''';

  /// The string to create a table for an additive of a meal.
  static final String _mealAdditive = '''
    CREATE TABLE MealAdditive(
      mealID TEXT,
      additiveID TEXT CHECK IN (${Additive.values.map((additive) => "'$additive'").join(', ')}),
      FOREIGN KEY(mealID) REFERENCES Meal(mealID),
      PRIMARY KEY(mealID, additiveID)
    )
  ''';

  /// The string to create a table for an allergen of a meal.
  static final String _mealAllergen = '''
    CREATE TABLE MealAllergen(
      mealID TEXT,
      allergenID TEXT CHECK IN (${Allergen.values.map((allergen) => "'$allergen'").join(', ')}),
      FOREIGN KEY(mealID) REFERENCES Meal(mealID),
      PRIMARY KEY(mealID, allergenID)
    )
  ''';

  /// The string to create a table for an additive of a side.
  static final String _sideAdditive = '''
    CREATE TABLE SideAdditive(
      sideID TEXT,
      additiveID TEXT CHECK IN (${Additive.values.map((additive) => "'$additive'").join(', ')}),
      FOREIGN KEY(sideID) REFERENCES Side(sideID),
      PRIMARY KEY(sideID, additiveID)
    )
  ''';

  /// The string to create a table for an allergen of a side.
  static final String _sideAllergen = '''
    CREATE TABLE SideAllergen(
      sideID TEXT,
      allergenID TEXT CHECK IN (${Allergen.values.map((allergen) => "'$allergen'").join(', ')}),
      FOREIGN KEY(sideID) REFERENCES Side(sideID),
      PRIMARY KEY(sideID, allergenID)
    )
  ''';

  /// The string to create a table for a favorite.
  static final String _favorite = '''
    CREATE TABLE Favorite(
      favoriteID TEXT PRIMARY KEY,
      lineID TEXT NOT NULL,
      lastDate TEXT NOT NULL,
      foodtype TEXT CHECK(foodtype IN (${FoodType.values.map((type) => "'$type'").join(', ')})),
      priceStudent INTEGER CHECK(priceStudent > 0),
      priceEmployee INTEGER CHECK(priceEmployee > 0),
      pricePupil INTEGER CHECK(pricePupil > 0),
      priceGuest INTEGER CHECK(priceGuest > 0),
      FOREIGN KEY(lineID) REFERENCES Line(lineID)
    )
  ''';

  static List<String> _getDatabaseBuilder() {
    return [
      _canteen,
      _line,
      _mealplan,
      _meal,
      _side,
      _image,
      _mealAdditive,
      _mealAllergen,
      _sideAdditive,
      _sideAllergen,
      _favorite
    ];
  }

  // Database access is provided by a singleton instance to prevent several databases.
  static final SQLiteDatabaseAccess _databaseAccess = SQLiteDatabaseAccess._internal();

  factory SQLiteDatabaseAccess() {
    return _databaseAccess;
  }

  SQLiteDatabaseAccess._internal() {
    db = _initiate();
  }

  static const String _dbName = 'meal_plan.db';
  late final Future<Database> db;

  static Future<Database> _initiate()  async {
    WidgetsFlutterBinding.ensureInitialized();
    return await openDatabase(
        join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) {
          for (String sql in _getDatabaseBuilder()) {
             db.execute(sql);
          }
        },
        version: 1,
    );
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