import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Category {
  String id;
  String name;
  String name_ar;
  Media image;

  Category();

  Category.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      name_ar=jsonMap['name_ar'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      id = '';
      name = '';
      name_ar='';
      image = new Media();
      print(CustomTrace(StackTrace.current, message: e));
    }
  }
}
