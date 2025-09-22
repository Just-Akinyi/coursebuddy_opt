import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class RoleBasedCalendar extends StatefulWidget {
  final Query classQuery; // Firestore query depending on role
  final String title;

  const RoleBasedCalendar({
    super.key,
    required this.classQuery,
    required this.title,
  });

  @override
  State<RoleBasedCalendar> createState() => _RoleBasedCalendarState();
}

class _RoleBasedCalendarState extends State<RoleBasedCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> events = {};

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.classQuery.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // build event map
        events.clear();
        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final DateTime date = DateTime.parse(data["date"]);
          if (events[date] == null) events[date] = [];
          events[date]!.add(data);
        }

        final selectedEvents = events[_selectedDay] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => events[day] ?? [],
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
            ),

            const Divider(),
            Expanded(
              child: selectedEvents.isEmpty
                  ? const Center(child: Text("No events for this day."))
                  : ListView.builder(
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final data = selectedEvents[index];
                        return ListTile(
                          title: Text(data["title"] ?? ""),
                          subtitle: Text(data["description"] ?? ""),
                          trailing: const Icon(Icons.event),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:table_calendar/table_calendar.dart';

// class RoleBasedCalendar extends StatefulWidget {
//   final Query classQuery; // Firestore query depending on role
//   final String title;

//   const RoleBasedCalendar({
//     super.key,
//     required this.classQuery,
//     required this.title,
//   });

//   @override
//   State<RoleBasedCalendar> createState() => _RoleBasedCalendarState();
// }

// class _RoleBasedCalendarState extends State<RoleBasedCalendar> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   Map<DateTime, List<Map<String, dynamic>>> events = {};

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: widget.classQuery.snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // build event map
//         events.clear();
//         for (var doc in snapshot.data!.docs) {
//           final data = doc.data() as Map<String, dynamic>;
//           final DateTime date = DateTime.parse(data["date"]);
//           if (events[date] == null) events[date] = [];
//           events[date]!.add(data);
//         }

//         final selectedEvents = events[_selectedDay] ?? [];

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.title,
//                 style: const TextStyle(
//                     fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),

//             TableCalendar(
//               firstDay: DateTime.utc(2020, 1, 1),
//               lastDay: DateTime.utc(2030, 12, 31),
//               focusedDay: _focusedDay,
//               selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
//               eventLoader: (day) => events[day] ?? [],
//               onDaySelected: (selected, focused) {
//                 setState(() {
//                   _selectedDay = selected;
//                   _focusedDay = focused;
//                 });
//               },
//             ),

//             const Divider(),
//             Expanded(
//               child: selectedEvents.isEmpty
//                   ? const Center(child: Text("No events for this day."))
//                   : ListView.builder(
//                       itemCount: selectedEvents.length,
//                       itemBuilder: (context, index) {
//                         final data = selectedEvents[index];
//                         return ListTile(
//                           title: Text(data["title"] ?? ""),
//                           subtitle: Text(data["description"] ?? ""),
//                           trailing: const Icon(Icons.event),
//                         );
//                       },
//                     ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:table_calendar/table_calendar.dart';

// // class RoleBasedCalendar extends StatefulWidget {
// //   final Query classQuery; // pass Firestore query depending on role
// //   final String title;

// //   const RoleBasedCalendar({super.key, required this.classQuery, required this.title});

// //   @override
// //   State<RoleBasedCalendar> createState() => _RoleBasedCalendarState();
// // }

// // class _RoleBasedCalendarState extends State<RoleBasedCalendar> {
// //   DateTime _focusedDay = DateTime.now();
// //   DateTime? _selectedDay;
// //   Map<DateTime, List<Map<String, dynamic>>> events = {};

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text(widget.title)),
// //       body: StreamBuilder<QuerySnapshot>(
// //         stream: widget.classQuery.snapshots(),
// //         builder: (context, snapshot) {
// //           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

// //           // build event map
// //           events.clear();
// //           for (var doc in snapshot.data!.docs) {
// //             final data = doc.data() as Map<String, dynamic>;
// //             final DateTime date = DateTime.parse(data["date"]);
// //             if (events[date] == null) events[date] = [];
// //             events[date]!.add(data);
// //           }

// //           final selectedEvents = events[_selectedDay] ?? [];

// //           return Column(
// //             children: [
// //               TableCalendar(
// //                 firstDay: DateTime.utc(2020, 1, 1),
// //                 lastDay: DateTime.utc(2030, 12, 31),
// //                 focusedDay: _focusedDay,
// //                 selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
// //                 eventLoader: (day) => events[day] ?? [],
// //                 onDaySelected: (selected, focused) {
// //                   setState(() {
// //                     _selectedDay = selected;
// //                     _focusedDay = focused;
// //                   });
// //                 },
// //               ),
// //               const Divider(),
// //               Expanded(
// //                 child: selectedEvents.isEmpty
// //                     ? const Center(child: Text("No events for this day."))
// //                     : ListView.builder(
// //                         itemCount: selectedEvents.length,
// //                         itemBuilder: (context, index) {
// //                           final data = selectedEvents[index];
// //                           return ListTile(
// //                             title: Text(data["title"] ?? ""),
// //                             subtitle: Text(data["description"] ?? ""),
// //                             trailing: const Icon(Icons.event),
// //                           );
// //                         },
// //                       ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
