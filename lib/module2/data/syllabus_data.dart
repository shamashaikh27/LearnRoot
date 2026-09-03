import '../models/topic.dart';

final List<Topic> syllabusTopics = [
  // 1. Introduction
  Topic(
    id: 'ds_intro',
    name: 'Introduction to Data Structures',
    subject: 'Data Structures',
  ),

  // 2. Types
  Topic(
    id: 'ds_types',
    name: 'Types of Data Structures',
    subject: 'Data Structures',
    prerequisites: ['ds_intro'],
  ),

  // 3. Complexity
  Topic(
    id: 'ds_complexity',
    name: 'Time and Space Complexity',
    subject: 'Data Structures',
    prerequisites: ['ds_intro'],
  ),

  // 4. Arrays
  Topic(
    id: 'ds_arrays',
    name: 'Arrays',
    subject: 'Data Structures',
    prerequisites: ['ds_types'],
  ),

  // 5. Strings
  Topic(
    id: 'ds_strings',
    name: 'Strings',
    subject: 'Data Structures',
    prerequisites: ['ds_arrays'],
  ),

  // 6. Linked List
  Topic(
    id: 'ds_linked_list',
    name: 'Linked List',
    subject: 'Data Structures',
    prerequisites: ['ds_types'],
  ),

  // 7. Singly Linked List
  Topic(
    id: 'ds_singly_linked_list',
    name: 'Singly Linked List',
    subject: 'Data Structures',
    prerequisites: ['ds_linked_list'],
  ),

  // 8. Doubly Linked List
  Topic(
    id: 'ds_doubly_linked_list',
    name: 'Doubly Linked List',
    subject: 'Data Structures',
    prerequisites: ['ds_linked_list'],
  ),

  // 9. Circular Linked List
  Topic(
    id: 'ds_circular_linked_list',
    name: 'Circular Linked List',
    subject: 'Data Structures',
    prerequisites: ['ds_linked_list'],
  ),

  // 10. Stack
  Topic(
    id: 'ds_stack',
    name: 'Stack',
    subject: 'Data Structures',
    prerequisites: ['ds_types'],
  ),

  // 11. Queue
  Topic(
    id: 'ds_queue',
    name: 'Queue',
    subject: 'Data Structures',
    prerequisites: ['ds_types'],
  ),

  // 12. Circular Queue
  Topic(
    id: 'ds_circular_queue',
    name: 'Circular Queue',
    subject: 'Data Structures',
    prerequisites: ['ds_queue'],
  ),

  // 13. Priority Queue
  Topic(
    id: 'ds_priority_queue',
    name: 'Priority Queue',
    subject: 'Data Structures',
    prerequisites: ['ds_queue'],
  ),

  // 14. Deque
  Topic(
    id: 'ds_deque',
    name: 'Deque',
    subject: 'Data Structures',
    prerequisites: ['ds_queue'],
  ),

  // 15. Recursion
  Topic(
    id: 'ds_recursion',
    name: 'Recursion',
    subject: 'Data Structures',
    prerequisites: ['ds_intro'],
  ),

  // 16. Trees
  Topic(
    id: 'ds_trees',
    name: 'Trees',
    subject: 'Data Structures',
    prerequisites: ['ds_types'],
  ),

  // 17. Binary Tree
  Topic(
    id: 'ds_binary_tree',
    name: 'Binary Tree',
    subject: 'Data Structures',
    prerequisites: ['ds_trees'],
  ),

  // 18. Binary Search Tree
  Topic(
    id: 'ds_bst',
    name: 'Binary Search Tree (BST)',
    subject: 'Data Structures',
    prerequisites: ['ds_binary_tree'],
  ),

  // 19. AVL Tree
  Topic(
    id: 'ds_avl',
    name: 'AVL Tree',
    subject: 'Data Structures',
    prerequisites: ['ds_bst'],
  ),

  // 20. Heap
  Topic(
    id: 'ds_heap',
    name: 'Heap',
    subject: 'Data Structures',
    prerequisites: ['ds_binary_tree'],
  ),

  // 21. Hashing
  Topic(
    id: 'ds_hashing',
    name: 'Hashing',
    subject: 'Data Structures',
    prerequisites: ['ds_types'],
  ),

  // 22. Hash Table
  Topic(
    id: 'ds_hash_table',
    name: 'Hash Table',
    subject: 'Data Structures',
    prerequisites: ['ds_hashing', 'ds_arrays'],
  ),

  // 23. Graphs
  Topic(
    id: 'ds_graphs',
    name: 'Graphs',
    subject: 'Data Structures',
    prerequisites: ['ds_types'],
  ),

  // 24. Graph Representation
  Topic(
    id: 'ds_graph_representation',
    name: 'Graph Representation',
    subject: 'Data Structures',
    prerequisites: ['ds_graphs', 'ds_arrays'],
  ),

  // 25. BFS
  Topic(
    id: 'ds_bfs',
    name: 'BFS',
    subject: 'Data Structures',
    prerequisites: ['ds_graph_representation', 'ds_queue'],
  ),

  // 26. DFS
  Topic(
    id: 'ds_dfs',
    name: 'DFS',
    subject: 'Data Structures',
    prerequisites: ['ds_graph_representation', 'ds_recursion'],
  ),

  // 27. Searching
  Topic(
    id: 'ds_searching',
    name: 'Searching',
    subject: 'Data Structures',
    prerequisites: ['ds_arrays'],
  ),

  // 28. Linear Search
  Topic(
    id: 'ds_linear_search',
    name: 'Linear Search',
    subject: 'Data Structures',
    prerequisites: ['ds_searching'],
  ),

  // 29. Binary Search
  Topic(
    id: 'ds_binary_search',
    name: 'Binary Search',
    subject: 'Data Structures',
    prerequisites: ['ds_searching'],
  ),

  // 30. Sorting
  Topic(
    id: 'ds_sorting',
    name: 'Sorting',
    subject: 'Data Structures',
    prerequisites: ['ds_arrays'],
  ),

  // 31. Bubble Sort
  Topic(
    id: 'ds_bubble_sort',
    name: 'Bubble Sort',
    subject: 'Data Structures',
    prerequisites: ['ds_sorting'],
  ),

  // 32. Selection Sort
  Topic(
    id: 'ds_selection_sort',
    name: 'Selection Sort',
    subject: 'Data Structures',
    prerequisites: ['ds_sorting'],
  ),

  // 33. Insertion Sort
  Topic(
    id: 'ds_insertion_sort',
    name: 'Insertion Sort',
    subject: 'Data Structures',
    prerequisites: ['ds_sorting'],
  ),

  // 34. Merge Sort
  Topic(
    id: 'ds_merge_sort',
    name: 'Merge Sort',
    subject: 'Data Structures',
    prerequisites: ['ds_sorting', 'ds_recursion'],
  ),

  // 35. Quick Sort
  Topic(
    id: 'ds_quick_sort',
    name: 'Quick Sort',
    subject: 'Data Structures',
    prerequisites: ['ds_sorting', 'ds_recursion'],
  ),

  // 36. Heap Sort
  Topic(
    id: 'ds_heap_sort',
    name: 'Heap Sort',
    subject: 'Data Structures',
    prerequisites: ['ds_sorting', 'ds_heap'],
  ),

  // 37. Greedy Algorithms
  Topic(
    id: 'ds_greedy',
    name: 'Greedy Algorithms',
    subject: 'Data Structures',
    prerequisites: ['ds_complexity'],
  ),

  // 38. Divide and Conquer
  Topic(
    id: 'ds_divide_conquer',
    name: 'Divide and Conquer',
    subject: 'Data Structures',
    prerequisites: ['ds_recursion'],
  ),

  // 39. Dynamic Programming
  Topic(
    id: 'ds_dynamic_programming',
    name: 'Dynamic Programming',
    subject: 'Data Structures',
    prerequisites: ['ds_recursion'],
  ),
];