import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/services/image_service.dart';

class ImageViewer extends StatefulWidget {
  final String label;
  final File? image;
  final Function(File?) setImage;

  const ImageViewer(
      {super.key, required this.label, required this.setImage, this.image});

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    ImageService()
                        .pickImage(ImageSource.camera, widget.setImage);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    ImageService()
                        .pickImage(ImageSource.gallery, widget.setImage);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: const Offset(3, 3),
              blurRadius: 6,
              color: Colors.grey.shade400,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, color: Colors.black54),
            const SizedBox(width: 5),
            Text(
              widget.image == null ? widget.label : '${widget.label} selected',
              style:  TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
