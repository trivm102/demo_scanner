import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hscanner/models/qr_box.dart';
import 'package:hscanner/scan/camera_scan_qr_code/widgets/scanner_button_widgets.dart';
import 'package:intl/intl.dart';

class QrCodeHistoryPage extends StatefulWidget {
  const QrCodeHistoryPage({super.key});

  @override
  State<QrCodeHistoryPage> createState() => _QrCodeHistoryPageState();
}

class _QrCodeHistoryPageState extends State<QrCodeHistoryPage> {
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
        title: const Text('Lịch sử'),
      ),
      body: _data.isNotEmpty == true
          ? ListView.separated(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20),
              itemBuilder: (context, index) {
                final item = _data[index];
                return _Item(item: item, index: index, deleteCallback: () {
                  _loadData();
                });
              },
              separatorBuilder: (context, index) => const Divider(height: 10),
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
      _data = HiveFunctions.getAllQrHistory() as List<Map<String, dynamic>>? ?? [];
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
    print('_Item: ${item.toString()}');
    final textTheme = Theme.of(context).textTheme;
    final int time = item[qrCreateDate] ?? 0;
    String content = item[qrContent] ?? '';

    return Slidable(
      key: ValueKey(index),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.2,
        children: [
          SlidableAction(
            onPressed: (context) async {
              await HiveFunctions.deleteQrHistory(item[qrKey]);
              deleteCallback?.call();
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          codePreview(context, content, type: CodePreviewType.view, close: () {});
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              content,
              style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(time)),
                  style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
