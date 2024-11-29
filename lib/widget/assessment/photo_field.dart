import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoField extends StatelessWidget {
  final XFile? image;
  final String? imageError;
  final Function(XFile?) onImageSelected;

  const PhotoField(
      {super.key,
      required this.image,
      required this.onImageSelected,
      this.imageError});

  Future<XFile?> _compressImage(XFile file) async {
    final compressed = await FlutterImageCompress.compressWithFile(file.path,
        minWidth: 800, minHeight: 800, quality: 80);
    if (compressed == null) return null;

    final tempDir = await getTemporaryDirectory();
    final compressedFilePath = '${tempDir.path}/compressed_${file.name}';
    File(compressedFilePath).writeAsBytesSync(compressed);

    return XFile(compressedFilePath);
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? selectedImage = await picker.pickImage(source: source);
    if (selectedImage != null) {
      final XFile? compressedImage = await _compressImage(selectedImage);
      onImageSelected(compressedImage ?? selectedImage);
    }
  }

  Widget _buildImage(File file) {
    return FutureBuilder(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                file,
                fit: BoxFit.cover,
              ),
            );
          } else {
            return const Text('Gambar tidak tersedia');
          }
        });
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pilih sumber gambar'),
            actions: [
              TextButton(
                  onPressed: () {
                    _pickImage(context, ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Kamera')),
              TextButton(
                  onPressed: () {
                    _pickImage(context, ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Galeri')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Batal')),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (image == null) ...[
          ElevatedButton(
              onPressed: () {
                _showImageSourceDialog(context);
              },
              child: const Text('Tambah foto')),
        ] else ...[
          _buildImage(File(image!.path)),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    _showImageSourceDialog(context);
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
          ),
          if (imageError != null) ...[
            const SizedBox(
              height: 5,
            ),
            Text(
              imageError ?? 'Terjadi error pada gambar',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ]
      ],
    );
  }
}
