import 'dart:io';
import 'package:app/model/database/SQLiteMigration.dart';
import 'package:app/model/database/entities/box_favorite.dart';
import 'package:app/model/database/objectbox.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Store store;
  late Directory tempDir;
  late String dbPath;

  setUp(() async {
    // Initialize in-memory ObjectBox
    store = await openStore(directory: 'memory:test-db');
    
    // Create temporary directory for SQLite file
    tempDir = Directory.systemTemp.createTempSync('sqlite_migration_test');
    dbPath = '${tempDir.path}/mensa.db';

    // Create mock SQLite database
    final db = sqlite3.open(dbPath);
    db.execute('''
      CREATE TABLE Favorite (
        mealID TEXT PRIMARY KEY,
        lineID TEXT,
        lastServed TEXT
      )
    ''');
    db.execute("INSERT INTO Favorite (mealID, lineID, lastServed) VALUES ('meal1', 'line1', '2023-10-27T12:00:00Z')");
    db.execute("INSERT INTO Favorite (mealID, lineID, lastServed) VALUES ('meal2', NULL, NULL)");
    db.dispose();
  });

  tearDown(() {
    store.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Migration correctly recovers favorites and renames file', () async {
    final migration = SQLiteMigration(store, testDbPath: dbPath);
    
    await migration.migrateFavorites();

    final favBox = store.box<BoxFavorite>();
    final favorites = favBox.getAll();
    expect(favorites.length, 2);

    // Verify first favorite
    final fav1 = favorites.firstWhere((f) => f.meal.target?.mealId == 'meal1');
    expect(fav1.meal.target?.name, 'Lade...');
    expect(fav1.line.target?.lineId, 'line1');
    expect(fav1.servedDate.year, 2023);

    // Verify second favorite
    final fav2 = favorites.firstWhere((f) => f.meal.target?.mealId == 'meal2');
    expect(fav2.meal.target?.mealId, 'meal2');
    expect(fav2.line.target, isNull);

    // Verify original file was renamed
    expect(File(dbPath).existsSync(), isFalse);
    expect(File('$dbPath.migrated').existsSync(), isTrue);
  });

  test('Migration handles missing table gracefully', () async {
    // Clear and recreate DB without the table
    if (File(dbPath).existsSync()) File(dbPath).deleteSync();
    final db = sqlite3.open(dbPath);
    db.dispose();

    final migration = SQLiteMigration(store, testDbPath: dbPath);
    await migration.migrateFavorites();

    expect(store.box<BoxFavorite>().count(), 0);
  });
}
