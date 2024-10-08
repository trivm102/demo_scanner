import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hscanner/models/qr_box.dart';
import 'package:hscanner/scan/camera_scan_qr_code/qrcode_scanner_controller.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  await HiveFunctions.openBox();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return MaterialApp(
          // The Mandy red, light theme.
          theme: FlexThemeData.light(scheme: FlexScheme.mandyRed),
          // The Mandy red, dark theme.
          darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed),
          // Use dark or light theme based on system setting.
          themeMode: ThemeMode.system,
          home: const QrCodeScannerWithController(),
        );
      },
      designSize: const Size(375, 813),
    );
  }
}
