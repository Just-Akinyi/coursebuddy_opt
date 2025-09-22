import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminCalendar extends StatelessWidget {
  const AdminCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final classQuery = FirebaseFirestore.instance
        .collection("calendars")
        .doc("master")
        .collection("classes")
        .where("status", isEqualTo: "approved");

    return Scaffold(
      appBar: AppBar(title: const Text("All Classes Calendar")),
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

// class AdminCalendar extends StatelessWidget {
//   const AdminCalendar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final query = FirebaseFirestore.instance
//         .collection("calendars")
//         .doc("master")
//         .collection("classes")
//         .where("status", isEqualTo: "approved");

//     return Scaffold(
//       appBar: AppBar(title: const Text("All Classes Calendar")),
//       body: RoleBasedCalendar(
//         classQuery: query,
//         title: "All Classes Calendar",
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:coursebuddy/services/role_based_calendar.dart';

// // class AdminCalendar extends StatelessWidget {
// //   const AdminCalendar({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final query = FirebaseFirestore.instance
// //         .collection("calendars")
// //         .doc("master")
// //         .collection("classes")
// //         .where("status", isEqualTo: "approved");

// //     return RoleBasedCalendar(classQuery: query, title: "All Classes Calendar");
// //   }
// // }



// // // import 'package:flutter/material.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';

// // // class AdminCalendar extends StatelessWidget {
// // //   const AdminCalendar({super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final classQuery = FirebaseFirestore.instance
// // //         .collection("calendars")
// // //         .doc("master")
// // //         .collection("classes")
// // //         .where("status", isEqualTo: "approved");

// // //     return Scaffold(
// // //       appBar: AppBar(title: const Text("All Classes Calendar")),
// // //       body: StreamBuilder<QuerySnapshot>(
// // //         stream: classQuery.snapshots(),
// // //         builder: (context, snapshot) {
// // //           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

// // //           final classes = snapshot.data!.docs;
// // //           if (classes.isEmpty) {
// // //             return const Center(child: Text("No classes in calendar."));
// // //           }

// // //           return ListView.builder(
// // //             itemCount: classes.length,
// // //             itemBuilder: (context, index) {
// // //               final data = classes[index].data() as Map<String, dynamic>;
// // //               return ListTile(
// // //                 title: Text(data["title"] ?? ""),
// // //                 subtitle: Text(data["date"] ?? ""),
// // //                 trailing: const Icon(Icons.admin_panel_settings),
// // //               );
// // //             },
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }
