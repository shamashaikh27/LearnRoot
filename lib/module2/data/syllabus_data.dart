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

  // =========================
  // C PROGRAMMING
  // =========================

  // 1. Introduction to C
  Topic(
    id: 'c_introduction',
    name: 'Introduction to C',
    subject: 'C Programming',
  ),

  // 2. Structure of C Program
  Topic(
    id: 'c_structure',
    name: 'Structure of C Program',
    subject: 'C Programming',
    prerequisites: ['c_introduction'],
  ),

  // 3. Compilation Process in C
  Topic(
    id: 'c_compilation',
    name: 'Compilation Process in C',
    subject: 'C Programming',
    prerequisites: ['c_structure'],
  ),

  // 4. Variables & Data Types
  Topic(
    id: 'c_variables_datatypes',
    name: 'Variables & Data Types',
    subject: 'C Programming',
    prerequisites: ['c_structure'],
  ),

  // 5. Constants and Literals
  Topic(
    id: 'c_constants_literals',
    name: 'Constants and Literals',
    subject: 'C Programming',
    prerequisites: ['c_variables_datatypes'],
  ),

  // 6. Operators & Expressions
  Topic(
    id: 'c_operators_expressions',
    name: 'Operators & Expressions',
    subject: 'C Programming',
    prerequisites: ['c_variables_datatypes'],
  ),

  // 7. Type Conversion
  Topic(
    id: 'c_type_conversion',
    name: 'Type Conversion',
    subject: 'C Programming',
    prerequisites: ['c_operators_expressions'],
  ),

  // 8. Input and Output
  Topic(
    id: 'c_input_output',
    name: 'Input and Output (printf, scanf)',
    subject: 'C Programming',
    prerequisites: ['c_structure'],
  ),

  // 9. Decision Making
  Topic(
    id: 'c_decision_making',
    name: 'Decision Making (if, if-else, switch)',
    subject: 'C Programming',
    prerequisites: ['c_operators_expressions'],
  ),

  // 10. Loops
  Topic(
    id: 'c_loops',
    name: 'Loops (while, do-while, for)',
    subject: 'C Programming',
    prerequisites: ['c_operators_expressions'],
  ),

  // 11. Break and Continue
  Topic(
    id: 'c_break_continue',
    name: 'Break and Continue',
    subject: 'C Programming',
    prerequisites: ['c_loops'],
  ),

  // 12. Functions Overview
  Topic(
    id: 'c_functions',
    name: 'Functions Overview',
    subject: 'C Programming',
    prerequisites: ['c_structure'],
  ),

  // 13. Function Prototypes & Definition
  Topic(
    id: 'c_function_prototypes',
    name: 'Function Prototypes & Definition',
    subject: 'C Programming',
    prerequisites: ['c_functions'],
  ),

  // 14. Parameter Passing
  Topic(
    id: 'c_parameter_passing',
    name: 'Parameter Passing (Call by Value)',
    subject: 'C Programming',
    prerequisites: ['c_function_prototypes'],
  ),

  // 15. Recursion in C
  Topic(
    id: 'c_recursion',
    name: 'Recursion in C',
    subject: 'C Programming',
    prerequisites: ['c_functions', 'c_decision_making'],
  ),

  // 16. Scope & Storage Classes
  Topic(
    id: 'c_scope_storage',
    name: 'Scope & Storage Classes',
    subject: 'C Programming',
    prerequisites: ['c_variables_datatypes', 'c_functions'],
  ),

  // 17. 1D Arrays
  Topic(
    id: 'c_1d_arrays',
    name: '1D Arrays',
    subject: 'C Programming',
    prerequisites: ['c_variables_datatypes', 'c_loops'],
  ),

  // 18. 2D Arrays & Multi-Dimensional Arrays
  Topic(
    id: 'c_2d_arrays',
    name: '2D Arrays & Multi-Dimensional Arrays',
    subject: 'C Programming',
    prerequisites: ['c_1d_arrays'],
  ),

  // 19. Passing Arrays to Functions
  Topic(
    id: 'c_arrays_functions',
    name: 'Passing Arrays to Functions',
    subject: 'C Programming',
    prerequisites: ['c_1d_arrays', 'c_functions'],
  ),

  // 20. Strings Concept & Declaration
  Topic(
    id: 'c_strings',
    name: 'Strings Concept & Declaration',
    subject: 'C Programming',
    prerequisites: ['c_1d_arrays'],
  ),

  // 21. String Handling Functions
  Topic(
    id: 'c_string_functions',
    name: 'String Handling Functions (string.h)',
    subject: 'C Programming',
    prerequisites: ['c_strings'],
  ),

  // 22. Pointers Basics
  Topic(
    id: 'c_pointers',
    name: 'Pointers Basics',
    subject: 'C Programming',
    prerequisites: ['c_variables_datatypes'],
  ),

  // 23. Pointer Arithmetic
  Topic(
    id: 'c_pointer_arithmetic',
    name: 'Pointer Arithmetic',
    subject: 'C Programming',
    prerequisites: ['c_pointers'],
  ),

  // 24. Pointers and Arrays
  Topic(
    id: 'c_pointers_arrays',
    name: 'Pointers and Arrays',
    subject: 'C Programming',
    prerequisites: ['c_pointers', 'c_1d_arrays'],
  ),

  // 25. Call by Reference
  Topic(
    id: 'c_call_by_reference',
    name: 'Call by Reference',
    subject: 'C Programming',
    prerequisites: ['c_pointers', 'c_functions'],
  ),

  // 26. Pointers to Pointers
  Topic(
    id: 'c_pointer_to_pointer',
    name: 'Pointers to Pointers',
    subject: 'C Programming',
    prerequisites: ['c_pointers'],
  ),

  // 27. Pointers and Strings
  Topic(
    id: 'c_pointers_strings',
    name: 'Pointers and Strings',
    subject: 'C Programming',
    prerequisites: ['c_pointers', 'c_strings'],
  ),

  // 28. Dynamic Memory Allocation
  Topic(
    id: 'c_dynamic_memory',
    name: 'Dynamic Memory Allocation (malloc, calloc, realloc, free)',
    subject: 'C Programming',
    prerequisites: ['c_pointers'],
  ),

  // 29. Function Pointers
  Topic(
    id: 'c_function_pointers',
    name: 'Function Pointers',
    subject: 'C Programming',
    prerequisites: ['c_pointers', 'c_functions'],
  ),

  // 30. Structures Basics
  Topic(
    id: 'c_structures',
    name: 'Structures Basics',
    subject: 'C Programming',
    prerequisites: ['c_variables_datatypes'],
  ),

  // 31. Array of Structures
  Topic(
    id: 'c_array_structures',
    name: 'Array of Structures',
    subject: 'C Programming',
    prerequisites: ['c_structures', 'c_1d_arrays'],
  ),

  // 32. Pointers to Structures
  Topic(
    id: 'c_pointer_structures',
    name: 'Pointers to Structures',
    subject: 'C Programming',
    prerequisites: ['c_structures', 'c_pointers'],
  ),

  // 33. Nested Structures
  Topic(
    id: 'c_nested_structures',
    name: 'Nested Structures',
    subject: 'C Programming',
    prerequisites: ['c_structures'],
  ),

  // 34. Unions
  Topic(
    id: 'c_unions',
    name: 'Unions',
    subject: 'C Programming',
    prerequisites: ['c_structures'],
  ),

  // 35. Typedef and Enum
  Topic(
    id: 'c_typedef_enum',
    name: 'Typedef and Enum',
    subject: 'C Programming',
    prerequisites: ['c_variables_datatypes'],
  ),

  // 36. Bit Fields
  Topic(
    id: 'c_bit_fields',
    name: 'Bit Fields',
    subject: 'C Programming',
    prerequisites: ['c_structures', 'c_operators_expressions'],
  ),

  // 37. File Handling Basics
  Topic(
    id: 'c_file_handling',
    name: 'File Handling Basics',
    subject: 'C Programming',
    prerequisites: ['c_functions', 'c_pointers'],
  ),

  // 38. File Reading and Writing
  Topic(
    id: 'c_file_read_write',
    name: 'File Reading and Writing',
    subject: 'C Programming',
    prerequisites: ['c_file_handling'],
  ),

  // 39. Command Line Arguments
  Topic(
    id: 'c_command_line',
    name: 'Command Line Arguments',
    subject: 'C Programming',
    prerequisites: ['c_functions', 'c_1d_arrays', 'c_pointers'],
  ),

  // 40. Preprocessor Directives
  Topic(
    id: 'c_preprocessor',
    name: 'Preprocessor Directives (#include, #define)',
    subject: 'C Programming',
    prerequisites: ['c_structure'],
  ),

  // 41. Macros and Conditional Compilation
  Topic(
    id: 'c_macros',
    name: 'Macros and Conditional Compilation',
    subject: 'C Programming',
    prerequisites: ['c_preprocessor'],
  ),

  // 42. Header Files and Multi-File Programs
  Topic(
    id: 'c_header_files',
    name: 'Header Files and Multi-File Programs',
    subject: 'C Programming',
    prerequisites: ['c_preprocessor', 'c_functions'],
  ),
];
