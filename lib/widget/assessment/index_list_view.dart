import 'package:flutter/material.dart';

class IndexListView<T> extends StatelessWidget {
  final List<T> items;
  final String errorMessage;
  final bool isLoading;
  final bool hasMoreData;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final ScrollController scrollController;

  const IndexListView(
      {super.key,
      required this.errorMessage,
      required this.isLoading,
      required this.hasMoreData,
      required this.onRefresh,
      required this.scrollController,
      required this.items,
      required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          errorMessage,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (items.isEmpty && isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
            controller: scrollController,
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index < items.length) {
                return itemBuilder(context, items[index]);
              } else if (hasMoreData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(items.isEmpty
                        ? 'Belum ada data.'
                        : 'Anda sudah mencapai akhir halaman.'),
                  ),
                );
              }
            }));
  }
}
