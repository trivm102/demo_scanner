import 'package:hscanner/models/cccd_model.dart';
import 'package:intl/intl.dart';

extension StringX on String? {
  bool cccdIsValid() {
    if (this == null) {
      return false;
    }
    final arrayString = this?.split('|');
    if (arrayString?.length == 7) {
      return true;
    }
    return false;
  }

  CCCDModel? parseDataCCCD() {
    if (this == null) {
      return null;
    }
    final arrayString = this?.split('|');
    if (arrayString?.length == 7) {
      final idCCCD = arrayString?.elementAt(0);
      final idCMND = arrayString?.elementAt(1);
      final fullName = arrayString?.elementAt(2);
      final dob = _convertDate(arrayString?.elementAt(3));
      final gender = arrayString?.elementAt(4);
      final address = arrayString?.elementAt(5);
      final issueDate = _convertDate(arrayString?.elementAt(6));
      return CCCDModel(
        fullName: fullName,
        address: address,
        cccd: idCCCD,
        cmnd: idCMND,
        dob: dob,
        gender: gender,
        issueDate: issueDate,
      );
    }
    return null;
  }

  DateTime? _convertDate(String? src) {
    if (src == null || src.length != 8) {
      return null;
    }
    try {
      String? result = src.substring(4, src.length) + src.substring(2, 4) + src.substring(0, 2);
      return DateTime.parse(result);
    } catch (e) {
      return null;
    }
  }
}


extension DateTimeX on DateTime? {
  String toStringDMYYY() {
    final DateTime? temp = this;
    if (temp == null) {
      return '';
    }
    try {
      return DateFormat('d/M/yyyy').format(temp);
    } catch (ex) {
      return '';
    }
  }
}
