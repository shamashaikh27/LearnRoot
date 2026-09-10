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