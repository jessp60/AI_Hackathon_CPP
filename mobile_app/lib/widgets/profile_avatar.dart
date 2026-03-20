import 'dart:io';

import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme_constants.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.account,
    this.radius = 20,
  });

  final AppAccount account;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final photoUrl = account.photoUrl?.trim();
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final imageProvider = hasPhoto ? _imageProvider(photoUrl) : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: brandAccent.withValues(alpha: 0.12),
      backgroundImage: imageProvider,
      child: hasPhoto
          ? null
          : Text(
              account.initials,
              style: TextStyle(
                color: brandAccentDark,
                fontWeight: FontWeight.w600,
                fontSize: radius * 0.75,
              ),
            ),
    );
  }

  ImageProvider? _imageProvider(String photoUrl) {
    final parsedUri = Uri.tryParse(photoUrl);
    final isRemote = parsedUri != null &&
        (parsedUri.scheme == 'http' || parsedUri.scheme == 'https');
    if (isRemote) {
      return NetworkImage(photoUrl);
    }
    if (photoUrl.isNotEmpty) {
      return FileImage(File(photoUrl));
    }
    return null;
  }
}
