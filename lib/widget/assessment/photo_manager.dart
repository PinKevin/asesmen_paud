import 'dart:io';
import 'dart:typed_data';

import 'package:asesmen_paud/api/service/photo_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

enum PhotoMode { create, edit, show }

class PhotoManager extends StatefulWidget {
  final PhotoMode mode;
  final String? initialImageUrl;
  final Function(XFile?) onImageSelected;

  const PhotoManager({
    super.key,
    required this.mode,
    this.initialImageUrl,
    required this.onImageSelected,
  });

  @override
  State<PhotoManager> createState() => _PhotoManagerState();
}

class _PhotoManagerState extends State<PhotoManager> {
  XFile? _selectedImage;
  bool _isImageDeleted = false;

  Future<Uint8List?> _loadImage(String imageEndpoint) async {
    try {
      return await PhotoService().getPhoto(imageEndpoint);
    } catch (e) {
      return null;
    }
  }

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
      setState(() {
        _selectedImage = compressedImage ?? selectedImage;
        _isImageDeleted = false;
      });
      widget.onImageSelected(_selectedImage);
    }
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
                child: const Text('Kamera'),
              ),
              TextButton(
                onPressed: () {
                  _pickImage(context, ImageSource.gallery);
                  Navigator.of(context).pop();
                },
                child: const Text('Galeri'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Batal'),
              ),
            ],
          );
        });
  }

  Widget _buildImage(BuildContext context) {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(_selectedImage!.path),
          fit: BoxFit.cover,
        ),
      );
    }

    if ((widget.mode == PhotoMode.show || widget.mode == PhotoMode.edit) &&
        widget.initialImageUrl != null &&
        !_isImageDeleted) {
      return FutureBuilder<Uint8List?>(
        future: _loadImage(widget.initialImageUrl!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError || snapshot.data == null) {
            return const SizedBox(
              height: 300,
              child: Center(
                child: Text('Gambar tidak dapat dimuat'),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            ),
          );
        },
      );
    }

    return const Text('Belum ada foto yang dipilih');
  }

  Widget _buildActions(BuildContext context) {
    if (widget.mode == PhotoMode.show) {
      return const SizedBox.shrink();
    }

    if ((_selectedImage == null && widget.mode == PhotoMode.create) ||
        _isImageDeleted) {
      return ElevatedButton(
          onPressed: () {
            _showImageSourceDialog(context);
          },
          child: const Text('Tambah foto'));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _showImageSourceDialog(context);
          },
          icon: const Icon(
            Icons.edit,
            color: Colors.blue,
          ),
          label: const Text(
            'Ubah foto',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _selectedImage = null;
              _isImageDeleted = true;
            });
            widget.onImageSelected(null);
          },
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          label: const Text(
            'Hapus foto',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImage(context),
        const SizedBox(
          height: 10,
        ),
        _buildActions(context)
      ],
    );
  }
}
