import 'dart:io';
import 'package:app/model/database/entities/box_favorite.dart';
import 'package:app/model/database/entities/box_meal.dart';
import 'package:app/model/database/entities/box_line.dart';
import 'package:app/model/database/objectbox.g.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteMigration {
  final Store _store;
  final String? _testDbPath;

  SQLiteMigration(this._store, {String? testDbPath})
      : _testDbPath = testDbPath;

  Future<void> migrateFavorites() async {
    try {
      final dbPath = _testDbPath ?? await _getDatabasePath();
      if (dbPath == null || !File(dbPath).existsSync()) {
        print("MensaApp Migration: No legacy SQLite database found at ${dbPath ?? 'unknown path'}");
        return;
      }

      print("MensaApp Migration: Legacy SQLite database found at $dbPath. Starting favorites recovery...");
      final db = sqlite3.open(dbPath);
      
      try {
        final results = db.select('SELECT * FROM Favorite');
        
        int count = 0;
        for (final row in results) {
          final mealId = row['mealID'] as String?;
          final lineId = row['lineID'] as String?;
          final lastServedStr = row['lastServed'] as String?;
          
          if (mealId != null) {
            _importFavorite(mealId, lineId, lastServedStr);
            count++;
          }
        }
        
        print("MensaApp Migration: Successfully recovered $count favorites from SQLite.");
        
        // Dispose connection and rename file to mark as migrated
        db.dispose();
        final migratedFile = File(dbPath).renameSync('$dbPath.migrated');
        print("MensaApp Migration: Legacy database renamed to prevent re-migration: ${migratedFile.path}");
        
      } catch (e) {
        print("MensaApp Migration Error: Could not read legacy Favorite table: $e");
        db.dispose();
      }
    } catch (e) {
      print("MensaApp Migration Error: Recovery failed: $e");
    }
  }

  void _importFavorite(String mealId, String? lineId, String? lastServedStr) {
    final mealBox = _store.box<BoxMeal>();
    final favBox = _store.box<BoxFavorite>();
    final lineBox = _store.box<BoxLine>();

    // 1. Check if this favorite already exists in ObjectBox
    final qb = favBox.query();
    qb.link(BoxFavorite_.meal, BoxMeal_.mealId.equals(mealId));
    final existingFav = qb.build().findFirst();

    if (existingFav != null) return;

    // 2. Find or create a minimal placeholder for the Meal.
    var boxMeal = mealBox.query(BoxMeal_.mealId.equals(mealId)).build().findFirst();
    if (boxMeal == null) {
      boxMeal = BoxMeal(
        mealId: mealId,
        name: "Lade...", 
        foodType: "UNKNOWN",
        individualRating: 0,
        numberOfRatings: 0,
        averageRating: 0,
        allergens: [],
        additives: [],
        isSide: false,
      );
      mealBox.put(boxMeal);
    }

    // 3. Find or create placeholder line if we have an ID
    BoxLine? boxLine;
    if (lineId != null) {
      boxLine = lineBox.query(BoxLine_.lineId.equals(lineId)).build().findFirst();
    }

    // 4. Parse date
    final date = lastServedStr != null 
      ? DateTime.tryParse(lastServedStr) ?? DateTime.now()
      : DateTime.now();

    // 5. Save the favorite link
    final favorite = BoxFavorite(servedDate: date);
    favorite.meal.target = boxMeal;
    if (boxLine != null) {
      favorite.line.target = boxLine;
    }
    
    favBox.put(favorite);
  }

  Future<String?> _getDatabasePath() async {
    if (Platform.isAndroid) {
      final docDir = await getApplicationDocumentsDirectory();
      // On Android, sqflite databases are in a 'databases' folder at the same level as 'app_flutter'
      return join(docDir.parent.path, 'databases', 'mensa.db');
    } else if (Platform.isIOS) {
      final docDir = await getApplicationDocumentsDirectory();
      return join(docDir.path, 'mensa.db');
    }
    return null;
  }
}
