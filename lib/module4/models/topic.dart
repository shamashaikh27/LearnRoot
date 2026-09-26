class Module4Topic {
  final int topicId;
  final String topicName;
  final String subject;
  final int topicOrder;
  final String topicCode;
  final bool completed;

  Module4Topic({
    required this.topicId,
    required this.topicName,
    required this.subject,
    required this.topicOrder,
    required this.topicCode,
    required this.completed,
  });

  factory Module4Topic.fromJson(Map<String, dynamic> json) {
    return Module4Topic(
      topicId: int.tryParse('${json['topic_id'] ?? json['id'] ?? 0}') ?? 0,
      topicName: '${json['topic_name'] ?? json['name'] ?? 'Untitled Topic'}',
      subject: '${json['subject'] ?? 'Data Structures'}',
      topicOrder: int.tryParse('${json['topic_order'] ?? json['order'] ?? 0}') ?? 0,
      topicCode: '${json['topic_code'] ?? ''}',
      completed: json['completed'] == true ||
          json['completed'] == 1 ||
          '${json['completed']}' == '1',
    );
  }
}
