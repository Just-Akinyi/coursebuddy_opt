import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Map<String, List<Map<String, String>>> events = {};

  @override
  void initState() {
    super.initState();
    _loadEventsForWeek();
  }

  Future<void> _loadEventsForWeek() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('calendars')
        .doc('master')
        .collection('classes')
        .where('status', isEqualTo: 'approved')
        .where('studentIds', arrayContains: userId)
        .get();

    final Map<String, List<Map<String, String>>> tempEvents = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['date'] != null) {
        final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(data['date']));
        tempEvents[dateKey] ??= [];
        tempEvents[dateKey]!.add({
          'title': data['title'] ?? 'Class',
          'time': data['time'] ?? '00:00 - 00:00',
          'icon': data['type'] == 'webinar' ? 'videocam' : 'event',
        });
      }
    }
    setState(() => events = tempEvents);
  }

  Future<String> _getStudentName() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data()?['name'] ?? "Student";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final bool isWide = width > 900;
          final bool isTablet = width > 600 && width <= 900;

          return SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 12 : (isWide ? 16 : 8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // 🔹 Greeting
                FutureBuilder<String>(
                  future: _getStudentName(),
                  builder: (context, snapshot) {
                    final name = snapshot.data ?? "Student";
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello, $name!",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 🔹 Progress cards
                isWide
                    ? Row(
                        children: [
                          Expanded(child: _progressCard("Attendance", "18/20", "You are on a good way!")),
                          const SizedBox(width: 12),
                          Expanded(child: _progressCard("Homework", "9/15", "Keep up your progress!")),
                          const SizedBox(width: 12),
                          Expanded(child: _progressCard("Rating", "70%", "Nice to go forward!")),
                          const SizedBox(width: 12),
                          Expanded(child: _progressCard("Classes completed", "2/6", "Great, a good start")),
                        ],
                      )
                    : Column(
                        children: [
                          _progressCard("Attendance", "18/20", "You are on a good way!"),
                          const SizedBox(height: 12),
                          _progressCard("Homework", "9/15", "Keep up your progress!"),
                          const SizedBox(height: 12),
                          _progressCard("Rating", "70%", "Nice to go forward!"),
                          const SizedBox(height: 12),
                          _progressCard("Classes completed", "2/6", "Great, a good start"),
                        ],
                      ),
                const SizedBox(height: 30),

                // 🔹 Week Calendar + Weekly Upcoming Events (adaptive)
                isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _weekCalendarList()),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: _upcomingWeekEvents()),
                        ],
                      )
                    : Column(
                        children: [
                          _weekCalendarList(),
                          const SizedBox(height: 16),
                          _upcomingWeekEvents(),
                        ],
                      ),
                const SizedBox(height: 16),
                // 🔹 Daily events below
                _dailyEvents(),
                const SizedBox(height: 16),
                // 🔹 Teachers section
                _teachersSection(),
                const SizedBox(height: 30),

                // 🔹 My Classes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("My classes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text("View more", style: TextStyle(color: Colors.blue, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 15),
                isWide
                    ? Row(
                        children: [
                          Expanded(child: _classCard("Data Science", "https://i.ibb.co/rmW3Q5J/datasci.jpg", 75, 50)),
                          const SizedBox(width: 16),
                          Expanded(child: _classCard("Artificial Intelligence", "https://i.ibb.co/SyJ9Yzn/ai.jpg", 80, 40)),
                          const SizedBox(width: 16),
                          Expanded(child: _classCard("Machine Learning", "https://i.ibb.co/tbDn1KQ/ml.jpg", 70, 30)),
                        ],
                      )
                    : Column(
                        children: [
                          _classCard("Data Science", "https://i.ibb.co/rmW3Q5J/datasci.jpg", 75, 50),
                          const SizedBox(height: 16),
                          _classCard("Artificial Intelligence", "https://i.ibb.co/SyJ9Yzn/ai.jpg", 80, 40),
                          const SizedBox(height: 16),
                          _classCard("Machine Learning", "https://i.ibb.co/tbDn1KQ/ml.jpg", 70, 30),
                        ],
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔹 Calendar List for week
  Widget _weekCalendarList() {
    final now = DateTime.now();
    final days = List.generate(7, (index) => now.add(Duration(days: index)));

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final dayKey = DateFormat('yyyy-MM-dd').format(day);
          final isSelected = selectedDay == dayKey;

          return GestureDetector(
            onTap: () => setState(() => selectedDay = dayKey),
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('E').format(day),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(day.day.toString(),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Weekly Upcoming Events
  Widget _upcomingWeekEvents() {
    final now = DateTime.now();
    final weekEvents = events.entries
        .where((e) {
          final date = DateTime.parse(e.key);
          return date.isAfter(now.subtract(const Duration(days: 1))) &&
              date.isBefore(now.add(const Duration(days: 7)));
        })
        .toList();

    if (weekEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Text("No classes this week", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Upcoming this week", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...weekEvents.map((e) {
            return Column(
              children: [
                ListTile(
                  leading: Icon(e.value.first['icon'] == 'videocam' ? Icons.videocam : Icons.event, color: Colors.blue),
                  title: Text(e.value.first['title']!),
                  subtitle: Text("${DateFormat('dd.MM.yyyy').format(DateTime.parse(e.key))}  ${e.value.first['time']}"),
                ),
                const Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  // 🔹 Daily Events
  Widget _dailyEvents() {
    final dayEvents = events[selectedDay] ?? [];
    if (dayEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Text("No class today", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...dayEvents.map((event) => Column(
                children: [
                  ListTile(
                    leading: Icon(event['icon'] == 'videocam' ? Icons.videocam : Icons.event, color: Colors.blue),
                    title: Text(event['title']!),
                    subtitle: Text(event['time']!),
                  ),
                  const Divider(),
                ],
              )),
        ],
      ),
    );
  }

  // 🔹 Progress Card
  static Widget _progressCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // 🔹 Teachers Section
  static Widget _teachersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Teachers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _teacherTile("Adam Potter", "Python Programming"),
          _teacherTile("Brian Green", "Data Science"),
          _teacherTile("Peter Nelson", "Artificial Intelligence"),
        ],
      ),
    );
  }

  static Widget _teacherTile(String name, String subject) {
    return ListTile(
      leading: CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$name")),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subject, style: const TextStyle(color: Colors.grey)),
      trailing: IconButton(icon: const Icon(Icons.message_outlined, color: Colors.blue), onPressed: () {}),
    );
  }

  // 🔹 Class Card
  static Widget _classCard(String title, String imageUrl, int theory, int practice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl, height: 100, fit: BoxFit.cover)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Theory"),
          LinearProgressIndicator(value: theory / 100),
          const SizedBox(height: 8),
          const Text("Practice"),
          LinearProgressIndicator(value: practice / 100),
        ],
      ),
    );
  }

  // 🔹 Shared Card Decoration
  static BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String selectedDay = DateFormat('yyyy-MM-dd').format(DateTime.now());
