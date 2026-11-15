
class TcgDexCard {
  final String id;
  final String name;
  final String localId;
  final String? image;

  TcgDexCard({
    required this.id,
    required this.name,
    required this.localId,
    this.image,
  });

  factory TcgDexCard.fromJson(Map<String, dynamic> json) {
    return TcgDexCard(
      id: json['id'] as String,
      name: json['name'] as String,
      localId: json['localId'].toString(),
      image: json['image'] as String?,
    );
  }

  String? get imageUrl {
    if (image == null) return null;
    return '$image/low.webp';
  }
}
