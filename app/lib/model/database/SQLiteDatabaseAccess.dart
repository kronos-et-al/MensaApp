import 'dart:async';
import 'dart:io';

import 'package:app/model/database/model/database_model.dart';
import 'package:app/model/database/model/db_mealplan_side.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/FavoriteMeal.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/meal/Side.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
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
import 'model/db_mealplan_meal.dart';
import 'model/db_side.dart';
import 'model/db_side_additive.dart';
import 'model/db_side_allergen.dart';

/// This class accesses the database and uses it as local storage.
class SQLiteDatabaseAccess implements IDatabaseAccess {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  static List<String> _getDatabaseBuilder() {
    return [
      DBCanteen.initTable(),
      DBLine.initTable(),
      DBMealPlan.initTable(),
      DBMealPlanMeal.initTable(),
      DBMealPlanSide.initTable(),
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
    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
    }
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
  Future<int> addFavorite(
      Meal meal, DateTime servedDate, Line servedLine) async {
    var db = await database;
    var favorite = DBFavorite(
      meal.id,
      _dateFormat.format(meal.lastServed ?? DateTime.now()),
      meal.foodType,
      meal.price.student,
      meal.price.employee,
      meal.price.pupil,
      meal.price.guest,
      servedDate,
      servedLine.id,
    );
    await _insertMeal(meal);
    return await db.insert(DBFavorite.tableName, favorite.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> deleteFavorite(Meal meal) async {
    var db = await database;
    return db.delete(DBFavorite.tableName,
        where: '${DBFavorite.columnMealID} = ?', whereArgs: [meal.id]);
  }

  @override
  Future<List<FavoriteMeal>> getFavorites() async {
    var db = await database;
    var meals = List<FavoriteMeal>.empty(growable: true);
    var dbFavoritesListResult = await db.query(DBFavorite.tableName);
    for (Map<String, dynamic> favoriteMap in dbFavoritesListResult) {
      DBFavorite? dbFavorite = DBFavorite.fromMap(favoriteMap);
      DBMeal? dbMeal = await _getDBMeal(dbFavorite.mealID);
      if (dbMeal != null) {
        Meal meal = DatabaseTransformer.fromDBMeal(
            dbMeal,
            Price(
                student: dbFavorite.priceStudent,
                employee: dbFavorite.priceEmployee,
                pupil: dbFavorite.priceEmployee,
                guest: dbFavorite.priceGuest),
            await _getMealAllergens(dbMeal.mealID),
            await _getMealAdditives(dbMeal.mealID),
            [],
            {},
            {},
            {},
            await _getDBImages(dbMeal.mealID),
            _dateFormat.parse(dbFavorite.lastDate),
            null,
            null,
            true);
        DBLine? dbLine = await _getDBLine(dbFavorite.servedLineId);
        DBCanteen? dbCanteen = await _getDBCanteen(dbLine!.canteenID);
        Line line = DatabaseTransformer.fromDBLine(dbLine, dbCanteen!);
        meals.add(FavoriteMeal(meal, dbFavorite.servedDate, line));
      }
    }
    return meals;
  }

  @override
  Future<Result<Meal, NoMealException>> getMealFavorite(String id) async {
    var db = await database;
    var result = await db.query(DBFavorite.tableName,
        where: '${DBFavorite.columnMealID} = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      DBFavorite dbFavorite = DBFavorite.fromMap(result.first);
      DBMeal? dbMeal = await _getDBMeal(dbFavorite.mealID);
      if (dbMeal != null) {
        return Success(DatabaseTransformer.fromDBMeal(
            dbMeal,
            Price(
                student: dbFavorite.priceStudent,
                employee: dbFavorite.priceEmployee,
                pupil: dbFavorite.priceEmployee,
                guest: dbFavorite.priceGuest),
            await _getMealAllergens(dbMeal.mealID),
            await _getMealAdditives(dbMeal.mealID),
            [],
            {},
            {},
            {},
            (await _getDBImages(dbMeal.mealID)),
            _dateFormat.parse(dbFavorite.lastDate),
            null,
            null,
            await _isFavorite(dbMeal.mealID)));
      } else {
        return Failure(NoMealException("Meal not found."));
      }
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
        whereArgs: [canteen.id, _dateFormat.format(date)]);
    if (result.isNotEmpty) {
      List<MealPlan> mealPlans = List.empty(growable: true);
      for (DBMealPlan dbMealPlan
          in result.map((plan) => DBMealPlan.fromMap(plan))) {
        var dbLine = await _getDBLine(dbMealPlan.lineID);
        var dbCanteen = await _getDBCanteen(dbLine!.canteenID);
        var meals = await _getMealPlanMeals(dbMealPlan);
        mealPlans.add(DatabaseTransformer.fromDBMealPlan(
            dbMealPlan, dbLine, dbCanteen!, meals));
      }
      return Success(mealPlans);
    } else {
      return Failure(NoDataException("No meal plan found for this date."));
    }
  }

  Future<List<Meal>> _getMealPlanMeals(DBMealPlan dbMealPlan) async {
    List<DBMealPlanMeal> dbMealPlanMeals =
        await _getDBMealPlanMeals(dbMealPlan.mealPlanID);
    List<Meal> meals = List<Meal>.empty(growable: true);
    for (DBMealPlanMeal dbMealPlanMeal in dbMealPlanMeals) {
      DBMeal? dbMeal = await _getDBMeal(dbMealPlanMeal.mealID);
      if (dbMeal == null) {
        continue;
      }
      bool isFavorite = await _isFavorite(dbMeal.mealID);
      Meal meal = Meal(
          id: dbMeal.mealID,
          name: dbMeal.name,
          foodType: dbMeal.foodType,
          lastServed: _dateFormat.parse(dbMealPlanMeal.lastServed),
          nextServed: _dateFormat.parse(dbMealPlanMeal.nextServed),
          relativeFrequency: dbMealPlanMeal.relativeFrequency,
          additives: await _getMealAdditives(dbMeal.mealID),
          allergens: await _getMealAllergens(dbMeal.mealID),
          averageRating: dbMeal.averageRating,
          individualRating: dbMeal.individualRating,
          numberOfRatings: dbMeal.numberOfRatings,
          images: (await _getDBImages(dbMeal.mealID))
              .map((dbImage) => ImageData(
                  id: dbImage.imageID,
                  url: dbImage.url,
                  imageRank: dbImage.imageRank,
                  negativeRating: dbImage.negativeRating,
                  positiveRating: dbImage.positiveRating,
                  individualRating: dbImage.individualRating))
              .toList(),
          sides: await _getMealPlanSides(dbMealPlan, dbMealPlanMeal),
          price: Price(
              student: dbMealPlanMeal.priceStudent,
              employee: dbMealPlanMeal.priceEmployee,
              pupil: dbMealPlanMeal.pricePupil,
              guest: dbMealPlanMeal.priceGuest),
          isFavorite: isFavorite);
      meals.add(meal);
    }
    return meals;
  }

  Future<List<Side>> _getMealPlanSides(
      DBMealPlan dbMealPlan, DBMealPlanMeal dbMealPlanMeal) async {
    List<DBMealPlanSide> dbMealPlanSides =
        await _getDBMealPlanSides(dbMealPlan.mealPlanID, dbMealPlanMeal.mealID);
    List<Side> sides = List<Side>.empty(growable: true);
    for (DBMealPlanSide dbMealPlanSide in dbMealPlanSides) {
      DBSide? dbSide = await _getDBSide(dbMealPlanSide.sideID);
      if (dbSide == null) {
        continue;
      }
      Side side = Side(
          id: dbSide.sideID,
          name: dbSide.name,
          foodType: dbSide.foodType,
          price: Price(
              student: dbMealPlanSide.priceStudent,
              employee: dbMealPlanSide.priceEmployee,
              pupil: dbMealPlanSide.pricePupil,
              guest: dbMealPlanSide.priceGuest),
          allergens: await _getSideAllergens(dbSide.sideID) ?? [],
          additives: await _getSideAdditive(dbSide.sideID) ?? []);
      sides.add(side);
    }
    return sides;
  }

  Future<bool> _isFavorite(String id) async {
    var db = await database;
    var result = await db.query(DBFavorite.tableName,
        where: '${DBFavorite.columnMealID} = ?', whereArgs: [id]);
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

  @override
  Future<void> updateMeal(Meal meal) async {
    await _insertMeal(meal);
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
        whereArgs: [mealPlan.line.id, _dateFormat.format(mealPlan.date)]);
    DBMealPlan? dbMealPlan;
    if (result.isNotEmpty) {
      DBMealPlan oldDbMealPlan = DBMealPlan.fromMap(result.first);
      dbMealPlan = DBMealPlan(oldDbMealPlan.mealPlanID, mealPlan.line.id,
          _dateFormat.format(mealPlan.date), mealPlan.isClosed);
    } else {
      var uuid = const Uuid();
      dbMealPlan = DBMealPlan(uuid.v4(), mealPlan.line.id,
          _dateFormat.format(mealPlan.date), mealPlan.isClosed);
    }
    int id = await db.insert(DBMealPlan.tableName, dbMealPlan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.delete(DBMealPlanMeal.tableName,
        where: '${DBMeal.columnMealPlanID} = ?',
        whereArgs: [dbMealPlan.mealPlanID]);
    await db.delete(DBMealPlanSide.tableName,
        where: '${DBMealPlanSide.columnMealPlanID} = ?',
        whereArgs: [dbMealPlan.mealPlanID]);
    await Future.wait(
        mealPlan.meals.map((e) => _insertMealPlanMeal(e, dbMealPlan!)));
    return id;
  }

  Future<int> _insertMeal(Meal meal) async {
    var db = await database;

    await db.delete(DBMealAllergen.tableName,
        where: '${DBMealAllergen.columnMealID} = ?', whereArgs: [meal.id]);
    await db.delete(DBMealAdditive.tableName,
        where: '${DBMealAdditive.columnMealID} = ?', whereArgs: [meal.id]);
    await db.delete(DBImage.tableName,
        where: '${DBImage.columnMealID} = ?', whereArgs: [meal.id]);

    DBMeal dbMeal = DBMeal(meal.id, meal.name, meal.foodType,
        meal.individualRating, meal.numberOfRatings, meal.averageRating);

    await Future.wait(
        meal.allergens?.map((e) => _insertMealAllergen(e, dbMeal)).toList() ??
            []);
    await Future.wait(
        meal.additives?.map((e) => _insertMealAdditive(e, dbMeal)).toList() ??
            []);
    await Future.wait(
        meal.images?.map((e) => _insertImage(e, dbMeal)).toList() ?? []);

    return await db.insert(DBMeal.tableName, dbMeal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealPlanMeal(Meal meal, DBMealPlan mealPlan) async {
    var db = await database;

    await db.delete(DBMealAllergen.tableName,
        where: '${DBMealAllergen.columnMealID} = ?', whereArgs: [meal.id]);
    await db.delete(DBMealAdditive.tableName,
        where: '${DBMealAdditive.columnMealID} = ?', whereArgs: [meal.id]);
    await db.delete(DBImage.tableName,
        where: '${DBImage.columnMealID} = ?', whereArgs: [meal.id]);

    DBMeal dbMeal = DBMeal(meal.id, meal.name, meal.foodType,
        meal.individualRating, meal.numberOfRatings, meal.averageRating);
    DBMealPlanMeal mealPlanMeal = DBMealPlanMeal(
        mealPlan.mealPlanID,
        dbMeal.mealID,
        meal.price.student,
        meal.price.employee,
        meal.price.pupil,
        meal.price.guest,
        _dateFormat.format(meal.lastServed ?? DateTime.now()),
        _dateFormat.format(meal.nextServed ?? DateTime.now()),
        meal.relativeFrequency ?? Frequency.normal);
    await Future.wait(
        meal.allergens?.map((e) => _insertMealAllergen(e, dbMeal)).toList() ??
            []);
    await Future.wait(
        meal.additives?.map((e) => _insertMealAdditive(e, dbMeal)).toList() ??
            []);
    await Future.wait(meal.sides!
        .map((e) => _insertMealPlanSide(e, dbMeal, mealPlan))
        .toList());
    await Future.wait(
        meal.images?.map((e) => _insertImage(e, dbMeal)).toList() ?? []);
    await db.insert(DBMeal.tableName, dbMeal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return await db.insert(DBMealPlanMeal.tableName, mealPlanMeal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealPlanSide(
      Side side, DBMeal meal, DBMealPlan mealPlan) async {
    var db = await database;
    await db.delete(DBSideAllergen.tableName,
        where: '${DBSideAllergen.columnSideID} = ?', whereArgs: [side.id]);
    await db.delete(DBSideAdditive.tableName,
        where: '${DBSideAdditive.columnSideID} = ?', whereArgs: [side.id]);
    DBSide dbSide = DBSide(side.id, side.name, side.foodType);
    DBMealPlanSide mealPlanSide = DBMealPlanSide(
        mealPlan.mealPlanID,
        meal.mealID,
        dbSide.sideID,
        side.price.student,
        side.price.employee,
        side.price.pupil,
        side.price.guest);
    await Future.wait(
        side.allergens.map((e) => _insertSideAllergen(e, dbSide)));
    await Future.wait(
        side.additives.map((e) => _insertSideAdditive(e, dbSide)));
    await db.insert(DBSide.tableName, dbSide.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return await db.insert(DBMealPlanSide.tableName, mealPlanSide.toMap());
  }

  Future<int> _insertMealAllergen(Allergen allergen, DBMeal meal) async {
    var db = await database;
    var dbMealAllergen = DBMealAllergen(meal.mealID, allergen);
    return await db.insert(DBMealAllergen.tableName, dbMealAllergen.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealAdditive(Additive additive, DBMeal meal) async {
    var db = await database;
    var dbMealAdditive = DBMealAdditive(meal.mealID, additive);
    return await db.insert(DBMealAdditive.tableName, dbMealAdditive.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertSideAllergen(Allergen allergen, DBSide side) async {
    var db = await database;
    var dbSideAllergen = DBSideAllergen(side.sideID, allergen);
    return await db.insert(DBSideAllergen.tableName, dbSideAllergen.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertSideAdditive(Additive additive, DBSide side) async {
    var db = await database;
    var dbSideAdditive = DBSideAdditive(side.sideID, additive);
    return await db.insert(DBSideAdditive.tableName, dbSideAdditive.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertImage(ImageData image, DBMeal meal) async {
    var db = await database;
    var dbImage = DBImage(image.id, meal.mealID, image.url, image.imageRank,
        image.positiveRating, image.negativeRating, image.individualRating);
    return await db.insert(DBImage.tableName, dbImage.toMap(),
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

  Future<List<DBMealPlanMeal>> _getDBMealPlanMeals(String mealPlanID) async {
    var db = await database;
    var result = await db.query(DBMealPlanMeal.tableName,
        where: '${DBMealPlanMeal.columnMealPlanID} = ?',
        whereArgs: [mealPlanID]);
    return result.map((mealRow) => DBMealPlanMeal.fromMap(mealRow)).toList();
  }

  Future<List<DBMealPlanSide>> _getDBMealPlanSides(
      String mealPlanID, String mealID) async {
    var db = await database;
    var result = await db.query(DBMealPlanSide.tableName,
        where:
            '${DBMealPlanSide.columnMealPlanID} = ? AND ${DBMealPlanSide.columnMealID} = ?',
        whereArgs: [mealPlanID, mealID]);

    return result.map((sideRow) => DBMealPlanSide.fromMap(sideRow)).toList();
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
        where: '${DBFavorite.columnMealID} = ?', whereArgs: [favoriteID]);
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
        .map((allergenMap) => DBSideAllergen.fromMap(allergenMap).allergen)
        .toList();
  }

  Future<List<Additive>?> _getMealAdditives(String id) async {
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
  Future<Canteen> getCanteenById(String id) async {
    DBCanteen? canteen = await _getDBCanteen(id);
    return DatabaseTransformer.fromDBCanteen(canteen!);
  }

  @override
  Future<List<Canteen>?> getCanteens() async {
    var db = await database;
    var result = await db.query(DBCanteen.tableName);
    return Future.value(result.isNotEmpty
        ? result
            .map((canteenRow) => DBCanteen.fromMap(canteenRow))
            .map((e) => Canteen(id: e.canteenID, name: e.name))
            .toList()
        : null);
  }

  @override
  Future<Result<Meal, NoMealException>> getMeal(Meal meal) async {
    return _getDBMeal(meal.id).then((dbMeal) async {
      if (dbMeal != null) {
        Meal newMeal = Meal.copy(
            meal: meal,
            name: dbMeal.name,
            averageRating: dbMeal.averageRating,
            individualRating: dbMeal.individualRating,
            images: (await _getDBImages(dbMeal.mealID))
                .map((e) => DatabaseTransformer.fromDBImage(e))
                .toList(),
            allergens: await _getMealAllergens(dbMeal.mealID),
            additives: await _getMealAdditives(dbMeal.mealID));
        return Success(newMeal);
      } else {
        return Failure(NoMealException("No meal found with id ${meal.id}"));
      }
    });
  }

  @override
  Future<void> removeImage(ImageData image) async {
    var db = await database;
    await db.delete(DBImage.tableName,
        where: '${DBImage.columnImageID} = ?', whereArgs: [image.id]);
  }

  @override
  Future<void> cleanUp() async {
    var db = await database;
    print("Cleaning up database");

    List<DBMealPlan> mealPlans = (await db.query(DBMealPlan.tableName,
            where: '${DBMealPlan.columnDate} < ?',
            whereArgs: [
          _dateFormat.format(DateTime.now().subtract(const Duration(days: 1)))
        ]))
        .map((e) => DBMealPlan.fromMap(e))
        .toList();

    for (DBMealPlan mealPlan in mealPlans) {
      List<DBMealPlanMeal> mealPlanMeals = (await db.query(
              DBMealPlanMeal.tableName,
              where: '${DBMealPlanMeal.columnMealPlanID} = ?',
              whereArgs: [mealPlan.mealPlanID]))
          .map((e) => DBMealPlanMeal.fromMap(e))
          .toList();
      List<DBMealPlanSide> mealPlanSides = (await db.query(
              DBMealPlanSide.tableName,
              where: '${DBMealPlanSide.columnMealPlanID} = ?',
              whereArgs: [mealPlan.mealPlanID]))
          .map((e) => DBMealPlanSide.fromMap(e))
          .toList();
      for (DBMealPlanSide mealPlanSide in mealPlanSides) {
        if ((await db.query(DBMealPlanSide.tableName,
                    where: '${DBMealPlanSide.columnSideID} = ?',
                    whereArgs: [mealPlanSide.sideID]))
                .length >
            1) {
          print("Side ${mealPlanSide.sideID} is used in another meal plan");
          continue;
        }
        db.delete(DBSide.tableName,
            where: '${DBSide.columnSideID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        db.delete(DBSideAllergen.tableName,
            where: '${DBSideAllergen.columnSideID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        db.delete(DBSideAdditive.tableName,
            where: '${DBSideAdditive.columnSideID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        db.delete(DBMealPlanSide.tableName,
            where: '${DBMealPlanSide.columnSideID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        print("Deleted side ${mealPlanSide.sideID}");
      }
      for (DBMealPlanMeal mealPlanMeal in mealPlanMeals) {
        if ((await db.query(DBFavorite.tableName,
                where: '${DBFavorite.columnMealID} = ?',
                whereArgs: [mealPlanMeal.mealID]))
            .isNotEmpty) {
          print("Meal ${mealPlanMeal.mealID} is a favorite");
          continue;
        }
        if ((await db.query(DBMealPlanMeal.tableName,
                    where: '${DBMealPlanMeal.columnMealID} = ?',
                    whereArgs: [mealPlanMeal.mealID]))
                .length >
            1) {
          print("Meal ${mealPlanMeal.mealID} is used in another meal plan");
          continue;
        }
        db.delete(DBMeal.tableName,
            where: '${DBMeal.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBMealAllergen.tableName,
            where: '${DBMealAllergen.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBMealAdditive.tableName,
            where: '${DBMealAdditive.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBImage.tableName,
            where: '${DBImage.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBMealPlanMeal.tableName,
            where: '${DBMealPlanMeal.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        print("Deleted meal ${mealPlanMeal.mealID}");
      }
      db.delete(DBMealPlan.tableName,
          where: '${DBMealPlan.columnMealPlanID} = ?',
          whereArgs: [mealPlan.mealPlanID]);
      print("Deleted meal plan ${mealPlan.mealPlanID}: ${mealPlan.date}");
    }
    print("cleanUp done");
  }
}
