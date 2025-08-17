import 'post.dart';

class Comment {
  final int id;
  final String text;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;
  final int postId;

  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.postId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      user: User.fromJson(json['User'] ?? json['user'] ?? {}),
      postId: json['postId'] ?? json['post_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
      'postId': postId,
    };
  }

  Comment copyWith({
    int? id,
    String? text,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
    int? postId,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      postId: postId ?? this.postId,
    );
  }
}
