import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 800; // 🔹 breakpoint

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isSmallScreen
          ? _buildMobileLayout()
          : _buildDesktopLayout(),
    );
  }

  // ---------------- DESKTOP LAYOUT ----------------
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Left main dashboard
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _welcomeCard(),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _studentsCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _workingHoursCard()),
                  ],
                ),
                const SizedBox(height: 20),
                _lessonsCard(),
              ],
            ),
          ),
        ),

        // 🔹 Right sidebar
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _calendarCard(),
                const SizedBox(height: 20),
                _tasksCard("Upcoming Lessons", [
                  "Common English - 9:00 AM",
                  "Business English - 11:00 AM",
                ]),
                const SizedBox(height: 20),
                _tasksCard("Completed Tasks", [
                  "Grammar Worksheet",
                  "Vocabulary Quiz",
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- MOBILE LAYOUT ----------------
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _welcomeCard(),
          const SizedBox(height: 20),
          _studentsCard(),
          const SizedBox(height: 20),
          _workingHoursCard(),
          const SizedBox(height: 20),
          _lessonsCard(),
          const SizedBox(height: 20),
          _calendarCard(),
          const SizedBox(height: 20),
          _tasksCard("Upcoming Lessons", [
            "Common English - 9:00 AM",
            "Business English - 11:00 AM",
          ]),
          const SizedBox(height: 20),
          _tasksCard("Completed Tasks", [
            "Grammar Worksheet",
            "Vocabulary Quiz",
          ]),
        ],
      ),
    );
  }

  // ---------------- CARDS (same as yours) ----------------
  Widget _welcomeCard() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.orange[200],
                child: const Icon(Icons.person, size: 32, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Welcome Back, Teacher!",
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Your students completed 80% of tasks. Progress is very good!",
                        style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _studentsCard() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("My Students",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildStudentRow("Amelia Calder", 95),
              _buildStudentRow("Estelle Baldwin", 75),
              _buildStudentRow("Amanda Wood", 60),
              _buildStudentRow("Lilly Tano", 85),
            ],
          ),
        ),
      );

  Widget _workingHoursCard() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text("Working Hours",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blueAccent,
                child: Text("84%",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              SizedBox(height: 8),
              Text("Progress vs Done", style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );

  Widget _lessonsCard() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Lessons",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              _buildLessonRow("Common English", "Cambridge.pdf", "Only view",
                  "48 members", "28 MB"),
              _buildLessonRow("Business English", "Dictionary.pdf", "Edit available",
                  "30 members", "65 MB"),
              _buildLessonRow("Spanish Grammar", "Easy Learning.zip", "Only view",
                  "63 members", "48 MB"),
            ],
          ),
        ),
      );

  Widget _calendarCard() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text("September 2025",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
                itemCount: 30,
                itemBuilder: (_, i) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == 20 ? Colors.orangeAccent : Colors.grey[200],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text("${i + 1}"),
                  );
                },
              ),
            ],
          ),
        ),
      );

  Widget _tasksCard(String title, List<String> items) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const Divider(),
              ...items.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text("• $e"),
                  )),
            ],
          ),
        ),
      );

  // ---------------- HELPERS ----------------
  Widget _buildStudentRow(String name, int percent) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(name)),
            SizedBox(
              width: 80,
              child: LinearProgressIndicator(
                value: percent / 100,
                color: Colors.orangeAccent,
                backgroundColor: Colors.grey[200],
              ),
            ),
            const SizedBox(width: 8),
            Text("$percent%"),
          ],
        ),
      );

  Widget _buildLessonRow(
      String title, String file, String access, String members, String size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child:
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(file, overflow: TextOverflow.ellipsis)),
          Expanded(child: Text(access, style: const TextStyle(color: Colors.orange))),
          Expanded(child: Text(members)),
          Expanded(child: Text(size)),
        ],
      ),
    );
  }
}
