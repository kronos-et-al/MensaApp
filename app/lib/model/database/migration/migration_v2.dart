import 'package:app/model/database/model/db_meal_nutrition_data.dart';

final String migrationV1_V2 = '''
  ${DBMealNutritionData.initTable()}
''';