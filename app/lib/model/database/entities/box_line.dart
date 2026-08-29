import 'package:objectbox/objectbox.dart';
import 'box_canteen.dart';

@Entity()
class BoxLine {
  int id = 0;

  @Unique()
  String lineId;

  String name;
  int position;

  final canteen = ToOne<BoxCanteen>();

  BoxLine({
    required this.lineId,
    required this.name,
    required this.position,
  });
}
