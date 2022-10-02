import 'dart:convert';

import 'package:odoo_api/odoo_user_response.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sharef {
  // late SharedPreferences preferences;
  // late Map<String, dynamic> user;
  static Future<bool> saveUser(OdooUser userInfo) async {
    if (userInfo.tz == false) {
      userInfo.tz = 'null';
    }

    String userStr = '{'
            '"name": "' +
        userInfo.name +
        '",'
            '"uid": "' +
        userInfo.uid.toString() +
        '",'
            '"partner_id": "' +
        userInfo.partnerId.toString() +
        '",'
            '"company_id": "' +
        userInfo.companyId.toString() +
        '",'
            '"username": "' +
        userInfo.username +
        '",'
            '"lang": "' +
        userInfo.lang +
        '",'
            '"timezone": "' +
        userInfo.tz +
        '",'
            '"database": "' +
        userInfo.database +
        '",'
            '"session_id": "' +
        userInfo.sessionId +
        '"'
            '}';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print('SetUserSessionId:' + userStr.toString());
    return preferences.setString('userInfo', userStr);
  }

  static Future<bool> getUserInfo() async {
    print('Get User Info');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userInfo = preferences.getString('userInfo');
    print('userInfo: $userInfo');
    if (userInfo == null) {
      return false;
    } else {
      return true;
    }
  }

  static Future<dynamic> getOdooClientInstance() async {
    print('EnterOdooClient');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userPref = preferences.getString('userInfo');
    Map<String, dynamic> user =
        (userPref != null) ? jsonDecode(userPref) : null;

    print(
        'GetUserSessionId: ${user['session_id'] == '' ? '' : user['session_id']}');
    return user;
  }

  static Future<void> deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  /// this will delete app's storage
  static Future<void> deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  static Future<bool> clearSessionId() async {
    print("Clear SessionId");
    SharedPreferences waitingPref = await SharedPreferences.getInstance();
    waitingPref.remove('userInfo');
    return true;
  }

  static Future<bool> logout() async {
    print('Clear preferences');
    await deleteCacheDir();
    await deleteAppDir();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();

    return true;
  }
}

class SharefCount {
  static Future<bool> setTotal(total) async {
    SharedPreferences setTotal = await SharedPreferences.getInstance();
    return setTotal.setInt('Total', total);
  }

  static Future<int?> getTotal() async {
    SharedPreferences setTotal = await SharedPreferences.getInstance();
    return setTotal.getInt('Total');
  }

  static Future<bool> setCount(count) async {
    print('Count from Setcount: $count');
    SharedPreferences waitingPref = await SharedPreferences.getInstance();
    return await waitingPref.setInt('Count', count);
  }

  static Future<int?> getCount() async {
    print('Enter Get Count');
    SharedPreferences waitingPref = await SharedPreferences.getInstance();
    return waitingPref.getInt('Count');
  }

  static Future<bool> clearCount() async {
    print("Clear Count");
    SharedPreferences waitingPref = await SharedPreferences.getInstance();
    waitingPref.remove('Count');
    return true;
  }
}
