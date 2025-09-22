import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  Widget _buildSection({
    required String title,
    required String status,
    required bool showActions,
  }) {
    return ExpansionTile(
      initiallyExpanded: false, // 🔹 collapsed by default
      title: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('notes')
              .where('status', isEqualTo: status)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(12.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("No $title"),
              );
            }

            final docs = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(data['title'] ?? ''),
                    subtitle: Text(data['content'] ?? ''),
                    trailing: showActions
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: () {
                                  doc.reference.update({"status": "approved"});
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  doc.reference.update({"status": "rejected"});
                                },
                              ),
                            ],
                          )
                        : (status == "rejected"
                            ? IconButton(
                                icon: const Icon(Icons.restore,
                                    color: Colors.orange),
                                tooltip: "Restore to waiting",
                                onPressed: () {
                                  doc.reference
                                      .update({"status": "waiting_approval"});
                                },
                              )
                            : null),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSection(
          title: "Pending Materials",
          status: "waiting_approval",
          showActions: true,
        ),
        _buildSection(
          title: "Approved Materials",
          status: "approved",
          showActions: false,
        ),
        _buildSection(
          title: "Rejected Materials",
          status: "rejected",
          showActions: false,
        ),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AdminApprovalScreen extends StatelessWidget {
//   const AdminApprovalScreen({super.key});

//   Future<void> _updateStatus(String docId, String status) async {
//     await FirebaseFirestore.instance
//         .collection('notes')
//         .doc(docId)
//         .update({"status": status});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Approve Materials")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('notes')
//             .where("status", isEqualTo: "waiting_approval")
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final docs = snapshot.data!.docs;

//           if (docs.isEmpty) {
//             return const Center(child: Text("No pending approvals"));
//           }

//           return ListView.builder(
//             padding: const EdgeInsets.all(12),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final doc = docs[index];
//               final data = doc.data() as Map<String, dynamic>;

//               return Card(
//                 margin: const EdgeInsets.only(bottom: 12),
//                 child: ListTile(
//                   title: Text(data["title"] ?? "Untitled"),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(data["content"] ?? ""),
//                       const SizedBox(height: 8),
//                       Text(
//                         data["exampleCode"] ?? "",
//                         style: const TextStyle(
//                           fontFamily: "monospace",
//                           color: Colors.blueGrey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   isThreeLine: true,
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.check_circle, color: Colors.green),
//                         onPressed: () => _updateStatus(doc.id, "approved"),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.cancel, color: Colors.red),
//                         onPressed: () => _updateStatus(doc.id, "rejected"),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
