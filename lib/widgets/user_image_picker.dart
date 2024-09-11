import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(
      {super.key, required this.onImageSelected, required this.hasError});

  final void Function(File image) onImageSelected;
  @override
  State<UserImagePicker> createState() {
    return _UserImageState();
  }

  final bool hasError;
}

class _UserImageState extends State<UserImagePicker> {
  File? _pickedImageFile;
  bool _imageUploaded = false;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 150,
        requestFullMetadata: false);
    setState(() => _imageUploaded = pickedImage != null);
    if (pickedImage == null) return;

    setState(() {
      _pickedImageFile = File(pickedImage.path);
      widget.onImageSelected(_pickedImageFile!);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color derivedColor = widget.hasError && !_imageUploaded
        ? Colors.red
        : Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
          icon: Icon(Icons.image, color: derivedColor),
          onPressed: _pickImage,
          label: Text(
            'Add Image',
            style: TextStyle(color: derivedColor),
          ),
        )
      ],
    );
  }
}
