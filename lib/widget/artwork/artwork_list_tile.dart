import 'package:asesmen_paud/api/payload/artwork_payload.dart';
import 'package:asesmen_paud/helper/datetime_converter.dart';
import 'package:flutter/material.dart';

class ArtworkListTile extends StatelessWidget {
  final Artwork artwork;
  final Function(Artwork) onArtworkTap;

  const ArtworkListTile(
      {super.key, required this.artwork, required this.onArtworkTap});

  @override
  Widget build(BuildContext context) {
    String formattedCreateDate = formatDate(artwork.createdAt!);
    String formattedUpdateDate = formatDate(artwork.updatedAt!);

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              backgroundColor: Colors.deepPurple[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              )),
          onPressed: () => onArtworkTap(artwork),
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
