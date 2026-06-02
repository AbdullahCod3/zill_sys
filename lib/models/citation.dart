import 'package:equatable/equatable.dart';

/// A knowledge-base source backing a suggested answer. Read from the matched
/// Pinecone chunk metadata (PRD §10/§11): `document_id` + `title`.
///
/// In the cockpit UI the [documentId] doubles as the short KB tag (e.g.
/// "KB-114") shown beside the [title].
class Citation extends Equatable {
  final String documentId;
  final String title;

  const Citation({required this.documentId, required this.title});

  factory Citation.fromJson(Map<String, dynamic> json) => Citation(
    documentId: json['document_id'] as String? ?? '',
    title: json['title'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {'document_id': documentId, 'title': title};

  @override
  List<Object?> get props => [documentId, title];
}
