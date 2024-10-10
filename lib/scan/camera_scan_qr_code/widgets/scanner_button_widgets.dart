import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hscanner/models/qr_box.dart';
import 'package:hscanner/qr_card/qr_code_history_page.dart';
import 'package:hscanner/qr_card/qr_code_page.dart';
import 'package:hscanner/scan/camera_scan_qr_code/widgets/preview_cccd.dart';
import 'package:hscanner/scan/camera_scan_qr_code/widgets/preview_link.dart';
import 'package:hscanner/utils/string_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';

class AnalyzeImageFromGalleryButton extends StatelessWidget {
  const AnalyzeImageFromGalleryButton({required this.controller, this.callback, super.key});

  final MobileScannerController controller;
  final Function(BarcodeCapture?)? callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.black.withAlpha(100),
      ),
      padding: const EdgeInsets.all(5),
      child: IconButton(
        color: Colors.white,
        icon: const Icon(Icons.image),
        iconSize: 32.0,
        onPressed: () async {
          final ImagePicker picker = ImagePicker();

          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
          );

          if (image == null) {
            return;
          }

          final BarcodeCapture? barcodes = await controller.analyzeImage(
            image.path,
          );
          if (barcodes != null) {
            callback?.call(barcodes);
            return;
          }

          if (!context.mounted) {
            return;
          }

          final SnackBar snackbar = barcodes != null
              ? const SnackBar(
                  content: Text('Barcode found!'),
                  backgroundColor: Colors.green,
                )
              : const SnackBar(
                  content: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text('Hãy chọn ảnh có chứa mã QR'),
                  ),
                  backgroundColor: Colors.red,
                );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
      ),
    );
  }
}

class HistoryButton extends StatelessWidget {
  const HistoryButton({this.callback, super.key});
  final Function()? callback;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.black.withAlpha(100),
      ),
      padding: const EdgeInsets.all(5),
      child: IconButton(
        color: Colors.white,
        icon: const Icon(Icons.history),
        iconSize: 32.0,
        onPressed: () async {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrCodeHistoryPage()));
        },
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.qr});
  final String qr;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        _showDialogSaveQR(context, qr);
      },
      child: Icon(
        Icons.save,
        color: Colors.black,
      ),
      style: ButtonStyle(
        shape: WidgetStateProperty.all(CircleBorder()),
        padding: WidgetStateProperty.all(EdgeInsets.all(12)),
        backgroundColor: WidgetStateProperty.all(Colors.grey.shade200), // <-- Button color
      ),
    );
  }

  void _showDialogSaveQR(BuildContext context, String qr) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ContentSaveQR(qr: qr);
      },
    );
  }
}

class _ContentSaveQR extends StatefulWidget {
  const _ContentSaveQR({super.key, required this.qr});
  final String qr;

  @override
  State<_ContentSaveQR> createState() => __ContentSaveQRState();
}

class __ContentSaveQRState extends State<_ContentSaveQR> {
  final _controller = TextEditingController();

  bool _enableSave = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _enableSave = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Nội dung thẻ QR'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Tiêu đề thẻ',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(99)),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Hủy', style: textTheme.bodyMedium?.copyWith(color: const Color.fromARGB(255, 44, 44, 44))),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          onPressed: !_enableSave
              ? null
              : () {
                  HiveFunctions.createQr({qrName: _controller.text, qrContent: widget.qr});
                  Navigator.of(context).pop();
                },
          child: Text('Lưu', style: textTheme.bodyMedium?.copyWith(color: _enableSave ? Colors.blue : Colors.grey)),
        ),
      ],
    );
  }
}

void codePreview(BuildContext context, String code,
    {CodePreviewType type = CodePreviewType.scan, Function()? close}) async {
  final Uri? uri = Uri.tryParse(code);
  bool hasInternetAccess = await InternetConnection().hasInternetAccess;
  final bool cccdIsValid = code.cccdIsValid();
  final bool isShowPreviewLink = AnyLinkPreview.isValidLink(code, requireProtocol: true) && hasInternetAccess;
  Future<void> future = showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext modalContext) {
      return Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.only(topLeft: const Radius.circular(20.0), topRight: const Radius.circular(20.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(5),
              width: 40,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 12),
                if (!cccdIsValid && !cccdIsValid && !isShowPreviewLink) ...{
                  Expanded(
                    child: Text(
                      code,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                },
                const SizedBox(height: 20),
                if (isShowPreviewLink) ...{
                  Expanded(child: PreviewLink(link: code)),
                },
                if (cccdIsValid) ...{
                  Expanded(child: PreviewCCCD(cccd: code)),
                },
                const SizedBox(width: 12),
              ],
            ),
            Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.all(18)),
                      backgroundColor: WidgetStateProperty.all(Colors.blue),
                    ),
                    onPressed: () async {
                      if (uri?.hasAbsolutePath == true) {
                        Share.shareUri(uri!);
                      } else if (cccdIsValid) {
                        Share.share(code.parseDataCCCD().toString());
                      } else {
                        Share.share(code);
                      }
                    },
                    child: const Icon(Icons.ios_share),
                  ),
                ),
                const SizedBox(width: 10),
                CopyButton(qr: code),
                const SizedBox(width: 10),
                if (type == CodePreviewType.scan) SaveButton(qr: code),
                const SizedBox(width: 10),
              ],
            ),
            const SafeArea(child: SizedBox(height: 20)),
          ],
        ),
      );
    },
  );
  future.then((void value) {
    close?.call();
  });
}

enum CodePreviewType { scan, view }

class MyQrCode extends StatelessWidget {
  const MyQrCode({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QRCardPage())),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.black.withAlpha(100),
        ),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        height: 50,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.recent_actors_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Mã QR của tôi',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

class CopyButton extends StatelessWidget {
  const CopyButton({super.key, required this.qr});
  final String qr;

  @override
  Widget build(BuildContext context) {
    final bool cccdIsValid = qr.cccdIsValid();
    return FilledButton(
      onPressed: () async {
        String textToCopy = qr;
        if (cccdIsValid) {
          textToCopy = qr.parseDataCCCD().toString();
        }
        await Clipboard.setData(ClipboardData(text: textToCopy));
        Fluttertoast.showToast(
            msg: 'Đã sao chép',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      },
      child: Icon(
        Icons.copy,
        color: Colors.black,
      ),
      style: ButtonStyle(
        shape: WidgetStateProperty.all(CircleBorder()),
        padding: WidgetStateProperty.all(EdgeInsets.all(12)),
        backgroundColor: WidgetStateProperty.all(Colors.grey.shade200), // <-- Button color
      ),
    );
  }
}
