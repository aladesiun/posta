class Post {
  final int id;
  final String text;
  final String? mediaUrl;
  final DateTime createdAt;
  final int userId;
  final int likeCount;
  final int commentCount;
  final int hasLiked;
  final User user;

  Post({
    required this.id,
    required this.text,
    this.mediaUrl,
    required this.createdAt,
    required this.userId,
    required this.likeCount,
    required this.commentCount,
    required this.hasLiked,
    required this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      text: json['text'] ?? '',
      mediaUrl: json['mediaUrl'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      userId: json['userId'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      hasLiked: json['hasLiked'] ?? 0,
      user: User.fromJson(json['User'] ?? json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'mediaUrl': mediaUrl,
      'created_at': createdAt.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'user': user.toJson(),
      'hasLiked': hasLiked,
    };
  }

  Post copyWith({
    int? id,
    String? text,
    String? mediaUrl,
    DateTime? createdAt,
    int? likeCount,
    int? commentCount,
    User? user,
    bool? hasLiked,
  }) {
    return Post(
      id: id ?? this.id,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      user: user ?? this.user,
      hasLiked: hasLiked != null ? (hasLiked ? 1 : 0) : this.hasLiked,
      userId: userId ?? this.userId,
    );
  }
}

class User {
  final int id;
  final String username;
  final String? avatarUrl;
  final String? email;

  User({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Unknown User',
      avatarUrl: json['avatarUrl'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'email': email,
    };
  }
}
