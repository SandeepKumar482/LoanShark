class User {
  final String userName;
  final String password;
  final String displayName;

  User({
    required this.userName,
    required this.password,
    required this.displayName,
  });

  // Convert a Map (from database query) to a User object
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userName: map['user_name'] as String,
      password: map['password'] as String,
      displayName: map['display_name'] as String,
    );
  }

  // Convert a User object to a Map (for database insertion/update)
  Map<String, dynamic> toMap() {
    return {
      'user_name': userName,
      'password': password,
      'display_name': displayName,
    };
  }
}