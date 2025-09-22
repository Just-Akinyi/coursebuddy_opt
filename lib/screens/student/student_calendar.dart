import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StudentCalendarWeekView extends StatelessWidget {
  const StudentCalendarWeekView({super.key});

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

        final now = DateTime.now();
        final weekDays = List.generate(7, (i) => now.add(Duration(days: i)));

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weekDays.length,
            itemBuilder: (context, index) {
              final day = weekDays[index];
              final dayEvents = events[DateTime(day.year, day.month, day.day)] ?? [];
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DateFormat.E().format(day), // Mon, Tue...
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("${day.day}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (dayEvents.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.lightBlueAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:table_calendar/table_calendar.dart';

// class StudentCalendar extends StatelessWidget {
//   const StudentCalendar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final currentUserId = FirebaseAuth.instance.currentUser!.uid;

//     // Query approved classes/events for this student
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

//         return TableCalendar(
//           focusedDay: DateTime.now(),
//           firstDay: DateTime.utc(2020, 1, 1),
//           lastDay: DateTime.utc(2030, 12, 31),
//           eventLoader: (day) => events[day] ?? [],
//           calendarStyle: const CalendarStyle(
//             todayDecoration: BoxDecoration(
//               color: Colors.orangeAccent,
//               shape: BoxShape.circle,
//             ),
//             markerDecoration: BoxDecoration(
//               color: Colors.lightBlueAccent,
//               shape: BoxShape.circle,
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:table_calendar/table_calendar.dart';

// class StudentCalendar extends StatelessWidget {
//   final String studentId;
//   const StudentCalendar({super.key, required this.studentId});

//   @override
//   Widget build(BuildContext context) {
//     final classQuery = FirebaseFirestore.instance
//         .collection("calendars")
//         .doc("master")
//         .collection("classes")
//         .where("status", isEqualTo: "approved")
//         .where("studentIds", arrayContains: studentId);

//     return Scaffold(
//       appBar: AppBar(title: const Text("My Classes")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: classQuery.snapshots(),
//         builder: (context, snapshot) {
//           final events = <DateTime, List>{};

//           if (snapshot.hasData) {
//             for (var doc in snapshot.data!.docs) {
//               final data = doc.data() as Map<String, dynamic>;
//               if (data["date"] != null) {
//                 final date = DateTime.parse(data["date"]);
//                 events[date] = [...(events[date] ?? []), data["title"]];
//               }
//             }
//           }

//           return TableCalendar(
//             focusedDay: DateTime.now(),
//             firstDay: DateTime.utc(2020, 1, 1),
//             lastDay: DateTime.utc(2030, 12, 31),
//             eventLoader: (day) => events[day] ?? [],
//             calendarStyle: const CalendarStyle(
//               todayDecoration: BoxDecoration(
//                 color: Colors.orangeAccent,
//                 shape: BoxShape.circle,
//               ),
//               markerDecoration: BoxDecoration(
//                 color: Colors.lightBlueAccent,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:coursebuddy/services/role_based_calendar.dart';

// // class StudentCalendar extends StatelessWidget {
// //   final String studentId;
// //   const StudentCalendar({super.key, required this.studentId});

// //   @override
// //   Widget build(BuildContext context) {
// //     final query = FirebaseFirestore.instance
// //         .collection("calendars")
// //         .doc("master")
// //         .collection("classes")
// //         .where("status", isEqualTo: "approved")
// //         .where("studentIds", arrayContains: studentId);

// //     return RoleBasedCalendar(
// //       classQuery: query,
// //       title: "My Classes",
// //     );
// //   }
// // }

// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:coursebuddy/services/role_based_calendar.dart';

// // // class StudentCalendar extends StatelessWidget {
// // //   const StudentCalendar({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final userId = FirebaseAuth.instance.currentUser!.uid;

// // //     final query = FirebaseFirestore.instance
// // //         .collection("calendars")
// // //         .doc("master")
// // //         .collection("classes")
// // //         .where("status", isEqualTo: "approved")
// // //         .where("studentIds", arrayContains: userId);

// // //     return RoleBasedCalendar(classQuery: query, title: "My Calendar");
// // //   }
// // // }
