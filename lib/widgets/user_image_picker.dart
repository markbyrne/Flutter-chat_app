import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File) onPickedImage;
  const UserImagePicker({super.key, required this.onPickedImage});

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  Future<ImageSource?> _pickImageSource() {
    return showModalBottomSheet<ImageSource?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(ctx).pop(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
                  title: const Text('Camera'),
                  onTap: () {
                    Navigator.of(ctx).pop(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.grey),
                  title: const Text('Cancel'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickImage() async {
    final ImageSource? imageSrc = kIsWeb
        ? ImageSource.gallery
        : await _pickImageSource();
    if (imageSrc == null) {
      return;
    }

    final pickedImage = await ImagePicker().pickImage(
      source: imageSrc,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickedImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: const Color.fromARGB(184, 205, 205, 205),
          foregroundImage: _pickedImageFile != null
              ? FileImage(_pickedImageFile!)
              : null,
          backgroundImage: Image.asset(
            'assets/images/material-symbols-contacts-product.png',
            color: Theme.of(context).colorScheme.onSurface,
          ).image,
        ),
        TextButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.image),
          label: Text(
            'Add Image',
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
