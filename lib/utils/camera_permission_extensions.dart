import 'package:permission_handler/permission_handler.dart';

extension CameraPermissionX on Permission {
  static const _diffInMills = 500;
  Future<PermissionStatus?> cameraRequest() async {
    final checkStatusTime = DateTime.now();
    final status = await Permission.camera.status;
    final newStatus = await Permission.camera.request();
    final newCheckStatusTime = DateTime.now();
    final difference = newCheckStatusTime.difference(checkStatusTime);
    if (status.isDenied &&
        newStatus.isPermanentlyDenied &&
        difference.inMilliseconds < _diffInMills) {
      return null;
    }
    return newStatus;
  }
}