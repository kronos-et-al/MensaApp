import 'package:objectbox/objectbox.dart';

@Entity()
class BoxCanteen {
  int id = 0;

  @Unique()
  String canteenId;

  String name;

  BoxCanteen({required this.canteenId, required this.name});
}
