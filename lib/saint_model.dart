import 'church_day.dart';

class Saint {
  String name;
  FeastType type;

  Saint(this.name, this.type);

  Saint.fromJson(Map<String, dynamic> json)
      : name = "${json['name']}",
        type = FeastType.values[json['typikon']];
}
