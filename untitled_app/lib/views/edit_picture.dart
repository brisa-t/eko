import 'dart:io';
import 'dart:ui' as ui;

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:go_router/go_router.dart';
import 'package:image_to_ascii/image_to_ascii.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled_app/custom_widgets/image_widget.dart';

class EditPicture extends StatefulWidget {
  final XFile picture;
  const EditPicture({super.key, required this.picture});

  @override
  State<EditPicture> createState() => _EditPictureState();
}

class _EditPictureState extends State<EditPicture> {
  AsciiImage? asciiPicture;
  bool isDark = true;
  bool isColor = false;

  Future<void> convert() async {
    final cropped = await cropToAspectRatio(widget.picture.path,
        desiredWidth: 150, vScale: 0.75);
    final img =
        await convertImageToAscii(cropped, dark: isDark, color: isColor);
    setState(() {
      asciiPicture = img;
    });
  }

  void toggleDarkMode() {
    setState(() {
      isDark = !isDark;
    });
    convert();
  }

  void toggleColor() {
    setState(() {
      isColor = !isColor;
    });
    convert();
  }

  void copyPressed() {
    if (asciiPicture != null) {
      Clipboard.setData(ClipboardData(text: asciiPicture!.toDisplayString()));
    }
  }

  bool downloading = false;
  GlobalKey imageKey = GlobalKey();

  void downloadPressed() async {
    if (downloading) return;
    downloading = true;

    RenderRepaintBoundary boundary =
        imageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Create a temporary file
    final Directory tempDir = await getTemporaryDirectory();
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String tempPath = '${tempDir.path}/ascii_image_$timestamp.png';

    // Save to temp file
    File tempFile = File(tempPath);
    await tempFile.writeAsBytes(pngBytes);

    // Save to gallery
    await GallerySaver.saveImage(tempPath, toDcim: true)
        .then((_) => tempFile.delete());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image saved to gallery'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    downloading = false;
  }

  @override
  void initState() {
    convert();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => context.pop(),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: copyPressed,
                  icon: Icon(
                    Icons.copy,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: downloadPressed,
                  icon: Icon(
                    Icons.download,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (asciiPicture != null) context.pop(asciiPicture);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.arrow_forward,
                        size: 20,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: asciiPicture == null
                  ? const Center(child: CircularProgressIndicator())
                  : RepaintBoundary(
                      key: imageKey, child: ImageWidget(ascii: asciiPicture!)),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: toggleDarkMode,
                  icon: Icon(
                    size: 35,
                    (isDark) ? Icons.dark_mode : Icons.light_mode,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: toggleColor,
                  icon: Icon(
                    size: 35,
                    isColor ? Icons.palette : Icons.filter_b_and_w,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
