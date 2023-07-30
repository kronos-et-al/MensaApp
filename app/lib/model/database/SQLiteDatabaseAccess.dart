import 'dart:async';

import 'package:app/model/database/model/database_model.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../view_model/repository/data_classes/meal/Allergen.dart';
import '../../view_model/repository/data_classes/mealplan/Line.dart';
import '../../view_model/repository/error_handling/NoMealException.dart';
import 'model/db_canteen.dart';
import 'model/db_favorite.dart';
import 'model/db_image.dart';
import 'model/db_line.dart';
import 'model/db_meal.dart';
import 'model/db_meal_additive.dart';
import 'model/db_meal_allergen.dart';
import 'model/db_meal_plan.dart';
import 'model/db_side.dart';
import 'model/db_side_additive.dart';
import 'model/db_side_allergen.dart';

/// This class accesses the database and uses it as local storage.
class SQLiteDatabaseAccess implements IDatabaseAccess {
  static List<String> _getDatabaseBuilder() {
    return [
      DBCanteen.initTable(),
      DBLine.initTable(),
      DBMealPlan.initTable(),
      DBMeal.initTable(),
      DBSide.initTable(),
      DBImage.initTable(),
      DBMealAdditive.initTable(),
      DBMealAllergen.initTable(),
      DBSideAdditive.initTable(),
      DBSideAllergen.initTable(),
      DBFavorite.initTable()
    ];
  }

  // Database access is provided by a singleton instance to prevent several databases.
  static final SQLiteDatabaseAccess _databaseAccess =
      SQLiteDatabaseAccess._internal();

  /// Returns the singleton instance of this class.
  /// @returns the singleton instance of this class
  factory SQLiteDatabaseAccess() {
    return _databaseAccess;
  }

  SQLiteDatabaseAccess._internal() {
    database = _initiate();
  }

  static const String _dbName = 'meal_plan.db';
  late final Future<Database> database;

