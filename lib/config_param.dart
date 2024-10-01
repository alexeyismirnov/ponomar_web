import 'package:shared_preferences/shared_preferences.dart';

typedef void SubscriptionHandler<T>(T val);

class ConfigParam<T> {
  static late SharedPreferences prefs;
  static var fontSize, langSelected;

  String prefKey;

  static initSharedParams({double initFontSize = 20.0}) async {
    prefs = await SharedPreferences.getInstance();

    fontSize = ConfigParam<double>('fontSize', initValue: initFontSize);
    langSelected = ConfigParam<bool>('lang_init', initValue: false);
  }

  ConfigParam(this.prefKey, {required T initValue}) {
    if (initValue != null && !exists) set(initValue);
  }

  bool get exists => prefs.getKeys().contains(prefKey);

  T val() {
    if (T == int)
      return prefs.getInt(prefKey) as T;
    else if (T == double)
      return prefs.getDouble(prefKey) as T;
    else if (T == bool)
      return prefs.getBool(prefKey) as T;
    else if (T == String)
      return prefs.getString(prefKey) as T;
    else
      return prefs.getStringList(prefKey) as T;
  }

  set(T val) {
    if (T == int)
      prefs.setInt(prefKey, val as int);
    else if (T == double)
      prefs.setDouble(prefKey, val as double);
    else if (T == bool)
      prefs.setBool(prefKey, val as bool);
    else if (T == String)
      prefs.setString(prefKey, val as String);
    else
      prefs.setStringList(prefKey, val as List<String>);
  }
}
