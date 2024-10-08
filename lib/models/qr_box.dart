import 'package:hive_flutter/hive_flutter.dart';

const String qrHiveBox = "QrBox";
const String qrHistoryHiveBox = "QrHistoryHiveBox";

const String qrKey = "key";
const String qrName = "qrName";
const String qrContent = "qrContent";
const String qrCreateDate = "qrCreateDate";

class HiveFunctions {
  static final qrBox = Hive.box(qrHiveBox);
  static final qrHistoryBox = Hive.box(qrHistoryHiveBox);

  static Future<void> openBox() async {
    await Future.wait([Hive.openBox(qrHiveBox), Hive.openBox(qrHistoryHiveBox)]);
  }

  static createQr(Map data) {
    qrBox.add(data);
  }

  static List getAllQR() {
    final data = qrBox.keys.map((key) {
      final value = qrBox.get(key);
      return {"key": key, qrName: value[qrName], qrContent: value[qrContent]};
    }).toList();

    return data.reversed.toList();
  }

  static Map getQR(int key) {
    return qrBox.get(key);
  }

  static Future<void>  updateQR(int key, Map data) async {
    await qrBox.put(key, data);
  }

  static Future<void> deleteQR(int key) async {
    await qrBox.delete(key);
  }

  static Future<void>  deleteAllQR(int key) async {
    await qrBox.deleteAll(qrBox.keys);
  }

  static Future<int> createQrHistory(Map data) async {
     return qrHistoryBox.add(data);
  }

  static List getAllQrHistory() {
    final data = qrHistoryBox.keys.map((key) {
      final value = qrHistoryBox.get(key);
      return {"key": key, qrContent: value[qrContent], qrCreateDate: value[qrCreateDate]};
    }).toList();

    return data.reversed.toList();
  }

  static Map getQrHistory(int key) {
    return qrHistoryBox.get(key);
  }

  static Future<void> updateQrHistory(int key, Map data) async {
    await qrHistoryBox.put(key, data);
  }

  static Future<void> deleteQrHistory(int key) async {
    await qrHistoryBox.delete(key);
  }

  static Future<void> deleteAllQrHistory(int key) async {
    await qrHistoryBox.deleteAll(HiveFunctions.qrHistoryBox.keys);
  }
}
