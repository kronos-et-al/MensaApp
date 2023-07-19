import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Mealplan.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
}