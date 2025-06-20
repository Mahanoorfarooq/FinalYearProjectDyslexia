import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': 'Can dyslexia be cured?',
        'answer':
            'Dyslexia is a lifelong condition, but with the right support and strategies, individuals can learn to manage and succeed.',
      },
      {
        'question': 'Is dyslexia genetic?',
        'answer':
            'Yes, dyslexia often runs in families, suggesting a genetic link.',
      },
      {
        'question': 'How can schools support children with dyslexia?',
        'answer':
            'Schools can provide individualized learning plans, use multi-sensory teaching techniques, and offer accommodations such as extra time on tests.',
      },
      {
        'question': 'What signs should parents look for?',
        'answer':
            'Signs include letter reversals, difficulty rhyming, slow reading, and problems with spelling and writing.',
      },
      {
        'question': 'Is dyslexia the same as a reading delay?',
        'answer':
            'No, dyslexia is a specific learning difficulty that affects reading despite normal intelligence and education.',
      },
      {
        'question': 'Are there any tools or technologies that help?',
        'answer':
            'Yes, tools like text-to-speech apps, audiobooks, and specialized fonts can support learning.',
      },
      {
        'question': 'Can adults have undiagnosed dyslexia?',
        'answer':
            'Absolutely. Many adults may never have been diagnosed but still experience reading and writing difficulties.',
      },
      {
        'question': 'How is dyslexia diagnosed?',
        'answer':
            'A licensed psychologist or educational specialist can conduct a comprehensive assessment.',
      },
      {
        'question': 'What interventions are most effective?',
        'answer':
            'Structured literacy programs and one-on-one tutoring are proven to be effective.',
      },
      {
        'question': 'Can a person with dyslexia succeed academically?',
        'answer':
            'Yes! With the right support, many people with dyslexia excel in school and beyond.',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
        title: const Text(
          'FAQ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: const Icon(Icons.help_outline, color: Colors.blue),
              title: Text(
                faq['question']!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    faq['answer']!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
