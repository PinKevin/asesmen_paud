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
      total: json['total'] as int,
      perPage: json['perPage'] as int,
      currentPage: json['currentPage'] as int,
      lastPage: json['lastPage'] as int,
      firstPage: json['firstPage'] as int,
      firstPageUrl: json['firstPageUrl'] as String,
      lastPageUrl: json['lastPageUrl'] as String,
      nextPageUrl: json['nextPageUrl'] as String?,
      previousPageUrl: json['previousPageUrl'] as String?,
    );
  }
}