//   Map<String, List<Map<String, String>>> events = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadEventsForWeek();
//   }

//   Future<void> _loadEventsForWeek() async {
//     final userId = FirebaseAuth.instance.currentUser!.uid;

//     final snapshot = await FirebaseFirestore.instance
//         .collection('calendars')
//         .doc('master')
//         .collection('classes')
//         .where('status', isEqualTo: 'approved')
//         .where('studentIds', arrayContains: userId)
//         .get();

//     final Map<String, List<Map<String, String>>> tempEvents = {};

//     for (var doc in snapshot.docs) {
//       final data = doc.data();
//       if (data['date'] != null) {
//         final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(data['date']));
//         tempEvents[dateKey] ??= [];
//         tempEvents[dateKey]!.add({
//           'title': data['title'] ?? 'Class',
//           'time': data['time'] ?? '00:00 - 00:00',
//           'icon': data['type'] == 'webinar' ? 'videocam' : 'event',
//         });
//       }
//     }

//     setState(() {
//       events = tempEvents;
//     });
//   }

//   Future<String> _getStudentName() async {
//     final userId = FirebaseAuth.instance.currentUser!.uid;
//     final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
//     return doc.data()?['name'] ?? "Student";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final bool isWide = constraints.maxWidth > 900;

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 10),

//                 // 🔹 Greeting
//                 FutureBuilder<String>(
//                   future: _getStudentName(),
//                   builder: (context, snapshot) {
//                     final name = snapshot.data ?? "Student";
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Hello, $name!",
//                           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}",
//                           style: const TextStyle(color: Colors.grey),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),

