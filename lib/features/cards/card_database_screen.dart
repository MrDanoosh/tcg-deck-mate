
import 'package:flutter/material.dart';
import 'tcgdex_card_detail_screen.dart';

import 'tcgdex_card.dart';
import '../../core/services/tcgdex_service.dart';

class CardDatabaseScreen extends StatefulWidget {
  const CardDatabaseScreen({super.key});

  @override
  State<CardDatabaseScreen> createState() =>
      _CardDatabaseScreenState();
}

class _CardDatabaseScreenState
    extends State<CardDatabaseScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final TcgDexService tcgDexService = TcgDexService();

  List<TcgDexCard> cards = [];

  bool isLoading = false;
  bool hasSearched = false;
  String? errorMessage;

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
        cards = results;
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
        cards = [];
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Database'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => searchCards(),
                decoration: InputDecoration(
                  hintText: 'Search Pokémon cards...',
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
                                const Icon(
                                  Icons.error_outline,
                                  size: 45,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Unable to load cards',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
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
                                'Search for a Pokémon card to get started.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          : cards.isEmpty
                              ? const Center(
                                  child: Text('No cards found'),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: cards.length,
                                  itemBuilder: (context, index) {
                                    final card = cards[index];

                                    return Card(
                                      color: const Color(0xFF26364C),
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(10),
                                        leading: SizedBox(
                                          width: 65,
                                          height: 90,
                                          child: card.imageUrl != null
                                              ? Image.network(
                                                  card.imageUrl!,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    final pngUrl = card.imageUrl!
                                                        .replaceFirst('/low.webp', '/low.png');

                                                    return Image.network(
                                                      pngUrl,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(
                                                          Icons.image_not_supported,
                                                          size: 35,
                                                        );
                                                      },
                                                    );
                                                  },
                                                )
                                              : const Icon(
                                                  Icons.catching_pokemon,
                                                  size: 35,
                                                ),
                                        ),
                                        title: Text(
                                          card.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Card number: ${card.localId}\nID: ${card.id}',
                                        ),
                                        isThreeLine: true,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TcgDexCardDetailScreen(
                                                cardId: card.id,
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