  static Future<Database> _initiate() async {
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
  Future<int> addFavorite(Meal meal) async {
    var db = await database;
    print(meal.id);
    var dbMeal = await _getDBMeal(meal.id);
    print(dbMeal?.toMap());
    var dbMealPlan = await _getDBMealPlan(dbMeal!.mealPlanID);
    var dbLine = await _getDBLine(dbMealPlan!.lineID);
    // FavoriteID is now the related mealID. Seems right. TODO: DateTime to String, if toString() isn't enough.
    var favorite = DBFavorite(
        meal.id,
        dbLine!.lineID,
        meal.lastServed.toString(),
        meal.foodType,
        meal.price.student,
        meal.price.employee,
        meal.price.pupil,
        meal.price.guest);
    return db.insert(DBFavorite.tableName, favorite.toMap());
  }

  @override
  Future<int> deleteFavorite(Meal meal) async {
    var db = await database;
    return db.delete(DBFavorite.tableName,
        where: '${DBFavorite.columnFavoriteID} = ?',
        // Same as above: mealID and favID is the same meal.
        whereArgs: [meal.id]);
  }

  @override
  Future<List<Meal>> getFavorites() async {
    var db = await database;
    var meals = List<Meal>.empty(growable: true);
    var dbFavoritesListResult = await db.query(DBFavorite.tableName);
    for (Map<String, dynamic> favoriteMap in dbFavoritesListResult) {
      var dbFavorite = DBFavorite.fromMap(favoriteMap);
      var meal = await _getMeal(dbFavorite.favoriteID, true);
      meals.add(meal);
    }
    return meals;
  }

  @override
  Future<Result<Meal, NoMealException>> getMealFavorite(String id) async {
    var db = await database;
    var result = await db.query(DBFavorite.tableName,
        where: '${DBFavorite.columnFavoriteID} = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      DBFavorite dbFavorite = DBFavorite.fromMap(result.first);
      var meal = await _getMeal(dbFavorite.favoriteID, true);
      return Success(meal);
    } else {
      return Failure(NoMealException("Meal not found."));
    }
  }

  @override
  Future<Result<List<MealPlan>, NoDataException>> getMealPlan(
      DateTime date, Canteen canteen) async {
    var db = await database;
    var result = await db.query(
        '${DBMealPlan.tableName}, ${DBCanteen.tableName}, ${DBLine.tableName}',
        where:
            '${DBCanteen.tableName}.${DBCanteen.columnCanteenID} = ${DBLine.tableName}.${DBLine.columnCanteenID} AND ${DBLine.tableName}.${DBLine.columnLineID} = ${DBMealPlan.tableName}.${DBMealPlan.columnLineID} AND ${DBCanteen.tableName}.${DBCanteen.columnCanteenID} = ? AND ${DBMealPlan.tableName}.${DBMealPlan.columnDate} = ?',
        whereArgs: [canteen.id, date.toString()]);
    if (result.isNotEmpty) {
      // Maybe better solution...
      /*List<MealPlan> mealPlans = await Future.wait(result.map((plan) async {
        DBMealPlan dbMealPlan= DBMealPlan.fromMap(plan);
        var dbLine = await _getDBLine(dbMealPlan.lineID);
        var dbCanteen = await _getDBCanteen(dbLine!.canteenID);
        List<Meal> meals = await Future.wait((await _getDBMeals(dbMealPlan.mealPlanID)).map<Future<Meal>>((dbMeal) async {
          bool isFavorite = await _isFavorite(dbMeal.mealID);
          return _getMeal(dbMeal.mealID, isFavorite);
        }));
        return DatabaseTransformer.fromDBMealPlan(dbMealPlan, dbLine, dbCanteen!, meals);
      }));
      return Success(mealPlans);*/
      int i = 0;
      List<MealPlan?> mealPlans = List.filled(result.length, null);
      for (DBMealPlan dbMealPlan
          in result.map((plan) => DBMealPlan.fromMap(plan))) {
        var dbLine = await _getDBLine(dbMealPlan.lineID);
        var dbCanteen = await _getDBCanteen(dbLine!.canteenID);
        var dbMeals = await _getDBMeals(dbMealPlan.mealPlanID);
        var meals = List<Meal>.empty(growable: true);
        for (DBMeal dbMeal in dbMeals) {
          bool isFavorite = await _isFavorite(dbMeal.mealID);
          Meal meal = await _getMeal(dbMeal.mealID, isFavorite);
          meals.add(meal);
        }
        i++;
        mealPlans.add(DatabaseTransformer.fromDBMealPlan(
            dbMealPlan, dbLine, dbCanteen!, meals));
      }
      return Success(mealPlans as List<MealPlan>);
    } else {
      return Failure(NoDataException("No meal plan found for this date."));
    }
  }

  Future<bool> _isFavorite(String id) async {
    var db = await database;
    var result = await db.query(DBFavorite.tableName,
        where: '${DBFavorite.columnFavoriteID} = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  @override
  Future<void> updateAll(List<MealPlan> mealPlans) async {
    for (MealPlan mealPlan in mealPlans) {
      await _insertCanteen(mealPlan.line.canteen);
      await _insertLine(mealPlan.line);
      await _insertMealPlan(mealPlan);
    }
  }

  Future<Meal> _getMeal(String mealID, bool isFavorite) async {
    var dbMeal = await _getDBMeal(mealID);
    var allergens = await _getMealAllergens(dbMeal!.mealID);
    var additives = await _getMealAdditive(dbMeal.mealID);
    var sides = await _getDBSides(dbMeal.mealID);
    var sideAllergens = <DBSide, List<Allergen>>{};
    var sideAdditives = <DBSide, List<Additive>>{};
    for (DBSide side in sides) {
      sideAllergens[side] = (await _getSideAllergens(side.sideID))!;
      sideAdditives[side] = (await _getSideAdditive(side.sideID))!;
    }
    var images = await _getDBImages(dbMeal.mealID);
    return DatabaseTransformer.fromDBMeal(dbMeal, allergens!, additives!, sides,
        sideAllergens, sideAdditives, images, isFavorite);
  }

  Future<int> _insertLine(Line line) async {
    var db = await database;
    var dbLine = DBLine(line.id, line.canteen.id, line.name, line.position);
    return db.insert(DBLine.tableName, dbLine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertCanteen(Canteen canteen) async {
    var db = await database;
    var dbCanteen = DBCanteen(canteen.id, canteen.name);
    return db.insert(DBCanteen.tableName, dbCanteen.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealPlan(MealPlan mealPlan) async {
    var db = await database;
    var result = await db.query(DBMealPlan.tableName,
        where:
            '${DBMealPlan.columnLineID} = ? AND ${DBMealPlan.columnDate} = ?',
        whereArgs: [mealPlan.line.id, mealPlan.date.toString()]);
    if (result.isNotEmpty) return 0;
    /*var result = await db.query(DBMealPlan.tableName,
        where:
            '${DBMealPlan.columnLineID} = ? AND ${DBMealPlan.columnDate} = ?',
        whereArgs: [mealPlan.line.id, mealPlan.date.toString()]);
    DBMealPlan? dbMealPlan;
    if (result.isNotEmpty) {
      DBMealPlan oldDbMealPlan = DBMealPlan.fromMap(result.first);
      dbMealPlan = DBMealPlan(oldDbMealPlan.mealPlanID, mealPlan.line.id,
          mealPlan.date.toString(), mealPlan.isClosed);
    } else {
      var uuid = const Uuid();
      dbMealPlan = DBMealPlan(uuid.v4(), mealPlan.line.id,
          mealPlan.date.toString(), mealPlan.isClosed);
    }
    int id = await db.insert(DBMealPlan.tableName, dbMealPlan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);*/
    /*for (Meal meal in mealPlan.meals) {
      print(await _insertMeal(meal, dbMealPlan));
    }*/
    var uuid = const Uuid();
    DBMealPlan dbMealPlan = DBMealPlan(uuid.v4(), mealPlan.line.id,
        mealPlan.date.toString(), mealPlan.isClosed);
    int id = await db.insert(DBMealPlan.tableName, dbMealPlan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  Future<int> _insertMeal(Meal meal, DBMealPlan mealPlan) async {
    var db = await database;
    var dbMeal = DBMeal(
        meal.id,
        mealPlan.mealPlanID,
        meal.name,
        meal.foodType,
        meal.price.student,
        meal.price.employee,
        meal.price.pupil,
        meal.price.guest,
        meal.individualRating ?? 0,
        meal.numberOfRatings ?? 0,
        meal.averageRating ?? 0,
        meal.lastServed.toString(),
        meal.nextServed.toString(),
        meal.relativeFrequency ?? Frequency.normal);
    for (Allergen allergen in meal.allergens ?? []) {
      await _insertMealAllergen(allergen, dbMeal);
    }
    for (Additive additive in meal.additives ?? []) {
      await _insertMealAdditive(additive, dbMeal);
    }
    return db.insert(DBMeal.tableName, dbMeal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealAllergen(Allergen allergen, DBMeal meal) async {
    var db = await database;
    var dbMealAllergen = DBMealAllergen(meal.mealID, allergen);
    return db.insert(DBMealAllergen.tableName, dbMealAllergen.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealAdditive(Additive additive, DBMeal meal) async {
    var db = await database;
    var dbMealAdditive = DBMealAdditive(meal.mealID, additive);
    return db.insert(DBMealAdditive.tableName, dbMealAdditive.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DBCanteen?> _getDBCanteen(String canteenID) async {
    var db = await database;
    var result = await db.query(DBCanteen.tableName,
        where: '${DBCanteen.columnCanteenID} = ?', whereArgs: [canteenID]);
    if (result.isNotEmpty) {
      return DBCanteen.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<DBLine?> _getDBLine(String lineID) async {
    var db = await database;
    var result = await db.query(DBLine.tableName,
        where: '${DBLine.columnLineID} = ?', whereArgs: [lineID]);
    if (result.isNotEmpty) {
      return DBLine.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<DBMeal?> _getDBMeal(String mealID) async {
    var db = await database;
    var result = await db.query(DBMeal.tableName,
        where: '${DBMeal.columnMealID} = ?', whereArgs: [mealID]);
    if (result.isNotEmpty) {
      return DBMeal.fromMap(result.first);
    } else {
      return null;
    }
  }

  // todo unused
  Future<DBSide?> _getDBSide(String sideID) async {
    var db = await database;
    var result = await db.query(DBSide.tableName,
        where: '${DBSide.columnSideID} = ?', whereArgs: [sideID]);
    if (result.isNotEmpty) {
      return DBSide.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<DBMeal>> _getDBMeals(String mealPlanID) async {
    var db = await database;
    var result = await db.query(DBMeal.tableName,
        where: '${DBMeal.columnMealPlanID} = ?', whereArgs: [mealPlanID]);
    return result.map((mealRow) => DBMeal.fromMap(mealRow)).toList();
  }

  Future<List<DBSide>> _getDBSides(String mealID) async {
    var db = await database;
    var result = await db.query(DBSide.tableName,
        where: '${DBSide.columnMealID} = ?', whereArgs: [mealID]);
    return result.map((sideRow) => DBSide.fromMap(sideRow)).toList();
  }

  // todo unused
  Future<DBImage?> _getDBImage(String imageID) async {
    var db = await database;
    var result = await db.query(DBImage.tableName,
        where: '${DBImage.columnImageID} = ?', whereArgs: [imageID]);
    if (result.isNotEmpty) {
      return DBImage.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<DBImage>> _getDBImages(String mealID) async {
    var db = await database;
    var result = await db.query(DBImage.tableName,
        where: '${DBImage.columnMealID} = ?', whereArgs: [mealID]);
    return result.map((imageRow) => DBImage.fromMap(imageRow)).toList();
  }

  Future<DBMealPlan?> _getDBMealPlan(String mealPlanID) async {
    var db = await database;
    var result = await db.query(DBMealPlan.tableName,
        where: '${DBMealPlan.columnMealPlanID} = ?', whereArgs: [mealPlanID]);
    if (result.isNotEmpty) {
      return DBMealPlan.fromMap(result.first);
    } else {
      return null;
    }
  }

  // todo unused
  Future<DBFavorite?> _getDBFavorite(String favoriteID) async {
    var db = await database;
    var result = await db.query(DBFavorite.tableName,
        where: '${DBFavorite.columnFavoriteID} = ?', whereArgs: [favoriteID]);
    if (result.isNotEmpty) {
      return DBFavorite.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<Allergen>?> _getMealAllergens(String id) async {
    var db = await database;
    var result = await db.query(DBMealAllergen.tableName,
        where: '${DBMealAllergen.columnMealID} = ?', whereArgs: [id]);
    return result
        .map((allergenMap) => DBMealAllergen.fromMap(allergenMap).allergen)
        .toList();
  }

  Future<List<Allergen>?> _getSideAllergens(String id) async {
    var db = await database;
    var result = await db.query(DBSideAllergen.tableName,
        where: '${DBSideAllergen.columnSideID} = ?', whereArgs: [id]);
    return result
        .map((allergenMap) => DBMealAllergen.fromMap(allergenMap).allergen)
        .toList();
  }

  Future<List<Additive>?> _getMealAdditive(String id) async {
    var db = await database;
    var result = await db.query(DBMealAdditive.tableName,
        where: '${DBMealAdditive.columnMealID} = ?', whereArgs: [id]);
    return result
        .map((allergenMap) => DBMealAdditive.fromMap(allergenMap).additive)
        .toList();
  }

  Future<List<Additive>?> _getSideAdditive(String id) async {
    var db = await database;
    var result = await db.query(DBSideAdditive.tableName,
        where: '${DBSideAdditive.columnSideID} = ?', whereArgs: [id]);
    return result
        .map((allergenMap) => DBSideAdditive.fromMap(allergenMap).additive)
        .toList();
  }

  @override
  Future<Canteen> getCanteenById(String id) {
    return Future.value(Canteen(id: id, name: 'Canteen $id'));
  }

  @override
  Future<DateTime?> getFavoriteMealsDate(Meal meal) {
    // todo what did he do?
    return Future.value(DateTime.now());
  }

  @override
  Future<Line?> getFavoriteMealsLine(Meal meal) {
    return Future.value(null);
  }
}
