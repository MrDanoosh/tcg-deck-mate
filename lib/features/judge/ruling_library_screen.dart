
import 'package:flutter/material.dart';

class JudgeRuling {
  final String title;
  final String category;
  final String question;
  final String answer;
  final String status;
  final List<String> keywords;

  const JudgeRuling({
    required this.title,
    required this.category,
    required this.question,
    required this.answer,
    required this.status,
    required this.keywords,
  });
}

class RulingLibraryScreen extends StatefulWidget {
  const RulingLibraryScreen({super.key});

  @override
  State<RulingLibraryScreen> createState() =>
      _RulingLibraryScreenState();
}

class _RulingLibraryScreenState
    extends State<RulingLibraryScreen> {

  final TextEditingController searchController =
      TextEditingController();

  String selectedCategory = 'All';

  final List<JudgeRuling> rulings = const [
    JudgeRuling(
      title: 'Knocked Out Pokémon',
      category: 'Knock Outs',
      question:
          'What happens when a Pokémon is Knocked Out during an attack?',
      answer:
          'This is a practice topic. Check the official TCG '
          'rules and tournament documents for the applicable '
          'Knock Out sequence, triggered effects and Prize card '
          'procedures before making a tournament ruling.',
      status: 'Study example',
      keywords: ['knockout', 'prize', 'attack', 'pokemon'],
    ),
    JudgeRuling(
      title: 'Ability Interactions',
      category: 'Abilities',
      question:
          'How should judges approach two interacting Abilities?',
      answer:
          'Identify when each Ability is triggered, whether its '
          'conditions are still satisfied, and the order in which '
          'the relevant effects are resolved. Verify the exact '
          'interaction against the card text and official rules.',
      status: 'Study example',
      keywords: ['ability', 'trigger', 'interaction', 'effect'],
    ),
    JudgeRuling(
      title: 'Special Conditions',
      category: 'Special Conditions',
      question:
          'When are Special Conditions checked during a game?',
      answer:
          'Review the official Pokémon TCG rules for the '
          'between-turns procedure and the individual Special '
          'Conditions. Do not rely on this practice entry as '
          'an official ruling.',
      status: 'Study example',
      keywords: ['poisoned', 'burned', 'asleep', 'paralyzed'],
    ),
    JudgeRuling(
      title: 'Attack Resolution',
      category: 'Attacks',
      question:
          'What should a judge consider when resolving an attack?',
      answer:
          'Check the attack requirements, effects, damage '
          'calculation and any relevant replacement or prevention '
          'effects. Follow the official rules and card text for '
          'the exact situation.',
      status: 'Study example',
      keywords: ['attack', 'damage', 'effects', 'weakness'],
    ),
  ];

  List<JudgeRuling> get filteredRulings {
    final search = searchController.text.toLowerCase();

    return rulings.where((ruling) {
      final matchesCategory =
          selectedCategory == 'All' ||
          ruling.category == selectedCategory;

      final searchableText = [
        ruling.title,
        ruling.category,
        ruling.question,
        ...ruling.keywords,
      ].join(' ').toLowerCase();

      return matchesCategory &&
          searchableText.contains(search);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      'Knock Outs',
      'Abilities',
      'Special Conditions',
      'Attacks',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Interaction Rulings'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search cards, abilities or situations...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFF26364C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ruling Reference Library',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: filteredRulings.isEmpty
                  ? const Center(
                      child: Text('No rulings found'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      itemCount: filteredRulings.length,
                      itemBuilder: (context, index) {
                        final ruling = filteredRulings[index];

                        return Card(
                          color: const Color(0xFF26364C),
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(
                                Icons.gavel,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              ruling.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${ruling.category} • ${ruling.status}\n'
                              '${ruling.question}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(
                              Icons.chevron_right,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      RulingDetailScreen(
                                    ruling: ruling,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class RulingDetailScreen extends StatelessWidget {
  final JudgeRuling ruling;

  const RulingDetailScreen({
    super.key,
    required this.ruling,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ruling Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            ruling.category.toUpperCase(),
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            ruling.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'QUESTION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            ruling.question,
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 24),

          const Text(
            'REFERENCE NOTES',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            ruling.answer,
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'STUDY EXAMPLE — NOT AN OFFICIAL RULING\n\n'
              'Verify the relevant card text and official '
              'Pokémon documentation before applying a '
              'decision in a tournament.',
              style: TextStyle(
                color: Colors.orangeAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
