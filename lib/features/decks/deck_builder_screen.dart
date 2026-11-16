
import 'package:flutter/material.dart';

import '../cards/tcgdex_card.dart';
import '../cards/tcgdex_card_detail_screen.dart';
import '../../core/services/tcgdex_service.dart';

class DeckCardOption {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final bool unlimitedCopies;

  const DeckCardOption({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
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
  final TextEditingController searchController =
      TextEditingController();

  final TcgDexService tcgDexService = TcgDexService();

  List<TcgDexCard> searchResults = [];

  final Map<String, int> deck = {};
  final Map<String, DeckCardOption> deckCardDetails = {};

  final Set<String> addingCardIds = {};

  bool isLoading = false;
  bool hasSearched = false;
  String? errorMessage;

  int get totalCards =>
      deck.values.fold(0, (total, count) => total + count);

  int copiesOfName(String name) {
    final matchingIds = deckCardDetails.values
        .where((card) =>
            card.name.trim().toLowerCase() ==
            name.trim().toLowerCase())
        .map((card) => card.id);

    return matchingIds.fold(
      0,
      (total, id) => total + (deck[id] ?? 0),
    );
  }

  Future<void> searchCards() async {
    final searchTerm = searchController.text.trim();

    if (searchTerm.isEmpty) return;

    setState(() {
      isLoading = true;
      hasSearched = true;
      errorMessage = null;
    });

    try {
      final results =
          await tcgDexService.searchCards(searchTerm);

      if (!mounted) return;

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        searchResults = [];
      });
    }
  }

  Future<void> addCard(TcgDexCard card) async {
    if (totalCards >= 60) return;
    if (addingCardIds.contains(card.id)) return;

    final existingCopies = copiesOfName(card.name);

    if (existingCopies >= 4 &&
        !deckCardDetails.values.any(
          (existing) =>
              existing.name.trim().toLowerCase() ==
                  card.name.trim().toLowerCase() &&
              existing.unlimitedCopies,
        )) {
      return;
    }

    setState(() {
      addingCardIds.add(card.id);
    });

    try {
      final details =
          await tcgDexService.getCard(card.id);

      if (!mounted) return;

      final category = details['category']?.toString() ?? 'Unknown';
      final energyType = details['energyType']?.toString();

      final isBasicEnergy =
          category == 'Energy' && energyType == 'Basic';

      final deckCard = DeckCardOption(
        id: card.id,
        name: card.name,
        category: category == 'Pokemon'
            ? 'Pokémon'
            : category,
        imageUrl: card.imageUrl,
        unlimitedCopies: isBasicEnergy,
      );

      final currentCopies = copiesOfName(card.name);

      if (totalCards >= 60 ||
          (!isBasicEnergy && currentCopies >= 4)) {
        setState(() {
          addingCardIds.remove(card.id);
        });
        return;
      }

      setState(() {
        deckCardDetails[card.id] = deckCard;
        deck[card.id] = (deck[card.id] ?? 0) + 1;
        addingCardIds.remove(card.id);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        addingCardIds.remove(card.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add card: $error'),
        ),
      );
    }
  }

  void removeCard(DeckCardOption card) {
    final currentCount = deck[card.id] ?? 0;

    if (currentCount <= 0) return;

    setState(() {
      if (currentCount == 1) {
        deck.remove(card.id);
        deckCardDetails.remove(card.id);
      } else {
        deck[card.id] = currentCount - 1;
      }
    });
  }

  void clearDeck() {
    setState(() {
      deck.clear();
      deckCardDetails.clear();
    });
  }

  Widget buildCardImage(String? imageUrl) {
    if (imageUrl == null) {
      return const Icon(
        Icons.catching_pokemon,
        size: 35,
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        final pngUrl =
            imageUrl.replaceFirst('/low.webp', '/low.png');

        return Image.network(
          pngUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.image_not_supported,
              size: 30,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCards = deck.entries
        .where((entry) => entry.value > 0)
        .map((entry) => deckCardDetails[entry.key])
        .whereType<DeckCardOption>()
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => searchCards(),
                decoration: InputDecoration(
                  hintText: 'Search Pokémon, Trainers or Energy...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: searchCards,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF26364C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Search Results',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Unable to load cards'),
                                const SizedBox(height: 8),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: searchCards,
                                  child: const Text('Try again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : !hasSearched
                          ? const Center(
                              child: Text(
                                'Search for a card to add it to your deck.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : searchResults.isEmpty
                              ? const Center(
                                  child: Text('No cards found'),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: searchResults.length,
                                  itemBuilder: (context, index) {
                                    final card = searchResults[index];
                                    final copies = copiesOfName(card.name);
                                    final isAdding =
                                        addingCardIds.contains(card.id);

                                    final canAdd = totalCards < 60 &&
                                        copies < 4 &&
                                        !isAdding;

                                    return Card(
                                      color: const Color(0xFF26364C),
                                      margin: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.all(8),
                                        leading: SizedBox(
                                          width: 55,
                                          height: 75,
                                          child: buildCardImage(
                                            card.imageUrl,
                                          ),
                                        ),
                                        title: Text(
                                          card.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Card number: ${card.localId}\n'
                                          'Copies in deck: $copies',
                                        ),
                                        isThreeLine: true,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TcgDexCardDetailScreen(
                                                cardId: card.id,
                                              ),
                                            ),
                                          );
                                        },
                                        trailing: IconButton(
                                          tooltip: 'Add card',
                                          icon: isAdding
                                              ? const SizedBox(
                                                  width: 22,
                                                  height: 22,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.add_circle_outline,
                                                ),
                                          onPressed: canAdd
                                              ? () => addCard(card)
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Cards in Your Deck',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 150,
              child: selectedCards.isEmpty
                  ? const Center(
                      child: Text(
                        'Your deck is empty. Search above to add cards.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedCards.length,
                      itemBuilder: (context, index) {
                        final card = selectedCards[index];
                        final count = deck[card.id] ?? 0;

                        return ListTile(
                          dense: true,
                          leading: SizedBox(
                            width: 35,
                            height: 45,
                            child: buildCardImage(card.imageUrl),
                          ),
                          title: Text(card.name),
                          subtitle: Text(card.category),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'x$count',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                ),
                                onPressed: () => removeCard(card),
                              ),
                            ],
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
