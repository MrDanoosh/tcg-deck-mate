
import 'package:flutter/material.dart';
import 'ruling_library_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class JudgeDocument {
  final String title;
  final String category;
  final String description;
  final String url;
  final String revision;

  const JudgeDocument({
    required this.title,
    required this.category,
    required this.description,
    required this.url,
    required this.revision,
  });
}

class JudgeDeskScreen extends StatefulWidget {
  const JudgeDeskScreen({super.key});

  @override
  State<JudgeDeskScreen> createState() =>
      _JudgeDeskScreenState();
}

class _JudgeDeskScreenState extends State<JudgeDeskScreen> {
  final TextEditingController searchController =
      TextEditingController();

  final List<JudgeDocument> documents = const [
    JudgeDocument(
      title: 'TCG Tournament Handbook',
      category: 'TCG Rules',
      description:
          'Official Pokémon TCG tournament rules, gameplay management and formats.',
      url:
          'https://www.pokemon.com/static-assets/content-assets/cms2/pdf/play-pokemon/rules/play-pokemon-tcg-tournament-handbook-en.pdf',
      revision: 'Check revision date inside PDF',
    ),
    JudgeDocument(
      title: 'Tournament Rules Handbook',
      category: 'Tournament Rules',
      description:
          'General Play! Pokémon tournament regulations and procedures.',
      url:
          'https://www.pokemon.com/static-assets/content-assets/cms2/pdf/play-pokemon/rules/play-pokemon-tournament-rules-handbook-en.pdf',
      revision: 'Check revision date inside PDF',
    ),
    JudgeDocument(
      title: 'Penalty Guidelines',
      category: 'Penalties',
      description:
          'Official guidance for handling tournament infractions and penalties.',
      url:
          'https://www.pokemon.com/static-assets/content-assets/cms2/pdf/play-pokemon/rules/play-pokemon-penalty-guidelines-en.pdf',
      revision: 'Check revision date inside PDF',
    ),
    JudgeDocument(
      title: 'TCG Errata',
      category: 'Card Rulings',
      description:
          'Official corrections and updates to Pokémon TCG card text.',
      url:
          'https://www.pokemon.com/us/play-pokemon/about/tournaments-rules-and-resources',
      revision: 'Official resource page',
    ),
  ];

  List<JudgeDocument> get filteredDocuments {
    final search = searchController.text.toLowerCase();

    return documents.where((document) {
      return document.title.toLowerCase().contains(search) ||
          document.category.toLowerCase().contains(search) ||
          document.description.toLowerCase().contains(search);
    }).toList();
  }

  Future<void> openDocument(JudgeDocument document) async {
    final uri = Uri.parse(document.url);

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open document'),
        ),
      );
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
        title: const Text('Judge Desk'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  ),
  child: Card(
    color: const Color(0xFF26364C),
    child: ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.gavel),
      ),
      title: const Text(
        'Card Interaction Rulings',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(
        'Search rulings and game situations',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RulingLibraryScreen(),
          ),
        );
      },
    ),
  ),
),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search rules and documents...',
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

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Official Reference Library',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Official Pokémon document links. '
                  'Check each PDF for its current revision date.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),

            Expanded(
              child: filteredDocuments.isEmpty
                  ? const Center(
                      child: Text('No documents found'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredDocuments.length,
                      itemBuilder: (context, index) {
                        final document =
                            filteredDocuments[index];

                        return Card(
                          color: const Color(0xFF26364C),
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.all(12),
                            leading: const CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Icon(
                                Icons.menu_book,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              document.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(document.category),
                                  const SizedBox(height: 5),
                                  Text(document.description),
                                  const SizedBox(height: 8),
                                  Text(
                                    document.revision,
                                    style: const TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isThreeLine: true,
                            trailing: const Icon(
                              Icons.open_in_new,
                            ),
                            onTap: () => openDocument(document),
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
