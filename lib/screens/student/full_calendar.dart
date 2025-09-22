// You can optimize further by:

// Limiting queries to a date range (e.g., next 30–60 days).

// Using const widgets where possible.

// Caching Firestore snapshots if needed.


// ----------------------------
// StudentCalendarPage.dart
// Fully adaptive calendar page
// ----------------------------
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class StudentCalendarPage extends StatelessWidget {
  const StudentCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final eventsQuery = FirebaseFirestore.instance
        .collection("calendars")
        .doc("master")
        .collection("classes")
        .where("status", isEqualTo: "approved")
        .where("studentIds", arrayContains: currentUserId);

    return StreamBuilder<QuerySnapshot>(
      stream: eventsQuery.snapshots(),
      builder: (context, snapshot) {
        final Map<DateTime, List<String>> events = {};

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data["date"] != null && data["title"] != null) {
              final eventDate = DateTime.parse(data["date"]);
              events[eventDate] = [...(events[eventDate] ?? []), data["title"]];
            }
          }
        }

        final width = MediaQuery.of(context).size.width;

        if (width < 600) {
          // Mobile: Column layout
          return Column(
            children: [
              TableCalendar(
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                eventLoader: (day) =>
                    events[DateTime(day.year, day.month, day.day)] ?? [],
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    "Select a date to see events here",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          );
        } else {
          // Wide: Row layout
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  eventLoader: (day) =>
                      events[DateTime(day.year, day.month, day.day)] ?? [],
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Center(
                  child: Text(
                    "Select a date to see events here",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:table_calendar/table_calendar.dart';

// class StudentCalendarPage extends StatelessWidget {
//   const StudentCalendarPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//     final eventsQuery = FirebaseFirestore.instance
//         .collection("calendars")
//         .doc("master")
//         .collection("classes")
//         .where("status", isEqualTo: "approved")
//         .where("studentIds", arrayContains: currentUserId);

//     return StreamBuilder<QuerySnapshot>(
//       stream: eventsQuery.snapshots(),
//       builder: (context, snapshot) {
//         final Map<DateTime, List<String>> events = {};

//         if (snapshot.hasData) {
//           for (var doc in snapshot.data!.docs) {
//             final data = doc.data() as Map<String, dynamic>;
//             if (data["date"] != null && data["title"] != null) {
//               final eventDate = DateTime.parse(data["date"]);
//               events[eventDate] = [...(events[eventDate] ?? []), data["title"]];
//             }
//           }
//         }

//         return Row(
//           children: [
//             Expanded(
//               flex: 3, // left part of screen
//               child: TableCalendar(
//                 focusedDay: DateTime.now(),
//                 firstDay: DateTime.utc(2020, 1, 1),
//                 lastDay: DateTime.utc(2030, 12, 31),
//                 eventLoader: (day) => events[DateTime(day.year, day.month, day.day)] ?? [],
//                 calendarStyle: const CalendarStyle(
//                   todayDecoration: BoxDecoration(
//                     color: Colors.orangeAccent,
//                     shape: BoxShape.circle,
//                   ),
//                   markerDecoration: BoxDecoration(
//                     color: Colors.lightBlueAccent,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ),
//             Expanded(
//               flex: 5,
//               child: Center(
//                 child: Text(
//                   "Select a date to see events here",
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ),
//             )
//           ],
//         );
//       },
//     );
//   }
// }
