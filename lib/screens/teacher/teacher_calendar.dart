import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class TeacherCalendar extends StatelessWidget {
  final String teacherId;
  const TeacherCalendar({super.key, required this.teacherId});

  @override
  Widget build(BuildContext context) {
    final classQuery = FirebaseFirestore.instance
        .collection("calendars")
        .doc("master")
        .collection("classes")
        .where("status", isEqualTo: "approved")
        .where("teacherId", isEqualTo: teacherId);

    return Scaffold(
      appBar: AppBar(title: const Text("My Classes Calendar")),
      body: StreamBuilder<QuerySnapshot>(
        stream: classQuery.snapshots(),
        builder: (context, snapshot) {
          final events = <DateTime, List>{};

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data["date"] != null) {
                final date = DateTime.parse(data["date"]);
                events[date] = [...(events[date] ?? []), data["title"]];
              }
            }
          }

          return TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            eventLoader: (day) => events[day] ?? [],
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
          );
        },
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:coursebuddy/services/role_based_calendar.dart';

// class TeacherCalendar extends StatelessWidget {
//   final String teacherId;
//   const TeacherCalendar({super.key, required this.teacherId});

//   @override
//   Widget build(BuildContext context) {
//     final query = FirebaseFirestore.instance
//         .collection("calendars")
//         .doc("master")
//         .collection("classes")
//         .where("status", isEqualTo: "approved")
//         .where("teacherId", isEqualTo: teacherId);

//     return Scaffold(
//       appBar: AppBar(title: const Text("My Classes Calendar")),
//       body: RoleBasedCalendar(
//         classQuery: query,
//         title: "My Classes",
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:coursebuddy/services/role_based_calendar.dart';


// // class TeacherCalendar extends StatelessWidget {
// //   const TeacherCalendar({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final userId = FirebaseAuth.instance.currentUser!.uid;

// //     final query = FirebaseFirestore.instance
// //         .collection("calendars")
// //         .doc("master")
// //         .collection("classes")
// //         .where("status", isEqualTo: "approved")
// //         .where("teacherIds", arrayContains: userId);

// //     return RoleBasedCalendar(classQuery: query, title: "Classes I Teach");
// //   }
// // }