//                 // 🔹 Progress cards
//                 isWide
//                     ? Row(
//                         children: [
//                           Expanded(child: _progressCard("Attendance", "18/20", "You are on a good way!")),
//                           const SizedBox(width: 12),
//                           Expanded(child: _progressCard("Homework", "9/15", "Keep up your progress!")),
//                           const SizedBox(width: 12),
//                           Expanded(child: _progressCard("Rating", "70%", "Nice to go forward!")),
//                           const SizedBox(width: 12),
//                           Expanded(child: _progressCard("Classes completed", "2/6", "Great, a good start")),
//                         ],
//                       )
//                     : Column(
//                         children: [
//                           _progressCard("Attendance", "18/20", "You are on a good way!"),
//                           const SizedBox(height: 12),
//                           _progressCard("Homework", "9/15", "Keep up your progress!"),
//                           const SizedBox(height: 12),
//                           _progressCard("Rating", "70%", "Nice to go forward!"),
//                           const SizedBox(height: 12),
//                           _progressCard("Classes completed", "2/6", "Great, a good start"),
//                         ],
//                       ),
//                 const SizedBox(height: 30),

//                 // 🔹 Calendar + Upcoming + Daily + Teachers
//                 _weekCalendar(),

//                 const SizedBox(height: 30),

