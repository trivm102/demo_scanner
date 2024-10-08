import 'package:mobile_scanner/mobile_scanner.dart';

extension MobileScannerStateX on MobileScannerState {
  bool get hasCameraPermission {
    return isInitialized && error?.errorCode != MobileScannerErrorCode.permissionDenied;
  }
}
