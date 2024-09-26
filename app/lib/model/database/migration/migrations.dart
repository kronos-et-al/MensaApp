import 'migration_v2.dart';
import 'migration_v3.dart';
import 'migration_v4.dart';

final Map<(int, int), List<String>> dbMigrations = {
  (1, 2): migrationV1ToV2,
  (2, 3): migrationV2ToV3,
  (3, 4): migrationV3ToV4,
};