import 'package:flutter/material.dart';
import 'package:dyslexify/Components/Drawer_navigation.dart';

class DyslexiaInfoPage extends StatefulWidget {
  const DyslexiaInfoPage({super.key});

  @override
  State<DyslexiaInfoPage> createState() => _DyslexiaInfoPageState();
}

class _DyslexiaInfoPageState extends State<DyslexiaInfoPage> {
  int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2C3A),
        elevation: 4,
        leadingWidth: 80,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'About Dyslexia',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child:
                  const Icon(Icons.info_outline, size: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(
        onItemSelected: (index) {
          Navigator.pop(context);
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/reports');
              break;
            case 2:
              Navigator.pushNamed(context, '/about');
              break;
            case 3:
              Navigator.pushNamed(context, '/contact');
              break;
            case 4:
              Navigator.pushNamed(context, '/faq');
              break;
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/reports');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoCard(
              title: "What is Dyslexia?",
              description:
                  "Dyslexia is a specific learning disorder that primarily affects a person's ability to read, spell, write, and sometimes speak. It is not a sign of low intelligence or laziness. Individuals with dyslexia often have average or above-average intelligence but struggle with language processing.",
            ),
            infoCard(
              title: "How Dyslexia Affects Learning",
              description:
                  "People with dyslexia may read slowly, make frequent errors, and struggle with spelling and writing. It can affect comprehension, the ability to follow instructions, verbal memory, and written organization.",
              image: 'assets/images/child.png',
            ),
            questionCard(
              "Do you often reverse letters like 'b' and 'd' when reading or writing?",
            ),
            infoCard(
              title: "Age Group & Gender Trends",
              description:
                  "Dyslexia is usually noticed between ages 5 and 7 when children start reading. Boys are diagnosed more often than girls (around 2:1 or 3:1), though girls may be underdiagnosed due to fewer disruptive behaviors.",
            ),
            infoCard(
              title: "Global Ratio and Diagnosis Trend",
              description:
                  "An estimated 5% to 15% of people worldwide have dyslexia. With rising awareness and screening, diagnosis rates are increasing—not because dyslexia is becoming more common, but because it is better understood.",
              image: 'assets/images/piechart.jpg',
            ),
            infoCard(
              title: "Related Conditions",
              description:
                  "• Dysgraphia: Affects handwriting and written expression.\n• Dyscalculia: Difficulty in understanding numbers and math-related tasks.",
            ),
            infoCard(
              title: "Dyslexia Based Institute in Pakistan",
              description:
                  "IDEAS Pakistan is a leading organization dedicated to supporting individuals with dyslexia and related learning difficulties. They provide:\n\n• Comprehensive assessments\n• Personalized remedial therapy\n• Training for teachers and parents\n• Awareness workshops",
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget infoCard({
    required String title,
    required String description,
    String? image,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  color: Colors.green,
                  margin: const EdgeInsets.only(right: 8),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (image != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget questionCard(String question) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 24,
              color: Colors.green,
              margin: const EdgeInsets.only(right: 8),
            ),
            const Icon(Icons.question_answer_outlined,
                color: Colors.deepOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
