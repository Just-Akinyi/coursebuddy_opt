import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> completeLesson(String userId, String lessonId) async {
  final userRef =
      FirebaseFirestore.instance.collection("users").doc(userId);
  final lessonRef =
      FirebaseFirestore.instance.collection("lessons").doc(lessonId);

  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final userSnap = await transaction.get(userRef);
    final lessonSnap = await transaction.get(lessonRef);

    final data = userSnap.data() as Map<String, dynamic>;
    final completed = List<String>.from(data["completedLessons"] ?? []);
    final badges = List<String>.from(data["badges"] ?? []);

    if (completed.contains(lessonId)) return; // already done

    final int currentXp = data["xp"] ?? 0;
    final int lessonXp = lessonSnap["xpReward"] ?? 0;
    const int xpPerLevel = 100; // ✅ hardcode or store in user doc

    // ✅ Update XP & Level
    final newXp = currentXp + lessonXp;
    final newLevel = (newXp ~/ xpPerLevel) + 1;

    completed.add(lessonId);

    // ✅ Auto-award badges
    if (!badges.contains("First Lesson Completed") && completed.length >= 1) {
      badges.add("First Lesson Completed");
    }

    // Example: award "Loops Master" after 3 loop lessons
    final loopLessonsDone =
        completed.where((id) => id.startsWith("loop")).length;
    if (loopLessonsDone >= 3 && !badges.contains("Loops Master")) {
      badges.add("Loops Master");
    }

    // ✅ Commit updates
    transaction.update(userRef, {
      "xp": newXp,
      "level": newLevel,
      "completedLessons": completed,
      "badges": badges,
    });
  });
}
