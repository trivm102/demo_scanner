import 'package:hscanner/utils/string_extensions.dart';

class CCCDModel {
  final String? fullName;
  final String? cccd;
  final String? cmnd;
  final String? gender;
  final String? address;
  final DateTime? dob;
  final DateTime? issueDate;

  const CCCDModel({
    this.fullName,
    this.address,
    this.cccd,
    this.cmnd,
    this.dob,
    this.gender,
    this.issueDate,
  });

  @override
  String toString() {
    return 'Số CCCD: $cccd\nSố CMND: $cmnd\nHọ và Tên: $fullName\nGiới tính:$gender\nNgày sinh: ${dob?.toStringDMYYY()}\nNơi thường trú: $address\nNgày cấp: ${issueDate?.toStringDMYYY()}';
  }
}

//086090009912|331585312|Võ Minh Trí|10021990|Nam|Số Nhà 29/6, Đường Trần Phú, Khóm 3, Phường 4, Thành phố Vĩnh Long, Vĩnh Long|02072021