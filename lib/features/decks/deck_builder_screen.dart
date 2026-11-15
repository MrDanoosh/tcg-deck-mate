
import 'package:flutter/material.dart';

class DeckCardOption {
  final String id;
  final String name;
  final String category;
  final bool unlimitedCopies;

  const DeckCardOption({
    required this.id,
    required this.name,
    required this.category,
    this.unlimitedCopies = false,
  });
}

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() =>
      _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> {
  final List<DeckCardOption> availableCards = const [
    DeckCardOption(
      id: 'charizard-ex',
      name: 'Charizard ex',
      category: 'Pokémon',
    ),
    DeckCardOption(
      id: 'pikachu-ex',
      name: 'Pikachu ex',
      category: 'Pokémon',
    ),
    DeckCardOption(
      id: 'prof-research',
      name: 'Professor’s Research',
      category: 'Trainer',
    ),
    DeckCardOption(
      id: 'ultra-ball',
      name: 'Ultra Ball',
      category: 'Trainer',
    ),
    DeckCardOption(
      id: 'lightning-energy',
      name: 'Basic Lightning Energy',
      category: 'Energy',
      unlimitedCopies: true,
    ),
    DeckCardOption(
      id: 'fire-energy',
      name: 'Basic Fire Energy',
      category: 'Energy',
      unlimitedCopies: true,
    ),
  ];

  final Map<String, int> deck = {};

  int get totalCards =>
      deck.values.fold(0, (total, count) => total + count);

  void addCard(DeckCardOption card) {
    final currentCount = deck[card.id] ?? 0;

    if (totalCards >= 60) return;

    if (!card.unlimitedCopies && currentCount >= 4) return;

    setState(() {
      deck[card.id] = currentCount + 1;
    });
  }

  void removeCard(DeckCardOption card) {
    final currentCount = deck[card.id] ?? 0;

    if (currentCount <= 0) return;

    setState(() {
      if (currentCount == 1) {
        deck.remove(card.id);
      } else {
        deck[card.id] = currentCount - 1;
      }
    });
  }

  void clearDeck() {
    setState(() {
      deck.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCards = availableCards
        .where((card) => (deck[card.id] ?? 0) > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deck Builder'),
        actions: [
          IconButton(
            tooltip: 'Clear deck',
            icon: const Icon(Icons.delete_outline),
            onPressed: deck.isEmpty ? null : clearDeck,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: const Color(0xFF26364C),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'YOUR DECK',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '$totalCards / 60 cards',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: totalCards / 60,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        totalCards == 60
                            ? 'Deck complete!'
                            : '${60 - totalCards} more cards needed',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available Cards',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...availableCards.map((card) {
                    final count = deck[card.id] ?? 0;
                    final canAdd = totalCards < 60 &&
                        (card.unlimitedCopies || count < 4);

                    return Card(
                      color: const Color(0xFF26364C),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(
                          card.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(card.category),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                              ),
                              onPressed: count == 0
                                  ? null
                                  : () => removeCard(card),
                            ),
                            SizedBox(
                              width: 24,
                              child: Text(
                                '$count',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                              ),
                              onPressed: canAdd
                                  ? () => addCard(card)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  const Text(
                    'Cards in Your Deck',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (selectedCards.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Your deck is empty. Add cards above to get started.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...selectedCards.map((card) {
                      return ListTile(
                        dense: true,
                        title: Text(card.name),
                        trailing: Text(
                          'x${deck[card.id]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