//                 // 🔹 My Classes
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: const [
//                     Text("My classes", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                     Text("View more", style: TextStyle(color: Colors.blue, fontSize: 14)),
//                   ],
//                 ),
//                 const SizedBox(height: 15),
//                 isWide
//                     ? Row(
//                         children: [
//                           Expanded(child: _classCard("Data Science", "https://i.ibb.co/rmW3Q5J/datasci.jpg", 75, 50)),
//                           const SizedBox(width: 16),
//                           Expanded(child: _classCard("Artificial Intelligence", "https://i.ibb.co/SyJ9Yzn/ai.jpg", 80, 40)),
//                           const SizedBox(width: 16),
//                           Expanded(child: _classCard("Machine Learning", "https://i.ibb.co/tbDn1KQ/ml.jpg", 70, 30)),
//                         ],
//                       )
//                     : Column(
//                         children: [
//                           _classCard("Data Science", "https://i.ibb.co/rmW3Q5J/datasci.jpg", 75, 50),
//                           const SizedBox(height: 16),
//                           _classCard("Artificial Intelligence", "https://i.ibb.co/SyJ9Yzn/ai.jpg", 80, 40),
//                           const SizedBox(height: 16),
//                           _classCard("Machine Learning", "https://i.ibb.co/tbDn1KQ/ml.jpg", 70, 30),
//                         ],
//                       ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // 🔹 Week calendar
//   Widget _weekCalendar() {
//     final now = DateTime.now();
//     final days = List.generate(7, (index) => now.add(Duration(days: index)));

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           height: 80,
//           child: ListView.separated(
//             scrollDirection: Axis.horizontal,
//             itemCount: days.length,
//             separatorBuilder: (_, __) => const SizedBox(width: 8),
//             itemBuilder: (context, index) {
//               final day = days[index];
//               final dayKey = DateFormat('yyyy-MM-dd').format(day);
//               final isSelected = selectedDay == dayKey;

//               return GestureDetector(
//                 onTap: () => setState(() => selectedDay = dayKey),
//                 child: Container(
//                   width: 60,
//                   decoration: BoxDecoration(
//                     color: isSelected ? Colors.blue : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: const [
//                       BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
//                     ],
//                   ),
//                   padding: const EdgeInsets.all(8),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(DateFormat('E').format(day),
//                           style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 4),
//                       Text(day.day.toString(),
//                           style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//         const SizedBox(height: 16),
//         // Upcoming week events
//         _upcomingWeekEvents(),
//         const SizedBox(height: 16),
//         // Daily events for selected day
//         _dailyEvents(),
//         const SizedBox(height: 16),
//         // Teachers
//         _teachersSection(),
//       ],
//     );
//   }

//   // 🔹 Weekly Upcoming Events
//   Widget _upcomingWeekEvents() {
//     final now = DateTime.now();
//     final weekEvents = events.entries
//         .where((e) {
//           final date = DateTime.parse(e.key);
//           return date.isAfter(now.subtract(const Duration(days: 1))) &&
//               date.isBefore(now.add(const Duration(days: 7)));
//         })
//         .toList();

//     if (weekEvents.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: _cardDecoration(),
//         child: const Text("No classes this week", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Upcoming this week", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           ...weekEvents.map((e) {
//             return Column(
//               children: [
//                 ListTile(
//                   leading: Icon(
//                     e.value.first['icon'] == 'videocam' ? Icons.videocam : Icons.event,
//                     color: Colors.blue,
//                   ),
//                   title: Text(e.value.first['title']!),
//                   subtitle: Text("${DateFormat('dd.MM.yyyy').format(DateTime.parse(e.key))}  ${e.value.first['time']}"),
//                 ),
//                 const Divider(),
//               ],
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   // 🔹 Daily events
//   Widget _dailyEvents() {
//     final dayEvents = events[selectedDay] ?? [];
//     if (dayEvents.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(16),
//         decoration: _cardDecoration(),
//         child: const Text("No class today", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Today's events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           ...dayEvents.map((event) => Column(
//                 children: [
//                   ListTile(
//                     leading: Icon(
//                       event['icon'] == 'videocam' ? Icons.videocam : Icons.event,
//                       color: Colors.blue,
//                     ),
//                     title: Text(event['title']!),
//                     subtitle: Text(event['time']!),
//                   ),
//                   const Divider(),
//                 ],
//               )),
//         ],
//       ),
//     );
//   }

//   // 🔹 Progress Card
//   static Widget _progressCard(String title, String value, String subtitle) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: _cardDecoration(),
//       child: Column(
//         children: [
//           Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
//           const SizedBox(height: 8),
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(height: 4),
//           Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   // 🔹 Teachers Section
//   static Widget _teachersSection() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Teachers", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 15),
//           _teacherTile("Adam Potter", "Python Programming"),
//           _teacherTile("Brian Green", "Data Science"),
//           _teacherTile("Peter Nelson", "Artificial Intelligence"),
//         ],
//       ),
//     );
//   }

//   static Widget _teacherTile(String name, String subject) {
//     return ListTile(
//       leading: CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$name")),
//       title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//       subtitle: Text(subject, style: const TextStyle(color: Colors.grey)),
//       trailing: IconButton(icon: const Icon(Icons.message_outlined, color: Colors.blue), onPressed: () {}),
//     );
//   }

//   // 🔹 Class Card
//   static Widget _classCard(String title, String imageUrl, int theory, int practice) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: _cardDecoration(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(imageUrl, height: 100, fit: BoxFit.cover)),
//           const SizedBox(height: 12),
//           Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 12),
//           const Text("Theory"),
//           LinearProgressIndicator(value: theory / 100),
//           const SizedBox(height: 8),
//           const Text("Practice"),
//           LinearProgressIndicator(value: practice / 100),
//         ],
//       ),
//     );
//   }

//   // 🔹 Shared Card Decoration
//   static BoxDecoration _cardDecoration() {
//     return BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
//     );
//   }
// }


// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'student_calendar_week_view.dart'; // Import the week view

// // class HomeScreen extends StatelessWidget {
// //   const HomeScreen({super.key});

// //   Future<String> _getStudentName() async {
// //     final uid = FirebaseAuth.instance.currentUser!.uid;
// //     final doc = await FirebaseFirestore.instance.collection('students').doc(uid).get();
// //     return doc.data()?['name'] ?? "Student";
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       body: FutureBuilder<String>(
// //         future: _getStudentName(),
// //         builder: (context, snapshot) {
// //           final name = snapshot.data ?? "Student";

// //           return SingleChildScrollView(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const SizedBox(height: 20),

// //                 // 🔹 Greeting
// //                 Text(
// //                   "Hello, $name!",
// //                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   "${DateTime.now().day} ${DateTime.now().month}, ${DateFormat.EEEE().format(DateTime.now())}",
// //                   style: const TextStyle(color: Colors.grey),
// //                 ),
// //                 const SizedBox(height: 20),

// //                 // 🔹 Progress cards can go here (optional)
// //                 // ...

// //                 const SizedBox(height: 30),

// //                 // 🔹 Upcoming 7-day calendar + events
// //                 const Text(
// //                   "Upcoming events",
// //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 12),
// //                 const StudentCalendarWeekView(),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:table_calendar/table_calendar.dart';

// // class HomeScreen extends StatelessWidget {
// //   const HomeScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[100],
// //       body: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final bool isWide = constraints.maxWidth > 900;

// //           return SingleChildScrollView(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // 🔹 Top bar (Icons + Avatar)
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.end,
// //                   children: [
// //                     IconButton(
// //                       icon: const Icon(Icons.message_outlined),
// //                       onPressed: () {},
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.notifications_none),
// //                       onPressed: () {},
// //                     ),
// //                     const CircleAvatar(
// //                       backgroundImage: NetworkImage(
// //                         "https://i.pravatar.cc/150?img=3",
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 20),

// //                 // 🔹 Greeting
// //                 const Text(
// //                   "Hello, Alex!",
// //                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 const Text(
// //                   "June 7, Wednesday",
// //                   style: TextStyle(color: Colors.grey),
// //                 ),
// //                 const SizedBox(height: 20),

