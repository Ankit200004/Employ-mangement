class UserModel {
  final String uid;
  final String phone;

  UserModel({required this.uid, required this.phone});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json["uid"],
      phone: json["phone"] ?? "",
    );
  }
}
