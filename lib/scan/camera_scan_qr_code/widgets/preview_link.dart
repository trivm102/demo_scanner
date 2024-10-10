import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class PreviewLink extends StatelessWidget {
  final String link;
  const PreviewLink({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 0.9.sw,
      child: AnyLinkPreview(
        link: link,
        displayDirection: UIDirection.uiDirectionHorizontal,
        showMultimedia: true,
        bodyMaxLines: 5,
        bodyTextOverflow: TextOverflow.ellipsis,
        titleStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        bodyStyle: TextStyle(color: Colors.grey, fontSize: 12),
        errorBody: 'error',
        errorTitle: 'error',
        placeholderWidget: _placeholderWidget(context),
        errorWidget: _placeholderWidget(context),
        errorImage: "https://google.com/",
        cache: Duration(days: 1),
        backgroundColor: Colors.grey[300],
        borderRadius: 12,
        removeElevation: false,
        boxShadow: [BoxShadow(blurRadius: 3, color: Colors.grey)],
        onTap: () {
          _openLink();
        },
        urlLaunchMode: LaunchMode.externalApplication,
      ),
    );
  }

  Widget _placeholderWidget(BuildContext context) {
    return InkWell(
      onTap: _openLink,
      child: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.grey[300],
        child: Flexible(
          child: Text(
            link,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      ),
    );
  }

  Future<void> _openLink() async {
    final Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
