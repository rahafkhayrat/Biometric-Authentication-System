class UserModel {
  final String uid;
  final String email;
  final String? displayName;

  UserModel({required this.uid, required this.email, this.displayName});

  Map<String, dynamic> toMap() => {'uid': uid, 'email': email, 'displayName': displayName};
}
