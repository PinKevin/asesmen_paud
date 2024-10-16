class PaginateMetaPayload {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int firstPage;
  final String firstPageUrl;
  final String lastPageUrl;
  final String? nextPageUrl;
  final String? previousPageUrl;

  PaginateMetaPayload(
      {required this.total,
      required this.perPage,
      required this.currentPage,
      required this.lastPage,
      required this.firstPage,
      required this.firstPageUrl,
      required this.lastPageUrl,
      this.nextPageUrl,
      this.previousPageUrl});

  factory PaginateMetaPayload.fromJson(Map<String, dynamic> json) {
    return PaginateMetaPayload(
      total: json['total'],
      perPage: json['perPage'],
      lastPage: json['lastPage'],
      currentPage: json['currentPage'],
      firstPage: json['firstPage'],
      firstPageUrl: json['firstPageUrl'],
      lastPageUrl: json['lastPageUrl'],
      nextPageUrl: json['nextPageUrl'],
      previousPageUrl: json['previousPageUrl'],
    );
  }
}
