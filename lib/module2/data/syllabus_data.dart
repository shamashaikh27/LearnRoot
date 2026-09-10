import '../models/topic.dart';

Topic _dsTopic(
  int id,
  String name,
  List<int> prerequisites,
) {
  return Topic(
    id: 'ds_$id',
    name: name,
    subject: 'Data Structures',
    prerequisites: prerequisites.map((p) => 'ds_$p').toList(),
  );
}

final List<Topic> syllabusTopics = [
  // UNIT 1: C PROGRAMMING FOUNDATIONS
  _dsTopic(1, 'Introduction to C', []),
  _dsTopic(2, 'Data Types & Variables in C', [1]),
  _dsTopic(3, 'Constants & Literals', [2]),
  _dsTopic(4, 'Operators & Expressions', [2]),
  _dsTopic(5, 'Type Conversion & Casting', [4]),
  _dsTopic(6, 'Input & Output Operations', [2]),
  _dsTopic(7, 'Decision Control (if, if-else)', [4]),
  _dsTopic(8, 'Switch Statement', [7]),
  _dsTopic(9, 'Nested Conditionals', [7]),
  _dsTopic(10, 'Loop Control (while, do-while)', [7]),
  _dsTopic(11, 'Iterative Statements (for loop)', [10]),
  _dsTopic(12, 'Nested Loops & Break/Continue', [11]),
  _dsTopic(13, 'Functions & Function Calls', [11]),
  _dsTopic(14, 'Scope, Storage Classes & Lifetime', [13]),
  _dsTopic(15, 'Pointers & Memory Addresses', [2]),
  _dsTopic(16, 'Pointer Arithmetic', [15]),
  _dsTopic(17, 'Pointers to Pointers', [15]),
  _dsTopic(18, 'Functions Returning Pointers', [13, 15]),
  _dsTopic(19, 'Function Pointers', [18]),
  _dsTopic(20, 'Static & Dynamic Memory Allocation', [15]),
  _dsTopic(21, 'Dynamic Memory (malloc, calloc, realloc, free)', [20]),
  _dsTopic(22, 'Recursion', [13]),

  // UNIT 2: DATA STRUCTURES & ALGORITHMS FUNDAMENTALS
  _dsTopic(23, 'Basic Terminology of Data Structures', [1]),
  _dsTopic(24, 'Classification of Data Structures', [23]),
  _dsTopic(25, 'Operations on Data Structures', [24]),
  _dsTopic(26, 'Abstract Data Types (ADTs)', [24]),
  _dsTopic(27, 'Introduction to Algorithms', [23]),
  _dsTopic(28, 'Algorithm Design Approaches', [27]),
  _dsTopic(29, 'Pseudo-code & Flowcharts', [27]),
  _dsTopic(30, 'Correctness of Algorithms', [27]),
  _dsTopic(31, 'Analysis of Algorithms', [27]),
  _dsTopic(32, 'Time Complexity Analysis', [31]),
  _dsTopic(33, 'Space Complexity Analysis', [31]),
  _dsTopic(34, 'Asymptotic Notations (Big-O, Big-Omega, Big-Theta)', [32]),
  _dsTopic(35, 'Best, Worst, and Average Case Analysis', [34]),
  _dsTopic(36, 'Mathematical Foundations for Algorithm Analysis', [31]),
  _dsTopic(37, 'Amortized Analysis', [34]),
  _dsTopic(38, 'Recurrence Relations', [22, 32]),
  _dsTopic(39, 'Substitution Method', [38]),
  _dsTopic(40, 'Recursion Tree Method', [38]),
  _dsTopic(41, 'Master Theorem', [38]),
  _dsTopic(42, 'Empirical Analysis of Algorithms', [31]),
  _dsTopic(43, 'Algorithm Efficiency Factors', [31]),
  _dsTopic(44, 'Trade-offs in Algorithm Design', [32, 33]),
  _dsTopic(45, 'Greedy Algorithms', [32]),

  // UNIT 3: ARRAYS
  _dsTopic(46, 'Introduction to Arrays', [24]),
  _dsTopic(47, 'Declaration & Initialization of Arrays', [46]),
  _dsTopic(48, 'Accessing Array Elements', [47]),
  _dsTopic(49, 'Address Calculation in Single-Dimensional Arrays', [48]),
  _dsTopic(50, 'Array Length & Bounds Checking', [48]),
  _dsTopic(51, 'Storing Arrays in Memory', [49]),
  _dsTopic(52, 'Traversing an Array', [48]),
  _dsTopic(53, 'Inserting an Element into an Array', [52]),
  _dsTopic(54, 'Deleting an Element from an Array', [52]),
  _dsTopic(55, 'Merging Two Arrays', [52]),
  _dsTopic(56, 'Searching in Arrays', [52]),
  _dsTopic(57, 'Updating Elements in Arrays', [48]),
  _dsTopic(58, 'Two-Dimensional Arrays', [46]),
  _dsTopic(59, 'Row-Major & Column-Major Ordering', [58]),
  _dsTopic(60, 'Address Calculation in 2D Arrays', [59]),
  _dsTopic(61, 'Multi-Dimensional Arrays', [58]),
  _dsTopic(62, 'Address Calculation in Multi-Dimensional Arrays', [61]),
  _dsTopic(63, 'Applications of Arrays', [52]),
  _dsTopic(64, 'Sparse Matrices', [58]),
  _dsTopic(65, 'Representation of Sparse Matrices', [64]),
  _dsTopic(66, 'Triplet Representation of Sparse Matrices', [65]),
  _dsTopic(67, 'Transpose of Sparse Matrix', [66]),
  _dsTopic(68, 'Addition of Sparse Matrices', [66]),
  _dsTopic(69, 'Dynamic Arrays', [21, 46]),
  _dsTopic(70, 'Resizing Dynamic Arrays', [69]),
  _dsTopic(71, 'Array Implementation of ADTs', [26, 46]),

  // UNIT 4: STRINGS
  _dsTopic(72, 'Introduction to Strings', [46]),
  _dsTopic(73, 'String Representation & Character Arrays', [72]),
  _dsTopic(74, 'Operations on Strings', [73]),
  _dsTopic(75, 'String Manipulation Functions in C', [74]),
  _dsTopic(76, 'String Pattern Matching Algorithms', [74]),
  _dsTopic(77, 'Applications of Strings', [74]),

  // UNIT 5: STRUCTURES & UNIONS
  _dsTopic(78, 'Introduction to Structures', [2]),
  _dsTopic(79, 'Declaring & Initializing Structures', [78]),
  _dsTopic(80, 'Accessing Structure Members', [79]),
  _dsTopic(81, 'Structure Padding & Alignment', [80]),
  _dsTopic(82, 'Array of Structures', [46, 79]),
  _dsTopic(83, 'Nested Structures', [79]),
  _dsTopic(84, 'Pointers to Structures', [15, 79]),
  _dsTopic(85, 'Self-Referential Structures', [84]),
  _dsTopic(86, 'Passing Structures to Functions', [13, 79]),
  _dsTopic(87, 'Returning Structures from Functions', [86]),
  _dsTopic(88, 'Dynamic Allocation of Structures', [21, 84]),
  _dsTopic(89, 'Introduction to Unions', [78]),
  _dsTopic(90, 'Differences Between Structures and Unions', [89]),
  _dsTopic(91, 'Applications of Unions', [89]),
  _dsTopic(92, 'Bit Fields in Structures', [80]),
  _dsTopic(93, 'Enumerations (enum)', [2]),
  _dsTopic(94, 'Typedef Keyword', [2]),
  _dsTopic(95, 'Using Typedef with Structures & Unions', [80, 89, 94]),
  _dsTopic(96, 'User-Defined Data Types using Structures', [95]),

  // UNIT 6: LINKED LISTS
  _dsTopic(97, 'Introduction to Linked Lists', [26, 85]),
  _dsTopic(98, 'Singly Linked List Representation', [97]),
  _dsTopic(99, 'Node Creation & Memory Allocation', [21, 98]),
  _dsTopic(100, 'Traversing a Singly Linked List', [98]),
  _dsTopic(101, 'Insertion in Singly Linked List', [100]),
  _dsTopic(102, 'Deletion from a Singly Linked List', [100]),
  _dsTopic(103, 'Searching in Singly Linked List', [100]),
  _dsTopic(104, 'Reversing a Singly Linked List', [100]),
  _dsTopic(105, 'Circular Linked Lists', [98]),
  _dsTopic(106, 'Operations on Circular Linked Lists', [105]),
  _dsTopic(107, 'Doubly Linked Lists', [98]),
  _dsTopic(108, 'Operations on Doubly Linked Lists', [107]),
  _dsTopic(109, 'Circular Doubly Linked Lists', [107]),
  _dsTopic(110, 'Operations on Circular Doubly Linked Lists', [109]),
  _dsTopic(111, 'Header Linked Lists', [98]),
  _dsTopic(112, 'Two-Way Header Linked Lists', [111]),
  _dsTopic(113, 'Polynomial Representation using Linked Lists', [98]),
  _dsTopic(114, 'Polynomial Addition using Linked Lists', [113]),
  _dsTopic(115, 'Sparse Matrix Representation using Linked Lists', [65, 98]),
  _dsTopic(116, 'Generalized Linked Lists', [98]),
  _dsTopic(117, 'Memory Management in Linked Lists', [99]),
  _dsTopic(118, 'Linked List vs. Array Comparison', [46, 97]),

  // UNIT 7: STACKS
  _dsTopic(119, 'Introduction to Stacks', [26]),
  _dsTopic(120, 'Stack ADT & Operations', [119]),
  _dsTopic(121, 'Array Implementation of Stacks', [46, 120]),
  _dsTopic(122, 'Linked List Implementation of Stacks', [98, 120]),
  _dsTopic(123, 'Multiple Stacks in Single Array', [121]),
  _dsTopic(124, 'Applications of Stacks', [120]),
  _dsTopic(125, 'Infix, Prefix, and Postfix Expressions', [124]),
  _dsTopic(126, 'Infix to Postfix Conversion', [125]),
  _dsTopic(127, 'Infix to Prefix Conversion', [125]),
  _dsTopic(128, 'Evaluation of Postfix Expression', [126]),
  _dsTopic(129, 'Evaluation of Prefix Expression', [127]),
  _dsTopic(130, 'Parenthesis Matching Algorithm', [120]),
  _dsTopic(131, 'Recursion Implementation using Stack', [22, 120]),
  _dsTopic(132, 'Tower of Hanoi using Stack', [131]),
  _dsTopic(133, 'Stack Frame & Call Stack', [131]),

  // UNIT 8: QUEUES
  _dsTopic(134, 'Introduction to Queues', [26]),
  _dsTopic(135, 'Queue ADT & Operations', [134]),
  _dsTopic(136, 'Array Implementation of Queues', [46, 135]),
  _dsTopic(137, 'Linked List Implementation of Queues', [98, 135]),
  _dsTopic(138, 'Limitations of Simple Queue', [136]),
  _dsTopic(139, 'Circular Queue', [138]),
  _dsTopic(140, 'Operations on Circular Queue', [139]),
  _dsTopic(141, 'Deque (Double Ended Queue)', [135]),
  _dsTopic(142, 'Priority Queue', [135]),
  _dsTopic(143, 'Array Implementation of Priority Queue', [142]),
  _dsTopic(144, 'Applications of Queues', [135]),

  // UNIT 9: TREES
  _dsTopic(145, 'Introduction to Trees', [24]),
  _dsTopic(146, 'Basic Tree Terminology', [145]),
  _dsTopic(147, 'Representation of Trees', [146]),
  _dsTopic(148, 'Binary Trees', [146]),
  _dsTopic(149, 'Types of Binary Trees', [148]),
  _dsTopic(150, 'Properties of Binary Trees', [148]),
  _dsTopic(151, 'Array Representation of Binary Trees', [46, 148]),
  _dsTopic(152, 'Linked Representation of Binary Trees', [85, 148]),
  _dsTopic(153, 'Binary Tree Traversal (Inorder, Preorder, Postorder)', [148]),
  _dsTopic(154, 'Iterative Traversals using Stack', [120, 153]),
  _dsTopic(155, 'Level Order Traversal using Queue', [135, 153]),
  _dsTopic(156, 'Constructing Binary Trees from Traversals', [153]),
  _dsTopic(157, 'Threaded Binary Trees', [148]),
  _dsTopic(158, 'Expression Trees', [125, 148]),
  _dsTopic(159, 'Operations on Binary Trees', [153]),
  _dsTopic(160, "Huffman's Tree", [45, 149]),
  _dsTopic(161, 'General Trees to Binary Trees Conversion', [148]),
  _dsTopic(162, 'Applications of Trees', [145]),

  // UNIT 10: EFFICIENT BINARY TREES
  _dsTopic(163, 'Binary Search Trees (BST)', [148]),
  _dsTopic(164, 'BST Operations (Search, Insert, Delete)', [163]),
  _dsTopic(165, 'Searching in a BST', [164]),
  _dsTopic(166, 'Insertion in a BST', [164]),
  _dsTopic(167, 'Deletion in a BST', [164]),
  _dsTopic(168, 'Time Complexity of BST Operations', [32, 164]),
  _dsTopic(169, 'AVL Trees', [163]),
  _dsTopic(170, 'Balance Factor in AVL Trees', [169]),
  _dsTopic(171, 'AVL Rotations (LL, RR, LR, RL)', [170]),
  _dsTopic(172, 'Insertion in AVL Trees', [171]),
  _dsTopic(173, 'Deletion in AVL Trees', [171]),
  _dsTopic(174, 'Red-Black Trees', [163]),
  _dsTopic(175, 'Properties of Red-Black Trees', [174]),
  _dsTopic(176, 'Insertion in Red-Black Trees', [175]),
  _dsTopic(177, 'Deletion in Red-Black Trees', [175]),
  _dsTopic(178, 'Splay Trees', [163]),
  _dsTopic(179, 'Splay Operations', [178]),
  _dsTopic(180, 'Augmented Binary Search Trees', [163]),
  _dsTopic(181, 'Interval Trees', [180]),
  _dsTopic(182, 'Segment Trees', [180]),
  _dsTopic(183, 'Scapegoat Trees', [163]),
  _dsTopic(184, 'Treaps', [163]),
  _dsTopic(185, 'Comparison of Efficient Binary Trees', [169, 174, 178]),

  // UNIT 11: MULTI-WAY SEARCH TREES
  _dsTopic(186, 'Multi-Way Search Trees (m-way Trees)', [163]),
  _dsTopic(187, 'B-Trees', [186]),
  _dsTopic(188, 'Properties of B-Trees', [187]),
  _dsTopic(189, 'Insertion in B-Trees', [188]),
  _dsTopic(190, 'Deletion from B-Trees', [188]),
  _dsTopic(191, 'B+ Trees', [187]),
  _dsTopic(192, 'Comparison of B-Trees and B+ Trees', [191]),
  _dsTopic(193, 'B* Trees', [187]),
  _dsTopic(194, '2-3 Trees', [187]),
  _dsTopic(195, '2-3-4 Trees', [187]),
  _dsTopic(196, 'Trie Data Structure', [73, 186]),
  _dsTopic(197, 'Compressed Tries (Patricia Trees)', [196]),
  _dsTopic(198, 'Suffix Trees', [196]),
  _dsTopic(199, 'Applications of Multi-Way Trees', [187]),

  // UNIT 12: HEAPS
  _dsTopic(200, 'Introduction to Heaps', [142, 151]),
  _dsTopic(201, 'Binary Heaps', [200]),
  _dsTopic(202, 'Min-Heap and Max-Heap Properties', [201]),
  _dsTopic(203, 'Array Representation of Heaps', [201]),
  _dsTopic(204, 'Heapify Operation', [202, 203]),
  _dsTopic(205, 'Insertion in Heaps', [204]),
  _dsTopic(206, 'Deletion from Heaps', [204]),
  _dsTopic(207, 'Binomial Heaps', [200]),
  _dsTopic(208, 'Binomial Trees and Properties', [207]),
  _dsTopic(209, 'Operations on Binomial Heaps', [208]),
  _dsTopic(210, 'Fibonacci Heaps', [200]),
  _dsTopic(211, 'Operations on Fibonacci Heaps', [210]),
  _dsTopic(212, 'Priority Queues using Heaps', [142, 201]),
  _dsTopic(213, 'Comparison of Heap Structures', [201, 207, 210]),

  // UNIT 13: GRAPHS
  _dsTopic(214, 'Introduction to Graphs', [24]),
  _dsTopic(215, 'Graph Terminology', [214]),
  _dsTopic(216, 'Directed and Undirected Graphs', [215]),
  _dsTopic(217, 'Representation of Graphs', [215]),
  _dsTopic(218, 'Adjacency Matrix Representation', [58, 217]),
  _dsTopic(219, 'Adjacency List Representation', [98, 217]),
  _dsTopic(220, 'Adjacency Multi-List Representation', [219]),
  _dsTopic(221, 'Incidence Matrix Representation', [58, 217]),
  _dsTopic(222, 'Graph Traversals', [217]),
  _dsTopic(223, 'Breadth-First Search (BFS)', [135, 222]),
  _dsTopic(224, 'Depth-First Search (DFS)', [22, 120, 222]),
  _dsTopic(225, 'Applications of BFS and DFS', [223, 224]),
  _dsTopic(226, 'Minimum Spanning Trees (MST)', [45, 215]),
  _dsTopic(227, "Prim's Algorithm", [226]),
  _dsTopic(228, "Kruskal's Algorithm", [226]),
  _dsTopic(229, 'Single-Source Shortest Path Algorithms', [215]),
  _dsTopic(230, "Dijkstra's Algorithm", [229]),
  _dsTopic(231, 'Bellman-Ford Algorithm', [229]),
  _dsTopic(232, 'All-Pairs Shortest Path Algorithms', [215]),
  _dsTopic(233, 'Floyd-Warshall Algorithm', [232]),
  _dsTopic(234, 'Topological Sort', [224]),
  _dsTopic(235, 'Applications of Graphs', [214]),

  // UNIT 14: SEARCHING & SORTING
  _dsTopic(236, 'Introduction to Searching', [56]),
  _dsTopic(237, 'Linear Search', [236]),
  _dsTopic(238, 'Binary Search', [236]),
  _dsTopic(239, 'Interpolation Search', [238]),
  _dsTopic(240, 'Jump Search', [238]),
  _dsTopic(241, 'Fibonacci Search', [238]),
  _dsTopic(242, 'Comparison of Searching Algorithms', [237, 238, 239]),
  _dsTopic(243, 'Introduction to Sorting', [52]),
  _dsTopic(244, 'Bubble Sort', [243]),
  _dsTopic(245, 'Selection Sort', [243]),
  _dsTopic(246, 'Insertion Sort', [243]),
  _dsTopic(247, 'Merge Sort', [22, 243]),
  _dsTopic(248, 'Quick Sort', [22, 243]),
  _dsTopic(249, 'Shell Sort', [246]),
  _dsTopic(250, 'Heap Sort', [201, 243]),
  _dsTopic(251, 'Radix Sort', [243]),
  _dsTopic(252, 'Bucket Sort', [243]),
  _dsTopic(253, 'Tree Sort', [163, 243]),
  _dsTopic(254, 'Comparison of Sorting Algorithms', [244, 247, 248, 250]),

  // UNIT 15: HASHING & COLLISION
  _dsTopic(255, 'Introduction to Hashing', [26]),
  _dsTopic(256, 'Hash Tables', [46, 255]),
  _dsTopic(257, 'Hash Functions', [256]),
  _dsTopic(258, 'Characteristics of Good Hash Functions', [257]),
  _dsTopic(259, 'Collision Resolution Techniques', [256]),
  _dsTopic(260, 'Separate Chaining (Open Hashing)', [98, 259]),
  _dsTopic(261, 'Open Addressing (Closed Hashing)', [259]),
  _dsTopic(262, 'Linear Probing', [261]),
  _dsTopic(263, 'Quadratic Probing', [261]),
  _dsTopic(264, 'Double Hashing', [261]),
  _dsTopic(265, 'Rehashing & Dynamic Hash Tables', [256]),
  _dsTopic(266, 'Applications of Hashing', [256]),

  // UNIT 16: FILES & FILE ORGANIZATION
  _dsTopic(267, 'Introduction to Files', [1]),
  _dsTopic(268, 'File Terminology', [267]),
  _dsTopic(269, 'File Operations in C', [267]),
  _dsTopic(270, 'File Organization Techniques', [268]),
  _dsTopic(271, 'Sequential File Organization', [270]),
  _dsTopic(272, 'Direct/Random File Organization', [270]),
  _dsTopic(273, 'Indexed Sequential File Organization (ISAM)', [270]),
  _dsTopic(274, 'Inverted File Organization', [270]),
  _dsTopic(275, 'Hashed File Organization', [256, 270]),
  _dsTopic(276, 'Indexing Techniques in Files', [268]),
  _dsTopic(277, 'Primary and Secondary Indices', [276]),
  _dsTopic(278, 'Dense and Sparse Indices', [276]),
  _dsTopic(279, 'Single-Level vs. Multi-Level Indexing', [276]),
  _dsTopic(280, 'B-Tree Indices', [187, 276]),
  _dsTopic(281, 'B+ Tree Indices', [191, 276]),
  _dsTopic(282, 'External Sorting', [247, 267]),
  _dsTopic(283, 'Multi-way Merge Sort for Files', [282]),

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

  // =========================
  // OPERATING SYSTEMS
  // =========================

  // 1. Introduction to Operating Systems
  Topic(
    id: 'os_introduction',
    name: 'Introduction to Operating Systems',
    subject: 'Operating Systems',
  ),

  // 2. OS Functions & Services
  Topic(
    id: 'os_functions_services',
    name: 'OS Functions & Services',
    subject: 'Operating Systems',
    prerequisites: ['os_introduction'],
  ),

  // 3. Types of Operating Systems
  Topic(
    id: 'os_types',
    name: 'Types of Operating Systems',
    subject: 'Operating Systems',
    prerequisites: ['os_introduction'],
  ),

  // 4. OS Structures
  Topic(
    id: 'os_structures',
    name: 'OS Structures',
    subject: 'Operating Systems',
    prerequisites: ['os_introduction'],
  ),

  // 5. System Calls
  Topic(
    id: 'os_system_calls',
    name: 'System Calls',
    subject: 'Operating Systems',
    prerequisites: ['os_functions_services'],
  ),

  // 6. User & Kernel Mode
  Topic(
    id: 'os_user_kernel_mode',
    name: 'User & Kernel Mode',
    subject: 'Operating Systems',
    prerequisites: ['os_functions_services'],
  ),

  // 7. Processes
  Topic(
    id: 'os_processes',
    name: 'Processes',
    subject: 'Operating Systems',
    prerequisites: ['os_introduction'],
  ),

  // 8. Process States
  Topic(
    id: 'os_process_states',
    name: 'Process States',
    subject: 'Operating Systems',
    prerequisites: ['os_processes'],
  ),

  // 9. Process Control Block (PCB)
  Topic(
    id: 'os_pcb',
    name: 'Process Control Block (PCB)',
    subject: 'Operating Systems',
    prerequisites: ['os_processes'],
  ),

  // 10. Process Scheduling
  Topic(
    id: 'os_process_scheduling',
    name: 'Process Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_processes'],
  ),

  // 11. Scheduling Criteria
  Topic(
    id: 'os_scheduling_criteria',
    name: 'Scheduling Criteria',
    subject: 'Operating Systems',
    prerequisites: ['os_process_scheduling'],
  ),

  // 12. FCFS Scheduling
  Topic(
    id: 'os_fcfs_scheduling',
    name: 'FCFS Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_process_scheduling', 'os_scheduling_criteria'],
  ),

  // 13. SJF Scheduling
  Topic(
    id: 'os_sjf_scheduling',
    name: 'SJF Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_process_scheduling', 'os_scheduling_criteria'],
  ),

  // 14. Priority Scheduling
  Topic(
    id: 'os_priority_scheduling',
    name: 'Priority Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_process_scheduling', 'os_scheduling_criteria'],
  ),

  // 15. Round Robin Scheduling
  Topic(
    id: 'os_round_robin',
    name: 'Round Robin Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_process_scheduling', 'os_scheduling_criteria'],
  ),

  // 16. Inter-Process Communication (IPC)
  Topic(
    id: 'os_ipc',
    name: 'Inter-Process Communication (IPC)',
    subject: 'Operating Systems',
    prerequisites: ['os_processes'],
  ),

  // 17. Shared Memory
  Topic(
    id: 'os_shared_memory',
    name: 'Shared Memory',
    subject: 'Operating Systems',
    prerequisites: ['os_ipc'],
  ),

  // 18. Message Passing
  Topic(
    id: 'os_message_passing',
    name: 'Message Passing',
    subject: 'Operating Systems',
    prerequisites: ['os_ipc'],
  ),

  // 19. Threads
  Topic(
    id: 'os_threads',
    name: 'Threads',
    subject: 'Operating Systems',
    prerequisites: ['os_processes'],
  ),

  // 20. Multithreading
  Topic(
    id: 'os_multithreading',
    name: 'Multithreading',
    subject: 'Operating Systems',
    prerequisites: ['os_threads'],
  ),

  // 21. Process Synchronization
  Topic(
    id: 'os_process_synchronization',
    name: 'Process Synchronization',
    subject: 'Operating Systems',
    prerequisites: ['os_processes'],
  ),

  // 22. Race Condition
  Topic(
    id: 'os_race_condition',
    name: 'Race Condition',
    subject: 'Operating Systems',
    prerequisites: ['os_process_synchronization'],
  ),

  // 23. Critical Section
  Topic(
    id: 'os_critical_section',
    name: 'Critical Section',
    subject: 'Operating Systems',
    prerequisites: ['os_race_condition'],
  ),

  // 24. Semaphores
  Topic(
    id: 'os_semaphores',
    name: 'Semaphores',
    subject: 'Operating Systems',
    prerequisites: ['os_critical_section'],
  ),

  // 25. Mutex
  Topic(
    id: 'os_mutex',
    name: 'Mutex',
    subject: 'Operating Systems',
    prerequisites: ['os_critical_section'],
  ),

  // 26. Deadlock
  Topic(
    id: 'os_deadlock',
    name: 'Deadlock',
    subject: 'Operating Systems',
    prerequisites: ['os_process_synchronization'],
  ),

  // 27. Deadlock Prevention
  Topic(
    id: 'os_deadlock_prevention',
    name: 'Deadlock Prevention',
    subject: 'Operating Systems',
    prerequisites: ['os_deadlock'],
  ),

  // 28. Deadlock Avoidance
  Topic(
    id: 'os_deadlock_avoidance',
    name: 'Deadlock Avoidance',
    subject: 'Operating Systems',
    prerequisites: ['os_deadlock'],
  ),

  // 29. Banker's Algorithm
  Topic(
    id: 'os_bankers_algorithm',
    name: "Banker's Algorithm",
    subject: 'Operating Systems',
    prerequisites: ['os_deadlock_avoidance'],
  ),

  // 30. Deadlock Detection & Recovery
  Topic(
    id: 'os_deadlock_detection_recovery',
    name: 'Deadlock Detection & Recovery',
    subject: 'Operating Systems',
    prerequisites: ['os_deadlock'],
  ),

  // 31. Memory Management
  Topic(
    id: 'os_memory_management',
    name: 'Memory Management',
    subject: 'Operating Systems',
    prerequisites: ['os_introduction'],
  ),

  // 32. Contiguous Memory Allocation
  Topic(
    id: 'os_contiguous_memory',
    name: 'Contiguous Memory Allocation',
    subject: 'Operating Systems',
    prerequisites: ['os_memory_management'],
  ),

  // 33. Paging
  Topic(
    id: 'os_paging',
    name: 'Paging',
    subject: 'Operating Systems',
    prerequisites: ['os_memory_management'],
  ),

  // 34. Page Table
  Topic(
    id: 'os_page_table',
    name: 'Page Table',
    subject: 'Operating Systems',
    prerequisites: ['os_paging'],
  ),

  // 35. Translation Lookaside Buffer (TLB)
  Topic(
    id: 'os_tlb',
    name: 'Translation Lookaside Buffer (TLB)',
    subject: 'Operating Systems',
    prerequisites: ['os_page_table'],
  ),

  // 36. Segmentation
  Topic(
    id: 'os_segmentation',
    name: 'Segmentation',
    subject: 'Operating Systems',
    prerequisites: ['os_memory_management'],
  ),

  // 37. Virtual Memory
  Topic(
    id: 'os_virtual_memory',
    name: 'Virtual Memory',
    subject: 'Operating Systems',
    prerequisites: ['os_paging'],
  ),

  // 38. Demand Paging
  Topic(
    id: 'os_demand_paging',
    name: 'Demand Paging',
    subject: 'Operating Systems',
    prerequisites: ['os_virtual_memory'],
  ),

  // 39. Page Replacement
  Topic(
    id: 'os_page_replacement',
    name: 'Page Replacement',
    subject: 'Operating Systems',
    prerequisites: ['os_demand_paging'],
  ),

  // 40. FIFO Page Replacement
  Topic(
    id: 'os_fifo_page_replacement',
    name: 'FIFO Page Replacement',
    subject: 'Operating Systems',
    prerequisites: ['os_page_replacement'],
  ),

  // 41. LRU Page Replacement
  Topic(
    id: 'os_lru_page_replacement',
    name: 'LRU Page Replacement',
    subject: 'Operating Systems',
    prerequisites: ['os_page_replacement'],
  ),

  // 42. Optimal Page Replacement
  Topic(
    id: 'os_optimal_page_replacement',
    name: 'Optimal Page Replacement',
    subject: 'Operating Systems',
    prerequisites: ['os_page_replacement'],
  ),

  // 43. File System
  Topic(
    id: 'os_file_system',
    name: 'File System',
    subject: 'Operating Systems',
    prerequisites: ['os_introduction'],
  ),

  // 44. File Concept & Attributes
  Topic(
    id: 'os_file_concept_attributes',
    name: 'File Concept & Attributes',
    subject: 'Operating Systems',
    prerequisites: ['os_file_system'],
  ),

  // 45. File Operations
  Topic(
    id: 'os_file_operations',
    name: 'File Operations',
    subject: 'Operating Systems',
    prerequisites: ['os_file_concept_attributes'],
  ),

  // 46. Directory Structure
  Topic(
    id: 'os_directory_structure',
    name: 'Directory Structure',
    subject: 'Operating Systems',
    prerequisites: ['os_file_system'],
  ),

  // 47. File Allocation Methods
  Topic(
    id: 'os_file_allocation',
    name: 'File Allocation Methods',
    subject: 'Operating Systems',
    prerequisites: ['os_file_system'],
  ),

  // 48. Free Space Management
  Topic(
    id: 'os_free_space',
    name: 'Free Space Management',
    subject: 'Operating Systems',
    prerequisites: ['os_file_system'],
  ),

  // 49. Disk Structure
  Topic(
    id: 'os_disk_structure',
    name: 'Disk Structure',
    subject: 'Operating Systems',
    prerequisites: ['os_introduction'],
  ),

  // 50. Disk Scheduling
  Topic(
    id: 'os_disk_scheduling',
    name: 'Disk Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_disk_structure'],
  ),

  // 51. FCFS Disk Scheduling
  Topic(
    id: 'os_fcfs_disk_scheduling',
    name: 'FCFS Disk Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_disk_scheduling'],
  ),

  // 52. SSTF Disk Scheduling
  Topic(
    id: 'os_sstf_disk_scheduling',
    name: 'SSTF Disk Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_disk_scheduling'],
  ),

  // 53. SCAN Disk Scheduling
  Topic(
    id: 'os_scan_disk_scheduling',
    name: 'SCAN Disk Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_disk_scheduling'],
  ),

  // 54. C-SCAN Disk Scheduling
  Topic(
    id: 'os_cscan_disk_scheduling',
    name: 'C-SCAN Disk Scheduling',
    subject: 'Operating Systems',
    prerequisites: ['os_disk_scheduling'],
  ),

  // 55. I/O Management
  Topic(
    id: 'os_io_management',
    name: 'I/O Management',
    subject: 'Operating Systems',
    prerequisites: ['os_introduction'],
  ),

  // 56. I/O Hardware
  Topic(
    id: 'os_io_hardware',
    name: 'I/O Hardware',
    subject: 'Operating Systems',
    prerequisites: ['os_io_management'],
  ),

  // 57. Device Drivers
  Topic(
    id: 'os_device_drivers',
    name: 'Device Drivers',
    subject: 'Operating Systems',
    prerequisites: ['os_io_hardware'],
  ),

  // 58. Protection & Security
  Topic(
    id: 'os_protection_security',
    name: 'Protection & Security',
    subject: 'Operating Systems',
    prerequisites: ['os_introduction'],
  ),

  // 59. Access Control
  Topic(
    id: 'os_access_control',
    name: 'Access Control',
    subject: 'Operating Systems',
    prerequisites: ['os_protection_security'],
  ),

    // 60. Authentication
  Topic(
    id: 'os_authentication',
    name: 'Authentication',
    subject: 'Operating Systems',
    prerequisites: ['os_protection_security'],
  ),

  // =========================
  // COMPUTER NETWORKS
  // =========================

  // 1. Introduction to Computer Networks
  Topic(
    id: 'cn_introduction',
    name: 'Introduction to Computer Networks',
    subject: 'Computer Networks',
  ),

  // 2. Network Topologies
  Topic(
    id: 'cn_network_topologies',
    name: 'Network Topologies',
    subject: 'Computer Networks',
    prerequisites: ['cn_introduction'],
  ),

  // 3. Network Types
  Topic(
    id: 'cn_network_types',
    name: 'Network Types (LAN, MAN, WAN)',
    subject: 'Computer Networks',
    prerequisites: ['cn_introduction'],
  ),

  // 4. OSI Reference Model
  Topic(
    id: 'cn_osi_model',
    name: 'OSI Reference Model',
    subject: 'Computer Networks',
    prerequisites: ['cn_introduction'],
  ),

  // 5. TCP/IP Reference Model
  Topic(
    id: 'cn_tcp_ip_model',
    name: 'TCP/IP Reference Model',
    subject: 'Computer Networks',
    prerequisites: ['cn_osi_model'],
  ),

  // 6. Physical Layer Overview
  Topic(
    id: 'cn_physical_layer',
    name: 'Physical Layer Overview',
    subject: 'Computer Networks',
    prerequisites: ['cn_osi_model'],
  ),

  // 7. Transmission Media
  Topic(
    id: 'cn_transmission_media',
    name: 'Transmission Media (Guided & Unguided)',
    subject: 'Computer Networks',
    prerequisites: ['cn_physical_layer'],
  ),

  // 8. Switching Techniques
  Topic(
    id: 'cn_switching',
    name: 'Switching Techniques (Circuit, Packet)',
    subject: 'Computer Networks',
    prerequisites: ['cn_physical_layer'],
  ),

  // 9. Multiplexing
  Topic(
    id: 'cn_multiplexing',
    name: 'Multiplexing (FDM, TDM, WDM)',
    subject: 'Computer Networks',
    prerequisites: ['cn_physical_layer'],
  ),

  // 10. Data Link Layer Overview
  Topic(
    id: 'cn_data_link_layer',
    name: 'Data Link Layer Overview',
    subject: 'Computer Networks',
    prerequisites: ['cn_osi_model'],
  ),

  // 11. Framing Techniques
  Topic(
    id: 'cn_framing',
    name: 'Framing Techniques',
    subject: 'Computer Networks',
    prerequisites: ['cn_data_link_layer'],
  ),

  // 12. Error Detection
  Topic(
    id: 'cn_error_detection',
    name: 'Error Detection (Parity, Checksum, CRC)',
    subject: 'Computer Networks',
    prerequisites: ['cn_data_link_layer'],
  ),

  // 13. Error Correction
  Topic(
    id: 'cn_error_correction',
    name: 'Error Correction (Hamming Code)',
    subject: 'Computer Networks',
    prerequisites: ['cn_error_detection'],
  ),

  // 14. Flow Control Protocols
  Topic(
    id: 'cn_flow_control',
    name: 'Flow Control Protocols (Stop-and-Wait, Sliding Window)',
    subject: 'Computer Networks',
    prerequisites: ['cn_data_link_layer'],
  ),

  // 15. Go-Back-N & Selective Repeat ARQ
  Topic(
    id: 'cn_arq',
    name: 'Go-Back-N & Selective Repeat ARQ',
    subject: 'Computer Networks',
    prerequisites: ['cn_flow_control'],
  ),

  // 16. Medium Access Control
  Topic(
    id: 'cn_mac',
    name: 'Medium Access Control (MAC)',
    subject: 'Computer Networks',
    prerequisites: ['cn_data_link_layer'],
  ),

  // 17. ALOHA
  Topic(
    id: 'cn_aloha',
    name: 'ALOHA (Pure and Slotted)',
    subject: 'Computer Networks',
    prerequisites: ['cn_mac'],
  ),

  // 18. CSMA, CSMA/CD, CSMA/CA
  Topic(
    id: 'cn_csma',
    name: 'CSMA, CSMA/CD, CSMA/CA',
    subject: 'Computer Networks',
    prerequisites: ['cn_mac'],
  ),

  // 19. Ethernet Standards
  Topic(
    id: 'cn_ethernet',
    name: 'Ethernet Standards',
    subject: 'Computer Networks',
    prerequisites: ['cn_mac'],
  ),

  // 20. Data Link Layer Devices
  Topic(
    id: 'cn_data_link_devices',
    name: 'Data Link Layer Devices (Switches, Bridges)',
    subject: 'Computer Networks',
    prerequisites: ['cn_data_link_layer'],
  ),

  // 21. Network Layer Overview
  Topic(
    id: 'cn_network_layer',
    name: 'Network Layer Overview',
    subject: 'Computer Networks',
    prerequisites: ['cn_osi_model'],
  ),

  // 22. IPv4 Addressing & Classes
  Topic(
    id: 'cn_ipv4',
    name: 'IPv4 Addressing & Classes',
    subject: 'Computer Networks',
    prerequisites: ['cn_network_layer'],
  ),

  // 23. Subnetting and CIDR
  Topic(
    id: 'cn_subnetting',
    name: 'Subnetting and CIDR',
    subject: 'Computer Networks',
    prerequisites: ['cn_ipv4'],
  ),

  // 24. IPv6 Addressing
  Topic(
    id: 'cn_ipv6',
    name: 'IPv6 Addressing',
    subject: 'Computer Networks',
    prerequisites: ['cn_network_layer'],
  ),

  // 25. Address Resolution Protocol
  Topic(
    id: 'cn_arp',
    name: 'Address Resolution Protocol (ARP & RARP)',
    subject: 'Computer Networks',
    prerequisites: ['cn_ipv4', 'cn_data_link_layer'],
  ),

  // 26. Internet Control Message Protocol
  Topic(
    id: 'cn_icmp',
    name: 'Internet Control Message Protocol (ICMP)',
    subject: 'Computer Networks',
    prerequisites: ['cn_network_layer'],
  ),

  // 27. Dynamic Host Configuration Protocol
  Topic(
    id: 'cn_dhcp',
    name: 'Dynamic Host Configuration Protocol (DHCP)',
    subject: 'Computer Networks',
    prerequisites: ['cn_ipv4'],
  ),

  // 28. Routing Algorithms Overview
  Topic(
    id: 'cn_routing_algorithms',
    name: 'Routing Algorithms Overview',
    subject: 'Computer Networks',
    prerequisites: ['cn_network_layer'],
  ),

  // 29. Distance Vector Routing
  Topic(
    id: 'cn_distance_vector',
    name: 'Distance Vector Routing',
    subject: 'Computer Networks',
    prerequisites: ['cn_routing_algorithms'],
  ),

  // 30. Link State Routing
  Topic(
    id: 'cn_link_state',
    name: 'Link State Routing',
    subject: 'Computer Networks',
    prerequisites: ['cn_routing_algorithms'],
  ),

  // 31. Unicast Routing Protocols
  Topic(
    id: 'cn_unicast_routing',
    name: 'Unicast Routing Protocols (RIP, OSPF, BGP)',
    subject: 'Computer Networks',
    prerequisites: ['cn_distance_vector', 'cn_link_state'],
  ),

  // 32. Multicast Routing Protocols
  Topic(
    id: 'cn_multicast_routing',
    name: 'Multicast Routing Protocols',
    subject: 'Computer Networks',
    prerequisites: ['cn_routing_algorithms'],
  ),

  // 33. Network Layer Devices
  Topic(
    id: 'cn_routers',
    name: 'Network Layer Devices (Routers)',
    subject: 'Computer Networks',
    prerequisites: ['cn_network_layer'],
  ),

  // 34. Transport Layer Overview
  Topic(
    id: 'cn_transport_layer',
    name: 'Transport Layer Overview',
    subject: 'Computer Networks',
    prerequisites: ['cn_osi_model'],
  ),

  // 35. Process-to-Process Delivery & Ports
  Topic(
    id: 'cn_process_delivery_ports',
    name: 'Process-to-Process Delivery & Ports',
    subject: 'Computer Networks',
    prerequisites: ['cn_transport_layer'],
  ),

  // 36. User Datagram Protocol
  Topic(
    id: 'cn_udp',
    name: 'User Datagram Protocol (UDP)',
    subject: 'Computer Networks',
    prerequisites: ['cn_transport_layer'],
  ),

  // 37. Transmission Control Protocol
  Topic(
    id: 'cn_tcp',
    name: 'Transmission Control Protocol (TCP)',
    subject: 'Computer Networks',
    prerequisites: ['cn_transport_layer'],
  ),

  // 38. TCP Segment Format
  Topic(
    id: 'cn_tcp_segment',
    name: 'TCP Segment Format',
    subject: 'Computer Networks',
    prerequisites: ['cn_tcp'],
  ),

  // 39. TCP Connection Management
  Topic(
    id: 'cn_tcp_connection',
    name: 'TCP Connection Management (3-Way Handshake)',
    subject: 'Computer Networks',
    prerequisites: ['cn_tcp'],
  ),

  // 40. TCP Flow & Congestion Control
  Topic(
    id: 'cn_tcp_flow_congestion',
    name: 'TCP Flow Control & Congestion Control',
    subject: 'Computer Networks',
    prerequisites: ['cn_tcp'],
  ),

  // 41. Application Layer Overview
  Topic(
    id: 'cn_application_layer',
    name: 'Application Layer Overview',
    subject: 'Computer Networks',
    prerequisites: ['cn_osi_model'],
  ),

  // 42. Domain Name System
  Topic(
    id: 'cn_dns',
    name: 'Domain Name System (DNS)',
    subject: 'Computer Networks',
    prerequisites: ['cn_application_layer'],
  ),

  // 43. HTTP / HTTPS
  Topic(
    id: 'cn_http',
    name: 'Hypertext Transfer Protocol (HTTP / HTTPS)',
    subject: 'Computer Networks',
    prerequisites: ['cn_application_layer', 'cn_tcp'],
  ),

  // 44. File Transfer Protocol
  Topic(
    id: 'cn_ftp',
    name: 'File Transfer Protocol (FTP)',
    subject: 'Computer Networks',
    prerequisites: ['cn_application_layer', 'cn_tcp'],
  ),

  // 45. Email Protocols
  Topic(
    id: 'cn_email_protocols',
    name: 'Email Protocols (SMTP, POP3, IMAP)',
    subject: 'Computer Networks',
    prerequisites: ['cn_application_layer', 'cn_tcp'],
  ),

  // 46. Network Security Overview
  Topic(
    id: 'cn_network_security',
    name: 'Network Security Overview',
    subject: 'Computer Networks',
    prerequisites: ['cn_introduction'],
  ),

  // 47. Cryptography Basics
  Topic(
    id: 'cn_cryptography',
    name: 'Cryptography Basics (Symmetric & Asymmetric)',
    subject: 'Computer Networks',
    prerequisites: ['cn_network_security'],
  ),

  // 48. Firewalls and Intrusion Detection Systems
  Topic(
    id: 'cn_firewalls_ids',
    name: 'Firewalls and Intrusion Detection Systems',
    subject: 'Computer Networks',
    prerequisites: ['cn_network_security'],
  ),

  // 49. Virtual Private Networks
  Topic(
    id: 'cn_vpn',
    name: 'Virtual Private Networks (VPN)',
    subject: 'Computer Networks',
    prerequisites: ['cn_network_security', 'cn_network_layer'],
  ),

  // 50. Wireless Networks
  Topic(
    id: 'cn_wireless',
    name: 'Wireless Networks (Wi-Fi, Bluetooth)',
    subject: 'Computer Networks',
    prerequisites: ['cn_physical_layer', 'cn_data_link_layer'],
  ),

    // 51. Network Performance
  Topic(
    id: 'cn_network_performance',
    name: 'Network Performance (Bandwidth, Throughput, Latency)',
    subject: 'Computer Networks',
    prerequisites: ['cn_physical_layer'],
  ),

  // =========================
  // DATABASE MANAGEMENT SYSTEM
  // =========================

  // 1. Introduction to DBMS
  Topic(
    id: 'dbms_introduction',
    name: 'Introduction to DBMS',
    subject: 'DBMS',
  ),

  // 2. File System vs DBMS
  Topic(
    id: 'dbms_file_system_vs_dbms',
    name: 'File System vs DBMS',
    subject: 'DBMS',
    prerequisites: ['dbms_introduction'],
  ),

  // 3. DBMS Architecture
  Topic(
    id: 'dbms_architecture',
    name: 'DBMS Architecture (1-Tier, 2-Tier, 3-Tier)',
    subject: 'DBMS',
    prerequisites: ['dbms_introduction'],
  ),

  // 4. Three-Schema Architecture & Data Independence
  Topic(
    id: 'dbms_three_schema',
    name: 'Three-Schema Architecture & Data Independence',
    subject: 'DBMS',
    prerequisites: ['dbms_architecture'],
  ),

  // 5. ER Model Concepts
  Topic(
    id: 'dbms_er_model',
    name: 'ER Model Concepts',
    subject: 'DBMS',
    prerequisites: ['dbms_introduction'],
  ),

  // 6. Entities, Attributes & Relationships
  Topic(
    id: 'dbms_entities_attributes_relationships',
    name: 'Entities, Attributes & Relationships',
    subject: 'DBMS',
    prerequisites: ['dbms_er_model'],
  ),

  // 7. ER Diagram Symbols & Notations
  Topic(
    id: 'dbms_er_symbols',
    name: 'ER Diagram Symbols & Notations',
    subject: 'DBMS',
    prerequisites: ['dbms_entities_attributes_relationships'],
  ),

  // 8. Extended ER Features
  Topic(
    id: 'dbms_extended_er',
    name: 'Extended ER Features (Generalization, Specialization, Aggregation)',
    subject: 'DBMS',
    prerequisites: ['dbms_er_symbols'],
  ),

  // 9. Relational Model Concepts
  Topic(
    id: 'dbms_relational_model',
    name: 'Relational Model Concepts',
    subject: 'DBMS',
    prerequisites: ['dbms_introduction'],
  ),

  // 10. ER to Relational Mapping
  Topic(
    id: 'dbms_er_to_relational',
    name: 'ER to Relational Mapping',
    subject: 'DBMS',
    prerequisites: ['dbms_er_model', 'dbms_relational_model'],
  ),

  // 11. Keys in Relational Model
  Topic(
    id: 'dbms_keys',
    name: 'Keys in Relational Model (Primary, Candidate, Super, Foreign)',
    subject: 'DBMS',
    prerequisites: ['dbms_relational_model'],
  ),

  // 12. Relational Integrity Constraints
  Topic(
    id: 'dbms_integrity_constraints',
    name: 'Relational Integrity Constraints',
    subject: 'DBMS',
    prerequisites: ['dbms_keys'],
  ),

  // 13. Relational Algebra
  Topic(
    id: 'dbms_relational_algebra',
    name: 'Relational Algebra (Select, Project, Rename)',
    subject: 'DBMS',
    prerequisites: ['dbms_relational_model'],
  ),

  // 14. Set Operations in Relational Algebra
  Topic(
    id: 'dbms_set_operations',
    name: 'Set Operations in Relational Algebra (Union, Intersection, Set Difference, Cartesian Product)',
    subject: 'DBMS',
    prerequisites: ['dbms_relational_algebra'],
  ),

  // 15. Join Operations
  Topic(
    id: 'dbms_join_operations',
    name: 'Join Operations (Inner, Outer, Equi, Natural)',
    subject: 'DBMS',
    prerequisites: ['dbms_relational_algebra'],
  ),

  // 16. Relational Calculus
  Topic(
    id: 'dbms_relational_calculus',
    name: 'Relational Calculus (Tuple & Domain)',
    subject: 'DBMS',
    prerequisites: ['dbms_relational_algebra'],
  ),

  // 17. Introduction to SQL
  Topic(
    id: 'dbms_sql_introduction',
    name: 'Introduction to SQL',
    subject: 'DBMS',
    prerequisites: ['dbms_relational_model'],
  ),

  // 18. DDL Commands
  Topic(
    id: 'dbms_ddl',
    name: 'DDL Commands (CREATE, ALTER, DROP, TRUNCATE)',
    subject: 'DBMS',
    prerequisites: ['dbms_sql_introduction'],
  ),

  // 19. DML Commands
  Topic(
    id: 'dbms_dml',
    name: 'DML Commands (INSERT, UPDATE, DELETE)',
    subject: 'DBMS',
    prerequisites: ['dbms_sql_introduction'],
  ),

  // 20. DQL Commands
  Topic(
    id: 'dbms_dql',
    name: 'DQL Commands (SELECT, WHERE, ORDER BY)',
    subject: 'DBMS',
    prerequisites: ['dbms_sql_introduction'],
  ),

  // 21. Aggregate Functions & GROUP BY / HAVING
  Topic(
    id: 'dbms_aggregate_functions',
    name: 'Aggregate Functions & GROUP BY / HAVING',
    subject: 'DBMS',
    prerequisites: ['dbms_dql'],
  ),

  // 22. SQL Joins
  Topic(
    id: 'dbms_sql_joins',
    name: 'SQL Joins (INNER, LEFT, RIGHT, FULL)',
    subject: 'DBMS',
    prerequisites: ['dbms_dql', 'dbms_join_operations'],
  ),

  // 23. Subqueries & Nested Queries
  Topic(
    id: 'dbms_subqueries',
    name: 'Subqueries & Nested Queries',
    subject: 'DBMS',
    prerequisites: ['dbms_dql'],
  ),

  // 24. Views in SQL
  Topic(
    id: 'dbms_views',
    name: 'Views in SQL',
    subject: 'DBMS',
    prerequisites: ['dbms_dql'],
  ),

  // 25. Constraints
  Topic(
    id: 'dbms_constraints',
    name: 'Constraints (NOT NULL, UNIQUE, CHECK, DEFAULT, Foreign Key)',
    subject: 'DBMS',
    prerequisites: ['dbms_ddl', 'dbms_integrity_constraints'],
  ),

  // 26. Functional Dependency
  Topic(
    id: 'dbms_functional_dependency',
    name: 'Functional Dependency (FD)',
    subject: 'DBMS',
    prerequisites: ['dbms_relational_model'],
  ),

  // 27. Inference Rules
  Topic(
    id: 'dbms_inference_rules',
    name: "Inference Rules (Armstrong's Axioms)",
    subject: 'DBMS',
    prerequisites: ['dbms_functional_dependency'],
  ),

  // 28. Closure of Attribute Sets & Candidate Key Finding
  Topic(
    id: 'dbms_attribute_closure',
    name: 'Closure of Attribute Sets & Candidate Key Finding',
    subject: 'DBMS',
    prerequisites: ['dbms_functional_dependency'],
  ),

  // 29. Normalization Overview
  Topic(
    id: 'dbms_normalization',
    name: 'Normalization Overview',
    subject: 'DBMS',
    prerequisites: ['dbms_functional_dependency'],
  ),

  // 30. First Normal Form
  Topic(
    id: 'dbms_1nf',
    name: 'First Normal Form (1NF)',
    subject: 'DBMS',
    prerequisites: ['dbms_normalization'],
  ),

  // 31. Second Normal Form
  Topic(
    id: 'dbms_2nf',
    name: 'Second Normal Form (2NF)',
    subject: 'DBMS',
    prerequisites: ['dbms_1nf', 'dbms_attribute_closure'],
  ),

  // 32. Third Normal Form
  Topic(
    id: 'dbms_3nf',
    name: 'Third Normal Form (3NF)',
    subject: 'DBMS',
    prerequisites: ['dbms_2nf'],
  ),

  // 33. Boyce-Codd Normal Form
  Topic(
    id: 'dbms_bcnf',
    name: 'Boyce-Codd Normal Form (BCNF)',
    subject: 'DBMS',
    prerequisites: ['dbms_3nf'],
  ),

  // 34. Fourth Normal Form
  Topic(
    id: 'dbms_4nf',
    name: 'Fourth Normal Form (4NF) & Multivalued Dependency',
    subject: 'DBMS',
    prerequisites: ['dbms_bcnf'],
  ),

  // 35. Lossless Join Decomposition
  Topic(
    id: 'dbms_lossless_join',
    name: 'Lossless Join Decomposition',
    subject: 'DBMS',
    prerequisites: ['dbms_normalization'],
  ),

  // 36. Dependency Preservation
  Topic(
    id: 'dbms_dependency_preservation',
    name: 'Dependency Preservation',
    subject: 'DBMS',
    prerequisites: ['dbms_normalization'],
  ),

  // 37. Transaction Concepts & ACID Properties
  Topic(
    id: 'dbms_transactions_acid',
    name: 'Transaction Concepts & ACID Properties',
    subject: 'DBMS',
    prerequisites: ['dbms_introduction'],
  ),

  // 38. Transaction States
  Topic(
    id: 'dbms_transaction_states',
    name: 'Transaction States',
    subject: 'DBMS',
    prerequisites: ['dbms_transactions_acid'],
  ),

  // 39. Concurrent Executions & Schedule
  Topic(
    id: 'dbms_concurrent_executions',
    name: 'Concurrent Executions & Schedule',
    subject: 'DBMS',
    prerequisites: ['dbms_transactions_acid'],
  ),

  // 40. Serializability
  Topic(
    id: 'dbms_serializability',
    name: 'Serializability (Conflict & View)',
    subject: 'DBMS',
    prerequisites: ['dbms_concurrent_executions'],
  ),

  // 41. Recoverability of Schedules
  Topic(
    id: 'dbms_recoverability',
    name: 'Recoverability of Schedules',
    subject: 'DBMS',
    prerequisites: ['dbms_concurrent_executions'],
  ),

  // 42. Concurrency Control Overview
  Topic(
    id: 'dbms_concurrency_control',
    name: 'Concurrency Control Overview',
    subject: 'DBMS',
    prerequisites: ['dbms_transactions_acid'],
  ),

  // 43. Lock-Based Protocols
  Topic(
    id: 'dbms_lock_protocols',
    name: 'Lock-Based Protocols (Shared/Exclusive, 2PL, Strict 2PL)',
    subject: 'DBMS',
    prerequisites: ['dbms_concurrency_control'],
  ),

  // 44. Timestamp-Based Protocols
  Topic(
    id: 'dbms_timestamp_protocols',
    name: 'Timestamp-Based Protocols',
    subject: 'DBMS',
    prerequisites: ['dbms_concurrency_control'],
  ),

  // 45. Deadlock Handling in DBMS
  Topic(
    id: 'dbms_deadlock_handling',
    name: 'Deadlock Handling in DBMS',
    subject: 'DBMS',
    prerequisites: ['dbms_lock_protocols'],
  ),

  // 46. Database Recovery Concepts
  Topic(
    id: 'dbms_recovery',
    name: 'Database Recovery Concepts',
    subject: 'DBMS',
    prerequisites: ['dbms_transactions_acid'],
  ),

  // 47. Log-Based Recovery
  Topic(
    id: 'dbms_log_recovery',
    name: 'Log-Based Recovery',
    subject: 'DBMS',
    prerequisites: ['dbms_recovery'],
  ),

  // 48. Checkpoints in Recovery
  Topic(
    id: 'dbms_checkpoints',
    name: 'Checkpoints in Recovery',
    subject: 'DBMS',
    prerequisites: ['dbms_log_recovery'],
  ),

  // 49. Indexing Concepts
  Topic(
    id: 'dbms_indexing',
    name: 'Indexing Concepts',
    subject: 'DBMS',
    prerequisites: ['dbms_relational_model'],
  ),

  // 50. Primary, Secondary & Clustered Indexes
  Topic(
    id: 'dbms_index_types',
    name: 'Primary, Secondary & Clustered Indexes',
    subject: 'DBMS',
    prerequisites: ['dbms_indexing'],
  ),

  // 51. B-Trees and B+ Trees Indexing
  Topic(
    id: 'dbms_btree',
    name: 'B-Trees and B+ Trees Indexing',
    subject: 'DBMS',
    prerequisites: ['dbms_indexing'],
  ),

    // 52. Hashing in DBMS
  Topic(
    id: 'dbms_hashing',
    name: 'Hashing in DBMS (Static & Dynamic)',
    subject: 'DBMS',
    prerequisites: ['dbms_indexing'],
  ),

  // =========================
  // JAVA OBJECT-ORIENTED PROGRAMMING
  // =========================

  // 1. Introduction to Java
  Topic(
    id: 'java_introduction',
    name: 'Introduction to Java',
    subject: 'OOPs – Java',
  ),

  // 2. JDK, JRE, and JVM
  Topic(
    id: 'java_jdk_jre_jvm',
    name: 'JDK, JRE, and JVM',
    subject: 'OOPs – Java',
    prerequisites: ['java_introduction'],
  ),

  // 3. Java Basic Syntax & Structure
  Topic(
    id: 'java_basic_syntax',
    name: 'Java Basic Syntax & Structure',
    subject: 'OOPs – Java',
    prerequisites: ['java_introduction'],
  ),

  // 4. Variables & Data Types
  Topic(
    id: 'java_variables_datatypes',
    name: 'Variables & Data Types',
    subject: 'OOPs – Java',
    prerequisites: ['java_basic_syntax'],
  ),

  // 5. Operators in Java
  Topic(
    id: 'java_operators',
    name: 'Operators in Java',
    subject: 'OOPs – Java',
    prerequisites: ['java_variables_datatypes'],
  ),

  // 6. Control Flow Statements
  Topic(
    id: 'java_control_flow',
    name: 'Control Flow Statements',
    subject: 'OOPs – Java',
    prerequisites: ['java_operators'],
  ),

  // 7. Arrays in Java
  Topic(
    id: 'java_arrays',
    name: 'Arrays in Java',
    subject: 'OOPs – Java',
    prerequisites: ['java_control_flow'],
  ),

  // 8. OOP Concepts Overview
  Topic(
    id: 'java_oop_concepts',
    name: 'OOP Concepts Overview',
    subject: 'OOPs – Java',
    prerequisites: ['java_introduction'],
  ),

  // 9. Classes and Objects
  Topic(
    id: 'java_classes_objects',
    name: 'Classes and Objects',
    subject: 'OOPs – Java',
    prerequisites: ['java_oop_concepts'],
  ),

  // 10. Constructors
  Topic(
    id: 'java_constructors',
    name: 'Constructors',
    subject: 'OOPs – Java',
    prerequisites: ['java_classes_objects'],
  ),

  // 11. Access Modifiers
  Topic(
    id: 'java_access_modifiers',
    name: 'Access Modifiers',
    subject: 'OOPs – Java',
    prerequisites: ['java_classes_objects'],
  ),

  // 12. Encapsulation
  Topic(
    id: 'java_encapsulation',
    name: 'Encapsulation',
    subject: 'OOPs – Java',
    prerequisites: ['java_classes_objects', 'java_access_modifiers'],
  ),

  // 13. Inheritance
  Topic(
    id: 'java_inheritance',
    name: 'Inheritance',
    subject: 'OOPs – Java',
    prerequisites: ['java_classes_objects'],
  ),

  // 14. Types of Inheritance
  Topic(
    id: 'java_inheritance_types',
    name: 'Types of Inheritance',
    subject: 'OOPs – Java',
    prerequisites: ['java_inheritance'],
  ),

  // 15. Method Overriding
  Topic(
    id: 'java_method_overriding',
    name: 'Method Overriding',
    subject: 'OOPs – Java',
    prerequisites: ['java_inheritance'],
  ),

  // 16. Super Keyword
  Topic(
    id: 'java_super_keyword',
    name: 'Super Keyword',
    subject: 'OOPs – Java',
    prerequisites: ['java_inheritance'],
  ),

  // 17. Polymorphism
  Topic(
    id: 'java_polymorphism',
    name: 'Polymorphism',
    subject: 'OOPs – Java',
    prerequisites: ['java_classes_objects'],
  ),

  // 18. Method Overloading
  Topic(
    id: 'java_method_overloading',
    name: 'Method Overloading',
    subject: 'OOPs – Java',
    prerequisites: ['java_polymorphism'],
  ),

  // 19. Abstraction
  Topic(
    id: 'java_abstraction',
    name: 'Abstraction',
    subject: 'OOPs – Java',
    prerequisites: ['java_oop_concepts'],
  ),

  // 20. Abstract Classes
  Topic(
    id: 'java_abstract_classes',
    name: 'Abstract Classes',
    subject: 'OOPs – Java',
    prerequisites: ['java_abstraction', 'java_classes_objects'],
  ),

  // 21. Interfaces
  Topic(
    id: 'java_interfaces',
    name: 'Interfaces',
    subject: 'OOPs – Java',
    prerequisites: ['java_abstraction'],
  ),

  // 22. Multiple Inheritance via Interfaces
  Topic(
    id: 'java_multiple_inheritance',
    name: 'Multiple Inheritance via Interfaces',
    subject: 'OOPs – Java',
    prerequisites: ['java_interfaces', 'java_inheritance'],
  ),

  // 23. Static Keyword
  Topic(
    id: 'java_static_keyword',
    name: 'Static Keyword',
    subject: 'OOPs – Java',
    prerequisites: ['java_classes_objects'],
  ),

  // 24. Final Keyword
  Topic(
    id: 'java_final_keyword',
    name: 'Final Keyword',
    subject: 'OOPs – Java',
    prerequisites: ['java_variables_datatypes', 'java_inheritance'],
  ),

  // 25. Package and Importing
  Topic(
    id: 'java_packages',
    name: 'Package and Importing',
    subject: 'OOPs – Java',
    prerequisites: ['java_access_modifiers'],
  ),

  // 26. Strings in Java
  Topic(
    id: 'java_strings',
    name: 'Strings in Java',
    subject: 'OOPs – Java',
    prerequisites: ['java_arrays', 'java_classes_objects'],
  ),

  // 27. StringBuilder and StringBuffer
  Topic(
    id: 'java_string_builder_buffer',
    name: 'StringBuilder and StringBuffer',
    subject: 'OOPs – Java',
    prerequisites: ['java_strings'],
  ),

  // 28. Exception Handling Overview
  Topic(
    id: 'java_exception_handling',
    name: 'Exception Handling Overview',
    subject: 'OOPs – Java',
    prerequisites: ['java_control_flow'],
  ),

  // 29. Try, Catch, and Finally
  Topic(
    id: 'java_try_catch_finally',
    name: 'Try, Catch, and Finally',
    subject: 'OOPs – Java',
    prerequisites: ['java_exception_handling'],
  ),

  // 30. Throw and Throws
  Topic(
    id: 'java_throw_throws',
    name: 'Throw and Throws',
    subject: 'OOPs – Java',
    prerequisites: ['java_exception_handling'],
  ),

  // 31. Custom Exceptions
  Topic(
    id: 'java_custom_exceptions',
    name: 'Custom Exceptions',
    subject: 'OOPs – Java',
    prerequisites: ['java_exception_handling', 'java_inheritance'],
  ),

  // 32. Collections Framework Overview
  Topic(
    id: 'java_collections',
    name: 'Collections Framework Overview',
    subject: 'OOPs – Java',
    prerequisites: ['java_interfaces', 'java_classes_objects'],
  ),

  // 33. List Interface & Implementations
  Topic(
    id: 'java_list',
    name: 'List Interface & Implementations',
    subject: 'OOPs – Java',
    prerequisites: ['java_collections'],
  ),

  // 34. Set Interface & Implementations
  Topic(
    id: 'java_set',
    name: 'Set Interface & Implementations',
    subject: 'OOPs – Java',
    prerequisites: ['java_collections'],
  ),

  // 35. Map Interface & Implementations
  Topic(
    id: 'java_map',
    name: 'Map Interface & Implementations',
    subject: 'OOPs – Java',
    prerequisites: ['java_collections'],
  ),

  // 36. Multithreading Overview
  Topic(
    id: 'java_multithreading',
    name: 'Multithreading Overview',
    subject: 'OOPs – Java',
    prerequisites: ['java_classes_objects'],
  ),

  // 37. Thread Life Cycle
  Topic(
    id: 'java_thread_lifecycle',
    name: 'Thread Life Cycle',
    subject: 'OOPs – Java',
    prerequisites: ['java_multithreading'],
  ),

  // 38. Creating Threads
  Topic(
    id: 'java_creating_threads',
    name: 'Creating Threads (Runnable & Thread Class)',
    subject: 'OOPs – Java',
    prerequisites: ['java_multithreading', 'java_interfaces', 'java_inheritance'],
  ),

  // 39. Synchronization in Java
  Topic(
    id: 'java_synchronization',
    name: 'Synchronization in Java',
    subject: 'OOPs – Java',
    prerequisites: ['java_multithreading'],
  ),

  // 40. File I/O in Java
  Topic(
    id: 'java_file_io',
    name: 'File I/O in Java',
    subject: 'OOPs – Java',
    prerequisites: ['java_exception_handling', 'java_strings'],
  ),
];