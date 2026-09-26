class LearningResource {
  final int resourceId;
  final String type;
  final String title;
  final String link;

  LearningResource({
    required this.resourceId,
    required this.type,
    required this.title,
    required this.link,
  });

  factory LearningResource.fromJson(Map<String, dynamic> json) {
    return LearningResource(
      resourceId: int.tryParse(
            '${json['resource_id'] ?? json['id'] ?? 0}',
          ) ??
          0,
      type: '${json['resource_type'] ?? json['type'] ?? ''}',
      title: '${json['title'] ?? 'Learning Resource'}',
      link: '${json['resource_link'] ?? json['url'] ?? json['link'] ?? ''}',
    );
  }

  bool get isVideo => type.toLowerCase().contains('video');
}
