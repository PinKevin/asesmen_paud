import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoField extends StatelessWidget {
  final XFile? image;
  final Function(XFile?) onImageSelected;

  const PhotoField(
      {super.key, required this.image, required this.onImageSelected});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      onImageSelected(selectedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (image == null)
          ElevatedButton(
              onPressed: () {
                _pickImage(context);
              },
              child: const Text('Tambah foto')),
        if (image != null)
          Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                image: image != null
                    ? DecorationImage(
                        image: FileImage(File(image!.path)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: image == null
                  ? const Expanded(
                      child: Center(
                        child: Text('Tekan untuk tambah foto'),
                      ),
                    )
                  : null),
        if (image != null)
          const SizedBox(
            height: 5,
          ),
        if (image != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _pickImage(context);
                  },
                  child: const Text('Ubah foto')),
              ElevatedButton.icon(
                label: const Text(
                  'Hapus foto',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  onImageSelected(null);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              ),
            ],
          )
      ],
    );
  }
}
