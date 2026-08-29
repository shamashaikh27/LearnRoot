class Topic {
  final String id;
  final String name;
  final List<String> prerequisites;

  const Topic({
    required this.id,
    required this.name,
    this.prerequisites = const [],
  });
}

final List<Topic> syllabusTopics = [
  // 1. Introduction
  Topic(
    id: 'ds_intro',
    name: 'Introduction to Data Structures',
  ),

  // 2. Types
  Topic(
    id: 'ds_types',
    name: 'Types of Data Structures',
    prerequisites: ['ds_intro'],
  ),

  // 3. Complexity
  Topic(
    id: 'ds_complexity',
    name: 'Time and Space Complexity',
    prerequisites: ['ds_intro'],
  ),

  // 4. Arrays
  Topic(
    id: 'ds_arrays',
    name: 'Arrays',
    prerequisites: ['ds_types', 'ds_complexity'],
  ),

  // 5. Strings
  Topic(
    id: 'ds_strings',
    name: 'Strings',
    prerequisites: ['ds_arrays'],
  ),

  // 6. Linked List
  Topic(
    id: 'ds_linked_list',
    name: 'Linked List',
    prerequisites: ['ds_arrays', 'ds_complexity'],
  ),

  // 7. Singly Linked List
  Topic(
    id: 'ds_singly_linked_list',
    name: 'Singly Linked List',
    prerequisites: ['ds_linked_list'],
  ),

  // 8. Doubly Linked List
  Topic(
    id: 'ds_doubly_linked_list',
    name: 'Doubly Linked List',
    prerequisites: ['ds_singly_linked_list'],
  ),

  // 9. Circular Linked List
  Topic(
    id: 'ds_circular_linked_list',
    name: 'Circular Linked List',
    prerequisites: ['ds_singly_linked_list'],
  ),

  // 10. Stack
  Topic(
    id: 'ds_stack',
    name: 'Stack',
    prerequisites: ['ds_arrays', 'ds_linked_list'],
  ),

  // 11. Queue
  Topic(
    id: 'ds_queue',
    name: 'Queue',
    prerequisites: ['ds_arrays', 'ds_linked_list'],
  ),

  // 12. Circular Queue
  Topic(
    id: 'ds_circular_queue',
    name: 'Circular Queue',
    prerequisites: ['ds_queue'],
  ),

  // 13. Priority Queue
  Topic(
    id: 'ds_priority_queue',
    name: 'Priority Queue',
    prerequisites: ['ds_queue'],
  ),

  // 14. Deque
  Topic(
    id: 'ds_deque',
    name: 'Deque',
    prerequisites: ['ds_queue', 'ds_linked_list'],
  ),

  // 15. Recursion
  Topic(
    id: 'ds_recursion',
    name: 'Recursion',
    prerequisites: ['ds_complexity'],
  ),

  // 16. Trees
  Topic(
    id: 'ds_trees',
    name: 'Trees',
    prerequisites: ['ds_recursion', 'ds_linked_list'],
  ),

  // 17. Binary Tree
  Topic(
    id: 'ds_binary_tree',
    name: 'Binary Tree',
    prerequisites: ['ds_trees', 'ds_recursion'],
  ),

  // 18. Binary Search Tree
  Topic(
    id: 'ds_bst',
    name: 'Binary Search Tree (BST)',
    prerequisites: ['ds_binary_tree'],
  ),

  // 19. AVL Tree
  Topic(
    id: 'ds_avl',
    name: 'AVL Tree',
    prerequisites: ['ds_bst'],
  ),

  // 20. Heap
  Topic(
    id: 'ds_heap',
    name: 'Heap',
    prerequisites: ['ds_binary_tree', 'ds_arrays'],
  ),

  // 21. Hashing
  Topic(
    id: 'ds_hashing',
    name: 'Hashing',
    prerequisites: ['ds_arrays', 'ds_complexity'],
  ),

  // 22. Hash Table
  Topic(
    id: 'ds_hash_table',
    name: 'Hash Table',
    prerequisites: ['ds_hashing', 'ds_arrays', 'ds_linked_list'],
  ),

  // 23. Graphs
  Topic(
    id: 'ds_graphs',
    name: 'Graphs',
    prerequisites: [
      'ds_arrays',
      'ds_linked_list',
      'ds_trees',
      'ds_recursion',
    ],
  ),

  // 24. Graph Representation
  Topic(
    id: 'ds_graph_representation',
    name: 'Graph Representation',
    prerequisites: [
      'ds_graphs',
      'ds_arrays',
      'ds_linked_list',
    ],
  ),

  // 25. BFS
  Topic(
    id: 'ds_bfs',
    name: 'BFS',
    prerequisites: [
      'ds_graph_representation',
      'ds_queue',
    ],
  ),

  // 26. DFS
  Topic(
    id: 'ds_dfs',
    name: 'DFS',
    prerequisites: [
      'ds_graph_representation',
      'ds_stack',
      'ds_recursion',
    ],
  ),

  // 27. Searching
  Topic(
    id: 'ds_searching',
    name: 'Searching',
    prerequisites: [
      'ds_arrays',
      'ds_complexity',
    ],
  ),

  // 28. Linear Search
  Topic(
    id: 'ds_linear_search',
    name: 'Linear Search',
    prerequisites: [
      'ds_searching',
      'ds_arrays',
    ],
  ),

  // 29. Binary Search
  Topic(
    id: 'ds_binary_search',
    name: 'Binary Search',
    prerequisites: [
      'ds_searching',
      'ds_arrays',
    ],
  ),

  // 30. Sorting
  Topic(
    id: 'ds_sorting',
    name: 'Sorting',
    prerequisites: [
      'ds_arrays',
      'ds_complexity',
    ],
  ),

  // 31. Bubble Sort
  Topic(
    id: 'ds_bubble_sort',
    name: 'Bubble Sort',
    prerequisites: [
      'ds_sorting',
      'ds_arrays',
    ],
  ),

  // 32. Selection Sort
  Topic(
    id: 'ds_selection_sort',
    name: 'Selection Sort',
    prerequisites: [
      'ds_sorting',
      'ds_arrays',
    ],
  ),

  // 33. Insertion Sort
  Topic(
    id: 'ds_insertion_sort',
    name: 'Insertion Sort',
    prerequisites: [
      'ds_sorting',
      'ds_arrays',
    ],
  ),

  // 34. Merge Sort
  Topic(
    id: 'ds_merge_sort',
    name: 'Merge Sort',
    prerequisites: [
      'ds_sorting',
      'ds_recursion',
    ],
  ),

  // 35. Quick Sort
  Topic(
    id: 'ds_quick_sort',
    name: 'Quick Sort',
    prerequisites: [
      'ds_sorting',
      'ds_recursion',
    ],
  ),

  // 36. Heap Sort
  Topic(
    id: 'ds_heap_sort',
    name: 'Heap Sort',
    prerequisites: [
      'ds_sorting',
      'ds_heap',
    ],
  ),

  // 37. Greedy Algorithms
  Topic(
    id: 'ds_greedy',
    name: 'Greedy Algorithms',
    prerequisites: [
      'ds_sorting',
      'ds_complexity',
    ],
  ),

  // 38. Divide and Conquer
  Topic(
    id: 'ds_divide_conquer',
    name: 'Divide and Conquer',
    prerequisites: [
      'ds_recursion',
      'ds_complexity',
    ],
  ),

  // 39. Dynamic Programming
  Topic(
    id: 'ds_dynamic_programming',
    name: 'Dynamic Programming',
    prerequisites: [
      'ds_recursion',
      'ds_divide_conquer',
      'ds_complexity',
    ],
  ),
];