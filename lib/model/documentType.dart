class DocumentType {
  final int id;
  final String name;

  DocumentType({required this.id, required this.name});

  factory DocumentType.fromJson(Map<String, dynamic> json) {
    return DocumentType(id: json["id"], name: json['name']);
  }
}
