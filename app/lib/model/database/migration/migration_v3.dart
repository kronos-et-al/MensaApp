import 'package:app/model/database/model/db_meal_nutrition_data.dart';
import 'package:app/model/database/model/db_side_nutrition_data.dart';

final List<String> migrationV2ToV3 = [
  '''
  DROP TABLE IF EXISTS ${DBMealNutritionData.tableName};
  ''',
  '''
  ${DBMealNutritionData.initTable()};
  ''',
  '''
  ${DBSideNutritionData.initTable()};
'''
];
