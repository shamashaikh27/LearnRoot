import 'package:flutter/material.dart';

class SubjectScreen extends StatelessWidget {
  final String subject;

  const SubjectScreen({
    super.key,
    required this.subject,
  });

  List<String> getTopics() {
    switch (subject) {
      case 'C Programming':
        return [
          'Introduction to C',
          'Variables and Data Types',
          'Operators',
          'Conditional Statements',
          'Loops',
          'Functions',
          'Arrays',
          'Pointers',
        ];

      case 'Data Structure':
        return [
          'Introduction to Data Structures',
          'Arrays',
          'Linked Lists',
          'Stacks',
          'Queues',
          'Trees',
          'Graphs',
          'Searching and Sorting',
        ];

      case 'Object Oriented Programming (Java)':
        return [
          'Introduction to Java',
          'Classes and Objects',
          'Constructors',
          'Inheritance',
          'Polymorphism',
          'Abstraction',
          'Encapsulation',
          'Exception Handling',
        ];

      case 'Computer Networks':
        return [
          'Introduction to Computer Networks',
          'Network Topologies',
          'OSI Model',
          'TCP/IP Model',
          'IP Addressing',
          'Routing',
          'Transport Layer',
          'Network Security',
        ];

      case 'Operating System':
        return [
          'Introduction to Operating System',
          'Process Management',
          'Threads',
          'CPU Scheduling',
          'Deadlocks',
          'Memory Management',
          'File Management',
          'Virtual Memory',
        ];

      case 'DBMS':
        return [
          'Introduction to DBMS',
          'Database Models',
          'ER Model',
          'Relational Model',
          'SQL',
          'Normalization',
          'Transactions',
          'Database Security',
        ];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = getTopics();

    return Scaffold(
      appBar: AppBar(
        title: Text(subject),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Topic',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Choose a topic to start learning.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),

                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo.shade50,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.indigo.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      title: Text(
                        topics[index],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 17,
                      ),

                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${topics[index]} selected',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}