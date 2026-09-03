class Topic {
  final String id;
  final String name;
  final String subject;
  final List<String> prerequisites;

  Topic({
    required this.id,
    required this.name,
    required this.subject,
    this.prerequisites = const [],
  });
}