// //                 // 🔹 Progress cards
// //                 isWide
// //                     ? Row(
// //                         children: [
// //                           Expanded(
// //                             child: _progressCard(
// //                               "Attendance",
// //                               "18/20",
// //                               "You are on a good way!",
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Expanded(
// //                             child: _progressCard(
// //                               "Homework",
// //                               "9/15",
// //                               "Keep up your progress!",
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Expanded(
// //                             child: _progressCard(
// //                               "Rating",
// //                               "70%",
// //                               "Nice to go forward!",
// //                             ),
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Expanded(
// //                             child: _progressCard(
// //                               "Classes completed",
// //                               "2/6",
// //                               "Great, a good start",
// //                             ),
// //                           ),
// //                         ],
// //                       )
// //                     : Column(
// //                         children: [
// //                           _progressCard("Attendance", "18/20", "You are on a good way!"),
// //                           const SizedBox(height: 12),
// //                           _progressCard("Homework", "9/15", "Keep up your progress!"),
// //                           const SizedBox(height: 12),
// //                           _progressCard("Rating", "70%", "Nice to go forward!"),
// //                           const SizedBox(height: 12),
// //                           _progressCard("Classes completed", "2/6", "Great, a good start"),
// //                         ],
// //                       ),
// //                 const SizedBox(height: 30),

// //                 // 🔹 Schedule + Right side (Events + Teachers)
// //                 isWide
// //                     ? Row(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const Expanded(flex: 2, child: StudentCalendar()), // ✅ TableCalendar
// //                           const SizedBox(width: 20),
// //                           Expanded(
// //                             flex: 1,
// //                             child: Column(
// //                               children: [
// //                                 _upcomingEvents(),
// //                                 const SizedBox(height: 20),
// //                                 _teachersSection(),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       )
// //                     : Column(
// //                         children: [
// //                           const StudentCalendar(), // ✅ TableCalendar
// //                           const SizedBox(height: 20),
// //                           _upcomingEvents(),
// //                           const SizedBox(height: 20),
// //                           _teachersSection(),
// //                         ],
// //                       ),
// //                 const SizedBox(height: 30),

// //                 // 🔹 My classes
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: const [
// //                     Text(
// //                       "My classes",
// //                       style: TextStyle(
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     Text(
// //                       "View more",
// //                       style: TextStyle(color: Colors.blue, fontSize: 14),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 15),
// //                 isWide
// //                     ? Row(
// //                         children: [
// //                           Expanded(
// //                             child: _classCard(
// //                               "Data Science",
// //                               "https://i.ibb.co/rmW3Q5J/datasci.jpg",
// //                               75,
// //                               50,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 16),
// //                           Expanded(
// //                             child: _classCard(
// //                               "Artificial Intelligence",
// //                               "https://i.ibb.co/SyJ9Yzn/ai.jpg",
// //                               80,
// //                               40,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 16),
// //                           Expanded(
// //                             child: _classCard(
// //                               "Machine Learning",
// //                               "https://i.ibb.co/tbDn1KQ/ml.jpg",
// //                               70,
// //                               30,
// //                             ),
// //                           ),
// //                         ],
// //                       )
// //                     : Column(
// //                         children: [
// //                           _classCard(
// //                             "Data Science",
// //                             "https://i.ibb.co/rmW3Q5J/datasci.jpg",
// //                             75,
// //                             50,
// //                           ),
// //                           const SizedBox(height: 16),
// //                           _classCard(
// //                             "Artificial Intelligence",
// //                             "https://i.ibb.co/SyJ9Yzn/ai.jpg",
// //                             80,
// //                             40,
// //                           ),
// //                           const SizedBox(height: 16),
// //                           _classCard(
// //                             "Machine Learning",
// //                             "https://i.ibb.co/tbDn1KQ/ml.jpg",
// //                             70,
// //                             30,
// //                           ),
// //                         ],
// //                       ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // 🔹 Progress Card
// //   static Widget _progressCard(String title, String value, String subtitle) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: _cardDecoration(),
// //       child: Column(
// //         children: [
// //           Text(
// //             value,
// //             style: const TextStyle(
// //               fontSize: 20,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.blue,
// //             ),
// //           ),
// //           const SizedBox(height: 8),
// //           Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
// //           const SizedBox(height: 4),
// //           Text(
// //             subtitle,
// //             textAlign: TextAlign.center,
// //             style: TextStyle(color: Colors.grey[600], fontSize: 12),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // 🔹 Upcoming events
// //   static Widget _upcomingEvents() {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: _cardDecoration(),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: const [
// //               Text(
// //                 "Upcoming events",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //               ),
// //               Text(
// //                 "View more",
// //                 style: TextStyle(color: Colors.blue, fontSize: 14),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 15),
// //           ListTile(
// //             leading: Icon(Icons.videocam, color: Colors.blue),
// //             title: const Text("Webinar: AI and Big Data"),
// //             subtitle: const Text("08.06.2023   18:00 - 20:00"),
// //           ),
// //           const Divider(),
// //           ListTile(
// //             leading: Icon(Icons.event, color: Colors.blue),
// //             title: const Text("Conference: AI and Big Data"),
// //             subtitle: const Text("17.06.2023   10:00 - 15:00"),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // 🔹 Teachers
// //   static Widget _teachersSection() {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: _cardDecoration(),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: const [
// //               Text(
// //                 "Teachers",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //               ),
// //               Text(
// //                 "View more",
// //                 style: TextStyle(color: Colors.blue, fontSize: 14),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 15),
// //           _teacherTile("Adam Potter", "Python Programming"),
// //           _teacherTile("Brian Green", "Data Science"),
// //           _teacherTile("Peter Nelson", "Artificial Intelligence"),
// //         ],
// //       ),
// //     );
// //   }

// //   static Widget _teacherTile(String name, String subject) {
// //     return ListTile(
// //       leading: CircleAvatar(
// //         backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=$name"),
// //       ),
// //       title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
// //       subtitle: Text(subject, style: const TextStyle(color: Colors.grey)),
// //       trailing: IconButton(
// //         icon: const Icon(Icons.message_outlined, color: Colors.blue),
// //         onPressed: () {},
// //       ),
// //     );
// //   }

// //   // 🔹 Class Card
// //   static Widget _classCard(
// //     String title,
// //     String imageUrl,
// //     int theory,
// //     int practice,
// //   ) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: _cardDecoration(),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(12),
// //             child: Image.network(imageUrl, height: 100, fit: BoxFit.cover),
// //           ),
// //           const SizedBox(height: 12),
// //           Text(
// //             title,
// //             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //           ),
// //           const SizedBox(height: 12),
// //           const Text("Theory"),
// //           LinearProgressIndicator(value: theory / 100),
// //           const SizedBox(height: 8),
// //           const Text("Practice"),
// //           LinearProgressIndicator(value: practice / 100),
// //         ],
// //       ),
// //     );
// //   }

// //   // 🔹 Shared Card Decoration
// //   static BoxDecoration _cardDecoration() {
// //     return BoxDecoration(
// //       color: Colors.white,
// //       borderRadius: BorderRadius.circular(16),
// //       boxShadow: [
// //         BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
// //       ],
// //     );
// //   }
// // }

// // // ✅ StudentCalendar with TableCalendar
// // class StudentCalendar extends StatelessWidget {
// //   const StudentCalendar({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final userId = FirebaseAuth.instance.currentUser!.uid;

// //     final classQuery = FirebaseFirestore.instance
// //         .collection("calendars")
// //         .doc("master")
// //         .collection("classes")
// //         .where("status", isEqualTo: "approved")
// //         .where("studentIds", arrayContains: userId);

// //     return StreamBuilder<QuerySnapshot>(
// //       stream: classQuery.snapshots(),
// //       builder: (context, snapshot) {
// //         final events = <DateTime, List>{};

// //         if (snapshot.hasData) {
// //           for (var doc in snapshot.data!.docs) {
// //             final data = doc.data() as Map<String, dynamic>;
// //             if (data["date"] != null) {
// //               final date = DateTime.parse(data["date"]);
// //               events[date] = [...(events[date] ?? []), data["title"]];
// //             }
// //           }
// //         }

// //         return TableCalendar(
// //           focusedDay: DateTime.now(),
// //           firstDay: DateTime.utc(2020, 1, 1),
// //           lastDay: DateTime.utc(2030, 12, 31),
// //           eventLoader: (day) => events[day] ?? [],
// //           calendarStyle: const CalendarStyle(
// //             todayDecoration: BoxDecoration(
// //               color: Colors.orangeAccent,
// //               shape: BoxShape.circle,
// //             ),
// //             markerDecoration: BoxDecoration(
// //               color: Colors.lightBlueAccent,
// //               shape: BoxShape.circle,
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
