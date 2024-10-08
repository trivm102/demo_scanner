import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hscanner/models/qr_box.dart';
import 'package:hscanner/scan/camera_scan_qr_code/widgets/qr_scanner_overlay_shape.dart';
import 'package:hscanner/scan/camera_scan_qr_code/widgets/scanner_button_widgets.dart';
import 'package:hscanner/utils/app_shared_preferences.dart';
import 'package:hscanner/utils/mobile_scanner_state_extensions.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visibility_detector/visibility_detector.dart';

class QrCodeScannerWithController extends StatefulWidget {
  const QrCodeScannerWithController({super.key});

  @override
  State<QrCodeScannerWithController> createState() => _QrCodeScannerWithControllerState();
}

class _QrCodeScannerWithControllerState extends State<QrCodeScannerWithController> with WidgetsBindingObserver {
  MobileScannerController controller = MobileScannerController(
    autoStart: false,
    torchEnabled: false,
  );

  StreamSubscription<Object?>? _subscription;
  bool _isShowPopup = false;
  String? _scanDataCode;

  void _handleBarcode(BarcodeCapture barcodes) {
    final String? displayValue = barcodes.barcodes.firstOrNull?.displayValue;
    if (displayValue == null || displayValue == _scanDataCode || _isShowPopup) {
      return;
    }
    _scanDataCode = displayValue;
    HiveFunctions.createQrHistory({qrContent: _scanDataCode, qrCreateDate: DateTime.now().millisecondsSinceEpoch});
    _isShowPopup = true;
    codePreview(
      context,
      _scanDataCode!,
      close: () {
        _scanDataCode = null;
        _isShowPopup = false;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkPermissionRequested();
      });
    }

    _subscription = controller.barcodes.listen(_handleBarcode);
    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);
        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: 300,
      height: 300,
    );
    return VisibilityDetector(
      key: const Key('QrCodeScannerWithController'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1) {
          controller.start();
        } else {
          controller.stop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              scanWindow: scanWindow,
              controller: controller,
              fit: BoxFit.contain,
              errorBuilder: (context, error, child) {
                if (!controller.value.hasCameraPermission) {
                  return AlertDialog(
                    title: const Text('Thông báo'),
                    content: const Text('Bạn vui lòng cho phép quyền sử dụng máy ảnh để thực hiện scan QRCode'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          openAppSettings();
                          closeApp();
                        },
                        child: const Text('Cài đặt'),
                      ),
                    ],
                  );
                }
                return child ?? const SizedBox.shrink();
              },
            ),
            _buildScanWindow(scanWindow),
            const Align(
                alignment: Alignment.topCenter,
                child: SafeArea(
                  //   child:
                  // TextButton(onPressed: (){}, child: const Text('Mã QR của tôi')),
                  child: MyQrCode(),
                )),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 100,
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnalyzeImageFromGalleryButton(
                        controller: controller,
                        callback: (barcodes) {
                          if (barcodes == null) return;
                          _handleBarcode(barcodes);
                        },
                      ),
                      const HistoryButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized || !value.isRunning || value.error != null || value.size.isEmpty) {
          return const SizedBox();
        }
        // return QrScannerOverlay();
        return Container(
            decoration: ShapeDecoration(
          shape: QrScannerOverlayShape(
            borderColor: const Color.fromARGB(255, 210, 207, 207),
            borderLength: 30,
            borderWidth: 13,
            cutOutSize: scanWindowRect.width,
            cutOutBottomOffset: 20,
          ),
        ));
      },
    );
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  Future<void> _checkPermissionRequested({int delayMilliseconds = 500}) async {
    Future.delayed(Duration(milliseconds: delayMilliseconds), () async {
      if (await AppSharedPreferences.getRequestCameraPermission() != null) {
      } else {
        AppSharedPreferences.setRequestCameraPermission();
      }
    });
  }
}

extension _BarcodeScannerWithControllerStateX on _QrCodeScannerWithControllerState {
  void closeApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      // exit(0);
    }
  }
}
