import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/link.dart';

Future<void> showAboutDialoog(
  BuildContext context,
) async {
  final appInfo = await PackageInfo.fromPlatform();
  showAboutDialog(
    context: context,
    applicationIcon: Image.asset('assets/app_icon_256.png', width: 64),
    applicationVersion: 'v${appInfo.version}',
    children: [
      const SizedBox(height: 16),
      Row(
        children: [
          const Text('GitHub: '),
          Link(
            uri: Uri.parse('https://github.com/mx1up/fdupes-gui'),
            builder: (context, followLink) => GestureDetector(
              onTap: followLink,
              child: const Text(
                'https://github.com/mx1up/fdupes-gui',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          const Text('Blog: '),
          Link(
            uri: Uri.parse('https://mattiesworld.gotdns.org/weblog/category/coding-excursions/fdupes-gui'),
            builder: (context, followLink) => GestureDetector(
              onTap: followLink,
              child: const Text(
                'https://mattiesworld.gotdns.org/weblog',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
