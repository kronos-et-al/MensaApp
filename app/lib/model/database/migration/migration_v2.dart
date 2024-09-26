import 'package:app/model/database/model/db_meal_nutrition_data.dart';

final List<String> migrationV1ToV2 = ['''
  ${DBMealNutritionData.initTable()}
'''];