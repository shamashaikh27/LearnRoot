import 'package:flutter/material.dart';

import '../data/syllabus_data.dart';
import 'graph_screen.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({super.key});

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';

  // ==========================================================
  // SUBJECT LIST
  // ==========================================================

  final List<String> subjects = [
    'C Programming',
    'Data Structures',
    'Operating Systems',
    'Computer Networks',
    'DBMS',
    'OOPs – Java',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSubjects = subjects.where((subject) {
      return subject.toLowerCase().contains(
            searchText.toLowerCase(),
          );
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FC),
        elevation: 0,

        title: const Text(
          'LearnRoot',
          style: TextStyle(
            color: Color(0xFF252238),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [
          // ====================================================
          // SEARCH SUBJECT
          // ====================================================

          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              12,
            ),

            child: TextField(
              controller: searchController,

              decoration: InputDecoration(
                hintText: 'Search subject...',

                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF6C63A8),
                ),

                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          searchController.clear();

                          setState(() {
                            searchText = '';
                          });
                        },
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF6C63A8),
                    width: 1.5,
                  ),
                ),
              ),

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),

          // ====================================================
          // SUBJECT LIST
          // ====================================================

          Expanded(
            child: filteredSubjects.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 55,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 12),

                        Text(
                          'No matching subject found.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF252238),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 20,
                    ),

                    itemCount:
                        filteredSubjects.length,

                    itemBuilder: (context, index) {
                      final subject =
                          filteredSubjects[index];

                      return Container(
                        margin:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),

                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),

                          leading: Container(
                            width: 46,
                            height: 46,

                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFEDEBFA,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),

                            child: const Icon(
                              Icons.menu_book_rounded,
                              color:
                                  Color(0xFF6C63A8),
                            ),
                          ),

                          title: Text(
                            subject,

                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                              color:
                                  Color(0xFF252238),
                            ),
                          ),

                          trailing:
                              const Icon(
                            Icons
                                .arrow_forward_ios_rounded,
                            size: 17,
                            color: Colors.grey,
                          ),

                          // ==================================================
                          // OPEN TOPICS FOR SELECTED SUBJECT
                          // ==================================================

                          onTap: () {
                            final subjectTopics =
                                syllabusTopics
                                    .where(
                              (topic) =>
                                  topic.subject ==
                                  subject,
                            )
                                    .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: const RouteSettings(
                                  name: '/topicList',
                                ),
                                builder: (_) =>
                                    GraphScreen(
                                  subject:
                                      subject,
                                  topics:
                                      subjectTopics,
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
    );
  }
}