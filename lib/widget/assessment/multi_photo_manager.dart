import 'dart:io';
import 'dart:typed_data';

import 'package:asesmen_paud/api/service/photo_service.dart';
import 'package:asesmen_paud/widget/button/submit_secondary_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

enum PhotoMode { create, edit, show }

class MultiPhotoManager extends StatefulWidget {
  final PhotoMode mode;
  final String? imageError;
  final List<String>? initialImageUrls;
  final Function(List<dynamic>?) onImagesSelected;

  const MultiPhotoManager({
    super.key,
    required this.mode,
    this.imageError,
    this.initialImageUrls,
    required this.onImagesSelected,
  });

  @override
  State<MultiPhotoManager> createState() => _PhotoManagerState();
}

class _PhotoManagerState extends State<MultiPhotoManager> {
  final List<dynamic> _images = [];
  final List<dynamic> _requestImages = [];
  bool _isLoading = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.mode != PhotoMode.create) {
      _requestImages.addAll(widget.initialImageUrls ?? []);
      _loadInitialImages();
    }
  }

  Future<Uint8List?> _loadImage(String imageEndpoint) async {
    try {
      return await PhotoService().getPhoto(imageEndpoint);
    } catch (e) {
      return null;
    }
  }

  Future<XFile?> _compressImage(XFile file) async {
    final compressed = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 800,
      minHeight: 800,
      quality: 80,
    );
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
      _addImage(compressedImage ?? selectedImage);
    }
  }

  void _addImage(dynamic image) {
    setState(() {
      _images.add(image);
      _requestImages.add(image);
    });

    widget.onImagesSelected(_requestImages);
  }

  Future<void> _loadInitialImages() async {
    if (widget.initialImageUrls == null) return;

    setState(() {
      _isLoading = true;
    });

    final List<Future<Uint8List?>> futures =
        widget.initialImageUrls!.map((url) => _loadImage(url)).toList();
    final results = await Future.wait(futures);
    setState(() {
      _images.addAll(results);
      _isLoading = false;
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

  void _showDeleteDialog(int index) {
    if (widget.mode != PhotoMode.show) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Hapus foto'),
            content: const Text('Yakin ingin hapus foto?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _images.removeAt(index);
                    _requestImages.removeAt(index);
                  });

                  widget.onImagesSelected(_requestImages);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Hapus',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildImageCarousel() {
    final List<Widget> items = _images.map((image) {
      if (image is XFile) {
        return GestureDetector(
          onLongPress: () => _showDeleteDialog(_images.indexOf(image)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(image.path),
              fit: BoxFit.cover,
            ),
          ),
        );
      } else if (image is Uint8List) {
        return GestureDetector(
          onLongPress: () => _showDeleteDialog(_images.indexOf(image)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              image,
              fit: BoxFit.cover,
            ),
          ),
        );
      } else {
        return GestureDetector(
          onLongPress: () => _showDeleteDialog(_images.indexOf(image)),
          child: const Center(
            child: Text('Format tidak didukung'),
          ),
        );
      }
    }).toList();

    if (items.isEmpty) {
      return const Center(
        child: Text('Belum ada foto yang dipilih'),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          items: items,
          options: CarouselOptions(
            height: 300,
            enableInfiniteScroll: false,
            enlargeCenterPage: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: items.asMap().entries.map((entry) {
            return GestureDetector(
              child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 2,
                  ),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? Colors.blueAccent
                          : Colors.grey)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions() {
    if (widget.mode == PhotoMode.show) {
      return const SizedBox.shrink();
    }

    final canAddMorePhotos = _images.length < 5;

    return Column(
      children: [
        if (_images.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Tekan lama pada foto untuk menghapusnya.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        if (widget.imageError != null)
          Text(
            widget.imageError!,
            style: const TextStyle(color: Colors.red),
          ),
        if (canAddMorePhotos)
          SubmitSecondaryButton(
            text: 'Tambah Foto',
            onPressed: () => _showImageSourceDialog(context),
          ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _buildImageCarousel(),
        const SizedBox(
          height: 10,
        ),
        _buildActions()
      ],
    );
  }
}
