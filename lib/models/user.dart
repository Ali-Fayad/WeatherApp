class User {
  final int? id;
  final String username;
  final String passwordHash; // hashed password

  User({this.id, required this.username, required this.passwordHash});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'passwordHash': passwordHash,
    };
  }

  factory User.fromMap(Map<String, dynamic> m) {
    return User(
      id: m['id'] as int?,
      username: m['username'] as String,
      passwordHash: m['passwordHash'] as String,
    );
  }
}
