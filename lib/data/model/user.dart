class User {
  int? id;
  String? title;
  String? body;

  User({
    this.id,
    this.body,
    this.title,
});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'title': title,
    };
  }
}