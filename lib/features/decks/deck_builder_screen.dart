
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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


class DecklistEntry {
  final int quantity;
  final String cardName;
  final String setCode;
  final String cardNumber;

  const DecklistEntry({
    required this.quantity,
    required this.cardName,
    required this.setCode,
    required this.cardNumber,
  });
}


class ImportedCardResult {
  final DecklistEntry entry;
  final Map<String, dynamic>? cardDetails;

  const ImportedCardResult({
    required this.entry,
    required this.cardDetails,
  });

  bool get isMatched => cardDetails != null;
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

final Map<String, Map<String, dynamic>> setCache = {};


  bool isLoading = false;
  bool hasSearched = false;
  String? errorMessage;
  String selectedCategory = 'All';

List<DecklistEntry> parseDecklist(String input) {
  final entries = <DecklistEntry>[];

  final lines = input.split('\n');

  final cardPattern = RegExp(
    r'^(\d+)\s+(.+?)\s+([A-Z0-9]{2,5})\s+(\d+[a-zA-Z]?)$',
  );

  for (final line in lines) {
    final trimmedLine = line.trim();

    if (trimmedLine.isEmpty) continue;

    final match = cardPattern.firstMatch(trimmedLine);

    if (match == null) continue;

    entries.add(
      DecklistEntry(
        quantity: int.parse(match.group(1)!),
        cardName: match.group(2)!,
        setCode: match.group(3)!,
        cardNumber: match.group(4)!,
      ),
    );
  }

  return entries;
}


  int get totalCards =>
      deck.values.fold(0, (total, count) => total + count);

int get pokemonCount => deck.entries
    .where((entry) =>
        deckCardDetails[entry.key]?.category == 'Pokémon')
    .fold(0, (total, entry) => total + entry.value);

int get trainerCount => deck.entries
    .where((entry) =>
        deckCardDetails[entry.key]?.category == 'Trainer')
    .fold(0, (total, entry) => total + entry.value);

int get energyCount => deck.entries
    .where((entry) =>
        deckCardDetails[entry.key]?.category == 'Energy')
    .fold(0, (total, entry) => total + entry.value);


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


Future<List<ImportedCardResult>> matchDecklist(
  List<DecklistEntry> entries,
) async {
  final results = <ImportedCardResult>[];

  for (final entry in entries) {
    final matchedCard = await matchImportedCard(entry);

    results.add(
      ImportedCardResult(
        entry: entry,
        cardDetails: matchedCard,
      ),
    );
  }

  return results;
}

Future<Map<String, dynamic>?> matchImportedCard(
  DecklistEntry entry,
) async {
  try {
    // Load the available set IDs once.
    if (setCache.isEmpty) {
      final uri = Uri.parse(
        '${TcgDexService.baseUrl}/sets',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Unable to retrieve sets');
      }

      final List<dynamic> sets = jsonDecode(response.body);

      for (final set in sets) {
        final setId = set['id']?.toString();

        if (setId != null) {
          setCache[setId] = {};
        }
      }
    }

    // Find a set with the matching abbreviation.
    for (final setId in setCache.keys.toList()) {
      if (setCache[setId]!.isEmpty) {
        final details = await tcgDexService.getSet(setId);

        setCache[setId] = details;
      }

      final set = setCache[setId]!;

      final abbreviation = set['abbreviation'];

      final official = abbreviation is Map
          ? abbreviation['official']?.toString()
          : null;

      final localized = abbreviation is Map
          ? abbreviation['localized']?.toString()
          : null;

      final matchesSet =
          official?.toUpperCase() == entry.setCode.toUpperCase() ||
          localized?.toUpperCase() == entry.setCode.toUpperCase();

      if (!matchesSet) continue;

      final card = await tcgDexService.getCardBySetAndNumber(
        setId,
        entry.cardNumber,
      );

      if (card['name']?.toString().toLowerCase() ==
          entry.cardName.toLowerCase()) {
        return card;
      }
    }

    return null;
  } catch (error) {
    debugPrint('Card matching error: $error');
    return null;
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




Future<void> showImportDialog() async {
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return const ImportDecklistDialog();
    },
  );

  if (!mounted || result == null) return;

  final entries = parseDecklist(result);

// Show a loading dialog while cards are being checked.
showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    return const AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Expanded(
            child: Text(
              'Checking cards against TCGdex...',
            ),
          ),
        ],
      ),
    );
  },
);

// Give Flutter time to display the loading dialog.
await Future.delayed(const Duration(milliseconds: 100));

// Check the cards.
final matchedResults = await matchDecklist(entries);

// Close the loading dialog.
if (mounted) {
  Navigator.of(context, rootNavigator: true).pop();
}

  if (entries.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No valid card entries found.'),
      ),
    );
    return;
  }

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
  'Import Preview '
  '(${matchedResults.where((item) => item.isMatched).length}'
  '/${matchedResults.length} matched)',
),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final result = matchedResults[index];
final entry = result.entry;

              
return ListTile(
  dense: true,
  leading: CircleAvatar(
    backgroundColor:
        result.isMatched ? Colors.green : Colors.red,
    child: Text('${entry.quantity}'),
  ),
  title: Text(entry.cardName),
  subtitle: Text(
    '${entry.setCode} ${entry.cardNumber}\n'
    '${result.isMatched ? "Matched: ${result.cardDetails!['name']}" : "Card not found"}',
  ),
  isThreeLine: true,
);

            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
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

final filteredSelectedCards = selectedCards
    .where((card) =>
        selectedCategory == 'All' ||
        card.category == selectedCategory)
    .toList();


    return Scaffold(
      
appBar: AppBar(
  title: const Text('Deck Builder'),
  actions: [
    IconButton(
      tooltip: 'Import decklist',
      icon: const Icon(Icons.file_download_outlined),
      onPressed: showImportDialog,
    ),
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

const SizedBox(height: 12),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
    Text('Pokémon: $pokemonCount'),
    Text('Trainers: $trainerCount'),
    Text('Energy: $energyCount'),
  ],
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

Padding(
  padding: const EdgeInsets.symmetric(horizontal: 12),
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: ['All', 'Pokémon', 'Trainer', 'Energy']
          .map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  onSelected: (selected) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
              ))
          .toList(),
    ),
  ),
),

            SizedBox(
              height: 150,
              child: filteredSelectedCards.isEmpty
                  ?  Center(
                      child: Text(
                        selectedCards.isEmpty
    ? 'Your deck is empty. Search above to add cards.'
    : 'No cards in this category.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredSelectedCards.length,
                      itemBuilder: (context, index) {
                        final card = filteredSelectedCards[index];
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

class ImportDecklistDialog extends StatefulWidget {
  const ImportDecklistDialog({super.key});

  @override
  State<ImportDecklistDialog> createState() =>
      _ImportDecklistDialogState();
}

class _ImportDecklistDialogState
    extends State<ImportDecklistDialog> {
  final TextEditingController controller =
      TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Limitless Decklist'),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
          controller: controller,
          maxLines: 12,
          minLines: 8,
          decoration: const InputDecoration(
            hintText: 'Paste your Pokémon TCG decklist here...',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
          child: const Text('Read Decklist'),
        ),
      ],
    );
  }
}
