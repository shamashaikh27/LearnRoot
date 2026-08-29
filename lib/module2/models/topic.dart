class Topic {
  final String id;
  final String name;
  final List<String> prerequisites;

  Topic({
    required this.id,
    required this.name,
    this.prerequisites = const [],
  });
}