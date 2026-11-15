
import 'package:flutter/material.dart';
import '../../core/services/tcgdex_service.dart';

class TcgDexCardDetailScreen extends StatefulWidget {
  final String cardId;

  const TcgDexCardDetailScreen({
    super.key,
    required this.cardId,
  });

  @override
  State<TcgDexCardDetailScreen> createState() =>
      _TcgDexCardDetailScreenState();
}

class _TcgDexCardDetailScreenState
    extends State<TcgDexCardDetailScreen> {
  final TcgDexService service = TcgDexService();

  late Future<Map<String, dynamic>> cardFuture;

  @override
  void initState() {
    super.initState();
    cardFuture = service.getCard(widget.cardId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: cardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Unable to load card details'),
            );
          }

          final card = snapshot.data!;
          final image = card['image'] as String?;

          final set = card['set'] as Map<String, dynamic>?;

          final attacks =
              card['attacks'] as List<dynamic>? ?? [];

          final abilities =
              card['abilities'] as List<dynamic>? ?? [];

          final weaknesses =
              card['weaknesses'] as List<dynamic>? ?? [];

          final resistances =
              card['resistances'] as List<dynamic>? ?? [];

          final legal =
              card['legal'] as Map<String, dynamic>? ?? {};

          final regulationMark =
              card['regulationMark'] ?? '-';

          final types =
              card['types'] as List<dynamic>? ?? [];

          Widget sectionTitle(String title) {
            return Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 10,
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                card['name'] ?? 'Unknown Card',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              if (image != null)
                Center(
                  child: Image.network(
                    '$image/high.webp',
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 80,
                      );
                    },
                  ),
                ),

              sectionTitle('Card Information'),

              Text('Category: ${card['category'] ?? '-'}'),
              Text('HP: ${card['hp'] ?? '-'}'),
              Text('Types: ${types.join(', ')}'),
              Text('Stage: ${card['stage'] ?? '-'}'),
              Text('Rarity: ${card['rarity'] ?? '-'}'),
              Text('Set: ${set?['name'] ?? '-'}'),
              Text('Card number: ${card['localId'] ?? '-'}'),
              Text('Regulation Mark: $regulationMark'),

const SizedBox(height: 12),

const Text(
  'Tournament Legality',
  style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  ),
),

const SizedBox(height: 8),

Row(
  children: [
    Expanded(
      child: Chip(
        avatar: Icon(
          legal['standard'] == true
              ? Icons.check_circle
              : Icons.cancel,
          color: legal['standard'] == true
              ? Colors.green
              : Colors.red,
        ),
        label: const Text('Standard'),
      ),
    ),
    Expanded(
      child: Chip(
        avatar: Icon(
          legal['expanded'] == true
              ? Icons.check_circle
              : Icons.cancel,
          color: legal['expanded'] == true
              ? Colors.green
              : Colors.red,
        ),
        label: const Text('Expanded'),
      ),
    ),
  ],
),

              if (abilities.isNotEmpty) ...[
                sectionTitle('Abilities'),
                ...abilities.map((ability) {
                  return Card(
                    child: ListTile(
                      title: Text(ability['name'] ?? 'Ability'),
                      subtitle: Text(
                        ability['effect'] ?? '',
                      ),
                      leading: const Icon(Icons.bolt),
                    ),
                  );
                }),
              ],

              if (attacks.isNotEmpty) ...[
                sectionTitle('Attacks'),
                ...attacks.map((attack) {
                  final cost =
                      attack['cost'] as List<dynamic>? ?? [];

                  return Card(
                    child: ListTile(
                      title: Text(
                        attack['name'] ?? 'Attack',
                      ),
                      subtitle: Text(
                        '${cost.join(', ')}\n'
                        '${attack['effect'] ?? ''}',
                      ),
                      trailing: Text(
                        attack['damage']?.toString() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                }),
              ],

              if (weaknesses.isNotEmpty) ...[
                sectionTitle('Weaknesses'),
                ...weaknesses.map((weakness) {
                  return Text(
                    '${weakness['type'] ?? '-'} '
                    '${weakness['value'] ?? ''}',
                  );
                }),
              ],
              if (resistances.isNotEmpty) ...[
  sectionTitle('Resistances'),
  ...resistances.map((resistance) {
    return Text(
      '${resistance['type'] ?? '-'} '
      '${resistance['value'] ?? ''}',
    );
  }),
],

              sectionTitle('Retreat Cost'),
              Text('${card['retreat'] ?? '-'}'),
            ],
          );
        },
      ),
    );
  }
}
