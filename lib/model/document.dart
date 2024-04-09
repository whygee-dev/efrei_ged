class Document {
  final int id;
  final String name;
  final String? description;
  final String path;

  Document({
    required this.id,
    required this.name,
    required this.description,
    required this.path,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json["id"],
      name: json['name'],
      description: json['description'],
      path: json['path'],
    );
  }
}
