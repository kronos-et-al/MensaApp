import 'dart:io';

import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:app/view_model/repository/interface/IServerAccess.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Simple legacy migration to move favorites from old SQLite DB to new storage
class LegacyMigration {
  static const String _oldDbName = 'meal_plan.db';

  /// Migrates favorites from old SQLite database to new storage
  /// This creates minimal meal objects with just IDs - the actual meal data
  /// will be fetched from the API by the existing refresh logic
  static Future<void> migrateFavoritesIfNeeded(
    IDatabaseAccess newDb, {
    IServerAccess? api,
  }) async {
    try {
      print('[LegacyMigration] Starting legacy migration check...');

      // Check if old database exists
      final dbPath = join(await getDatabasesPath(), _oldDbName);
      if (!await File(dbPath).exists()) {
        print('[LegacyMigration] No old database found, migration not needed');
        return; // No old database, nothing to migrate
      }

      print('[LegacyMigration] Found old database, starting migration...');

      // Open old database in read-only mode
      final oldDb = await openDatabase(dbPath, readOnly: true);

      try {
        // Get all favorites from old database
        final favorites = await oldDb.rawQuery(
          'SELECT mealID, servedDate, servedLineId FROM favorite',
        );

        if (favorites.isEmpty) {
          print(
            '[LegacyMigration] Old database found but no favorites to migrate',
          );
          return; // No favorites to migrate
        }

        print(
          '[LegacyMigration] Found ${favorites.length} favorites to migrate',
        );

        // Get line and canteen data
        final lines = await oldDb.rawQuery(
          'SELECT lineID, canteenID, name, position FROM line',
        );
        final canteens = await oldDb.rawQuery(
          'SELECT canteenID, name FROM canteen',
        );

        // Create lookup maps
        final canteenMap = <String, Canteen>{};
        for (final canteen in canteens) {
          canteenMap[canteen['canteenID'] as String] = Canteen(
            id: canteen['canteenID'] as String,
            name: canteen['name'] as String,
          );
        }

        final lineMap = <String, Line>{};
        for (final line in lines) {
          final canteen = canteenMap[line['canteenID'] as String];
          if (canteen != null) {
            lineMap[line['lineID'] as String] = Line(
              id: line['lineID'] as String,
              name: line['name'] as String,
              position: line['position'] as int,
              canteen: canteen,
            );
          }
        }

        // For each favorite, create a minimal meal and add to new DB
        for (final fav in favorites) {
          final mealId = fav['mealID'] as String;
          final servedDate = DateTime.parse(fav['servedDate'] as String);
          final lineId = fav['servedLineId'] as String;

          final line = lineMap[lineId];
          if (line == null) continue;

          // Create a minimal meal with just the ID and required fields
          // The existing refresh logic will fetch the full meal data from API
          final minimalMeal = Meal(
            id: mealId,
            name: '', // Will be updated from API
            foodType: FoodType.unknown, // Will be updated from API
            price: Price(
              student: 0,
              employee: 0,
              pupil: 0,
              guest: 0,
            ), // Will be updated from API
            allergens: [],
            additives: [],
            sides: [],
            isFavorite: true,
          );

          try {
            // Add to new database - the existing refresh logic will update with real data
            await newDb.addFavorite(minimalMeal, servedDate, line);
            print('[LegacyMigration] Successfully migrated favorite: $mealId');
          } catch (e) {
            // Skip individual failures
            print('[LegacyMigration] Failed to migrate favorite $mealId: $e');
            continue;
          }
        }

        print('[LegacyMigration] Migration completed successfully');

        // Rename the old database to prevent re-migration
        try {
          final oldDbFile = File(dbPath);
          final backupPath = '$dbPath.migrated';
          await oldDbFile.rename(backupPath);
          print('[LegacyMigration] Renamed old database to $backupPath');
        } catch (e) {
          print('[LegacyMigration] Failed to rename old database: $e');
        }

        // If API access is provided, try to refresh the migrated favorites
        if (api != null) {
          await _refreshMigratedFavorites(newDb, api);
        }
      } finally {
        oldDb.close();
      }
    } catch (e) {
      // Migration failed, but that's okay - it's legacy data
      // The app will work fine without the old favorites
      print('[LegacyMigration] Migration failed: $e');
    }
  }

  /// Refreshes the migrated favorites by fetching current data from API
  static Future<void> _refreshMigratedFavorites(
    IDatabaseAccess db,
    IServerAccess api,
  ) async {
    print('[LegacyMigration] Refreshing migrated favorites from API...');

    try {
      final favorites = await db.getFavorites();

      for (final favorite in favorites) {
        // Try to get current meal data from API
        final result = await api.getMeal(
          favorite.meal,
          favorite.servedLine,
          favorite.servedDate,
        );

        if (result case Success(value: final meal)) {
          // Update the meal with current data from API
          await db.updateMeal(meal);
          await db.addFavorite(
            meal,
            meal.lastServed ?? favorite.servedDate,
            favorite.servedLine,
          );
          print('[LegacyMigration] Refreshed meal ${meal.id} from API');
        } else {
          print(
            '[LegacyMigration] Could not refresh meal ${favorite.meal.id} from API',
          );
        }
      }

      print('[LegacyMigration] Favorite refresh completed');
    } catch (e) {
      print('[LegacyMigration] Failed to refresh favorites: $e');
    }
  }
}
