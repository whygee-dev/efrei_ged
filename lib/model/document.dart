class Document {
  final int id;
  final String name;
  final String path;

  Document({required this.id, required this.name, required this.path});

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(id: json["id"], name: json['name'], path: json['path']);
  }
}
