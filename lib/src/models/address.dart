import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Address {
  String id;
  String description;
  String address;
  double latitude;
  double longitude;
  bool isDefault;
  String userId;
  String market_id;
  String address_id;
  Address();

  void loadaddress() async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    address_id = prefs1.getString('del_id');
  }

  Address.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      description = jsonMap['description'] != null ? jsonMap['description'].toString() : null;
      address = jsonMap['address'] != null ? jsonMap['address'] : null;
      latitude = jsonMap['latitude'] != null ? jsonMap['latitude'] : null;
      longitude = jsonMap['longitude'] != null ? jsonMap['longitude'] : null;
      market_id = jsonMap['market_id'].toString();
      isDefault = jsonMap['is_default'] ?? false;
    } catch (e) {
      print(e);
    }
  }

  bool isUnknown() {
    return latitude == null || longitude == null;
  }

  Map toMap() {
    loadaddress();
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["description"] = description;
    map["address"] = address;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["is_default"] = isDefault;
    map['market_id'] = market_id;
    map["user_id"] = userId;
    map["address_id"] = address_id;
    return map;
  }

  LocationData toLocationData() {
    return LocationData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
    });
  }
}
