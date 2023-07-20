import 'package:app/model/database/model/database_model.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Mealplan.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../view_model/repository/data_classes/meal/Allergen.dart';
import '../../view_model/repository/data_classes/mealplan/Line.dart';
import 'model/db_favorite.dart';
import 'model/db_image.dart';
import 'model/db_meal.dart';
import 'model/db_meal_additive.dart';
import 'model/db_meal_allergen.dart';
import 'model/db_side.dart';
import 'model/db_canteen.dart';
import 'model/db_meal_plan.dart';
import 'model/db_line.dart';
import 'model/db_side_additive.dart';
import 'model/db_side_allergen.dart';



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
  static final SQLiteDatabaseAccess _databaseAccess = SQLiteDatabaseAccess._internal();

  factory SQLiteDatabaseAccess() {
    return _databaseAccess;
  }

  SQLiteDatabaseAccess._internal() {
    database = _initiate();
  }

  static const String _dbName = 'meal_plan.db';
  late final Future<Database> database;

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
  Future<int> addFavorite(Meal meal) async {
    var db = await database;
    var dbMeal = await _getMeal(meal.id);
    var dbMealPlan = await _getMealPlan(dbMeal!.mealPlanID);
    var dbLine = await _getLine(dbMealPlan!.lineID);
    // FavoriteID is now the related mealID. Seems right. TODO: DateTime to String, if toString() isn't enough.
    var favorite = DBFavorite(meal.id, dbLine!.lineID, meal.lastServed.toString(), meal.foodType, meal.price.student, meal.price.employee, meal.price.pupil, meal.price.guest);
    return db.insert(
      DBFavorite.tableName,
      favorite.toMap()
    );
  }

  @override
  Future<int> deleteFavorite(Meal meal) async {
    var db = await database;
    return db.delete(
      DBFavorite.tableName,
      where: '${DBFavorite.columnFavoriteID} = ?',
      // Same as above: mealID and favID is the same meal.
      whereArgs: [meal.id]
    );
  }

  @override
  Future<List<Meal>> getFavorites() async {
    var db = await database;
    var meals = List<Meal>.empty();
    var dbFavoritesListResult = await db.query(DBFavorite.tableName);
    for (Map<String, dynamic> favoriteMap in dbFavoritesListResult) {
      var favorite = DBFavorite.fromMap(favoriteMap);
      var dbMeal = await _getMeal(favorite.favoriteID);
      var allergens = await _getMealAllergens(dbMeal!.mealID);
      var additives = await _getMealAdditive(dbMeal.mealID);
      var sides = await _getSides(dbMeal.mealID);
      var sideAllergens = <DBSide, List<Allergen>>{};
      var sideAdditives = <DBSide, List<Additive>>{};
      for (DBSide side in sides) {
        sideAllergens[side] = (await _getSideAllergens(side.sideID))!;
        sideAdditives[side] = (await _getSideAdditive(side.sideID))!;
      }
      var images = await _getImages(dbMeal.mealID);
      meals.add(DatabaseTransformer.fromDBMeal(dbMeal, allergens!, additives!, sides, sideAllergens, sideAdditives, images, true));
    }
    return meals;
  }

  @override
  Future<Result<Meal>> getMealFavorite(String id) {
    // TODO: implement getMealFavorite
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Mealplan>>> getMealPlan(DateTime date, Canteen canteen) async {
    var db = await database;
    var result = await db.query(
      DBMealPlan.tableName,
      where: '${DBCanteen.tableName}.${DBCanteen.columnCanteenID} = ${DBLine.tableName}.${DBLine.columnCanteenID} AND ${DBLine.tableName}.${DBLine.columnLineID} = ${DBMealPlan.tableName}.${DBMealPlan.columnLineID} AND ${DBCanteen.tableName}.${DBCanteen.columnCanteenID} = "?" AND ${DBMealPlan.tableName}.${DBMealPlan.columnDate} = "?"',
      whereArgs: [canteen.id, date.toString()]
    );
    if(result.isNotEmpty) {
      return Success(result.map((mealPlanRow) => DBMealPlan.fromMap(mealPlanRow)).cast<Mealplan>().toList());
    } else {
      return Failure(result as Exception);
    }

  }

  @override
  Future<void> updateAll(List<Mealplan> mealPlans) async {
    for (Mealplan mealPlan in mealPlans) {
      await _insertCanteen(mealPlan.line.canteen);
      await _insertLine(mealPlan.line);
      await _insertMealPlan(mealPlan);
    }
  }

  Future<int> _insertLine(Line line) async {
    var db = await database;
    var dbLine = DBLine(line.id, line.canteen.id, line.name, line.position);
    return db.insert(DBLine.tableName, dbLine.toMap());
  }

  Future<int> _insertCanteen(Canteen canteen) async {
    var db = await database;
    var dbCanteen = DBCanteen(canteen.id, canteen.name);
    return db.insert(DBCanteen.tableName, dbCanteen.toMap());
  }

  Future<int> _insertMealPlan(Mealplan mealPlan) async {
    var db = await database;
    var uuid = const Uuid(); // TODO: generate UUID or get uuid from backend
    var dbMealPlan = DBMealPlan(uuid.toString(), mealPlan.line.id, mealPlan.date.toString(), mealPlan.isClosed);
    return db.insert(DBMealPlan.tableName, dbMealPlan.toMap());
  }

  Future<DBCanteen?> _getCanteen(String canteenID) async {
    var db = await database;
    var result = await db.query(
      DBCanteen.tableName,
      where: '${DBCanteen.columnCanteenID} = ?',
      whereArgs: [canteenID]
    );
    if(result.isNotEmpty) {
      return DBCanteen.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<DBLine?> _getLine(String lineID) async {
    var db = await database;
    var result = await db.query(
        DBLine.tableName,
        where: '${DBLine.columnLineID} = ?',
        whereArgs: [lineID]
    );
    if(result.isNotEmpty) {
      return DBLine.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<DBMeal?> _getMeal(String mealID) async {
    var db = await database;
    var result = await db.query(
        DBMeal.tableName,
        where: '${DBMeal.columnMealID} = ?',
        whereArgs: [mealID]
    );
    if(result.isNotEmpty) {
      return DBMeal.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<DBSide?> _getSide(String sideID) async {
    var db = await database;
    var result = await db.query(
        DBSide.tableName,
        where: '${DBSide.columnSideID} = ?',
        whereArgs: [sideID]
    );
    if(result.isNotEmpty) {
      return DBSide.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<DBSide>> _getSides(String mealID) async {
    var db = await database;
    var result = await db.query(
        DBSide.tableName,
        where: '${DBSide.columnMealID} = ?',
        whereArgs: [mealID]
    );
    return result.map((sideRow) => DBSide.fromMap(sideRow)).toList();
  }

  Future<DBImage?> _getImage(String imageID) async {
    var db = await database;
    var result = await db.query(
        DBImage.tableName,
        where: '${DBImage.columnImageID} = ?',
        whereArgs: [imageID]
    );
    if(result.isNotEmpty) {
      return DBImage.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<DBImage>> _getImages(String mealID) async {
    var db = await database;
    var result = await db.query(
        DBImage.tableName,
        where: '${DBImage.columnMealID} = ?',
        whereArgs: [mealID]
    );
    return result.map((imageRow) => DBImage.fromMap(imageRow)).toList();
  }

  Future<DBMealPlan?> _getMealPlan(String mealPlanID) async {
    var db = await database;
    var result = await db.query(
        DBMealPlan.tableName,
        where: '${DBMealPlan.columnMealPlanID} = ?',
        whereArgs: [mealPlanID]
    );
    if(result.isNotEmpty) {
      return DBMealPlan.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<DBFavorite?> _getFavorite(String favoriteID) async {
    var db = await database;
    var result = await db.query(
        DBFavorite.tableName,
        where: '${DBFavorite.columnFavoriteID} = ?',
        whereArgs: [favoriteID]
    );
    if(result.isNotEmpty) {
      return DBFavorite.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<Allergen>?> _getMealAllergens(String id) async {
    var db = await database;
    var result = await db.query(
        DBMealAllergen.tableName,
        where: '${DBMealAllergen.columnMealID} = ?',
        whereArgs: [id]
    );
    return result.map((allergenMap) => DBMealAllergen.fromMap(allergenMap).allergen).toList();
  }

  Future<List<Allergen>?> _getSideAllergens(String id) async {
    var db = await database;
    var result = await db.query(
        DBSideAllergen.tableName,
        where: '${DBSideAllergen.columnSideID} = ?',
        whereArgs: [id]
    );
    return result.map((allergenMap) => DBMealAllergen.fromMap(allergenMap).allergen).toList();
  }

  Future<List<Additive>?> _getMealAdditive(String id) async {
    var db = await database;
    var result = await db.query(
        DBMealAdditive.tableName,
        where: '${DBMealAdditive.columnMealID} = ?',
        whereArgs: [id]
    );
    return result.map((allergenMap) => DBMealAdditive.fromMap(allergenMap).additive).toList();
  }

  Future<List<Additive>?> _getSideAdditive(String id) async {
    var db = await database;
    var result = await db.query(
        DBSideAdditive.tableName,
        where: '${DBSideAdditive.columnSideID} = ?',
        whereArgs: [id]
    );
    return result.map((allergenMap) => DBSideAdditive.fromMap(allergenMap).additive).toList();
  }

}