import 'migration_v2.dart';
import 'migration_v3.dart';
import 'migration_v4.dart';

final Map<(int, int), List<String>> dbMigrations = {
  (1, 2): migrationV1_V2,
  (2, 3): migrationV2_V3,
  (3, 4): migrationV3_V4,
};