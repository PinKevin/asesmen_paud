class LoginPayload {
  final String? type;
  final String? name;
  final String token;
  final List<String> abilities;
  final String? lastUsedAt;
  final String? expiresAt;

  LoginPayload(
      {required this.type,
      required this.token,
      required this.abilities,
      this.name,
      this.lastUsedAt,
      this.expiresAt});

  factory LoginPayload.fromJson(Map<String, dynamic> json) {
    return LoginPayload(
        type: json['type'],
        name: json['name'],
        token: json['token'],
        abilities: List<String>.from(json['abilities']),
        lastUsedAt: json['lastUsedAt'],
        expiresAt: json['expiresAt']);
  }
}
