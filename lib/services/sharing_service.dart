import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SharingService {
  SharingService._();

  static Future<void> shareApp({
    required BuildContext context,
    Rect? sharePositionOrigin,
    required String message,
  }) async {
    final box = context.findRenderObject() as RenderBox?;
    Rect? origin = sharePositionOrigin;
    if (origin == null && box != null && box.hasSize) {
      origin = box.localToGlobal(Offset.zero) & box.size;
    }
    await Share.share(
      message,
      sharePositionOrigin: origin,
    );
  }
}
