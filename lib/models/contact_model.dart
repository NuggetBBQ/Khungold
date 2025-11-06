class Contact {
  const Contact ({
    required this.id,
    required this.mainName,
    this.otherNames = const [],
    this.isMe = false,
  });

  final String id;
  final String mainName;
  final List<String> otherNames;
  final bool isMe;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contact &&
          runtimeType == other.runtimeType &&
          id == other.id;


  @override
  int get hashCode => id.hashCode;
  
  bool matchesName(String name) {
    return mainName.toLowerCase() == name.toLowerCase() || 
           otherNames.any((o) => o.toLowerCase() == name.toLowerCase());
  }

  Contact copyWith({
    String? id,
    String? mainName,
    List<String>? otherNames,
    bool? isMe,
  }) {
    return Contact(
      id: id ?? this.id,
      mainName: mainName ?? this.mainName,
      otherNames: otherNames ?? this.otherNames,
      isMe: isMe ?? this.isMe,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mainName': mainName,
      'otherNames': otherNames,
      'isMe': isMe,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> data, String id) {
    return Contact(
      id: id,
      mainName: data['mainName'] as String,
      otherNames: List<String>.from(data['otherNames'] ?? []),
      isMe: data['isMe'] as bool? ?? false,
    );
  }
}