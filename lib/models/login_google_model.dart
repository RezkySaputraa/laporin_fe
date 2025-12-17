class LoginGoogleModel {
  final String username;
  final String email;

  LoginGoogleModel({required this.username, required this.email});

  factory LoginGoogleModel.fromJson(Map<String, dynamic> json) =>
      LoginGoogleModel(username: json["username"], email: json["email"]);

  Map<String, dynamic> toJson() => {"username": username, "email": email};
}
