
import 'package:flutter/material.dart';
import 'package:hscanner/utils/string_extensions.dart';

class PreviewCCCD extends StatelessWidget {
  final String cccd;
  const PreviewCCCD({super.key, required this.cccd});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cccdModel =  cccd.parseDataCCCD();
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFF7FFF7),
        border: Border.all(color: const Color(0xFFACB8B6))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Thông tin căn cước công dân', style: textTheme.titleLarge?.copyWith(color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 25),
        InfoCCCD(title: 'Số CCCD', content: cccdModel?.cccd ?? '', contentStyle: textTheme.titleLarge),
        _spacing,
        InfoCCCD(title: 'Số CMND', content: cccdModel?.cmnd ?? ''),
        _spacing,
        InfoCCCD(title: 'Họ và Tên', content: cccdModel?.fullName ?? ''),
        _spacing,
        Row(
          children: [
            Expanded(flex: 1, child: InfoCCCD(title: 'Giới tính', content: cccdModel?.gender ?? '')),
            Expanded(flex: 1, child: InfoCCCD(title: 'Ngày sinh', content: cccdModel?.dob?.toStringDMYYY() ?? '')),
          ],
        ),
        _spacing,
        InfoCCCD(title: 'Nơi thường trú', content: cccdModel?.address ?? ''),
         _spacing,
        InfoCCCD(title: 'Ngày cấp', content: cccdModel?.issueDate?.toStringDMYYY() ?? ''),
      ],
    ),
    );
  }

  Widget get _spacing =>  SizedBox(height: 15);
}

class InfoCCCD extends StatelessWidget {
  final String? title;
  final TextStyle? contentStyle;
  final String? content;
  const InfoCCCD({super.key, this.title, this.content, this.contentStyle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title ?? '', style: textTheme.bodyMedium?.copyWith(color: Color(0xFF626262))),
        SizedBox(height: 4),
        Text(content ?? '', style: contentStyle ?? textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400))
      ],
    );
  }
}