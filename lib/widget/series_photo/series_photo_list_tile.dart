import 'package:asesmen_paud/api/payload/series_photo_payload.dart';
import 'package:asesmen_paud/helper/datetime_converter.dart';
import 'package:flutter/material.dart';

class SeriesPhotoListTile extends StatelessWidget {
  final SeriesPhoto seriesPhoto;
  final Function(SeriesPhoto) onSeriesPhotoTap;

  const SeriesPhotoListTile(
      {super.key, required this.seriesPhoto, required this.onSeriesPhotoTap});

  @override
  Widget build(BuildContext context) {
    String formattedCreateDate = formatDate(seriesPhoto.createdAt!);
    String formattedUpdateDate = formatDate(seriesPhoto.updatedAt!);

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              backgroundColor: Colors.deepPurple[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )),
          onPressed: () => onSeriesPhotoTap(seriesPhoto),
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.transparent,
            elevation: 0,
            child: ListTile(
              title: Text(formattedCreateDate),
              subtitle: Text(
                'Terakhir diubah: $formattedUpdateDate',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_right_outlined),
            ),
          ),
        ));
  }
}
