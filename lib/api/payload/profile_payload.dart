class ProfilePayload {
  final String name;
  final String nuptk;
  final String email;

  ProfilePayload(
      {required this.name, required this.nuptk, required this.email});

  factory ProfilePayload.fromJson(Map<String, dynamic> json) {
    return ProfilePayload(
      name: json['name'],
      nuptk: json['nuptk'],
      email: json['email'],
    );
  }
}
