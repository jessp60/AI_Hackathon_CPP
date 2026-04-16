import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openInAppLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;

  final mode = kIsWeb
      ? LaunchMode.platformDefault
      : LaunchMode.inAppBrowserView;

  await launchUrl(uri, mode: mode);
}
