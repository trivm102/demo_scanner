import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hscanner/models/qr_box.dart';
import 'package:hscanner/scan/camera_scan_qr_code/widgets/scanner_button_widgets.dart';
import 'package:hscanner/utils/string_extensions.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCardPage extends StatefulWidget {
  const QRCardPage({super.key});

  @override
  State<QRCardPage> createState() => _QRCardPageState();
}

class _QRCardPageState extends State<QRCardPage> {
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách QR đã lưu'),
      ),
      body: _data.isNotEmpty == true
          ? ListView.separated(
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                final item = _data[index];
                return _Item(
                  item: item,
                  index: index,
                  deleteCallback: () {
                    _loadData();
                  },
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemCount: _data.length,
            )
          : Center(
              child: Text(
                'Không có dữ liệu',
                style: textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            ),
    );
  }

  void _loadData() {
    setState(() {
      _data = HiveFunctions.getAllQR() as List<Map<String, dynamic>>? ?? [];
    });
  }
}

class _Item extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final Function()? deleteCallback;
  const _Item({super.key, required this.item, required this.index, this.deleteCallback});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final String name = item[qrName] ?? '';
    String content = item[qrContent] ?? '';
    if (content.cccdIsValid()) {
      content = content.parseDataCCCD().toString();
    }
    return Slidable(
      key: ValueKey(index),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (context) async {
              await HiveFunctions.deleteQR(item[qrKey]);
              deleteCallback?.call();
            },
            foregroundColor: const Color(0xFFFE4A49),
            icon: Icons.delete,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          codePreview(context, content, type: CodePreviewType.view, close: () {});
        },
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          child: Container(
            color: Color(0xFFa7c957),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    name,
                    style: textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  height: 120,
                  width: double.infinity,
                  color: const Color(0xFFf2e8cf),
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QrImageView(
                        data: content,
                        size: 100.0,
                      ),
                      Flexible(
                        child: Text(
                          content,
                          style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
